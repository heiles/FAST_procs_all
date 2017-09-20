;+
;NAME:
;sbplotmet - plot the sband meter values vs time
;SYNTAX: sbplotmet,d,utit=utit,wait=wait,pagelist=pagelist
;ARGS:
;      d[n]:{}  sband long info read from disc via sblogget()
;KEYWORDS:
;utit: string   user title to add to top of  each page
;wait:          if set then wait for return after each page.
;pagelist:long  specify the pages to be plotted. pagelist=1236
;               will plot pages 1,2,3, and 6
;
;DESCRIPTION:
;   Plot the meter values vs day number. The data should first
;be input with sblogget(). 
;	Utit is the user specified title that will be added to each page
;pagelist=n can be used to plot only a subset of all of the pages.
;eg pagelist=135 will only plot pages 1,3, and 5
;
;	Plot pages are generated for:
;Page 1: kly1 forwared power
;        kly2 forwared power
;        antenna forward power
;        waster forward power
;
;Page 2: kly1 reflected power
;        kly2 reflected power
;        antenna reflected power
;        waster reflected power
;
;Page 3: kly1,2  magnet voltage
;        kly1,2  magnet currents
;        kly1,2  filament voltages
;        kly1,2  filament currents
;
;Page 4: kly1,2 rf drive power
;        kly1,2 collector currents
;        beam voltage
;        body current
;
;Page 5: kly1,2 vacion current
;        waster flow rate
;        delta temp
;        collector flow kly2
;
;Page 6: turnstyle dummy load power
;        exciter input proof
;
;-
pro sbplotmet,d,pagelist=pagelist,wait=wait,utit=utit
;
;	
	common colph,decomposedph,colph
	maxPage=6
	pagelistL=intarr(maxPage) + 1
	if n_elements(pagelist) gt 0 then begin
		i=pagelist
		pagelistL=intarr(maxPage)
		while i ne 0 do begin
			val=i mod 10
			if (val gt 0) and (val le maxpage) then pageListL[val-1]=1
			i=i/10
		endwhile
	endif

	veps=.05
	sym=0
	font=1
	eps=.003
	hor,min(d.dayno)-eps,max(d.dayno)+eps
	cs=2.2
	csn=1.5
	ln=7.2 
	xp=0
	xpinc=.1 
	x=d.dayno
;
; 	figure out date for first dayno
;
	year=d[0].year
	dm=daynotodm(fix(x[0]),year)
	yymmdd=string(format='(i02,i02,i02)',year mod 100L,dm[1],dm[0]) 
	xtit=string(format='("daynum AST (",i3,"=",a,")")',$
			fix(x[0]),yymmddtodmy(yymmdd))
	ytit='[KW]'
	tit0=(n_elements(utit) gt 0)?utit:''
;-------------------------------------------------------
; 	page 1 forward powers
;
	if pagelistL[0] then begin
	!p.multi=[0,1,4]
	amax=max([d.met.fwdpk1,d.met.fwdpk2])
	ver,0,amax*(1+veps)
	plot,x,d.met.fwdpk1,chars=cs,font=font,psym=sym,$
		xtitle=xtit,ytitle=ytit,$
	title=tit0 + "Kly1 forward Pwr.  (page1)"

	plot,x,d.met.fwdpk2,chars=cs,font=font,psym=sym,$
	xtitle=xtit,ytitle=ytit,$
	title="Kly2 forward Pwr"
	ver
	plot,x,d.met.antfwdp,chars=cs,font=font,psym=sym,$
		xtitle=xtit,ytitle=ytit,$
		title="Antenna forward Pwr"

	plot,x,d.met.wastfwdp,chars=cs,font=font,psym=sym,$
 		xtitle=xtit,ytitle=ytit,$
		title="Waster Load forward Pwr"
	if keyword_set(wait) then key=checkkey(/wait)
	endif

;-------------------------------------------------------
; 	page 2 reflected power
;
	if pagelistL[1] then begin
	!p.multi=[0,1,4]
	amax=max([d.met.reflpk1,d.met.reflpk2])
	ver,0,amax*(1+veps)
	plot,x,d.met.reflpk1,chars=cs,font=font,psym=sym,$
		xtitle=xtit,ytitle=ytit,$
	title=tit0 + "Kly1 reflected Pwr.  (page2)"


	plot,x,d.met.reflpk2,chars=cs,font=font,psym=sym,$
	xtitle=xtit,ytitle=ytit,$
	title="Kly2 reflected Pwr"
	ver
	plot,x,d.met.antreflp,chars=cs,font=font,psym=sym,$
		xtitle=xtit,ytitle=ytit,$
		title="Antenna reflected Pwr"

	plot,x,d.met.wastreflp,chars=cs,font=font,psym=sym,$
 		xtitle=xtit,ytitle=ytit,$
		title="Waster Load reflected Pwr"
	if keyword_set(wait) then key=checkkey(/wait)
	endif
;-------------------------------------------------------
; page 3
; magnet voltages,currents
	if pagelistL[2] then begin
	!p.multi=[0,1,4]
	ytit='[Volts]'
	amax=max([d.met.magVk1,d.met.magVK2])
	ver,0,amax*(1+veps)
	plot,x,d.met.magVk1,chars=cs,font=font,psym=sym,$
		xtitle=xtit,ytitle=ytit,$
		title=tit0 + "Magnet voltages.  (page3)"
		oplot,x,d.met.magVk2,col=colph[2],psym=sym
	note,ln,'Kly1',col=colph[1],xp=xp,chars=csn,font=font
	note,ln,'Kly2',col=colph[2],xp=xp+xpinc,chars=csn,font=font
; mag currents
	ytit='[Amps]'
	ver,0,15
	plot,x,d.met.magIk1,chars=cs,font=font,psym=sym,$
		xtitle=xtit,ytitle=ytit,$
		title="Magnet Currents"
	oplot,x,d.met.magIk2,col=colph[2],psym=sym
; filament voltages
	ver,0,15
	ytit='[Volts]'
	plot,x,d.met.filVk1,chars=cs,font=font,psym=sym,$
		xtitle=xtit,ytitle=ytit,$
		title="Filament Voltages"
	oplot,x,d.met.filVk2,col=colph[2],psym=sym
; filament currents
	ytit='[Amps]'
	ver,0,25
	plot,x,d.met.filIk1,chars=cs,font=font,psym=sym,$
		xtitle=xtit,ytitle=ytit,$
		title="Filament Currents"
	oplot,x,d.met.filIk2,col=colph[2],psym=sym
	if keyword_set(wait) then key=checkkey(/wait)
	endif
;-------------------------------------------------------
; page 4
; rf drive, collector currents, beam voltage, body current
;
	if pagelistL[3] then begin
	!p.multi=[0,1,4]
; 	rfdriv
	ytit='[W]'
	ver,0,5
	plot,x,d.met.rfdrvPK1,chars=cs,font=font,psym=sym,$
	xtitle=xtit,ytitle=ytit,$
	title=tit0 + "Rf drive Pwr.  (page4)"
	oplot,x,d.met.rfdrvPK2,col=colph[2],psym=sym
	note,ln,'Kly1',col=colph[1],xp=xp,chars=csn,font=font
	note,ln,'Kly2',col=colph[2],xp=xp+xpinc,chars=csn,font=font
;
;  collector currents
	ytit='[Amps]'
	ver,0,15.5
	plot,x,d.met.colIk1,chars=cs,font=font,psym=sym,$
		xtitle=xtit,ytitle=ytit,$
		title="Collector Currents"
	oplot,x,d.met.colIk2,col=colph[2],psym=sym
;
;	beam voltage
;
	ver,0,max(d.met.beamv)*(1+veps)
	ytit='[KVolts]'
	plot,x,d.met.beamV,chars=cs,font=font,psym=sym,$
	xtitle=xtit,ytitle=ytit,$
	title="Beam Voltage"
; 	body current
	ver,0,max(d.met.bodyI)*(1+veps)
	ytit='[Amps]' 
	plot,x,d.met.bodyI,chars=cs,font=font,psym=sym,$
	xtitle=xtit,ytitle=ytit,$
	title="Body current"
	if keyword_set(wait) then key=checkkey(/wait)
	endif
;
;-------------------------------------------------------
; page 5
;   vacion,wasterflow,delta temp,collecter flow kly2
;
	if pagelistL[4] then begin
	ver,.01,max([d.met.vaciiK1,d.met.vaciik2])*(1.+veps)
	ytit='[MicroAmps]' 
	plot,x,d.met.vaciIk1,chars=cs,font=font,psym=sym,$
		xtitle=xtit,ytitle=ytit,/ylog,$
		title=tit0 + "Vacion current.  (page5)"
	oplot,x,d.met.vaciIk2,col=colph[2],psym=sym
	note,ln,'Kly1',col=colph[1],xp=xp,chars=csn,font=font
	note,ln,'Kly2',col=colph[2],xp=xp+xpinc,chars=csn,font=font

	ver,0,max(d.met.wastflwrate)*(1.+veps)
	ytit='[Gal/Min]'
	plot,x,d.met.wastflwrate,chars=cs,font=font,psym=sym,$
	xtitle=xtit,ytitle=ytit,$
	title="Waster Flow Rate"
;
	ver,0,max(d.met.deltatemp)*(1.+veps)
	ytit='[Deg C]'
	plot,x,d.met.deltatemp,chars=cs,font=font,psym=sym,$
	xtitle=xtit,ytitle=ytit,$
	title="Waster Flow DeltaTemp"
;
	ver,0,max(d.met.colflowK2)*(1.+veps)
	ytit='[Gal/Min]'
	plot,x,d.met.colflowk2,chars=cs,font=font,psym=sym,$
	xtitle=xtit,ytitle=ytit,$
	title="Kly2 Collector Flow Rate"
	if keyword_set(wait) then key=checkkey(/wait)
	endif
;-------------------------------------------------------
; page 6
;   turnstyle dummy load power
;   exciter input proof.
;
;
	if pagelistL[5] then begin
	ver,.0,max(d.met.turndlp)*(1.+veps)
	ytit='[KW]'
	plot,x,d.met.turndlp,chars=cs,font=font,psym=sym,$
		xtitle=xtit,ytitle=ytit,$
		title=tit0 + "Turnstile DummyLoad Pwr.  (page6)"

	ver,0,max(d.met.exciterinpp)*(1.+veps)
	ytit='AnalogReading'
	plot,x,d.met.exciterinpp,chars=cs,font=font,psym=sym,$
	xtitle=xtit,ytitle=ytit,$
	title="Exciter Input proof"
	oplot,[x[0],max(x)],[250,250],col=colph[2],linestyle=2
	ln=14.5
	note,ln,'250--> exciter on',col=colph[2],xp=xp,chars=csn,font=font
	endif
	return
end
