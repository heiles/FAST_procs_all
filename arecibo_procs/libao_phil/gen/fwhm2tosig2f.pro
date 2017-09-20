;+
;NAME:
;fwhm2tosig2f - FWHM^2 to sigma^2 factor.
;SYNTAX: fac=fwhm2tosig2f()
;ARGS:   none
;RETURNS:
;   fac:    float conversion factor.
;DESCRIPTION:
;   for a gaussian defined as:
;   y=A0*exp( -[(x-x0)/sig]^2) 
;   convert full width half max squared to sigma squared.
; If the gaussian is defined as:
;  
;   y=A0*exp( -.5*[(x-x0)/sig]^2) 
;  you need to multiply the returned value by .5
;-
function fwhm2tosig2f
    return,1.D/(4.D*alog(2.))
end
