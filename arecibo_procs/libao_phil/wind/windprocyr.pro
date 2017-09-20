;+
;windprocyr - do yearly processing of wind data
;
;
; avereage,peak hold over entire range. take 15 minute chunks
;  
pro windprocyr,year
	forward_function winddir

	 monlist=['JAN','FEB','MAR','APR','MAY','JUN','JUL','AUG','SEP','OCT',$
             'NOV','DEC']

	savedir=winddir()
	maxaccel  =30.				; max accel vel/sec^2 before we ignore data
    histmaxvel=35. 				; for histograms
	maxAvgVel =10.              ; for plot vs hour of day
    mindirvel=1.                ; for computing vel by direction
	minGdVel =.1
	secsMon=86400L*30L
    minGdPnts=secsMon*.001
	daysYr=isleapyear(year)?366:365

;
;    loop thru the 12 months of the year		
;
;    for each month compute:
;    velMean(24.,12)
;    velMedian(24,12)
;    dirMean(360,12)
;    dirMedian(360,12)
;    histvel(35,12)
;    totCnts(12) 		; for each month
;    
;    velDayAvg[daysYr]
;    velDayPk[daysYr]
;    velDayMin[daysYr]
;    velDayCnt[daysYr]
;	 
	 velHrMn=fltarr(24,12)
	 velHrMd=fltarr(24,12)
	 velHrHist=fltarr(24,12)

	 velDirMn  =fltarr(360,12)
	 velDirMd  =fltarr(360,12)
	 velDirHist=fltarr(360,12)

	 velDayAvg =dblarr(daysYr)
	 velDayPk  =fltarr(daysYr)
	 velDayMin =fltarr(daysYr)
	 velDayCnt =lonarr(daysYr) ; to compute the average
;
	 histVel =fltarr(35,12)
	 totCnts   =fltarr(12)
	 totCntsDir=fltarr(12)
	 jdStartYrAst=julday(1,1,year,0D,0d,0d) + 4D/24. ; ast start of year
;
; 	loop over 12 months
;
	for imon=0,11 do begin
	    print,'start:',year,monlist[imon]
		n=windgetmonth(year,imon+1,d)
		if n le 0 then continue
;
;   throw out jumps in vel and velocities < .1 mph
;
    	accel=(d.vel - shift(d.vel,1))
    	accel[0]=accel[1]
    	ntot=n_elements(d)
    	indp=where((accel) gt maxaccel,count1)
    	indm=where((accel) lt -maxaccel,count2)
		indz=where(d.vel lt minGdVel,countz)
    	counta=count1+count2
    	if (countA + countZ) gt 0 then begin &$
		     lab=string(format='("-->zeroVelSkip:",i7," accelSkip:",i4)',$
                    countz,counta)
        	if counta gt 0 then begin &$
            	if count1 gt 0 then d[indp].vel    = 0. &$
            	if count2 gt 0 then d[indm-1L].vel = 0. &$
        	endif
        	ind=where(d.vel gt minGdVel,count)
        	if count eq 0 then begin
           		 print,'-->no good data available for ',year,monlist[imon]
				 continue
       		 endif
        	print,lab
        	d=d[ind]
    	endif
	    accel=''
		if n_elements(d) lt minGdPnts then begin
        	print,'--> Not enough good Data to plot:',n_elements(d)
        	continue
   		 endif

;
;		histogram hour of day in 1 hour steps
;
		hr=((d.jd - .5 - 4./24.) mod 1D)*24
		hrstep=1.
		nbins=24
		velHrHist[*,imon]=$
				histogram(hr,min=0,nbins=24,binsize=hrstep,reverse=r)
		for i=0,nbins-1 do begin &$
            if (r[i] ne r[i+1]) then begin &$
                velHrMn[i,imon]=mean(d[r[r[i]:r[i+1]-1]].vel) &$
                velHrMd[i,imon]=median(d[r[r[i]:r[i+1]-1]].vel) &$
            endif &$
        endfor
;
; 	 and the direction info
;
		ind=where(d.vel gt mindirvel,count)
		if count lt 10 then begin
    		print,'not enough vel > 2mph for direction plots'
    		goto,dohist
		endif
		totcntsDir[imon]=count
		vel=d[ind].vel
		dir=d[ind].dir
	    nbins=360
		velDirHist[*,imon]=histogram(dir,min=0,nbins=nbins,binsize=1,reverse=r)
		for i=0,nbins-1 do begin &$
			if (r[i] ne r[i+1] ) then begin &$
        		velDirMn[i,imon]=mean(vel[r[r[i]:r[i+1]-1]]) &$
        		velDirMd[i,imon]=median(vel[r[r[i]:r[i+1]-1]]) &$
			endif &$
		endfor
;
;       histogram velocity by day
;
        day=d.jd -  jdStartYrAst
        dayStep=1.
        nbins=daysYr
        h = histogram(day,min=0,nbins=nbins,binsize=daystep,reverse=r)
        for i=0,nbins-1 do begin &$
	 	    if h[i] ne 0 then begin
                velDayAvg[i]+=total(d[r[r[i]:r[i+1]-1]].vel) &$
                velDayCnt[i]+=h[i] &$
                velDayPk[i]  =max(d[r[r[i]:r[i+1]-1]].vel) > velDayPk[i]
            endif &$
        endfor
;
; 		histogram
;
dohist:
		min=0.
		binsize=1.
		histVel[*,imon]=histogram(d.vel,binsize=binsize,min=min,$$
			max=histMaxVel-binsize/2.)
		totCnts[imon]=total(histVel[*,imon])
	endfor
;
; compute average for daily velocity
;
	ind =where(velDayCnt gt 0L ,count)
	if count gt 0 then velDayAvg[ind]/=velDayCnt[ind]
;
;	
	xhist=findgen(n_elements(histVel[*,0]) + .5) * binsize 
	xdir =findgen(360)
	xhour=findgen(24)+ .5
;
; 	now save info to save file
;
	savefile=string(format='("wind_yr",i2.2,".sav")',year mod 100L)
	save,velHrMn,velHrMd,velHrHist,$
		 velDirMn,velDirMd,velDirHist,histVel,totCnts,year,$
		 velDayAvg,velDayPk,velDayCnt,jdStartYrAst,$
		 xhist,xhour,xdir,file=savedir+savefile
	return

end
