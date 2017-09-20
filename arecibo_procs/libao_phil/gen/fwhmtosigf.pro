;+
;NAME:
;fwhmtosigf - convert factor fwhm to sigma 
;SYNTAX: scl=fwhmtosigf(div2=div2)
;KEYWORDS:
;div2:     if set then return 1/(sqrt(8*log(2))
;DESCRIPTION:
;	Returns factor to go from fwhm to sigma for a 
;gaussian of:  y=a0(x^2/sig^2) 
;	If div2 keyword is set then return factor for:
;    y=a0*exp(.5* x^2/sig^2)
;-
function fwhmtosigf,div2=div2
    if keyword_set(div2) then begin
        return,1.D/(sqrt(8D*alog(2.)))
    endif else begin
        return,1.D/(2.D*sqrt(alog(2.)))
    endelse

end
