;+
;NAME:
;fitsinnl - nonlinear least squares fit to a sin
;SYNTAX:   fitsinnl,x,y,weights,a,yfit,chisq,iter,sigma,tol=tol,itmax=itmax
;ARGS:
;    x[npts]: float  x values. The unit will determine the frequency 
;                     unit (eg. sec--> cycle/sec, min--> cycle/min).
;    y[npts]: float  measured data values
;    a[4]   : float  initial values for fit:
;                    a[0] constant,
;                    a[1] amplitude
;                    a[2] frequency cycles/(xunit)
;                    a[3] phase (fraction of a cycle)
;weights[npts]:float weights for each data point
;KEYWORDS:
;   tol  : float    tolerance for conversion. default 1e-3
;   itmax: int      max number of step iterations before non-convergence.
;   
;RETURNS:
;        a     - fitted coefficients
;        yfit  - fit value evalutated at x
;        chisq - chisq for fit 
;        iter  - number of iterations that were made
;        sigma[4] - sigmas for each coef.
;DESCRIPTION:
;   Do a non-linear least squares fit to a sin wave fitting for offset,
;amplitude, frequency, and phase. Use the idl routine curvefit().
;-
pro fitsinnl,x,y,weights,a,yfit,chisq,iter,sigma,tol=tol, itmax=itmax

    if n_elements(tol)   eq 0 then tol=1e-3
    if n_elements(itmax) eq 0 then itmax=20
    if n_elements(sigma) eq 0 then sigma=0.
    a[2]=a[2]*!pi*2.            ; hz to radians/sec
    a[3]=a[3]*!pi*2.            ; fract cycle to  radians
    yfit=curvefit(x,y,weights,a,sigma,chisq=chisq,$
               function_name='fitsinnlfunc',iter=iter,tol=tol,itmax=itmax)
    a[2]=a[2]/(2.*!pi)          ; to hz
    a[3]=a[3]/(2.*!pi)          ; to fraction of a cycle
    sigma[2]=sigma[2]/(2.*!pi)
    sigma[3]=sigma[3]/(2.*!pi)
    if  a[1] lt 0. then begin   ; neg amplitude, make positive, flip phase 
        a[1]=-a[1]
        a[3]=a[3] + .5          ; now fract of a cycle
    endif
    a[3]=a[3] mod (2.*!pi)      ; get rid of cycles in phase
    if a[3] lt 0. then a[3]=a[3] + 1.   ; make positive fraction of a cycle
    return
end
