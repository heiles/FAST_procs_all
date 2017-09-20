;+
;NAME:
; tdcor - compute the td positions to correct for pitch,roll, and focus
;
; SYNTAX:
;  tdposition=tdcor(az,za,p,r,refTemp=refTemp,refPos=refPos,focus=focus,$
;                   temp=temp)
;
;  ARGS:
;  az[npts]:float  azimuth in degrees
;  za[npts]:float  za   in degrees
;  p[npts] :float  pitch error at az,za in degrees
;  r[npts] :float  roll  error at az,za in degrees
;  KEYWORDS:
; refPos[3]:float  use this as the tiedown ref position at ref temp instead
;                  of the default. The default is measured at 72 degF.
;   refTemp:float  reference temperature for the reference position.
;                  Default is 72. This temp should correspond to the
;                  refPos
;focus[npts]:float use this array for focus error, rather then the standard
;     temp:int     if set then include the platform vertical motion from
;                  temperature. It will be measured relative to the 
;                  refTemp,refPosition
;
; RETURNS:
;      tdposition[3,npts]  tdposition for each point
;
; DESCRIPTION:
; This routine computes the tiedown motion needed to correct for
; a pitch,roll, focus error at the requested temperature and positions. It then
; adds this to the reference position to return the actual tiedown positions
; after correction. If the
; dome is measured to have a pitch error of .1 degrees, we end up moving it
; by -.1 degrees. This routines wants .1 as the input (the current error,
; not the requested motion).
;
;10may00 - updated focus computation *cos(za) to 1/cos(za) 
;-
function tdcor,az,za,p,r,reftemp=reftemp,refpos=refpos,focus=focus,temp=temp
;
    forward_function focerr,tdref

        
    npts=(size(az))[1]
    tdpos=fltarr(3,npts)
    azrd=az*!dtor
    zard=za*!dtor
;
;  mikes constants
;
    tdparms,tdRadiusHor=tdRadiusHor,$
            refTdPos=refposloc,$
            refTemp =refTempLoc,$
            rotScale=scaleRot,$
            trScale=scaleTr,$
        plInPerDegF=plInPerDegF,$
                  Sscale=S 
    radOptCenIn= 435.*12.       ;/* radius optical center to focus*/
    offset  =0.;
    if n_elements(refpos) eq  0 then refpos=refPosLoc
    if n_elements(reftemp) eq 0 then refTemp=refTempLoc
;
;   azimuth of each td
;
    azTdRd=fltarr(3)
    azTdRd[0]= 2.87 *  !dtor
    azTdRd[1]= 122.87 * !dtor
    azTdRd[2]= 242.87 * !dtor
;
;
;To *correct* for pitch and roll, pull:
;
;TdPos(i) [expr (cos(Az - TdAz(i)) * P + sin(Az - TdAz(i)) * R) * S
;There is also a focus correction to correct for pulling down the dome
;at high zenith angle:
;TdPos[i] -= sin(za - off) * ROC * sin(P) * TDS2; same for all tiedowns.
;off is due to the difference between the pointing za and the center of the dome
;for the focus correction.  Is it zero?
;
;   focErr - radial focus error, project to vertical, convert td motion
;          
    if (n_elements(focus) eq 0 ) then begin
        focErrV=(focerr(az,za)/cos(zard))*scaleTr   ;
    endif else begin
        focErrV=(focus/cos(zard))*scaleTr   ;
    endelse
; 
;    The pitch correction moved us out of focus, compensate for it..
;    probably should be tan(pitch) but differs by < .0001 up to .3 degrees pitch..
;   
    focOff= -sin(!dtor*(za - offset)) * radOptCenIn * $
             sin(p *!dtor) * scaleTr        ;
    focusAll=focOff + focErrV ; 
    if n_elements(temp) ne 0 then begin
        tempCor= (temp - refTemp)*(scaleTr)*(plInPerDegF);<0 for pos temp
    endif else begin
        tempCor=0.
    endelse
;
;   compute the td positions
;
    for i=0,2 do begin
        tdPos[i,*]=  (cos(azRd - azTdRd[i])*p +     $
                     sin(azRd - azTdRd[i])*r ) * S + $
                     focusAll +  refPos[i] + tempCor
    endfor
    return,tdPos
end
