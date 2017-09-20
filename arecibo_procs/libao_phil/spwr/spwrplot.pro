;+
;NAME:
;spwrplot - plot site power info
;
;SYNTAX: spwrplot,p,hr=hr,adate=adate,mytit=mytit
;
;ARGS:
;     p[]:{}   array of site power info to plot
;KEYWORDS:
;hr      :     if set then plot vs hour of day
;              assumes 1 day of data  
;adate   :     if set then plot xaxis as year,mon,day
;mytit   : string  extra title to add at top
;
;DESCRIPTION:
;
;   plot the info in the site power structure.
;-
;
pro spwrplot,p,hr=hr,adate=adate,mytit=mytit
;
    common colph,decomposedph,colph
	
;	min value so we don't plot 0's if things dropout
	if n_elements(mytit) eq 0 then mytit=''
	minP  =150.
	minI  =10.
	minVPP  =13.
	minVPG  =7.5
	xtickf=''
	if (keyword_set(hr)) then begin
		x=p.time/3600.
	    xtit='hour of day'
		tit0=string(format='(" Date:",i08)',p[0].date)
	endif else begin
		if (keyword_set(adate)) then begin	
			junk=label_date(date_format="%D%M%H")
;          .5D since plots put tick marks at noon, not at midnite
			x=yymmddtojulday(p.date) +  p.time/86400D + .5D
	    	xtit='Date for year ' + string(p[0].date/10000L)
			xtickf='LABEL_DATE'
			tit0=''
		endif else begin
			day=p.date mod 100L
			mon=(p.date/100L)  mod 100L
			yr=(p.date/10000L)
			x=dmtodayno(day,mon,yr) + p.time/86400D
	    	xtit='Daynumber for year ' + string(yr[0])
			tit0=string(format='(" Starting@",i08)',p[0].date)
		endelse
	endelse
	cs=2.2
	csn=1.3
	font=1
	ls=3
	col1=1
	col2=2
	col3=4
	colar=[col1,col2,col3] 
	mins=.94
	maxs=1.05
;
; power
;
	hor
	psign=-1
	vmax=max(p.papparent)
	vmin=(min(-[p.pactive,p.preactive]))> minP
	ver,vmin*mins,vmax*maxs
	ytit='KW'
	tit='Power'
	!p.multi=[0,1,5]
	plot,x,p.Papparent,chars=cs,font=font,$
		xtitle=xtit,ytitle=ytit,$
		xtickformat=xtickf,$
		title=mytit + tit + tit0
	oplot,x,p.Pactive*psign,col=colph[col2]
	oplot,x,p.Preactive*psign,col=colph[col3]
;
	ln=5.5
	xp=-.05 
	xpinc=.13 
	note,ln,'Apparent',xp=xp,col=colph[col1],chars=csn,font=font
	note,ln,'-Active',xp=xp+xpinc,col=colph[col2],chars=csn,font=font
	note,ln,'-ReActive',xp=xp+xpinc*2,col=colph[col3],chars=csn,font=font
;
; power factor .. computed from apparent,active
;
	ii=where(p.papparent eq 0,cnt)
    pf=p.pactive
    y=p.papparent
    if cnt gt 0 then y[ii]=1.
    pf/=y

	minV=min(pf,max=maxV)
;	ver,minv*maxs,maxv*mins
	ver,maxv*mins,minv*maxs
	tit='Power factor (computed from Pactive/Papparent)'
	plot,x,pf,chars=cs,font=font,$
		xtitle=xtit,ytitle="Pactive/Papparent",$
		xtickformat=xtickf,$
		title=tit

;  currents
;
	minV=(min(p.idemandcur,max=maxV))>minI
	ver,minv*mins,maxv*maxs
	tit="Current usage"
	stripsxy,x,transpose(p.Imag),0,0,/step,chars=cs,font=font,$
		xtitle=xtit,ytitle="Amps",colar=colar,$
		xtickformat=xtickf,$
		title=tit
	stripsxy,x,transpose(p.IdemandCur),0,0,/step,colar=colar,$
		xtickformat=xtickf,$
		linestyle=ls,/over
	ln=13.4
	xp=.02
	xpinc=.15  

	note,ln,'____ Inst.',xp=xp,chars=csn,font=font
	note,ln,'- - - Demand (1min)',xp=xp +xpinc,chars=csn,font=font
	xp=.6
	xpinc=.12
	note,ln,'PhaseA',xp=xp,col=colph[col1],chars=csn,font=font
	note,ln,'PhaseB',xp=xp+xpinc,col=colph[col2],chars=csn,font=font
	note,ln,'PhaseC',xp=xp+xpinc*2,col=colph[col3],chars=csn,font=font
;
;
; voltages
;
	minV=(mins*min(p.VphToph,max=maxV)) > minVPP
	ver,minv,maxv*maxs
	tit='Phase to Phase Voltages'
	stripsxy,x,transpose(p.VphToPh),0,0,/step,chars=cs,font=font,$
		xtitle=xtit,ytitle='KVolts',$
		xtickformat=xtickf,$
		title=tit,colar=colar
    xp=.5
	ln=19.5
    xpinc=.12
    note,ln,'V_AtoB',xp=xp,col=colph[col1],chars=csn,font=font
    note,ln,'V_BtoC',xp=xp+xpinc,col=colph[col2],chars=csn,font=font
    note,ln,'V_CtoA',xp=xp+xpinc*2,col=colph[col3],chars=csn,font=font

	minV=(mins*min(p.Vtognd,max=maxV)) > minVPG
	ver,minv,maxv*maxs
	tit='Phase to ground Voltages'
	stripsxy,x,transpose(p.VtoGnd),0,0,/step,chars=cs,font=font,$
		xtitle=xtit,ytitle='KVolts',$
		xtickformat=xtickf,$
		title=tit,colar=colar
    xp=.5
	ln=25.5 
    xpinc=.12
    note,ln,'PhaseA',xp=xp,col=colph[col1],chars=csn,font=font
    note,ln,'PhaseB',xp=xp+xpinc,col=colph[col2],chars=csn,font=font
    note,ln,'PhaseC',xp=xp+xpinc*2,col=colph[col3],chars=csn,font=font

	return
end
