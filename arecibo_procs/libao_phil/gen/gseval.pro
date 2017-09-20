;+
;NAME:
; gseval - evaluate a gausian at the requested positions. 
; SYNTAX: val=gseval(fwhm,position)
; ARGS:
;     fwhm  :   float.. full width at half maximum of gaussian.
;     position:  float. to evaluate (same units as fwhm
; RETURNS:
;     vals  :  evaluated at position.
;Assume gaussian is unit height
;-
function gseval,w,p
    
    sigma2=(w*w)*1.D/(4.* 0.693147180560D)  ;fwhm**2 to sig**2 (1/(4*ln2)
    return,  exp(-(p)^2/sigma2) > 1e-14
end
