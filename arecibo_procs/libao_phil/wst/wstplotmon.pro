;+
;NAME:
;wstplotmon - monthly weather station plots
;SYNTAX: npnts=wstplotmon(yymm,wait=wait
;ARGS:
;yymm : int  year,month to plot
;KEYWORDS:
;wait :   if set the wait for keyboard input between plots
;usebar:  if set then user passes data in via bar= keyword.
;         program will not read it in
;RETURNS:
;npnts: long < 0 --> error
;            > 0  number of points in month
;bar[npnts]:{} if usebar is not set then the input data will be
;              passed back in bar.
;-
function wstplotmon, yymm,wait=wait,bar=bar,usebar=usebar

    common colph,decomposedph,colph

	vminPres=27.
	vminTemp=60.
	junk=label_date(date_format="%Z%N%D") 
	verExtra=1.05	; to scale vertical from peak
	cs=2.0
	csn=1.5
	font=1
	asttoutc=4d/24d
	year=yymm/100L
	if year lt 99 then year+=2000L
	mon=yymm mod 100L
	yymmdd1=yymm * 100L + 1
	ndays=daysinmon(mon,year)
	if keyword_set(usebar) then begin
		npnts=n_elements(bar)
	endif else begin	
 		npnts=wstgetarchive(yymmdd1,0L,bar,ndays=ndays)
	endelse
	if npnts eq 0 then begin
		print,"no data for mon,yr:",mon,yr
		stop
		return,-1
	endif
	caldat,bar[0].jd,mon,day,yr	
	ldate=monname(mon) + string(format='(i02)',yr mod 100L) + " "
; ----------------------------------------------------
; wind velocity
; top: every 15 minutes
;   default time step
	minstep=15.
	n=wstbindata(bar.windspd,bar.jd,davg,dpk,djd)
;
; need inc since idl labels put dat at noon, not 0am..
; need astf to move to ast from gmt
;
	; by hour
    lnpk=2
    lnavg=lnpk+10
    xppk=.04
    scl=.7

	maxVelPk=max(dpk)
    !p.multi=[0,1,3]
    inc=.5D
    ver,0,maxVelPk*verExtra
    hor
    lab=string(format=$
        '("Avg & Peak velocities vs date (over ",f4.1," minutes)")',$
		minStep)
    plot,djd-astToUtc + inc,dpk,xtickf='label_date',$
		charsize=cs,font=font,$
        xtitle='date [Ast]',ytitle='velocity [mph]',$
        title= ldate + lab
    oplot,djd - astToUtc+ inc,davg,color=colph[2]
    note,lnpk      ,'Peak hold',xp=xppk,color=colph[1],$
		chars=csn,font=font
    note,lnpk+1*scl,'Average',xp=xppk,color=colph[2],$
		chars=csn,font=font

; -----------------------------------------------------
; windvelocity: 2 vel by hour of day
;
; velocity by 15 min step of day
;   jd starts at noon
;
	hr=((bar.jd -.5d - 4d/24d) mod 1d) * 24d
	n=wstbindata(bar.windspd,hr,davg,dpk,dhr,/hrdat)
	maxVal=max(davg)
	ver,0,maxVal*verExtra
	hor,0,24
	sym=0
	plot,dhr,davg,$
		charsize=cs,font=font,$
   	 	xtitle='hour of day',ytitle='Vel [mph]',$
    	title= ' Average velocity by hour of day'
; -------------------------------
; wind: 3  velocity by direction
;
    mindirvel=1.      ; for computing vel by direction
    ind=where(bar.windspd gt mindirvel,count)
	dir=bar[ind].winddiradj
	n=wstbindata(bar[ind].windspd,bar[ind].winddiradj,davg,dpk,dx,$
				/degdat,hist=h)
	hor,0,360
	maxVal=max(davg)
	ver,0,maxVal*verExtra
	plot,dx,davg,psym=sym,$
			chars=cs,font=font,$
    xtitle='direction [degrees east of North]',ytitle='Vel [mph]',$
    title= ' Average  velocity by direction'
;
;	overplot the histogram
;
	scl=(maxVal*verExtra/5.)/max(h)
	oplot,dx,h*scl,col=colph[4]
	ln=26
    note,ln,'Histogram of direction',xp=xppk,color=colph[4],$
			chars=csn,font=font
; ------------------------------------
; page 2.1:temp
; temp, rain month, rel, barometric pressure, humidity
;
pg2:
	if keyword_set(wait) then begin
		print,'hit return to continue'
		key=checkkey(/wait)
	endif
    !p.multi=[0,1,4]
    n=wstbindata(bar.temp,bar.jd,davg,dpk,djd)

	maxTemp=max(davg)
    ver,vminTemp,maxTemp*verExtra
    hor
    lab=string(format=$
        '("Temp  vs date (averaged over ",f4.1," minutes)")',$
		minStep)
    plot,djd-astToUtc + inc,davg,xtickf='label_date',$
		charsize=cs,font=font,$
        xtitle='date [Ast]',ytitle='degF',$
        title= ldate + lab

; -------------------------------------------------
;	page 2.2: cumulative rain month
;
    n=wstbindata(bar.rainmonth,bar.jd,davg,dpk,djd)

    lab=string(format=$
        '("Cumulative rainfall for month vs date (averaged over ",f4.1," minutes)")',$
		minStep)
	maxRain=max(davg)
    ver,0,maxRain*verExtra
    hor
    plot,djd-astToUtc + inc,davg,xtickf='label_date',$
		charsize=cs,font=font,$
        xtitle='date [Ast]',ytitle='inches',$
        title=  lab
; -------------------------------------------------
;	page 2.3: relative humidity
;
     n=wstbindata(bar.relhum,bar.jd,davg,dpk,djd)

    lab=string(format=$
        '("Relative humidity (averaged over ",f4.1," minutes)")',$
		minStep)
    ver,0,100
    hor
    plot,djd-astToUtc + inc,davg,xtickf='label_date',$
		charsize=cs,font=font,$
        xtitle='date [Ast]',ytitle='percent',$
        title=  lab
; -------------------------------------------------
;	page 2.4: barometric pressure (adjusted)
;
     n=wstbindata(bar.barpresadj,bar.jd,davg,dpk,djd)

    lab=string(format=$
        '("Barometric pressure vs date. (averaged over ",f4.1," minutes)")',$
		minStep)
	maxPressure=max(davg)
	minPressure=min(davg)
	; in case we have 0's
	minUse=(minPressure > vminPres)
	vstp=.1
    ver,minUse,maxPressure+vstp
    hor
    plot,djd-astToUtc + inc,davg,xtickf='label_date',$
		charsize=cs,font=font,$
        xtitle='date [Ast]',ytitle='Inches Mercury',$
        title=  lab
	ln=24
	xp=.04
	note,ln,"Adjusted for altitude",xp=xp,chars=csn,font=font
	return,npnts
end
