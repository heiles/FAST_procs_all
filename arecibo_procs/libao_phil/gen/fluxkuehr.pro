;+
;NAME:
;fluxkuehr - compute flux given kuehr et al. coefficients
;SYNTAX: flux=fluxkuehr(coef,freqMhz)
;ARGS:
;       coef[4]: float kuehr coefficients .. see below
;       freqM  : frequency in Mhz
;RETURNS:
;       flux   : in janskies
;DESCRIPTION:
;   Return the flux computed from the kuehr coef..
; (Kuehr et al., A+AS, 45, 367, (1981))
; log10(flux)= coef[0] + coef[1]*x + coef[2]*exp(-coef[3]*x)
; and x=log10(freqMhz)
;-
function fluxkuehr,coef,freqMhz
    x=alog10(double(freqMhz))
    return,10^(coef[0]+x*coef[1]+coef[2]*exp(coef[3]*x))
end
