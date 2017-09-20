;+
;NAME:
;plotoffsets - generic offset plotting routine
; the plot have stairwell up +y, x + pointing downhil
; this orientation of the axis is looking up from the tertiary.
;
; useGc - use germans sky defs.
; note on angle direction
; -german .. this is the view that the plots show..
;     x is downhill, y toward the stairwell, z down
;     positioners CCW rotation is CW for german
;     since the z axis is opposite.
; Where the data is coming from.
; The x,y offsets for centers comes from the dipole offsets file
; The sky centers for each position comes from skyOffsetsForCenters.dat
;   this was generated from:
;   1. germans mapping, then updates using the pointing crosses.
;   
;
pro plotoffsets,sky=sky,hard=hard,nocir=nocir,usegc=usegc,$
		horA=horA,verA=verA,tit=tit,over=over,r12=r12
	
    common colph,decomposedph,colph
;

	if n_elements(usegc) eq 0 then usegc=0
	if n_elements(over) eq 0 then  over=0
	
	if n_elements(tit) eq 0 then tit="ao19 tiling "
	ndip=dipolexyoff(dipOffxy)
	docir=not keyword_set(nocir)
	lnCount=0
	if keyword_set(sky) then begin
		xtitle='dAz [Amin]'
		ytitle='DZa [Amin]'
		h=32
		hor,-h,h
		ver,-h,h
		gstep=2
		epsF=-2*h/90.
	    epsR=0.*h/90.
		dosky=1
	endif else begin
		xtitle='X [cm] (decreasing za->)'
    	ytitle='Y [cm] (toward stairwell->)'
		hor,-90,90
		ver,-90,90
		gstep=5
		h=90
		epsF=-2
		epsR=2.
		dosky=0
	endelse
	if n_elements(horA) eq 2 then begin
		hor,horA[0],horA[1]
		h=horA[1]
	endif
	if n_elements(verA) eq 2 then begin
		ver,verA[0],verA[1]
	endif
	symAr=-[4,5,6,7]
	nsym=n_elements(symAr)
	ws=800
	if not keyword_set(hard) and not (keyword_set(over)) then window,0,xsize=ws,ysize=ws
; Cn label center of each 
	centh=1
; note line
	th=5. 
; for radi
	linth=5
	r12th=3
	cs=1.5
; symbols
	symth=3.
	symsize=1
; circle
	thC=3. 
	lsC=0
;
;   for grid
	ls=1
	lspl=2
;
	font=1
	xp=-.1
	xpdelt=.6    ; for 2nd row
;	ln=-2 
 	ln=0 
	scl=.8
	icol= 1
	icolOver=2
	isym=0
;"center  Xcm    Ycm    radiusCm"
;"  B0 :ffff.ff,fff.ffbbb33.33"
;
;	plot the center A0
;
	dipOffL=dipOffxy
	lab=' '
	xytosky,dipOffL,skyOff,usegc=usegc
	off=(dosky)?skyOff:dipOffL
	if (dosky) then begin
		ll=(usegc)?" On sky. 2013 German positions":$
		           " On sky. 2010 equation german"
	endif else begin
		ll=" in Focal plane"
	endelse
	if not keyword_set(over) then begin
		plot,Off[0,1:*],Off[1,1:*],/iso,charsize=cs,font=font,$
		xtitle=xtitle,ytitle=ytitle,$
		title=tit+ll,psym=symAr[isym],linestyle=lspl,$
        col=colph[icol],symsize=symsize,thick=symth
	endif else begin
		oplot,Off[0,1:*],Off[1,1:*],psym=symAr[isym],linestyle=lspl,$
        col=colph[icolover],symsize=symsize,thick=symth
	endelse
	if keyword_set(r12) and (not over) then  begin
		 oplot,off[0,0:1],off[1,0:1],th=r12th
		 oplot,off[0,1:2],off[1,1:2],th=r12th
	endif
	labT="center  Xcm  Ycm   radiusCm"
	if dosky then  labT="center AzAmin ZaAmin radiusAmin"
	ln0=ln
	xpout=xp
    note,ln0,labT,thick=th,xp=xpout,charsize=cs ,font=font
	ln=ln0+1*scl
	xc=string(format='("  A0 :",f7.2,",",f6.2,3x,f5.2)',0,0,0) &$
    note,ln,xc,sym=symAr[isym],col=colph[icol],thick=th,$
                symsize=symsize,xp=xpout,charsize=cs ,font=font
	xyouts,Off[0,0],Off[1,0]+epsF,$
		lab + string(format='(i1)',0),col=colph[icol],$
	    font=font,charsize=cs,alignment=.5,charth=centh	
	note,ln+ 1*scl,"German's 2010 equations",col=colph[1],thick=th,$
                xp=xpout,charsize=cs ,font=font
	if (over) then begin
	note,ln+ 2*scl,"German's 2013 values",col=colph[2],thick=th,$
                xp=xpout,charsize=cs ,font=font
	endif
    maxRadius=max(sqrt(Off[0,*]^2+Off[1,*]^2))+epsR
;	print,maxRadius
	if (not over) then begin
		if docir then $
		drawcircle,0,0,maxRadius,col=icol,th=thC,linestyle=lsC,/over
		for i=-h,h,gstep do begin
			lsl=(i eq 0)?0:ls
			oplot,[-h,h],[i,i],linestyle=lsl
		endfor
		for i=-h,h,gstep do begin
			lsl=(i eq 0)?0:ls
			oplot,[i,i],[-h,h],linestyle=lsl
		endfor
	endif
	return
end
