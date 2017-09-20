;+
;NAME:
;plotoffsets - generic offset plotting routine
; the plot have stairwell up +y, x + pointing downhil
; this orientation of the axis is looking up from the tertiary.
;
; note on angle direction
; - positioner, david looks from top of floor
;     +x is uphill, y is toward the stairwell
;     + rotation is CCW with z up away from the tertiary
; -german .. this is the view that the plots show..
;     x is downhill, y toward the stairwell, z down
;     positioners CCW rotation is CW for german
;     since the z axis is opposite.
; Where the data is coming from.
; The x,y offsets for centers comes from the positioner command file.
; The sky centers for each position comes from skyOffsetsForCenters.dat
;   this was generated from:
;   1. germans mapping, then updates using the pointing crosses.
;   
;
pro plotoffsets,doA,doC,doD,sky=sky,hard=hard,nocir=nocir,norad=norad,$
		horA=horA,verA=verA,tit=tit,over=over,r12=r12,norota0=norota0,cAltMount=cAltMount
	
    common colph,decomposedph,colph
;
;   angle sign.. positive positioner angle is ccw FROM ABOVE. 
;                this is CW is germans system. The rotVec routine
;                goes CCW for a positive anglee around the axis of rotation.
;                so need a minus sign.
	asgn=-1.
;   file holding commands the positioner uses
;   this is davids rotation. clockwise looking down from top of floor.
;
	posCmdFile="/home/online/Tcl/Proc/byu/data/positionerCmdsForCenters.dat" 
	n=readasciifile(posCmdFile,inplines,comment="#")
	a={ posNm: '',$
	    rotD : 0.,$; davids angle
        radiusCm:0.};
	posCmdAr=replicate(a,n)
	a=stregex(inplines,"[ ]*([^ ]+) *([0-9.]+) *([0-9.]+)",/extract,$
		/subex)
	for i=0,n-1 do begin
		posCmdAr[i].posNm=a[1,i]
		posCmdAr[i].rotD=float(a[2,i])
		posCmdAr[i].radiusCm=float(a[3,i])
	endfor
	
	if n_elements(tit) eq 0 then tit="A0-A6,C1-C6,D1-D6  tiling "
    dorad=not keyword_set(norad)
	ndip=dipolexyoff(dipOffxy)
	if keyword_set(caltMount) then begin
		ndip=dipolexyoff(dipOffxyC,/altmount)
	endif else begin
		ndip=dipolexyoff(dipOffxyC)
	endelse
 	ndip=dipolexyoff(dipOffxyD)
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
	symAr=[4,5,6,7]
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
;
	font=1
	xp=-.1
	xpdelt=.6    ; for 2nd row
;	ln=-2 
 	ln=0 
	scl=.8
	j=0
	icol= (j mod 10) +1
	isym=j mod nsym
;"center  Xcm    Ycm    radiusCm"
;"  B0 :ffff.ff,fff.ffbbb33.33"
;
;	plot the center A0
;
	ii=where(posCmdAr.posNm eq "A0")
	dipOffL=keyword_set(norota0)?dipOffxy:rotvec(dipOffxy,asgn*posCmdAr[ii].rotD)
	lab='A'
	xytosky,dipOffL,skyOff
	off=(dosky)?skyOff:dipOffL
	ll=(dosky)?" On sky":" in Focal plane"
	if not keyword_set(over) then begin
		plot,Off[0,1:*],Off[1,1:*],/iso,charsize=cs,font=font,$
		xtitle=xtitle,ytitle=ytitle,$
		title=tit+ll,psym=symAr[isym],$
        col=colph[icol],symsize=symsize,thick=symth
	endif else begin
		oplot,Off[0,1:*],Off[1,1:*],psym=symAr[isym],$
        col=colph[icol],symsize=symsize,thick=symth
	endelse
	if keyword_set(r12) then  begin
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
    note,ln+j*scl,xc,sym=symAr[isym],col=colph[icol],thick=th,$
                symsize=symsize,xp=xpout,charsize=cs ,font=font
	xyouts,Off[0,0],Off[1,0]+epsF,$
		lab + string(format='(i1)',0),col=colph[icol],$
	    font=font,charsize=cs,alignment=.5,charth=centh	
    maxRadius=max(sqrt(Off[0,*]^2+Off[1,*]^2))+epsR
;	print,maxRadius
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

	j=j+1
;
; 	loop over A1-6 and C1-6
;   for each position rotate then translate the unrotated dipole positions
;
; 0 
	for ii=0,2 do begin
		case ii of
		0 : begin
			lab='A'
			dipOffL=dipOffxy 
			end
		1 : begin
			lab='C'
			dipOffL=dipOffxyC
		    end
		2 : begin
			lab='D'
			dipOffL=dipOffxyD
		    end
		endcase
		
		if (ii eq 0) and (not doA) then  continue
		if (ii eq 1) and (not doC) then  continue
		if (ii eq 2) and (not doD) then  continue
		for i=0,6-1 do begin &$
			icol= (j mod 10) +1 &$
			isym=j mod nsym &$
;   rotate by postioner angle 
			posNm=lab + string(format='(i1)',i+1)
			jj=where(posCmdAr.posNm eq posNm)
			rotD=posCmdAr[jj].rotD
			radCm=posCmdAr[jj].radiusCm
;			print,posNm," ",rotd,RadCm
			dipOffR=rotvec(dipOffL,asgn*rotD)
;
;  positioner moves negative in germans coord
			dipOffR[0,*]-=radCm*cos(asgn*rotD*!dtor)
			dipOffR[1,*]-=radCm*sin(asgn*rotD*!dtor)
			xytosky,dipOffR,skyOff,usemeas=posNm
			off=(doSky)?skyOff:dipOffR
			oplot,Off[0,1:*],off[1,1:*],psym=symAr[isym],$
				col=colph[icol],symsize=symsize,thick=symth &$
;		line to center
			if doRad then $
			oplot,[0,off[0,0]],[0,Off[1,0]],th=linth,col=colph[icol]
	        if keyword_set(r12) then begin
				 oplot,off[0,0:1],off[1,0:1],col=colph[icol],th=r12th
				 oplot,off[0,1:2],off[1,1:2],col=colph[icol],th=r12th
			endif
;		label the center
			xc=string(format='(2x,a,i1," :",f7.2,",",f6.2,3x,f5.2)',$
			lab,i+1,Off[0,0],Off[1,0],sqrt(Off[0,0]^2 + Off[1,0]^2)) &$
			xyouts,Off[0,0],Off[1,0]+epsF,$
			lab + string(format='(i1)',i+1),col=colph[icol],$
	    	font=font,charsize=cs,alignment=.5,charth=centh	
;		Line at top with center offset
			note,ln+j*scl,xc,sym=symAr[isym],col=colph[icol],$
				symsize=symsize,xp=xpout,charsize=cs,font=font &$
            maxRadius=max(sqrt((Off[0,*]-Off[0,0])^2+(Off[1,*]-off[1,0])^2))+epsR
;			print,maxRadius
			if docir then $
				drawcircle,off[0,0],Off[1,0],maxRadius,col=icol,$
				th=thC,linestyle=lsC,/over
			j=j+1 &$
		    if j eq 13 then begin
				xpout=xpout+ xpdelt
				j=1
    			note,ln0,labT,thick=th,xp=xpout,charsize=cs ,font=font
	            ln=ln0+1*scl
			endif
		endfor
	endfor
	return
end
