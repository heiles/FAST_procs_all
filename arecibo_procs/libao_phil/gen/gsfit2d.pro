;+
;NAME:
;gsfit2d - cross pattern 2d fit to total power az,za stripsI
;SYNTAX: fitCoef=gsfit2d,az,za,z,initCoef,linearza=linearza,zfit=zfit,$
;                covar=covar,sigCoef=sigCoef,chisq=chisq,sigma=sigma,$
;                trouble=trouble,weights=weights
;ARGS:
;       az[npts]: az pos (offsets from center) in gcdeg all pnts in pat
;       za[npts]: za pos (offsets from center) in gcdeg all pnts in pat
;        z[npts]: measured data points
;    initCoef[m]: float. coef to fit for. first guess
;    fitCoef[m]:  float coef from fit
;KEYWORDS:
;       linearza  : if true then include a linear term in za (a7)
;       zfit[npts]: float return fit evaluated at input points
;       sigma=sigma : sigma for fit  
;       covar[10,10]: covariance matrix
;       sigCoef[10] : sigmas for coef.
;       chisq       : float ..
;       weights[npts]: float weights 
;       trouble     : 0 converged,
;                    -1 chisq infinite,
;                    -2 flamdacount>30*10/flstep
;                    -3 iteration > iterationmax def. 20
;                    -4 alpha/c not finite.. probably 0 in partial deriv
;       nostop      : if set then if trouble=-4 then don't stop, just return
;                     with trouble=-4
;DESCRIPTION:
; Fit to the function:
;
;z(x,y)= a0 + a1*exp[-xp^2/sigxp^2 - yp^2/sigyp^2] 
;If linearza is set then fit to:
;z(x,y)= a0 + a1*exp[-xp^2/sigxp^2 - yp^2/sigyp^2] + a7*za
;
;You need to give the coef initial values when the routine is called.
;The units are:
;a0 - constant
;a1 : amplitude
;a2 : xoffset ,az coord direction offset is az units
;a3 : yoffset ,za coord direction offset in za units
;a4 : sigx^2  ,in prime coordinate system: fwhm az units
;a5 : sigy^2  ,in prime coordinate system: fwhm za units
;a6 : theta   ,rotate unprimed to primed aligned along ellipsoid of beam,Deg
;a7 : zaslope ,The za slope in amplitude units per za unit
;
;xm=(x-x0)
;ym=(y-y0)
;xp = xm*cos(th)  + ym*sin(th)
;yp =-xm*sin(th)  + ym*cos(th)
;
; angle theta rotates from az,za to axes aligned with the major axis
; of the beam elipse
; 
;The x,y values are passed via a common block. The call passes in 
;an index to this common block.
;
; The fit is done in the units passed in (az,za). They should be
;greatcircle units with the same scale (don't mix hrs and deg)
;-
; 
;NAME:
;gsfit2dFunc -  cross pattern 2d fit to total power I
;
;DESCRIPTION:
;a0 - constant
;a1 : amplitude
;a2 : xoffset ,az coord direction
;a3 : yoffset ,za coord direction
;a4 : sigx^2  ,in prime coordinate system
;a5 : sigy^2  ,in prime coordinate system ;a6 : theta   ,rotate unprimed to primed aligned along ellipsoid of beam,Rd
;a7 : slope   ,optional fit for slope of Y (usually za)
;              if lineary is set in common block
;
;z(x,y)= a0 + a1*exp[-xp^2/sigxp^2* - yp^2/sigyp^2*]
;xm=(x-x0)
;ym=(y-y0)
;xp = xm*cos(th)  + ym*sin(th)
;yp =-xm*sin(th)  + ym*cos(th)
;
; angle theta rotates from az,za to axes aligned with the major axis
; of the beam elipse
;
;The x,y values are passed via a common block. The call passes in 
;an index to this common block. This routine is used by gsfit2d
;
; 
pro gsfit2dFunc,i,a,z,pder
;
common  comgsfit2d,comgsfit2dx,comgsfit2dy,lineary
;
;   get the x,y values in the prime system (aligned with the ellipitcal beam).
;
;   angles for rotation 
;
    costh =cos(a[6])
    sinth =sin(a[6])
    xm =comgsfit2dx[i]-a[2]
    ym =comgsfit2dy[i]-a[3]
    xp = xm*costh  + ym*sinth
    yp =-xm*sinth  + ym*costh
    sigX2=(1d-16 > a[4])
    sigY2=(1d-16 > a[5])
    if lineary then  begin
        z=a[0] + a[7]*comgsfit2dy[i] + a[1]*exp(-(xp*xp)/sigX2 - (yp*yp)/sigY2)
    endif else begin
        z=a[0] + a[1]*exp(-(xp*xp)/sigX2 - (yp*yp)/sigY2)
    endelse
    return
end
function  gsfit2d,az,za,z,a,zfit=zfit,covar=covar,sigCoef=sigCoef,chisq=chisq,$
                 sigma=sigma,trouble=trouble,cfplot=cfplot,nterms=nterms,$
                 weights=weights,cfparms=cfparms,linearza=linearza,$
                 nostop=nostop,itmax=itmax
;
common  comgsfit2d ,comgsfit2dx,comgsfit2dy,lineary
    
    flambdastep=10.             ; default
    fwhm2tosig2=1.D/(4.D*alog(2.)); fwhm^2 to sig^2
	if n_elements(itmax) eq 0 then itmax    =20                ; default
    s=size(az)
	if s[0] eq 1 then begin
    	pntstp=s[1]
    	pnttot=s[1]
	endif else begin
    	pntstp=s[1]
    	pnttot=s[1]*s[2]
	endelse
    comgsfit2dx=reform(az,pnttot)  ; in fwhm
    comgsfit2dy=reform(za,pnttot)  ;
    lindar=lindgen(pnttot)
    ad=double(a)
    if not keyword_set(weights) then begin
        weightsl=dblarr(pnttot)+1.D
    endif else begin
        weightsl=weights*1.D
    endelse
    lineary=0
    if keyword_set(linearza) then  lineary=1
;
;   change fwhm to sig^2 for fit
;
;   make sure the two fwhm are a little different so the
;   theta fit works..
;
    if ad[4] eq ad[5] then begin
        ad[4]=ad[4]*.99
        ad[5]=ad[5]*1.01
    endif
    fwhm=ad[4]
    ad[4]=fwhm*fwhm*fwhm2tosig2
    fwhm=ad[5]
    ad[5]=fwhm*fwhm*fwhm2tosig2
    ad[6]=ad[6]*!dtor
    zloc=reform(z,pnttot)
    zfit=curvefitpp(lindar,zloc,weightsl,ad,sigCoef,chisq=chisq,$
            function_name='gsfit2dfunc',itmax=itmax,tol=tol,nostop=nostop,$
            covar=covar,flambdastep=flambdastep,/noderivative,trouble=trouble,$
            cfplot=cfplot,cfparms=cfparms)
;
;   fix up ..
;
    ad[4]= sqrt(ad[4]/fwhm2tosig2)  ; back to fwhm
    ad[5]= sqrt(ad[5]/fwhm2tosig2)  ; back to fwhm
    ad[6]=ad[6]*!radeg mod 360.
    sigma=(rms(zfit-zloc,/quiet))[1]
    return,ad
end
