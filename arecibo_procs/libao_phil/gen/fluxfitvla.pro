;+
;NAME:
;fluxfitvla - return source flux using vla formula
;SYNTAX: flux=fluxfitvla(coef,freq)
;ARGS:
;   coef[3 or 4]:    float   coefficients for fit.
;      freq:    float   Frequency in Mhz.
;RETURNS:
;      flux:    float  flux in Janskies.
;
;DESCRIPTION:
;   Evaluate the function
; 
;log(s)= coef[0]+coef[1]*log(freq)+coef[2]*(log(freq)^2)
;
;This can be used for the standard calibrators: 3C286,3C48, and 3C147.
;You must input the coefficients for each source.
;It is taken from the vla calibration manual (chris salters copy
;or the web). 
;There are no corrections to baars et scale done here.
;If number of coef > 3 then the newer fit (circa 1999) will be used
;that includes freq^3 term).
;-
function fluxfitvla,coef,freq

    if n_elements(coef) eq 3 then begin
        logfreq=alog10(freq)
    return,10^(coef[0]+coef[1]*logfreq+coef[2]*(logfreq^2))
    endif else begin
        logfreq=alog10(freq*.001D)
        
    return,10^(coef[0]+coef[1]*logfreq+coef[2]*(logfreq^2)+coef[3]*(logfreq^3))
    endelse
end

