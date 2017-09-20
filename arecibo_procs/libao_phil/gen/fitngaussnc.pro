;..............................................................................
;+
;NAME:
;fitngaussnc - fit n gaussians (no coma)
;SYNTAX: coef=fitngaussnc(x,y,ngauss,coefInit,chisq=chisq,sigmaCoef=sigmaCoef,
;                       weights=weights,yfit=yfit,covar=covar,trouble=trouble,
;                       
;ARGS:
;   x[npts]:    inpependent data
;   y[npts]:    dependent data
;   ngauss :    int the number of gaussians to fit for 1 to 3
;   coefInit[m] initial values for coef.
;KEYWORDS:
;   weights[npts] : for data. default is unity
;   trouble       : int    0 converged ok
;                         -1 chisq infinite
;                         -2 flambdacount > max=30 *10/flambdaste
;                         -3 iterdone >itmax(def 20)
;                         -4 divide by zero on partials
; _extra=e
;       cfplot    : if set, then curveFit will plot each strip
;       cfparms   : if set, then curveFit will print input parms
;   flambdastep   : float. how much we decrease step curvature matrix when
;   tol           : float. when chisq decreases by this amount, done..def:.001
;   itmax         : int..  iterations max. default:40
;   iter          : int..  iterations done.
;   noderiv       : if set then have let the routine compute the derivatives
;                   from differences rather than from the analytic formula.
;
;RETURNS   :
;       coef[m]     fit coef..
;keywords:
;       yfit[npts]: fit evaluated at input values
;       chisq     : double (y-yfit)^2/(npts-mcoef)
;       sigmaCoef[m]:formal errors in coef. sqrt(diag of matrix*chisq)
;       covar[m,m]  : covariance matrix
;DESCRIPTION:
;   fit the function:
;   y= a0 +a1*x + a2*exp[(x-a3)^2/a4 +
;                 a6*exp((x-a7)^2/a8 +
;                 a9*exp((x-a10)^2/a11
; where:
; a0= constant
; a1= linear in x
; a2=Ampl      1st gaussian
; a3=Mean (offset error)
; a4=sigma   input as fwhm in units of x
;
; a5=Ampl      2nd guassian 
; a6=Mean
; a7=sigma     input as fwhm
;
; a8 =Ampl     3rd gaussian
; a9 =Mean
; a10=sigma input as fwhm
;
;   The variable ngauss determines how many gaussians to fit for. This
;routine is similar to fitngauss but it does not have the coma
; parameter (which tends to diverge).
;-
;mods:
; 07aug04 - make sure that the coefinit array that is
;           used matches the number of gauss fits requested.
;           The length of the coef array is used by the eval function
;           to determine the number of gaussians to fit.
;**********************-
;+
;NAME:
; fitngaussncfunc - function for fitting n gaussians
; SYNTAX:
;   fitngaussncfunc,x,a,f,pder
;
; ARGS:
;    x[npts]          : independant variable
;    a[2+3*ngauss]    : parameters to fit for
;    f[npts] : return value of function here
;    pder[2+3*ngauss] :return partial derivatives with respect to each param
;
; DESCRIPTION:
;  evaluate the function and optionally it's partial derivatives
;  for the curvefit routine of idl:
;
;  f(x)= a0 + a1*x + a2*exp[ (x-a3)**2 )]
;                             -------------------- + n more gaussians
;                               a4^2
; a0= constant
; a1= linear in x
; a2=Ampl
; a3=Mean
; a4=sigma
;
; a5=Ampl
; a6=Mean
; a7=sigma
;
; a8=Ampl
; a9=Mean
; a10=sigma
;
; note that we are fitting for sigx  not sigx^2
;-
pro fitngaussncfunc,x,a,f,pder
    case (size(a))[1] of
        5: ngauss=1
        8: ngauss=2
       11: ngauss=3
     else: message,'fitngaussfunc. num coef is 5, 8, or 11'
    endcase
    xp1= (x-a[3])
    if a[4] ne 0.D then  begin
        a4=a[4]
        u1 =exp((-(xp1/a4)^2))
    endif else begin
        u1=0.
        a4=1.
    endelse
    if ngauss ge 2 then begin
        xp2= (x-a[6])
        if a[7] ne 0.D then begin
            a7=a[7]
            u2=exp(-((xp2/a7)^2))
        endif else begin
            u2=0.
            a7=1.
        endelse
        if  ngauss ge 3 then begin
            xp3= (x-a[9])
            if a[10] gt 0.D then begin
               a10= a[10]
               u3=exp((-(xp3/a10)^2))
            endif else begin
                u3=0.
                a10=1.
            endelse
        endif
    endif
    case ngauss of
    1:  f= a[0] + a[1]*x + a[2]*u1
    2:  f= a[0] + a[1]*x + a[2]*u1 + a[5]*u2
    3:  f= a[0] + a[1]*x + a[2]*u1 + a[5]*u2 + a[8]*u3
    endcase
;   plot,f
;   print,a[0:1]
;   print,a[2:4]
;   print,a[5:7]
;   stop
    if n_params() le 3 then  return
;
;   need partial derivatives
;
;   print,'partial'
;   help,pder
;
    a4sq=a4*a4
    npts  =(size(x))[1]
    nterms=(size(a))[1]
    pder=dblarr(npts,nterms)
    pder[*,0]= 1.D
    pder[*,1]= x
    pder[*,2]= u1                                      ;d/dAmp1
    pder[*,3]= 2.*a[2]*u1*(xp1)/(a4sq)            ;d/dMean
    pder[*,4]= 2.*a[2]*u1*((xp1/a4)^2)/(a4)         ;d/dsigma
    if ngauss ge 2 then begin
        a7sq=a7*a7
        pder[*,5]= u2                                  ;d/dAmp1
        pder[*,6]= 2.*a[5]*u2*(xp2)/(a7sq)             ;d/dMean
        pder[*,7]= 2.*a[5]*u2*((xp2/a7)^2)/(a7)      ;d/dsigma
        if ngauss ge 3 then begin
            a10sq=a10*a10
            pder[*,8] = u3                                      ;d/dAmp1
            pder[*,9] = 2.*a[8]*u3*(xp3)/(a10sq)        ;d/dMean
            pder[*,10]= 2.*a[8]*u3*((xp3/a10)^2)/(a10) ;d/dsigma
        endif
    endif
;   print,'partial'
;   help,pder
    return
end
;..........................................................
function fitngaussnc,x,y,ngauss,coefInit,chisq=chisq,sigmaCoef=sigmaCoef,$
                    weights=weights,yfit=yfit,covar=covar,tol=tol, $
                    flambdastep=flambdastep,itmax=itmax,iter=iter,$
                    trouble=trouble,_extra=e,noderiv=noderiv
;
;
    npts=(size(x))[1]
    if n_elements(weights) eq 0 then weights=dblarr(npts)+ 1.D
    if n_elements(trouble)       eq 0 then trouble=0
    if n_elements(noderiv)       eq 0 then noderiv=0
;
;   figure out the number of parameters
;
    nparams=2 + 3*ngauss
    sigmaCoef=dblarr(nparams)
    a=dblarr(nparams)
    a=coefinit[0:nparams-1]*1d
;
;   fix up fwhm -> sig^
;
    for ng=0,ngauss-1 do a[4+3*ng]= a[4+3*ng]*fwhmtosigf()
;
;   do the fit
;
    yfit=curvefitpp(x,y,weights,a,sigmaCoef,chisq=chisq,function_name=$
            'fitngaussncfunc',covar=covar,trouble=trouble,_extra=e,$
             flambdastep=flambdastep,itmax=itmax,iter=iter,$ 
             noderivative=noderiv)
;
;   compute the formal errors
;
    sigmaCoef=sqrt(chisq)*abs(sigmaCoef)
;
;   convert sigmas back to fwhm
;
    for ng=0,ngauss-1 do begin
        a[4+3*ng]= a[4+3*ng]/fwhmtosigf()
        sigmaCoef[4+3*ng]= sigmaCoef[4+3*ng]/fwhmtosigf()
    endfor
    return,a
end
