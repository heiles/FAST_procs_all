;+
;NAME:
;spwrplotday - plot a days worth of info
;
;SYNTAX: n=spwrplotday(yymmdd,p,fname=fname)
;
;ARGS:
; yymmdd : long    date to plot
; fname  : stirng  if supplied then dir/name to input
;RETURNS:
;nrecs   : long number of recs fount
;p[nrecs]: {}   data input
;
;DESCRIPTION:
;
;   plot a days worth of data
;-
;
function spwrplotday,yymmdd,p,fname=fname
;
	    common colph,decomposedph,colph
	lprefix='/share/phildat/sitepwr/sitepwr_'
	lsuf   ='.dat'
	if (n_elements(fname)) eq 0 then begin
		yymmddL=(yymmdd lt 1000000L)?yymmdd + 20000000L:yymmdd
		fnameL=lprefix + string(format='(i08)',yymmddL) + lsuf
	endif else begin
		fnameL=fname
	endelse

	nrecs=spwrget(lun,p,fname=fnameL)
	if nrecs le 0 then begin
		print,"No data found for file:",fnameL
		p=''
		return,0
	endif
    yr=yymmdd/10000L	
	mon=(yymmdd / 100L) mod 100L
	day= yymmdd mod 100L
	yr=yr mod 100

	day=p.date mod 100L
	mon=(p.date/100L)  mod 100L
	yr=(p.date/10000L)
	dayno=dmtodayno(day,mon,yr) + p.time/86400D
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

	x=dayno
	xtit='Daynumber for year ' + string(yr[0])

;
; power
;
	psign=-1
	vmax=max(p.papparent)
	vmin=min(-[p.pactive,p.preactive])
	ver,vmin*mins,vmax*maxs
	ytit='KW'
	tit='Power'
	!p.multi=[0,1,5]
	plot,x,p.Papparent,chars=cs,font=font,$
		xtitle=xtit,ytitle=ytit,$
		title=tit
	oplot,x,p.Pactive*psign,col=colph[col2]
	oplot,x,p.Preactive*psign,col=colph[col3]
;
	ln=0.6
	xp=.0 
	xpinc=.14 
	note,ln,'Apparent',xp=xp,col=colph[col1],chars=csn,font=font
	note,ln,'-Active',xp=xp+xpinc,col=colph[col2],chars=csn,font=font
	note,ln,'-ReActive',xp=xp+xpinc*2,col=colph[col3],chars=csn,font=font
;
; power factor .. computed from apparent,active
; stay away from 0 power 
	ii=where(p.papparent eq 0,cnt)
	pf=p.pactive
	y=p.papparent
	if cnt gt 0 then y[ii]=1. 
	pf/=y
	minV=min(pf,max=maxV)
	ver,minv*maxs,maxv*mins
	tit='Power factor (computed from Pactive/Papparent)'
	plot,x,pf,chars=cs,font=font,$
			xtitle=xtit,ytitle="Pactive/Papparent",$
			title=tit

;  currents
;
	minV=min(p.idemandcur,max=maxV)
	ver,minv*mins,maxv*maxs
	tit="Current usage"
	stripsxy,x,transpose(p.Imag),0,0,/step,chars=cs,font=font,$
		xtitle=xtit,ytitle="Amps",colar=colar,$
		title=tit
	stripsxy,x,transpose(p.IdemandCur),0,0,/step,colar=colar,$
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
	minV=min(p.VphToph,max=maxV)
	ver,minv*mins,maxv*maxs
	tit='Phase to Phase Voltages'
	stripsxy,x,transpose(p.VphToPh),0,0,/step,chars=cs,font=font,$
		xtitle=xtit,ytitle='KVolts',$
		title=tit,colar=colar
    xp=.5
	ln=19.5
    xpinc=.12
    note,ln,'V_AtoB',xp=xp,col=colph[col1],chars=csn,font=font
    note,ln,'V_BtoC',xp=xp+xpinc,col=colph[col2],chars=csn,font=font
    note,ln,'V_CtoA',xp=xp+xpinc*2,col=colph[col3],chars=csn,font=font

	minV=min(p.Vtognd,max=maxV)
	ver,minv*mins,maxv*maxs
	tit='Phase to ground Voltages'
	stripsxy,x,transpose(p.VtoGnd),0,0,/step,chars=cs,font=font,$
		xtitle=xtit,ytitle='KVolts',$
		title=tit,colar=colar
    xp=.5
	ln=25.5 
    xpinc=.12
    note,ln,'PhaseA',xp=xp,col=colph[col1],chars=csn,font=font
    note,ln,'PhaseB',xp=xp+xpinc,col=colph[col2],chars=csn,font=font
    note,ln,'PhaseC',xp=xp+xpinc*2,col=colph[col3],chars=csn,font=font

	return,nrecs
end
