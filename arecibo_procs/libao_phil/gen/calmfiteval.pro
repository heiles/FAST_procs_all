;
; evaluate a fit at a set of frequencies . if beyond edge, use edge value 
;
pro calmfiteval,freq,fit,calVal
;
;  map freq to fit range 0 to 1. 
;
    fmin=fit.frqmin
    fmax=fit.frqmax
    fspan=(fmax-fmin)
    x=(freq - fmin)/fspan
    x= (x > 0.) < 1.
    ya=corblautoeval(x,fit.fitI,pol=1)
    yb=corblautoeval(x,fit.fitI,pol=2)
    calval=reform([ya,yb],n_elements(ya),2)
    return
end
