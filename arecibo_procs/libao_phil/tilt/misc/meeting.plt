;
;
; output td pos for each az swing 2 thru 19.5 by 2
;
; recreate the prgrid using the td fits.. it used to use the interpolations
; need to compile tilt/tspro/Old/tdcmpgrid.pro
prfit2dio,prfit2d
prgrid={prgrid}
tdgrid={prgrid}
prgrid.az=findgen(360)
prgrid.za=findgen(41)*.5
for i=5,40 do begin 
	za=fltarr(360)+prgrid.za[i] 
	prgrid.p[*,i]=prfit2deval(prfit2d,prgrid.az,za) 
	prgrid.r[*,i]=prfit2deval(prfit2d,prgrid.az,za,/roll)
endfor
;
tdpos07=tdcmpgrid(prgrid)

;

  scaleTr=1.74
    tdRadiusHor=192.            ;/* center to tiedown feet*/
    radOptCenIn= 435.*12.       ;/* radius optical center to focus*/
    scaleRot=1.24               ;/* td in/inch for rotation*/
    S       =40.212*scaleRot    ;/* 1deg*pi/180* 192*12* scaleRot*/

az=findgen(360)
refpos=fltarr(3)
lims=fltarr(2,3)
lims[*,0]=[1.43,22.29]
lims[*,1]=[1.93,22.87]
lims[*,2]=[1.19,22.20]
lims[0,*]=lims[0,*] + .2
lims[1,*]=lims[1,*] - .2
hor,0,360
ver,-10,25
for i=2,20,2 do begin
	title=string(format='("tiedown position za:",i3," temp=72")',i)
	plot,az,tdpos07[0,*,i*2],xstyle=1,ystyle=1,color=1,$
		xtitle='az',ytitle='td position [i]',$
		title=title
	oplot,az,fltarr(360)+lims[0,0],color=1
	oplot,az,fltarr(360)+lims[1,0],color=1
	note,3,'line:td12,dash:td4,dash-dot:td8'
		for j=1,2 do begin
			oplot,az,tdpos07[j,*,i*2],linestyle=j+1,color=j+1
			oplot,az,fltarr(360)+lims[0,j],color=j+1,linestyle=j+1
			oplot,az,fltarr(360)+lims[1,j],color=j+1,linestyle=j+1
		endfor
endfor
;
; output pitch,roll,focus
note3='07apr00, temp=72  (za20=...)'
;
pltdcor,tdpos07,prgrid,/pitch,/roll,/prq,note3=note3
pltdcor,tdpos07,prgrid,/focrad,/focrp,/focp,note3=note3
pltdcor,tdpos07,prgrid,td=12 ,note3=note3
pltdcor,tdpos07,prgrid,td=4 ,note3=note3
pltdcor,tdpos07,prgrid,td=8 ,note3=note3
;
; output pitch vs za for all az
;
ver,-.05,.25
hor,0,20
for i=0,359,10 do begin &$
	if  i eq 0 then begin &$
		plot,prgrid.za,prgrid.p[i,*],xstyle=1,ystyle=1, $
			xtitle='za',ytitle='pitch [deg]',$
		title='Pitch vs za for azimuths 0-360' &$
	endif else begin &$
		oplot,prgrid.za,prgrid.p[i,*] &$
	endelse &$
endfor
;
; output roll vs za for all az
;
ver,-.3,.0
for i=0,359,10 do begin &$
	if  i eq 0 then begin &$
		plot,prgrid.za,prgrid.r[i,*],xstyle=1,ystyle=1, $
			xtitle='za',ytitle='Roll [deg]',$
		title='Roll vs za for azimuths 0-360' &$
	endif else begin &$
		oplot,prgrid.za,prgrid.r[i,*] &$
	endelse &$
endfor
;
;   plot radial focus vs az for za 1-20
;
	mkazzagrid,az,za
    az=reform(az)
    za=reform(za)
	oplot=0
	note3='7apr00 temp=72'
    ver,-2,4
    y=reform(tsfocus(az,za),360,41)
    title='radial focus correction [in]'
    ytitle=title
	note3='7apr00 temp=72'
for i=0,359,10 do begin &$
	if  i eq 0 then begin &$
		plot,prgrid.za,y[i,*],xstyle=1,ystyle=1, $
			xtitle='za',ytitle=ytitle,$
    title='radial focus [in] vs za for az:0 to 360' &$
	note,3,note3 &$
	endif else begin &$
		oplot,prgrid.za,y[i,*] &$
	endelse &$
endfor
;
;   plot radial focus projected to td inches
;
	scaleTr=1.74
    ver,-5,5
    y=reform(tsfocus(az,za)* $
                     cos(za*!dtor)*scaletr  ,360,41)
    ytitle='td motion [in]'
for i=0,359,10 do begin &$
	if  i eq 0 then begin &$
		plot,prgrid.za,y[i,*],xstyle=1,ystyle=1, $
			xtitle='za',ytitle=ytitle,$
    title='radial focus projected to td [in] vs za for az:0 to 360' &$
	note,3,note3 &$
	endif else begin &$
		oplot,prgrid.za,y[i,*] &$
	endelse &$
endfor
;
;   plot radial focus from pitch  vs za
;
    ver,-12,2
    y= reform(-sin(!dtor*za) * radOptCenIn * $
                      sin(reform(prgrid.p)*!dtor)*scaleTr, 360,41)
        title='focus correction from pitch projected to td [in]'
        ytitle='td position [in]'

    ytitle='td motion [in]'
for i=0,359,10 do begin &$
    if  i eq 0 then begin &$
        plot,prgrid.za,y[i,*],xstyle=1,ystyle=1, $
            xtitle='za',ytitle=ytitle,$
    title='focus correction from pitch projected to td [in] vs za' &$
    note,3,note3 &$
    endif else begin &$
        oplot,prgrid.za,y[i,*] &$
    endelse &$
endfor
;
; plot tdmotion vs pitch
;
za=findgen(21)
p=(findgen(21) - 10.)/10. * .3
tdPos=p*S
hor,-.3,.3
ver,-15,15
plot,p,tdPos,xstyle=1,ystyle=1,$
    xtitle='pitch [deg]',ytitle='td motion [in] needed',$
    title='max td motion [in] needed as a function of pitch'
;
; focus correction for pitch  vs za
;
ver,-15,15
for i=0,21,2 do begin &$
      focOff= -sin(!dtor*za[i]) * radOptCenIn * $
             sin(p *!dtor) * scaleTr         &$
    if i eq 0 then  begin &$
        plot,p,focOff,xstyle=1,ystyle=1,xtitle='pitch [deg]',$
        ytitle='td motion [in]',$
title='focus correction pitch vs pitch for za 0->20 (2deg steps. dash=20)' &$
    endif else begin &$
        if (i eq 20) then begin &$
            oplot,p,focOff,linestyle=2 &$
        endif else begin &$
            oplot,p,focOff &$
        endelse &$
    endelse &$
endfor
end
