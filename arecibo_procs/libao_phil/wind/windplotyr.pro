;+
;NAME:
;windplotyr - make the windmeter yearly summary plots
;SYNTAX: windplotyr,year
;ARGS:
; year: int	year to plot
;DESCRIPTION:
;	Make the yearly summary wind plots for the specified year.
;-
;
;   subroutine used by main routine
;
pro windplotyr_1,x,y,OkAr,inc,ls=ls,sym=sym,_extra=e,minx=minx,$
	smo=smo,loff=loff,linc=linc,lineps=lineps
	forward_function winddir

    common colph,decomposedph,colph


	month=['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct',$
			'Nov','Dec']
	if not keyword_set(sym) then sym=0
	if not keyword_set(minx) then minx=0
	if not keyword_set(loff) then loff=0
	if not keyword_set(linc) then linc=.7
	eps=(n_elements(lineps) eq 0)?.5: lineps
	nlines=n_elements(okAr)
	if not keyword_set(ls) then ls=1
	yy=y
	if keyword_set(smo) then yy=smooth(y,[smo,0])
	iiOk=where(okAr eq 1)
	plot,[0,1],[0,1],/nodat,_extra=e
	for i=0,nlines-1 do begin
		col= (i mod 10 ) + 1
		ii=inc*i
;
; 	plot the 0 baseline
;
;		oplot,[0,500],[ii,ii],linestyle=1,color=col
		if okAr[i] then begin
			ls=(i ge 10)?2:0
			oplot,x,yy[*,i] + ii,color=colph[col],psym=sym,lines=ls
			xl=minx
			yl=linc*i+loff
		    xyouts,xl,yl,month[i],color=colph[col]
			if i ge 10 then $
				oplot,[xl-eps,xl],[yl,yl],linestyle=ls,color=colph[col]

		endif
	endfor
		
	return
end
;
;
pro windplotyr,year
;
;	input the save file
;
    common colph,decomposedph,colph

    dir=winddir()
    file=string(format='("wind_yr",i2.2,".sav")',year mod 100L)
    restore,dir+file
	minCntsMon=86400L*30L*.25   ; month must have 25% of counts
	minCntsDay=86400*.5		    ; day must have 50% of counts
	maxVelDayAvg = 15
	maxVelDayPk  =40
	maxVelHr     =12
	lyear=string(year)
	jdStMon=dblarr(12)			; start of each month  (ast)
   	for i=1,12 do jdStMon[i-1]=daynotojul(dmtodayno(1,i,year),year) + 4/24D &$

    monOk=lonarr(12)
    ii=where(totcnts gt minCntsMon,count)
    if count gt 0 then monOk[ii]=1
 	mon=['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct',$
		 'Nov','Dec']

	cs=1.7
;
	xday=findgen(n_elements(veldayavg)) + jdstartYrAst 
	a=label_date(date_format='%D%M%Z')
	daysYr=n_elements(xday)
	hor,jdStartYrAst,jdSTartYrAst + daysYr
;
;  ----------------------
; 	avg daily velocities
;
	!p.multi=[0,1,3]
 	y=veldayavg 
	ind=where(velDayCnt lt  minCntsDay,count)
	if count gt 0 then y[ind]=0
	ver,0,maxVelDayAvg
	plot,xday,y,xtickf='label_date' ,charsize=cs,$
		xtitle='Date',ytitle='Velocity [mph]',$
	    title =lyear + ' Average daily velocity'
	oplot,xday[ind],y[ind],color=colph[2],psym=1
	ylab=2
	for i=0,11 do begin &$
		col=(i mod 10) + 1  &$
    	flag,jdStMon[i],color=colph[col], linestyle=2 &$
		xyouts,jdStMon[i]+10,ylab,mon[i],color=colph[col] &$
	endfor
;
;  ----------------------
;
;	peak daily velocityav
;
	ver,0,maxVelDayPk
	y=veldayPk
	y[ind]=0
	plot,xday,y,xtickf='label_date' ,charsize=cs,$
		xtitle='Date',ytitle='Velocity [mph]',$
	    title =lyear + ' Maximum daily velocity'
	oplot,xday[ind],y[ind],color=colph[2],psym=1
	ylab=5
	for i=0,11 do begin &$
		col=(i mod 10) + 1  &$
    	flag,jdStMon[i],color=colph[col], linestyle=2 &$
		xyouts,jdStMon[i]+10,ylab,mon[i],color=colph[col] &$
	endfor
;
;  ----------------------
; 	hourly averge by month
;
	hor,-2. ,24
	smo=0
	inc=0
	linc=.7
	loff=1.
	ver,0,10
	lineps=1.
	minx  =-.6
	windplotyr_1,xhour,velHrMn,monOk,inc,minx=minx,smo=smo,linc=linc,loff=loff,$
        charsize=cs,xtitle='Hour of day',ytitle='Vel [mph]',lineps=lineps,$
        title=string(year) + ' Monthly average wind velocity vs hour'
;
;  
;  ----------------------
	!p.multi=[0,1,3]
;
;   histogram of velocity
;
    yy    =histVel
    ytot=total(yy,1)
    ind=where(ytot eq 0.,count)
    if count ne 0 then ytot[ind]=1.
    for i=0,11 do yy[*,i]/=ytot[i]
;
    hor,-1.5 ,15
    smo=0
    inc=0
    linc=.015
    loff=.01
    minx=-.5 
	lineps=.6
    ver,.0,.2
    windplotyr_1,xhist,yy,monOk,inc,minx=minx,smo=smo,linc=linc,loff=loff,$
        charsize=cs,xtitle='wind velocity [mph]',ytitle='Fraction of time',$
        title=string(year) +$
		 ' Monthly histogram of wind velocity (1 mph bins)'
;

;  ----------------------
;   average monthly velocity versus direction
;
    hor,-30. ,360
    smo=5
    inc=0
    linc=.7
    loff=.54
    minx=-14
	lineps=10
    ver,0,10
    windplotyr_1,xdir,velDirMn,monOk,inc,minx=minx,smo=smo,linc=linc,loff=loff,$
        charsize=cs,xtitle='Wind direction [deg]',ytitle='Vel [mph]',$
        title=string(year) + ' Monthly average wind velocity vs direction',$
		lineps=lineps
;
;  ---------------------------------
;   histogram of wind direction
;
	degstp=10
	xx    =total(reform(xdir,degstp,360/degstp),1)/degstp
	yy    =total(reform(velDirHist,degstp,360/degstp,12),1)/degstp
	ytot=total(yy,1)
	ind=where(ytot eq 0.,count)
	if count ne 0 then ytot[ind]=1.
	for i=0,11 do yy[*,i]/=ytot[i]
;
    hor,-30. ,360
    smo=0
    inc=0
    linc=.015
    loff=.013
    minx=-14
    ver,0,.2
	lineps=10
    windplotyr_1,xx,yy,monOk,inc,minx=minx,smo=smo,linc=linc,loff=loff,$
        charsize=cs,xtitle='wind direction [deg]',ytitle='Fraction of time',$
        title=string(year) + $
	 ' Monthly histogram of wind direction (10 deg bins)',lineps=lineps
;
	return
end
