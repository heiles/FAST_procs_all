;+
;NAME:
;tsysplotalfa - plot the tsys info for alfa
;SYNTAX: tsysplotalfa,rcvI,adate=adate,pscol=pscol,title=title,$
;			      nolab=nolab,xp=xp,_extra=e
;ARGS:
;	rcvI : {} structure holding tsys info input by tsysinpalfa
;KEYWORDS:
;   adate : if set then plot versus alphanumeric date rather than daynumber
;drange[2]: fltarr range of daynumbers to plot 1..365
;	pscol : if set,then setup colors for hardcopy rather than the screen
;			(background colors flipped).
;   title : if set then this is the title to use
;	_extra: e keywords passed to plot and oplot routines. eg psym=xx
;   nolab ; if  set then don't bother to put cal labels
;    xp   ; float 0..1. position to place cal labels. default .01
;DESCRIPTION:
;	Plot the system temperature first day of year for alfa daily system
;  temperature data. The data is stored in rcvI struct.This data should be 
;input with the tsysinpalfa
;EXAMPLES:
; tsysplotalfa,          plot versus daynumber of year
; tsysplotalfa,/adate	plot versus day,month,year
; tsysplotalfa,/adate,drange=[30,60] plot data for daynumbers 30 through 60.
;-
pro tsysplotalfa,rcvI,adate=adate,_extra=e,pscol=pscol,drange=drange,$
			 xp=xp,nolab=nolab,title=title
common colph,decomposedph,colph
;

; 	
;
	font=1
	csn=1.5
	cs=csn
	nbeams=7
	!x.style=1
	if n_elements(xp) eq 0 then xp=.01
	if n_elements(drange) ne 2 then begin
		drind=lindgen(n_elements(rcvI.date))
	endif else begin
		drind=where((rcvI.date ge drange[0]) and $
		            (rcvI.date le drange[1]),count)
		if count le 0 then begin
		   printf,-2,"no data between daynumbers:",drange
		   return
	    endif
	endelse
	if n_elements(title) eq 0 then begin
		title=string(format=$
	   '("alfa system temperature for ",I4)',rcvi[0].year)
	endif
	if not keyword_set(adate) then begin
		adate=0
	    xtformat=''
	    xtitle='daynumber of year'
		x=rcvI[drind].date
	endif else begin
	    a=label_date(date_format='%D%M')
		xtformat='label_date'
		xtitle='date'
		x=daynotojul(rcvI[drind].date,rcvI.year)
		x=x+.5		; juldate starts at noon of day 1.. switch back to midnite
	endelse
;	if (not (!d.flags and 1 ) ) then begin ; not ps
;		device,get_decomp=decomposed
;		if decomposed then device,decomposed=0
;	endif
	gotit=0
    lsA=0
    lsB=1
	lpol=['PolA','PolB']
	!p.multi=[0,1,2]
	for ipol=0,1 do begin
	  for ibm=0,nbeams-1 do begin
		colorind=ibm+1
		if (ibm eq 0 ) then begin 
			if n_elements(drind) lt 2 then begin
 					plot,[0,1],[0,1],/nodata,chars=cs,font=font,$
				linestyle=0,color=colph[1],xtitle=xtitle, xtickformat=xtformat,$
					title=title + ' ' + lpol[ipol],ytitle='Tsys [ K ]',_extra=e
			endif else begin
 				plot,x,rcvI[drind].tsys[0,0],/nodata,chars=cs,font=font,$
				linestyle=0,color=colph[1],xtitle=xtitle, xtickformat=xtformat,$
				title=title + " " + lpol[ipol],ytitle='Tsys [ K ]',_extra=e
			endelse
			gotit=1
		endif
		y=rcvI[drind].tsys[ipol,ibm]
		ind=where(y ne 0.,count)
		if count ge 2 then $
			oplot,x[ind],y[ind],linestyle=0,$
			color=colph[colorind], MAX_VALUE=1000,min_value=-1000,_extra=e
	  endfor
  endfor
;
; now label the plot
;
	if not keyword_set(nolab) then begin
    ln=15
    xpinc=.08
    xp=-.05
    for ibm=0,nbeams-1 do begin
        note,ln,'bm' + $
            string(format='(i1)',ibm),xp=xp+ibm*xpinc,col=colph[ibm+1],$
            font=font,chars=csn
    endfor

	endif
	return
end
