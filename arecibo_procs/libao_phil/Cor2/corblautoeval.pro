;+
;NAME:
;corblautoeval - evaluate corblauto fit
; 
;SYNTAX:  yfit=corblautoeval(x,coef,sbc=sbc,pol=pol)
;ARGS:   
;    x[n]:  float   xvalue to fit . Full scale should be 0. to 1.
;   coefI:  {}      coef struct returned by corblauto
;KEYWORDS:
;   sbc:    int     sbc to eval. default is 1. count 1..n
;   pol     int     pol to eval. default is 1. count 1,2
;RETURNS:
;   yfit[n]: float  the fit evaluated at x
;
;DESCRIPTION:
;   corblauto fits a polynomial and harmonic function returning the
;fit coeficients in coef. This routine will evaluate the fit at the
;specified points x[n]. x should go 0 to 1. for full scale.
;SEE ALSO: corblauto
;-
;history:
;
function corblautoeval,x,coefI,sbc=sbc,pol=pol
; 
; for now just do the 
;
    ipol=(n_elements(pol) ne 0) ? pol-1 : 0
    ipol=(ipol > 0) 
    ipol=(ipol < 1) 
    isbc=(n_elements(sbc) ne 0) ? sbc - 1 : 0
    isbc=(isbc > 0) 
    isbc=(isbc < 7) 
    xx=!pi*(2.*x - 1)
    deg =coefI.deg
    fsin=coefI.fsin
    z=poly(xx,coefI.coefAr[0:coefI.deg,ipol,isbc])
    if fsin gt 0 then begin
        ii=deg+1
        hcoef=reform(coefI.coefAr[ii:ii+fsin*2-1,ipol,isbc],2,fsin)
        for i=1,fsin do begin &$
            z=z + hcoef[0,i-1]*cos(i*xx) + hcoef[1,i-1]*sin(i*xx) &$
        endfor 
    endif
    return,z
end

