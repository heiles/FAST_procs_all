;+
;windplotmon - monthly wind data plots
;
;
; avereage,peak hold over entire range. take 15 minute chunks
;  
pro windplotmon,year,mon,wait=wait

	 secsMon=86400L*30L
	 minGdVel=.1
	 minGdPnts=secsMon*.001
	 monlist=['JAN','FEB','MAR','APR','MAY','JUN','JUL','AUG','SEP','OCT',$
             'NOV','DEC']


	maxaccel  =30.				; max accel vel/sec^2 before we ignore data
    histmaxvel=35. 				; for histograms
	maxAvgVel =10.              ; for plot vs hour of day
    mindirvel=1.                ; for computing vel by direction
;
;	 or average and peak hold for whole range
;
	ndays=daysinmon(mon,year)
	yymmdd=(year mod 100L)*10000L + mon*100L + 1L
	jdSt=yymmddtojulday(yymmdd) + 4D/24 	; since we start ast 0
	minStep=15D
	ldate=string(format='(a,i2.2," ")',monlist[mon-1],year mod 100L)
	a=label_date(date_format="%D%M%Z")
	plMaxVelPk=40.				; for peak velocity,mean velocity
	astF=4./24D					; so dates are ast not gmt
	cs=1.8
	lnpk=2
	lnavg=lnpk+10
	xppk=.04
	scl=.7
	print,'processing:',ldate
;
; 	get the data
;
	n=windgetmonth(year,mon,d)
	if n le 0 then begin
		print,'no data available for ',ldate
		return
	endif
;
;	throw out jumps in vel
;
	accel=(d.vel - shift(d.vel,1))
	accel[0]=accel[1]
	ntot=n_elements(d)
	indp=where((accel) gt maxaccel,count1)
	indm=where((accel) lt -maxaccel,count2)
	indz=where(d.vel lt minGdVel,countz)
	counta=count1+count2 
	if (counta+countz gt 0) then begin 
		lab=string(format='("-->zeroVelSkip:",i7," accelSkip:",i4)',$
					countz,counta)
		if counta gt 0 then begin &$
			if count1 gt 0 then d[indp].vel    = 0. &$
			if count2 gt 0 then d[indm-1L].vel = 0. &$
		endif
		ind=where(d.vel gt minGdVel,count)
		if count eq 0 then begin
			print,'-->no good data available for ',ldate
			return
		endif
		print,lab
		d=d[ind]
	endif
	if n_elements(d) lt minGdPnts then begin
		print,'--> Not enough good Data to plot:',n_elements(d)
		return
	endif
	accel=''
;
;	
; ------------------------------------
; page 1 plot 1
;   
;
;	pk,mean histogram every 15 minutes
;
	nbins=ndays*24L*4	
	min=(d.jd - jdSt)*24D*60D
    h=histogram(min,min=0,nbins=nbins,binsize=minStep,revers=r)
	velArMn=fltarr(nbins)
	velArPk=fltarr(nbins)
	for i=0,nbins-1 do begin &$
        if (h[i] gt 1) then begin &$
           velArMn[i]=mean(d[r[r[i]:r[i+1]-1]].vel) &$
           velArPk[i]=max(d[r[r[i]:r[i+1]-1]].vel) &$
        endif &$
    endfor
	jdAr=findgen(nbins)*15D/(24D*60.) + jdSt
;
;
; need inc since idl labels put dat at noon, not 0am..
; need astf to move to ast from gmt
;
	!p.multi=[0,1,3]
	inc=.5D
	ver,0,plMaxvelPk
	hor
	lab=string(format=$
		'("Avg & Peak velocities vs date (over ",f4.1," minutes)")',minStep)
	plot,jdar-astF + inc,velarPk,xtickf='label_date',charsize=cs,$
		xtitle='date [Ast]',ytitle='velocity [mph]',$
		title= ldate + lab
	oplot,jdar-astF+ inc,velArMn,color=2
	note,lnpk      ,'Peak hold',xp=xppk,color=1
	note,lnpk+1*scl,'Average',xp=xppk,color=2
;
; -----------------------------------------------------
; page 1 : plot 2 by hour of day 
;
; velocity by 15 min step of day
;
	nbins=24*60L/minStep
	min=((d.jd - .5 - 4./24.) mod 1D)*24*60L
	velHrMn=fltarr(nbins)
	velHrMd=fltarr(nbins)
	velHrPk=fltarr(nbins)
	h=histogram(min,min=0,binsize=minStep,nbins=nbins,reverse=r)
    for i=0,nbins-1 do begin &$
       if (h[i] gt 1) then begin &$
          velHrMn[i]=mean(d[r[r[i]:r[i+1]-1]].vel) &$
          velHrMd[i]=median(d[r[r[i]:r[i+1]-1]].vel) &$
          velHrPk[i]=max(d[r[r[i]:r[i+1]-1]].vel) &$
       endif &$
     endfor
	xhr=findgen(nbins)*minStep/60.
	ver,0,maxAvgVel
	hor,0,24
	sym=0
	plot,xhr,velHrMn,psym=sym,charsize=cs,$
   	 	xtitle='hour of day',ytitle='Vel [mph]',$
    	title=ldate + ' Average,median velocity by hour of day'
	oplot,xhr,velHrMd,psym=sym,color=2
	oplot,xhr,h*1./max(h) * maxAvgVel/5,color=4
	note,lnavg      ,'average vel',xp=xppk,color=1
	note,lnavg+1*scl,'median vel',xp=xppk,color=2
	note,lnavg+2*scl,'histogram of data',xp=xppk,color=4
	
	min=''
; -------------------------------
; page 1 plot 3 
;
; velocity by dir limit to vel gt 2mph
;
    ind=where(d.vel gt mindirvel,count)
    if count lt 10 then begin &$
       print,'not enough vel > 2mph for direction plots' &$
       goto,pg2 &$
    endif
    vel=d[ind].vel
    dir=d[ind].dir
	dirStep=1.
    nbins=360
	velDirMn=fltarr(nbins)
	velDirMd=fltarr(nbins)
	velDirPk=fltarr(nbins)
    h=histogram(dir,min=0,nbins=nbins,binsize=dirStep,reverse=r)
    for i=0,nbins-1 do begin &$
        if (h[i] gt 1 ) then begin &$
           velDirMn[i]=mean(vel[r[r[i]:r[i+1]-1]]) &$
           velDirMd[i]=median(vel[r[r[i]:r[i+1]-1]]) &$
           velDirPk[i]=max(vel[r[r[i]:r[i+1]-1]]) &$
        endif &$
    endfor
;
	xdir=findgen(n)*dirstep + dirstep/2.
	hor,0,360
	plot,xdir,velDirMn,psym=sym,charsize=cs,$
    xtitle='direction [degrees]',ytitle='Vel [mph]',$
    title=ldate + ' Average,median velocity by direction'
	oplot,xdir,velDirMd,psym=sym,color=2
	oplot,xdir,h*1./max(h) * maxAvgVel/5,color=4
; ------------------------------------
; page 2 plot 1
; histogram of velocity
;
pg2:
	if keyword_set(wait) then begin
		print,'hit return to continue'
		key=checkkey(/wait)
	endif
	!p.multi=[0,1,3]
	min=0.
	binsize=1.
	h=histogram(d.vel,binsize=binsize,min=min,max=histMaxVel-binsize/2.)
	x=(findgen(n_elements(h)) + .5)*binsize
	npts=total(h)
;
	sym=10
	vmax=(long(max(h/npts)/.05) + 1)*.05
	ver,0,vmax
	hor,0,histmaxvel
	plot,x,h/npts,psym=sym,charsize=cs,$
	xtitle='vel [mph]',ytitle='fraction of total time',$
	title=ldate + ' Histogram of wind velocity (normalized to total cnts)'
; ---------------------------------
; page 2 plot 2
; cumulative distribution 
;
	ver,0,1.
	acum=total(h,/cum)
	plot,x,(npts-acum)/npts,psym=sym,charsize=cs,$
		xtitle='vel [mph]',ytitle='fraction total time',$
		title=ldate + ' Fraction of time wind velocity exceeds specified vel'
; ---------------------------------
; page 2 plot 3
; blowup cumulative distribution 
;
ver,0,.1
	plot,x,(npts-acum)/npts,psym=sym,charsize=cs,$
		xtitle='vel [mph]',ytitle='fraction total time',$
		title=ldate + $
	' Fraction of time wind velocity exceeds specified vel (blowup)'
; -------------------------------------------------
	return
end
