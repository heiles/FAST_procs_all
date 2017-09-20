;+
;NAME:
;cgenplot - plot generator data
;SYNTAX: cgenplot,d,title=title,drange=drange,cs=cs,font=font,sym=sym,$
;					labadate=labadate,wait=wait,hard=hard,psname=psname
;ARGS:   
;   d[n]:{cgeninfo} array of generator data
;KEYWORDS:
; title     : string title to add to the top of each page
; drange[2] : long  [yyyymmdd,numdays] to plot
;  cs       : float character size scaling if single plot. default=2
; font      : int   1-truetype, -1 hershey, 0 device
;                   def:hershey
;   sym     : int   symbol to using when plotting x vs y.
;                   1,2,3 .. plot a symbol at each measured position.
;                   1 +, 2 *, 3 . , Negative number -1,-2,-3 will plot 
;                   the symbol and the connecting lines.
;                   default:4
; title     : string add this to top of each page
;  labadate : string if supplied, then this is the output format
;                   for label_date call:
;                   %M-monName,%N-monNun,%D-dayNo,%Z-yy,%H-hr,%I-min
;                   default is "%D%M" (ddMon)
;   wait    :       if set then wait for enter between plots
;   hard    :       if set then write a .ps file.
; psname    : string name for psfile. Default="cgensum_yyyymm.ps"
;
;DESCRIPTION:
;   Plot the cummings generator data passed in.
;The first page plots combined data (from the 4 generators)
; 1. total power vs time.
; 2. fuel rate (gallons/hour) vs time.
; 3. fuel rate vs total power.
; 4. efficiency vs total power. (KW for 1gallon/hour)
;Page 2:
; 1. combined fuel usage (gallons) since start of this dataset.
; 2. cumulative hours run for each generator (since installation).
;    each generator is a separate color.
;
;	The /hard keyword will generate a hardcopy file (ps). The default
;name is cgensum_yyyymm.ps . You can change the psname using the psname
;keyword.
;
;	You can limit the data plotted using the drange= keyword
;  	drange[0]= yyyymmdd   start of data
;   drange[1]= ndays       number of days (from drange[0] to plot).
;                         if ndays can be positive or negative.
;-
pro cgenplot,d , title=title,cs=cs,font=font,sym=sym,drange=drange ,$
				labadate=labadate,wait=wait,hard=hard,psname=psname
;
	common colph,decomposedph,colph

;	see if they are plotting to file


	hdc=(!d.flags and 1) or (keyword_set(hard))
	if hdc then begin
		csL=2.0
		fontL=1
	endif else begin
		csL=2.0
		fontL=-1
	endelse

	csn=1.5
	if n_elements(cs) ne 0 then csL=cs
	if n_elements(font) ne 0 then fontL=font

	if n_elements(sym) eq 0 then sym=4
	if n_elements(title) eq 0 then title=''
	useDrange=(n_elements(drange) eq 2)

    !x.style=1
    !y.style=1
	hor
	ver
;
;	if 3 or fewer days, include hour of day
;

	n=n_elements(d)
	ii=lindgen(n)
	; make jd basedon utc
	astToUtc= 4D/24D 
	jd=d.jd - AstToUtc
    if useDrange then begin
;
       jd1=yymmddtojulday(drange[0])
       delta=drange[1]
       if delta lt 0. then begin 
        ii=where((jd ge (jd1+delta)) and (jd le jd1),count)
       endif else begin
        ii=where((jd ge jd1) and (jd le (jd1+ delta)),count)
       endelse
       if count le 0 then begin
            printf,-2,"no data for date,range:",drange
            return 
        endif
		jd=jd[ii]
    endif

	d_jd=max(jd)-min(jd)
	defLabdate=(d_jd le 3)?"%Hh_%D%M":"%D%M"
	aa=(n_elements(labadate) gt 0)?labadate:defLabDate
	; when label_date is used to plot jd dates,
    ; - if highest resolution is day, then the tick
    ;   marks occur at utc Noon (start of jd).
    ; - if you include hours in the axis, you can
    ;   see where the utc date starts
    ; - labDateoff tries to make it so the day starts
    ;   at 0 utc (or ast since we use 4/24 to go utc to ast.
	labDateOff=(strpos(aa,"H") ne -1)?0.:.5
    a=label_date(date_format=aa)
    xtformat='label_date'
    xtitleL='date'

    xp=.02
    xpinc=.1
    scl=.8
    n=n_elements(d)
;
; 	total power vs time
;
	totPwr=total(d[ii].geni.totkw,1)
	totFuel=total(d[ii].geni.totFuel,1)
	dHr=(jd  - shift(jd,1))*24.
	dhr[0]=dhr[1]
	jj=where(dhr lt 1e-4,cnt)
	if cnt gt 0 then dhr[jj]=-1
	dfuel=totFuel  - shift(totfuel,1)
	dfuel[0]=dfuel[1] 
	fuelrate=dfuel/dhr
	if cnt gt 0 then fuelrate[jj]=0.

	jj=where(fuelrate lt 1.,cnt)
	if cnt gt 0 then fuelrate[jj]=-1
	effic=totPwr/fuelrate
	if cnt gt 0 then fuelrate[jj]=0.
;
	if  keyword_set(hard) then begin
		if n_elements(psname) eq 0 then begin
			psname="cgensum_" + string(format='(i4,i02)',$
				d[ii[0]].yyyymmdd/10000L,$
				(d[ii[0]].yyyymmdd/100L) mod 100L) + ".ps"
		endif
		pscol,psname,/full
	endif
	vscl=1.05
	hscl=1.05
	!p.multi=[0,1,4]
	ver,0,max(totpwr)*vscl
	plot,jd + labDateOff ,totPwr,chars=csl,font=fontL,$
		xtickformat=xtformat,$
    	xtit=xtitleL,ytit='power [KW]',$
    title=title + ' Total power vs Time (sum all generators)'
	ver,0,max(fuelrate)*vscl
	plot,jd +labDateOff ,fuelrate,chars=csL,font=fontL,$
		xtickformat=xtformat,$
    	xtit=xtitleL,ytit="gallonPerHour",$
    	title='Fuel Rate vs time (sum all generators)'
	;
	tosmo=5
	y=smooth(fuelrate,tosmo)
	x=smooth(totpwr,tosmo)
	ver,0,max(y)*vscl
	hor,0,max(x)*vscl
	plot,x,y,chars=csL,font=fontL,psym=sym,$
    	xtit="power KW",ytit="gallonPerHour",$
    	title='Fuel Rate vs powerr (sum all generators)'
	coef=poly_fit(x,y,1,yfit=yfit)
	xx=findgen(101)/100 *max(totpwr)
	oplot,xx,poly(xx,coef),col=colph[2]
	ln=17
	xp=.04
	note,ln,string(format='(f6.2," gal/Hr per MegaW")',$
			coef[1]*1000),xp=xp,col=colph[2],$
			chars=csn,font=fontl
	y=smooth(effic,tosmo)
	x=smooth(totpwr,tosmo)

	ver,0,max(y)*vscl
	plot,x,y,chars=csL,font=fontL,psym=sym,$
    xtit='power [KW]',ytit="KW From (1 gallonPerHr)",$
    title="Efficiency: KW for 1 gallon/hour. (sum all generators)"
;
; page 2 fuel usage, hours run
;
	if not keyword_set(hard) then begin
		key=checkkey(/all)
		if keyword_set(wait) then begin
			print,"Hit enter to continue"
			key=checkkey(/wait)
		endif
	endif
!p.multi=[0,1,2]
	hor
	y=totfuel -totfuel[0]
	ver,0,max(y)*vscl
	csl=1.2
	plot,jd + labDateOff ,totfuel- totfuel[0],chars=csL,font=fontL,psym=sym,$
		xtickformat=xtformat,$
    xtit='date',ytit='gallons',$
    title="Gallons used for this time period (sum all generators)"
;
; cumulative hours used
;
	cumhours=d[ii].geni.engruntime
	ymin=min(cumhours)
	ymax=max(cumhours)
	
	eps=(ymax-ymin)*(vscl-1)
	ver,ymin-eps,ymax +  eps
	plot,jd + labDateOff,cumhours[0,*],chars=csL,font=fontL,psym=sym,$
		xtickformat=xtformat,$
    	xtit='date',ytit='cumRunTime [hours]',$
    title="Cumulative run time for 4 generators"
	for i=1,3 do oplot,jd+labDateOff,cumhours[i,*],psym=sym,col=colph[i+1]
	ln=18
	xp=.04
	scl=.8
	for i=0,3 do note,ln +i*scl,"Gen"+string(format='(i1)',i+1),col=colph[i+1],$
			chars=csn,font=fontL ,xp=xp
	if keyword_set(hard) then begin
		hardcopy
		x
		ldcolph
	endif
    return
end
