;+
;NAME:
;gs - generate a gaussian
;SYNTAX: f=gs(len,height,fwhm,position)
;ARGS:
;        len:   int  .. length to make f. x values will be 0 thru len-1
;     height:   float.. height of the gaussian.
;     fwhm  :   float.. full width at half maximum. full range 0 to len-1
;   position:   float.. position for the peak (0..len-1)
; RETURNS:
;     computed gaussian as a double.
;-
function gs,len,h,w,p
    
    sigma2=(w*w)*1.D/(4.* 0.693147180560D)  ;fwhm**2 to sig**2 (1/(4*ln2)
    return,  double(h)*exp(-(dindgen(len)-p)^2/sigma2) > 1e-14
end
