;+
;NAME:
;pltdcorcmp - compute data for the pltdcor routine.
;SYNTAX:pltdcorcmp,pitch,roll,focus,tdposition
;ARGS: note
;RETURNS:
;   pitch[360,41]: float pitch error (degrees) on az,za grid 
;    roll[360,41]: float roll  error (degrees) on az,za grid 
;   focus[360,41]: float focus error (inches) on az,za grid 
;tdposition[3,360,41]: float tiedown position (inches) on az,za grid 
;DESCRIPTION:
;   pltdcorcmp computes the pitch, roll, focuserr, and then tiedown 
;positions that correct for these errors. This data is then passed to
;pltdcor  so it doesn't have to be recomputed on each all to pltdcor
;   The data is computed on an az,za grid of (360,41). Az=0..359 in 1 deg
;steps and za 0..20 with .5 degree steps.1
;The temperature used is the reference temp (usually 72 degrees).
;
;Before calling this routine, you should:
;@prfinit
;@tdinit
;-
pro pltdcorcmp,pitch,roll,focus,tdposition
;
    forward_function tdcor,prfit2deval
    prfit2dio,prfit2d
    mkazzagrid,az,za
    za=reform(za,360*41L)
    az=reform(az,360*41L)
    pitch=reform(prfit2deval(prfit2d,az,za),360,41)
    roll =reform(prfit2deval(prfit2d,az,za,/roll),360,41)
;
;   make za<2 --> za2 until we get better data down below
;   make za>19.5 == 19.5
;
    for i=0,3 do begin
        pitch[*,i]=pitch[*,4]
         roll[*,i]=roll[*,4]
    endfor
    pitch[*,40]=pitch[*,39]
    roll[*,40]=roll[*,39]
    focus=reform(focerr(az,za),360,41)
;
    tdposition=reform(tdcor(az,za,reform(pitch,360*41L),reform(roll,360*41L)),$
        3,360,41)
    return
end
