;+
;NAME:
;chebeval - evaluate chebyshev polynomial
;SYNTAX: y=chebeval(a,b,coef,x)
;ARGS:
;     a : double    min value of xrange used for fit.
;     b : double    max value of xrange used for fit.
;coef[m]: double coefficients from fit.
;   x[n: double xvalues where polynomial should be evaluated.
;
;RETURNS:
;   y[n]: fit evaluated at the requested x values.
;DESCRIPTION:
;   Evaluate a chebyshev polynomial at the requested x values. These
;values should be within the x values used for the fit. The a,b
;parameters are the min,max x values used in the fit.
;SEE ALSO: chebfit()
;-
function chebeval,a,b,coef,x
    y=(2.D*x-a-b)/(b-a)
    y2=2.*y
    nx=n_elements(x)
    ncoef=n_elements(coef)
    Tnm1=dblarr(nx) +1.D
    Tn  =y
    f= coef[0]*tnm1 + coef[1]*tn
    for i=2,ncoef-1 do begin
        sv=tn
        TN= tN*y2 - TNm1
        f=f+coef[i]*tn
        tnm1=sv
    endfor
    return,f
end
