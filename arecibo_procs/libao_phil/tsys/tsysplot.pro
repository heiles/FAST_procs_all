;+
;NAME:
;tsysplot - plot the tsys info for one receiver
;SYNTAX: tsysplot,rcvI,cals=cals,adate=adate,pscol=pscol,title=title,$
;			      nolab=nolab,xp=xp,_extra=e
;ARGS:
;	rcvI : {} structure holding tsys info input by tsysinp	
;KEYWORDS:
;	cals[]: limit cals to those specified in this array. numbering is:
;			0:hcal,1:hxcal,2:hcorcal,3:h90cal,4:lcal,5:lxcal,6:lcorcal,7:l90cal
;   adate : if set then plot versus alphanumeric date rather than daynumber
;drange[2]: fltarr range of daynumbers to plot 1..365
;	pscol : if set,then setup colors for hardcopy rather than the screen
;			(background colors flipped).
;   title : if set then this is the title to use
;	_extra: e keywords passed to plot and oplot routines. eg psym=xx
;   nolab ; if  set then don't bother to put cal labels
;    xp   ; float 0..1. position to place cal labels. default .01
;DESCRIPTION:
;	Plot the system temperature first day of year for daily system temperature
;data. The receivers data is stored in structures named R1,R2..R12 where the
;number is the receiver number. This data should be input with the tsysinpall
;routine (done for you when you call the tsys program). 
;EXAMPLES:
; tsysplot,R7           plot versus daynumber of year
; tsysplot,R6,/adate	plot versus day,month,year
; tsysplot,R5,/adate,drange=[30,60] plot data for daynumbers 30 through 60.
;-
pro tsysplot,rcvI,cals=cals,adate=adate,_extra=e,pscol=pscol,drange=drange,$
			 xp=xp,nolab=nolab
;
; 	
;
	!x.style=1
	listcals= n_elements(cals) gt 0
	black=[0,0,0]
	r   =[1.,0,0]
	g   =[0,1.,0]
	b   =[0,0,1.]
	w   = (r+g+b)
	rg  =((r+g))
	rb  =((r+b))
	gb  =((g+b))
	if n_elements(xp) eq 0 then xp=.01
	if n_elements(drange) ne 2 then begin
		drind=lindgen(n_elements(rcvI.r.date))
	endif else begin
		drind=where((rcvI.r.date ge drange[0]) and $
		            (rcvI.r.date le drange[1]),count)
		if count le 0 then begin
		   printf,-2,"no data between daynumbers:",drange
		   return
	    endif
	endelse
	if n_elements(title) eq 0 then begin
	   a=rcvnumtonam(rcvI.rcvnum,rcvnam)
	   if a ne 0 then begin 
		title=string(format=$
	   '("system temperature for ",a," (receiver number R",i0,") ",I4)',$
						rcvnam,rcvi.rcvnum,rcvi.year)
	   endif else begin
			title="tsys"
	   endelse
	endif
    if keyword_set(pscol) then begin
        col0   =black
        forgrnd=black
    endif else begin
        col0 =black
        forgrnd=w
    endelse
	if not keyword_set(adate) then begin
		adate=0
	    xtformat=''
	    xtitle='daynumber of year'
		x=rcvI.r[drind].date
	endif else begin
	    a=label_date(date_format='%D%M')
		xtformat='label_date'
		xtitle='date'
		x=daynotojul(rcvI.r[drind].date,fltarr(n_elements(rcvI.r[drind].date))$
				+rcvI.year)
		x=x+.5		; juldate starts at noon of day 1.. switch back to midnite
	endelse
 	coltbl=fltarr(10,3)
        coltbl[0,*]=col0
	coltbl[1,*]=forgrnd
	coltbl[2,*]=r
	coltbl[3,*]=g
	coltbl[4,*]=b
 	coltbl[5,*]=rg
    if keyword_set(pscol) then coltbl[5,*]=r*.8 + .2*g +.3*b


	mix=.65
	coltbl[6,*]=coltbl[2,*]*(1.-mix) + w*mix
	coltbl[7,*]=coltbl[3,*]*(1.-mix) + w*mix
	coltbl[8,*]=coltbl[4,*]*(1.-mix) + w*mix
 	coltbl[9,*]=coltbl[5,*]*(1.-mix) + w*mix
;
;	coltbl[1,*]=w
;	coltbl[2,*]=r
;	coltbl[3,*]=g
;	coltbl[4,*]=b
;
; 	coltbl[5,*]=rg
;	coltbl[6,*]=rb
;	coltbl[7,*]=(r*.8+g*.7)
;	coltbl[8,*]=gb
;
	coltbl=long(coltbl*255.)
; 	for i=0,9 do print,'i=',i,' coltbl:',coltbl[i,0],coltbl[i,1],coltbl[i,2]
	tvlct,coltbl[*,0],coltbl[*,1],coltbl[*,2]
	if (not (!d.flags and 1 ) ) then begin ; not ps
		device,get_decomp=decomposed
		if decomposed then device,decomposed=0
	endif
	gotit=0
	for i=0,7 do begin
		linestyle=i mod 4
;		if (decomposed) then begin
;			jj=i+2L
;			colorInd=jj+jj*256L + jj*256l*256L
;			print,string(format=$
;			'("i, colorind:",i,z)',i,colorind)
;		endif else begin
			colorind=i+2
;		endelse
		docal=1
		if listcals then begin
			docal=0
			ind=where(i eq cals,count)
			if count gt 0 then docal=1
		endif
		if ((rcvI.calAvail[i] ne 0) and docal ) then begin
			if (gotit eq 0) then begin 
				if n_elements(drind) lt 2 then begin
 					plot,[0,1],[0,1],/nodata,$
					linestyle=0,color=1,xtitle=xtitle, xtickformat=xtformat,$
					title=title,ytitle='Tsys [ K ]',_extra=e
				endif else begin
 				plot,x,rcvI.r[drind].ct[i].tsysV[0],/nodata,$
				linestyle=0,color=1,xtitle=xtitle, xtickformat=xtformat,$
				title=title,ytitle='Tsys [ K ]',_extra=e
				endelse
				gotit=1
			endif
			y=rcvI.r[drind].ct[i].tsysv[0]
			ind=where(y ne 0.,count)
			if count ge 2 then $
			oplot,x[ind],y[ind],linestyle=0,$
				color=colorind, MAX_VALUE=1000,min_value=-1000,_extra=e
			y=rcvI.r[drind].ct[i].tsysv[1]
			ind=where(y ne 0.,count)
			if count ge 2 then $
			oplot,x[ind],y[ind],linestyle=2,$
				color=colorind,  MAX_VALUE=1000,min_value=-1000,_extra=e
		endif
	endfor
;
; now label the plot
;
	if not keyword_set(nolab) then begin
	xoff=xp
	yoff=.92
	ystp=-.03
	tsyscaltypes,calA			 
	for i=0,7 do begin
		if ( rcvI.calAvail[i] ne 0 ) then begin
			colorind=i+2
			lab=string(format='(a0)',calA[i])
			if listcals then begin
			   docal=0
			   ind=where(i eq cals,count)
			   if count gt 0 then docal=1
			endif else begin
				docal=1
			endelse
			if docal then begin
			xyouts,xoff,yoff,lab,alignment=0.,/normal,color=colorind,$
					charsize=1.5
			endif
			yoff=yoff+ystp
		endif
	endfor
	endif
	return
end
