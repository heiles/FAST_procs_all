;
; output td pos for each az swing 2 thru 19.5 by 2
;
;@prfinit
;@tdinit
;
; psfiles created:
;'tdPosAbs.ps',/full
;'tdPosRel.ps',/full
;'prfVsAz.ps',/full
;'prfVsZa.ps',/full
;'prfMaxCor.ps',/full

forward_function tdlimits
hard=1
;
; this computes the errors
;
pltdcorcmp,pp,rr,ff,tdpos
;
	tdparms,trScal=scaleTr,$
			tdRadiusHor=tdRadiushor,$
			rotScale=scaleRot,$
			slimits=lims,$
			reftdPos=refpos,$
				   Sscale=S

  radOptCenIn= 435.*12.       ;/* radius optical center to focus*/

mkazzagrid,azgr,zagr
az=findgen(360)
za=findgen(41)*.5
hor,0,360
ver,-10,25
if hard then pscol,'tdPosAbs.ps',/full
!p.multi=[0,1,2]
k=0
for i=2,20,2 do begin &$
	tdposind=i*2	  &$			;they are in .5 deg steps..
	title=string(format='("tiedown position za:",i3," temp=72")',i) &$
	plot,az,tdpos[0,*,tdposind],xstyle=1,ystyle=1,color=1,$
		xtitle='az',ytitle='td position [i]',$
		title=title &$
	oplot,az,fltarr(360)+lims[0,0],color=1 &$
	oplot,az,fltarr(360)+lims[1,0],color=1 &$
	if k mod 2 eq 0 then note,1.5,'line:td12,dash:td4,dash-dot:td8' &$
		for j=1,2 do begin &$
			oplot,az,tdpos[j,*,tdposind],linestyle=j+1,color=j+1 &$
			oplot,az,fltarr(360)+lims[0,j],color=j+1,linestyle=j+1 &$
			oplot,az,fltarr(360)+lims[1,j],color=j+1,linestyle=j+1 &$
		endfor &$
	k=k+1 &$
endfor
if hard then hardcopy
if hard then pscol,'tdPosRel.ps',/full
!p.multi=[0,1,2]
pltdcor,pp,rr,ff,tdpos,td=12 ,note3=note3
pltdcor,pp,rr,ff,tdpos,td=4 ,note3=note3
pltdcor,pp,rr,ff,tdpos,td=8 ,note3=note3
if hard then hardcopy
;
; output pitch,roll,focus
note3='aug01, temp=72  (za20=...)'
;
;if hard then pagesize
if hard then pscol,'prfVsAz.ps',/full
!p.multi=[0,1,2]
pltdcor,pp,rr,rr,tdpos,/pitch,/roll,/prq,note3=note3
pltdcor,pp,rr,ff,tdpos,/focrad,/focrp,/focp,note3=note3
if hard then hardcopy
;
; output pitch vs za for all az
;
if hard then pscol,'prfVsZa.ps',/full
!p.multi=[0,1,2]
ver,-.05,.25
hor,0,20
for i=0,359,10 do begin &$
	if  i eq 0 then begin &$
		plot,za,pp[i,*],xstyle=1,ystyle=1, $
			xtitle='za',ytitle='pitch [deg]',$
		title='Pitch Error vs za for azimuths 0-360' &$
	endif else begin &$
		oplot,za,pp[i,*] &$
	endelse &$
endfor
;
; output roll vs za for all az
;
ver,-.3,.0
for i=0,359,10 do begin &$
	if  i eq 0 then begin &$
		plot,za,rr[i,*],xstyle=1,ystyle=1, $
			xtitle='za',ytitle='Roll [deg]',$
		title='Roll Error vs za for azimuths 0-360' &$
	endif else begin &$
		oplot,za,rr[i,*] &$
	endelse &$
endfor
;
;   plot radial focus vs za for az in 10 deg steps
;
	oplot=0
	note3='09aug01 temp=72'
    ver,-2,4
    title='radial focus error [in] (+ --> pltfrm too high)'
    ytitle=title
	for i=0,359,10 do begin &$
	if  i eq 0 then begin &$
		plot,za,ff[i,*],xstyle=1,ystyle=1, $
			xtitle='za',ytitle=ytitle,$
    title='radial focus error [in] vs za for az:0 to 360' &$
	note,3,note3 &$
	endif else begin &$
		oplot,za,ff[i,*] &$
	endelse &$
endfor
;
;   plot radial focus error projected to td inches
;
	scaleTr=1.74
    ver,-3,7
	hor
    y=reform(ff*cos(reform(zagr,360*41L)*!dtor)*scaletr  ,360,41)
    ytitle='td inches (+ --> pltfrm too high) '
for i=0,359,10 do begin &$
	if  i eq 0 then begin &$
		plot,za,y[i,*],xstyle=1,ystyle=1, $
			xtitle='za',ytitle=ytitle,$
    title='radial focus error projected to td [in] vs za for az:0 to 360' &$
;	note,3,note3 &$
	endif else begin &$
		oplot,za,y[i,*] &$
	endelse &$
endfor
;
;   plot radial focus from pitch  vs za
;
    ver,-9,3
    y= reform(-sin(!dtor*reform(zagr,360*41L)) * radOptCenIn * $
                      sin(reform(pp,360*41L)*!dtor)*scaleTr, 360,41)

    ytitle='td inches (+ --> pltfrm too high)'
for i=0,359,10 do begin &$
    if  i eq 0 then begin &$
        plot,za,y[i,*],xstyle=1,ystyle=1, $
            xtitle='za',ytitle=ytitle,$
    title='focus error from pitch projected to td [in] vs za' &$
    note,3,note3 &$
    endif else begin &$
        oplot,za,y[i,*] &$
    endelse &$
endfor
if hard then hardcopy
if hard then pscol,'prfMaxCor.ps',/full
!p.multi=[0,1,2]
;
; plot tdmotion vs pitch
;
ptmp=(findgen(21) - 10.)/10. * .3
tdPostmp=ptmp*S
hor,-.3,.3
ver,-15,15
plot,ptmp,tdPostmp,xstyle=1,ystyle=1,$
    xtitle='pitch [deg]',ytitle='td motion [in] needed',$
    title='max td motion [in] needed as a function of pitch'
;
; focus correction for pitch  vs za
;
ver,-15,15
zatmp=findgen(21)
for i=0,21,2 do begin &$
      focOff= -sin(!dtor*zatmp[i]) * radOptCenIn * $
             sin(ptmp *!dtor) * scaleTr         &$
    if i eq 0 then  begin &$
        plot,ptmp,focOff,xstyle=1,ystyle=1,xtitle='pitch [deg]',$
        ytitle='td motion [in]',$
title='focus correction pitch vs pitch for za 0->20 (2deg steps. dash=20)' &$
    endif else begin &$
        if (i eq 20) then begin &$
            oplot,ptmp,focOff,linestyle=2 &$
        endif else begin &$
            oplot,ptmp,focOff &$
        endelse &$
    endelse &$
endfor
if hard then hardcopy
x
end
