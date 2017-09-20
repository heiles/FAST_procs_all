;..............................................................................
;+
;NAME:
;fitngauss - fit n gaussians
;SYNTAX: coef=fitngauss(x,y,ngauss,coefInit,chisq=chisq,sigmaCoef=sigmaCoef,
;                       weights=weights,yfit=yfit,covar=covar,trouble=trouble)
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
;   y= a0 +a1*x + a3*exp[(x-a4)^2/a5*(1+alpha*x) +
;                 a6*exp((x-a7)^2/a8 +
;                 a9*exp((x-a10)^2/a11
; a0= constant
; a1= linear in x
; a2= alpha  skew first gaussian
; a3=Ampl
; a4=Mean (offset error)
; a5=sigma   input as fwhm in units of x
;
; a6=Ampl
; a7=Mean
; a8=sigma     input as fwhm
;
; a9=Ampl
; a10=Mean
; a11=sigma input as fwhm
;-
;**********************-
;+
;NAME:
; fitngaussfunc - function for fitting n gaussians
; SYNTAX:
;   fitngaussfunc,x,a,f,pder
;
; ARGS:
;    x[npts]          : independant variable
;    a[2+4*ngauss]    : parameters to fit for
;    f[npts] : return value of function here
;    pder[2+4*ngauss] :return partial derivatives with respect to each param
;
; DESCRIPTION:
;  evaluate the function and optionally it's partial derivatives
;  for the curvefit routine of idl:
;
;  f(x)= a0 + a1*x + a3*exp[ (x-a4)**2 * (1+a2*(x-a4))]
;                             -------------------- + n more gaussians
;                               a5^2
; a0= constant
; a1= linear in x
; a2=skew first gaussian
; a3=Ampl
; a4=Mean
; a5=sigma
;
; a6=Ampl
; a7=Mean
; a8=sigma
;
; a9=Ampl
; a10=Mean
; a11=sigma
;
; note that we are fitting for sigx  not sigx^2
;-
;mods:
; 07aug04 - make sure that the coefinit array that is
;           used matches the number of gauss fits requested.
;           The length of the coef array is used by the eval function
;           to determine the number of gaussians to fit.
;
pro fitngaussfunc,x,a,f,pder
    clipA2=.2
    case (size(a))[1] of
        6: ngauss=1
        9: ngauss=2
       12: ngauss=3
     else: message,'fitngaussfunc. num coef is 6, 9, or 12'
    endcase
    xp1= (x-a[4])
    if a[5] ne 0.D then  begin
        a[2]=(a[2] > (-.2))<.2  
        a[2]=0.
        a5=a[5]
        u1 =exp((-xp1*xp1*(1.d + a[2]*xp1))/(a5*a5))
    endif else begin
        u1=0.
        a5=1.
    endelse
    if ngauss ge 2 then begin
        xp2= (x-a[7])
        if a[8] ne 0.D then begin
            a8=a[8]
            u2=exp(-(xp2*xp2)/(a8*a8))
        endif else begin
            u2=0.
            a8=1.
        endelse
        if  ngauss ge 3 then begin
            xp3= (x-a[10])
            if a[11] gt 0.D then begin
               a11= a[11]
               u3=exp(-(xp3*xp3)/(a11*a11))
            endif else begin
                u3=0.
                a11=1.
            endelse
        endif
    endif
    case ngauss of
    1:  f= a[0] + a[1]*x + a[3]*u1
    2:  f= a[0] + a[1]*x + a[3]*u1 + a[6]*u2
    3:  f= a[0] + a[1]*x + a[3]*u1 + a[6]*u2 + a[9]*u3
    endcase
    if n_params() le 3 then  return
;
;   need partial derivatives
;
;   print,'partial'
;   help,pder
    a5sq=a5*a5
    npts  =(size(x))[1]
    nterms=(size(a))[1]
    pder=dblarr(npts,nterms)
    pder[*,0]= 1.D
    pder[*,1]= x
    pder[*,2]= a[3]*u1*(-xp1*xp1*xp1/a5sq)                    ;d/dalpha
    pder[*,3]= u1                                             ;d/dAmp1
    pder[*,4]= a[3]*u1*(xp1 * (3.*xp1*a[2] + 2.)/a5sq)        ;d/dMean
    pder[*,5]= a[3]*u1*2.*(xp1*xp1*(1.+a[2]*xp1)/(a5sq*a5))    ;d/dsigma
    if ngauss ge 2 then begin
        pder[*,6]= u2                                             ;d/dAmp1
        pder[*,7]= a[6]*u2*(2.*xp2)/(a8*a8)                      ;d/dMean
        pder[*,8]= a[6]*u2*2.*( xp2*xp2)/(a8*a8*a8)              ;d/dsigma
        if ngauss ge 3 then begin
        pder[*,9]=u3                                              ;d/dAmp1
        pder[*,10]=a[9]*u3*(2. *xp3)/(a11*a11)                    ;d/dMean
        pder[*,11]=a[9]*u3*2.*(xp3*xp3)/(a11*a11*a11)             ;d/dsigma
        endif
    endif
;   print,'partial'
;   help,pder
    return
end
;..........................................................
function fitngauss,x,y,ngauss,coefInit,chisq=chisq,sigmaCoef=sigmaCoef,$
                    weights=weights,yfit=yfit,covar=covar,tol=tol, $
                    flambdastep=flambdastep,itmax=itmax,iter=iter,$
                    trouble=trouble,_extra=e
;
;
    npts=(size(x))[1]
    if n_elements(weights) eq 0 then weights=dblarr(npts)+ 1.D
    if n_elements(trouble)       eq 0 then troulbe=0
;
;   compute number of parameters needed from ngauss
;
    nparams=3+3*ngauss
    sigmaCoef=dblarr(nparams)
    a=coefinit[0:nparams-1]*1d
;
;   fix up fwhm -> sig^
;
    for ng=0,ngauss-1 do a[5+3*ng]= a[5+3*ng]*fwhmtosigf()
;
;   do the fit
;
    yfit=curvefitpp(x,y,weights,a,sigmaCoef,chisq=chisq,function_name=$
            'fitngaussfunc',covar=covar,trouble=trouble,_extra=e,$
             flambdastep=flambdastep,itmax=itmax,iter=iter)

;           ,/noderivative)
;
;   compute the formal errors
;
    sigmaCoef=sqrt(chisq)*abs(sigmaCoef)
;
;   convert sigmas back to fwhm
;
    for ng=0,ngauss-1 do begin
        a[5+3*ng]= a[5+3*ng]/fwhmtosigf()
        sigmaCoef[5+3*ng]= sigmaCoef[5+3*ng]/fwhmtosigf()
    endfor
    return,a
end
