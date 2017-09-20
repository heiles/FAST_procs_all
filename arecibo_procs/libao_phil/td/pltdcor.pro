;+
;NAME:
;pltdcor - plot the tiedown correction for prf over a az,za grid.
;SYNTAX:pltdcor,pitchdata,rolldata,tdfocusdata,tdposdatadata,td=td,focrad=focr,
;               focrp=focrp,focp=focp,pitch=pitch,roll=roll,prq=prq,ver=ver,
;               pitp=pitp,rolp=rolp,note3=note3,oplot=oplot
;ARGS:
; pitchdata[360,41]: float the computed pitch on the az,za grid
;  rolldata[360,41]: float the computed roll on az,za grid
;  focusdata[360,41]: float the computed focus error on az,za grid
;  tdposdatadata[3,360,41]: float the computed tiedown positions on the az,za
;                       grid.   
;KEYWORDS:
;   td   : int  12,4, or 8. If provided then plot the relative motion 
;               of this tiedown in inches (from the reference position).
;   focr : if set then plot radial focus error inches
;   focrp: if set then plot radial focus projected to td inches
;   pitch: if set then plot pitch angle vs az
;   roll : if set then plot roll angle vs az
;   pitp : int 12,4,or 8 if provided, then plot pitch projected to td inches
;              for the requested td.
;   rolp : int 12,4,or 8. if provided, then plot roll projected to td inches
;              for the requested td.
;   prq   - if set then plot pitch,roll added in quadtrature versus vs az
;   note3 - string place note on line 3
;   oplot - overplot on whatever was there, no labels either
;DESCRIPTION:
;   This routine will make various plots of pitch,roll, focus, and tiedown
;position that will correct for the pitch roll and focus. It assumes that
;the pitch, roll errors have already been computed and that the td corrections
;have already been computed on a (360,41) grid of az za (az:0..359, za:0 to 20
;degrees za in .5 degree steps). Use pltdcorcmp() to do this computation
;before calling this routine.
;
;This routine requires that you do:
;@prfinit 
;prfit2dio,prfit2d  to input the 2d fit
;pltdcorcmp,prfit2d,pitchdata,rolldata,tdposdatadata
;
; once before calling the routine.
;
;-
;29jan02 switch to use 2d fit
pro pltdcor,pitchdata,rolldata,focusdata,tdposdata,td=td,focrad=focr,$
            focrp=focrP,focp=focp,pitch=pitch,roll=roll,prq=prq ,ver=ver,$
            pitp=pitp,rolp=rolp,note3=note3,oplot=oplot
;
    forward_function tdref,tdcor

    if n_elements(note3) eq 0 then note3=' '
    if n_elements(oplot) eq 0 then oplot=0
    mkazzagrid,az,za
    az=reform(az,360*41L)
    za=reform(za,360*41L)
;
    azTdRd=fltarr(3)
    azTdRd[0]=  2.87*!dtor
    azTdRd[1]=122.87*!dtor
    azTdRd[2]=242.87*!dtor
;
    tdparms,refTdPos=refPosTd,$
            tdRadiusHor=tdRadiusHor,$
            rotScale =scaleRot,$
            trScale =scaleTr,$
            slimits =lims,$
                  Sscale = S
    radOptCenIn= 435.*12.       ;/* radius optical center to focus*/

    hor,0,360
;
;   plot td 12 relative motion in inches vs az for za 1=20
;
    if  n_elements(td) ne 0  then begin
        case td of
             4:begin
           title='td 4 relative motion for pitch,roll, and focus correction' 
                ytitle='td 4 motion [in]' 
                i=1
               end
             8:begin
            title='td 8 relative motion for pitch,roll, and focus correction' 
                ytitle='td 8 motion [in]' 
                i=2
               end
            else:begin
            title='td12 relative motion for pitch,roll, and focus correction' 
                ytitle='td12 motion [in]' 
                i=0
                end
        endcase
        if n_elements(ver) ne 0 then begin
            ver,ver[0],ver[1]
        endif else begin
            ver,-25,15 
        endelse
        pltdcor1,reform(tdposdata[i,*,*]-refPosTd[i],360,41),title,ytitle,$
                    note3=note3,oplot=oplot
        yy=lims[1,i]-refPosTd[i]        ; max pos motion from ref
        oplot,[0,360],[yy,yy]
        yy=lims[0,i]-refPosTd[i]        ; max neg motion from ref
        oplot,[0,360],[yy,yy]
    endif
;
;   plot radial focus vs az for za 1-20
;
    if n_elements(focr) ne 0 then begin
        if n_elements(ver) ne 0 then begin
            ver,ver[0],ver[1]
        endif else begin
            ver,-2,4
        endelse
        title='radial focus Error [in] (+ --> pltfrm too high)'
        ytitle=title
        pltdcor1,focusdata,title,ytitle,note3=note3,oplot=oplot
    endif
;
;   plot radial focus projected to td inches
;
    if n_elements(focrp) ne 0 then begin
        if n_elements(ver) ne 0 then begin
            ver,ver[0],ver[1]
        endif else begin
            ver,-3,7
        endelse
        y=reform(reform(focusdata,360L*41L)/cos(za*!dtor)*scaletr  ,360,41)
        title='radial focus error projected to td'
        ytitle='inches at td (+ --> pltfrm is too high)'
        pltdcor1,y,title,ytitle,note3=note3,oplot=oplot
    endif
;
;   plot focus correction do to pitch motion projected to td inches
;
    if n_elements(focp) ne 0 then begin
        if n_elements(ver) ne 0 then begin
            ver,ver[0],ver[1]
        endif else begin
            ver,-12,2
        endelse
        y= reform(-sin(!dtor*za) * radOptCenIn * $
                      sin(reform(pitchdata,360L*41L)*!dtor)*scaleTr, 360,41)
        title='focus error from pitch projected to td'
        ytitle='inches at td (+ --> pltfrm is too high'
        pltdcor1,y,title,ytitle,note3=note3,oplot=oplot
    endif
;
;   plot pitch angle vs az
;
    if n_elements(pitch) ne 0 then begin
        if n_elements(ver) ne 0 then begin
            ver,ver[0],ver[1]
        endif else begin
            ver,-.1,.3
        endelse
        title='pitch error [deg]'
        ytitle=title
        pltdcor1,pitchdata,title,ytitle,note3=note3,oplot=oplot
    endif
;
;   plot Roll  angle vs az
;
    if n_elements(roll) ne 0 then begin
        if n_elements(ver) ne 0 then begin
            ver,ver[0],ver[1]
        endif else begin
            ver,-.3,.1
        endelse
        title='roll  error [deg]'
        ytitle=title
        pltdcor1,rolldata,title,ytitle,note3=note3,oplot=oplot
    endif
;
;   plot quadrature of pitch,roll  angle vs az
;
    if n_elements(prq) ne 0 then begin
        if n_elements(ver) ne 0 then begin
            ver,ver[0],ver[1]
        endif else begin
            ver,0,.4
        endelse
        title=' pitch + roll  error  added in quadrature [deg]'
        ytitle= ' degrees'
        y= reform(sqrt(reform(pitchdata,360L*41L)*reform(pitchdata,360*41) + $
                       reform(rolldata,360L*41)*reform(rolldata,360L*41)),360,41)
        pltdcor1,y,title,ytitle,note3=note3,oplot=oplot
    endif
;
; pitch projected to td inches
;
    if  n_elements(pitp) ne 0  then begin
        case pitp of
             4:begin
                title='pitch motion projected to td 4 inches' 
                ytitle='td 4 motion [in]' 
                i=1
               end
             8:begin
                title='pitch motion projected to td 8 inches' 
                ytitle='td 8 motion [in]' 
                i=2
               end
            else:begin
                title='pitch motion projected to td 12 inches' 
                ytitle='td12 motion [in]' 
                i=0
                end
        endcase
        y= reform((cos(az*!dtor - azTdRd[i])*reform(pitchdata,360L*41L)*S),$
            360,41)
        if n_elements(ver) ne 0 then begin
            ver,ver[0],ver[1]
        endif else begin
            ver,-15,15 
        endelse
        pltdcor1,y,title,ytitle,note3=note3,oplot=oplot
    endif
;
; roll projected to td inches
;
    if  n_elements(rolp) ne 0  then begin
        case rolp of
             4:begin
                title='roll motion projected to td 4 inches'
                ytitle='td 4 motion [in]'
                i=1
               end
             8:begin
                title='roll motion projected  to td 8 inches'
                ytitle='td 8 motion [in]'
                i=2
               end
            else:begin
                title='roll  motion projected to td 12 inches'
                ytitle='td12 motion [in]'
                i=0
                end
        endcase
        y= reform((sin(az*!dtor - azTdRd[i])*reform(rolldata,360L*41L)*S),360,41)
        if n_elements(ver) ne 0 then begin
            ver,ver[0],ver[1]
        endif else begin
            ver,-15,15
        endelse
        pltdcor1,y,title,ytitle,note3=note3,oplot=oplot
    endif
    return
end
