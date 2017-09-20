; 
;NAME:
;corfrq - compute the freq/vel array for a spectra
;
;SYNTAX:  retArr=corfrq(hdr,retvel=retvel,retrest=retrest)
;
;ARGS:  
;         hdr: header for this board
;
;KEYWORDS:
;         retvel : if not equal to zero, then return velocity rather 
;                   than frequency array
;         retrest: if not equal to zero, then return the rest frequency
;                  for the object being observered rather than the 
;                  topocentric frequency.
;
;RETURNS:
;           retArr: Array of floating point frequencies or velocities.
;              
;DESCRIPTION:
;
;   Compute the topocentric frequency array (in Mhz) for the correlator board
; corresponding to the header (hdr) passed in. If the keyword retvel 
; is set (not equal to zero) then return the velocity (optical definition).
; If the keyword retrest is set, then return the rest frequency of the object
; rather than the topocentric frequency.
; The array returned (retArr) will have the same number of elements
; as a single output sub correlator. 
;
;   The order of the data  assumes that the spectral channels are in
; increasing frequency order (corget always returns the data this way).
; If the spectra are spDat[2048] and then retAr[0] will be the lowest
; frequecy or the highest velocity.
;
;EXAMPLE:
;   .. assume 2 boards used, pola,b per board
;   corget,lun,b
;   frqArr=corfrq(b.b1.h)
;   frqArrRest=corfrq(b.b1.h,/rest)
;   velArr=corfrq(b.b1.h,/retvel)
;   plot,frqArr,b.b1.d[*,0] 
; 
;history:
;31jun00 - updated to new corget format
;02jun00 - fixed velocity computation. for rfonly, need band center
;          rest frequency, no rest frequency of center of topocentric band.
;02jaug01- vel definition was backwards.
;was:  vel= c*(f/f0 - 1.) + obserVelProjected.. optical definition
;      if retvel ne 0 then x= c*(1.D - x/cfrRestMhz) + h.dop.velObsProj;
;new:  vel= c*(f0/f - 1.) + obserVelProjected.. optical definition
;       if retvel ne 0 then x= c*(cfrRestMhz/x -1.D) + h.dop.velObsProj;
;18jun04- <pjp001>fixed projected observer velocity to work in the relativistic
;         case (thanks to chris salter...)
;   
function corfrq,h,retvel=retvel,retrest=retrest,wb=wb

;    on_error,1
;
;   note below crpix1 is zero based.. eventually we'll change it to 1 based
;   note this needs to be fixed when the crpix1 changes..
;
    usewb=keyword_set(wb)
    usev1= (h[0].version eq '1.0')
    a=size(h[0].(0))
    if (n_elements(retvel) eq 0) then retvel=0 ;return vel or freq
    if (n_elements(retrest) eq 0) then retrest=0 ;return rest freq
;
    if not usewb then begin
		nchancmp = round(h[0].bandwid/h[0].cdelt1)
		smo      = (nchancmp lt 5000)
        nchan    = (usev1)?7935L: (not smo)? 7679L : 1097L 
        cenChan0 = (usev1)?3967L: (not smo)? 3839L : 548L ; 0 based
        binWd    =h[0].cdelt1*1d-6
        cfrTopMhz =h[0].crval1*1d-6
    endif else begin
        nchan    = (usev1)?256L: 512L
        cenChan0 = (usev1)?128 : 256L
        binWd     =h[0].g_wdelt*1d-6
        cfrTopMhz =h[0].g_wcenter*1d-6
    endelse
;
    return,(findgen(nchan)-cenChan0)*binWd + cfrTopMhz
end
