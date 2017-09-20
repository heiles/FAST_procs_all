;+
;NAME:
;gsfit2dc - cross pattern 2d fit to az,za stripsI with coma
;SYNTAX: gsfit2dc,az,za,z,a,zfit=zfit,covar=covar,sigCoef=sigCoef,$
;                chisq=chisq,sigma=sigma,trouble=trouble
;ARGS:
;       az[npts]: az pos (offsets from center) in gcdeg all pnts in pat
;       za[npts]: za pos (offsets from center) in gcdeg all pnts in pat
;        z[npts]: measured data points
;        a[m]     : float. coef to fit for. first guess
;KEYWORDS:
;       zfit[npts]: float return fit evaluated at input points
;       sigma=sigma : sigma for fit  
;       covar[10,10]: covariance matrix
;       sigCoef[10] : sigmas for coef.
;       chisq       : float ..
;       trouble     : 0 converged,
;                    -1 chisq infinite,
;                    -2 flamdacount>30*10/flstep
;                    -3 iteration > iterationmax def. 20
;DESCRIPTION:
; Fit to the function:
;
;z(x,y)= a0 + a1*exp[-xp^2/sigxp^2*(1.+alphax*xpp) -
;                     yp^2/sigyp^2*(1.+alphay*ypp)]
;You need to give the coef initial values when the routine is called.
;The units are:
;a0 - constant
;a1 : amplitude
;a2 : xoffset ,az coord direction units:amin
;a3 : yoffset ,za coord direction      :amin
;a4 : sigx^2  ,in prime coordinate system: fwhm amin
;a5 : sigy^2  ,in prime coordinate system: fwhm amin
;a6 : alphax  ,comma in pp system aligned along coma direction
;a7 : alphay  ,comma in pp system aligned along coma direction
;a8 : theta   ,rotate unprimed to primed aligned along ellipsoid of beam,Deg
;a9 : thetap  ,rotate primed to coma aligned, Deg
;
;z(x,y)= a0 + a1*exp[-xp^2/sigxp^2*(1.+alphax*xpp) -
;                     yp^2/sigyp^2*(1.+alphay*ypp)]
;xm=(x-x0)
;ym=(y-y0)
;xp = xm*cos(th)  + ym*sin(th)
;yp =-xm*sin(th)  + ym*cos(th)
;xpp= xp*cos(thp) + xp*sin(thp)
;ypp=-xp*sin(thp) + yp*cos(thp)
;
; angle theta rotates from az,za to axes aligned with the major axis
; of the beam elipse
; 
; angle thetap rotates from xp,yp axes to xpp,ypp which are aligned with the
; coma direction of the fit.
;
;The x,y values are passed via a common block. The call passes in 
;an index to this common block.
;
; we convert postions to arcminutes and angles to radians before calling
; fit, we then back convert when done
;-
;
;gsfit2dcFunc -  cross pattern 2d fit to total power with coma
;
;DESCRIPTION:
;a0 - constant
;a1 : amplitude
;a2 : xoffset ,az coord direction
;a3 : yoffset ,za coord direction
;a4 : sigx^2  ,in prime coordinate system
;a5 : sigy^2  ,in prime coordinate system
;a6 : alphax  ,comma in pp system aligned along coma direction
;a7 : alphay  ,comma in pp system aligned along coma direction
;a8 : theta   ,rotate unprimed to primed aligned along ellipsoid of beam,Rd
;a9 : thetap  ,rotate primed to coma aligned, Rd
;
;z(x,y)= a0 + a1*exp[-xp^2/sigxp^2*(1.+alphax*xpp) -
;                     yp^2/sigyp^2*(1.+alphay*ypp)]
;xm=(x-x0)
;ym=(y-y0)
;xp = xm*cos(th)  + ym*sin(th)
;yp =-xm*sin(th)  + ym*cos(th)
;xpp= xp*cos(thp) + xp*sin(thp)
;ypp=-xp*sin(thp) + yp*cos(thp)
;
; angle theta rotates from az,za to axes aligned with the major axis
; of the beam elipse
; 
; angle thetap rotates from xp,yp axes to xpp,ypp which are aligned with the
; coma direction of the fit.
;
;The x,y values are passed via a common block. The call passes in 
;an index to this common block. This routine is called by gsfit2dc.
;
; 
pro gsfit2dcFunc,i,a,z,pder
;
common  comgsfit2dc,comgsfit2dx,comgsfit2dy
;
;   get the x,y values in the prime system (aligned with the ellipitcal beam).
;
;   angles for rotation 
;
    costh =cos(a[8])
    sinth =sin(a[8])
    costhp=cos(a[9])
    sinthp=sin(a[9])
    xm =comgsfit2dx[i]-a[2]
    ym =comgsfit2dy[i]-a[3]
    xp = xm*costh  + ym*sinth
    yp =-xm*sinth  + ym*costh
    xpp= xp*costhp + yp*sinthp
    ypp=-xp*sinthp + yp*costhp
    sigX2=(1d-8 > a[4])
    sigY2=(1d-8 > a[5])
    z=a[0] + a[1]*$
      exp(-(xp*xp)/sigX2*(1.+a[6]*xpp) - (yp*yp)/sigY2*(1+a[7]*ypp))
    return
end
;..............................................................................
function  gsfit2dc,az,za,z,a,zfit=zfit,covar=covar,sigCoef=sigCoef,chisq=chisq,$
                 sigma=sigma,trouble=trouble
;
common  comgsfit2dc ,comgsfit2dx,comgsfit2dy
    
    flambdastep=10.             ; default
    fwhm2tosig2=1.D/(4.D*alog(2.)); fwhm^2 to sig^2
    itmax    =20                ; default
    s=size(az)
    pntstp=s[1]
    pnttot=s[1]*s[2]
    comgsfit2dx=reform(az,pnttot)  ; in fwhm
    comgsfit2dy=reform(za,pnttot)  ;
    lindar=lindgen(pnttot)
    ad=double(a)
    weights=dblarr(pnttot)+1.D
;
;   change fwhm to sig^2 for fit
;
    fwhm=ad[4]
    ad[4]=fwhm*fwhm*fwhm2tosig2
    fwhm=ad[5]
    ad[5]=fwhm*fwhm*fwhm2tosig2
    ad[8]=ad[8]*!dtor
    ad[9]=ad[9]*!dtor
    zloc=reform(z,pnttot)
    zfit=curvefitpp(lindar,zloc,weights,ad,sigmaCoef,chisq=chisq,$
            function_name='gsfit2dcfunc',itmax=itmax,tol=tol,$
            covar=covar,flambdastep=flambdastep,/noderivative,trouble=trouble)
;
;   fix up ..
;
    ad[4]= sqrt(ad[4]/fwhm2tosig2)  ; back to fwhm
    ad[5]= sqrt(ad[5]/fwhm2tosig2)  ; back to fwhm
    ad[8]=ad[8]*!radeg mod 360.
    ad[9]=ad[9]*!radeg mod 360.
    sigma=(rms(zfit-zloc,/quiet))[1]
    return,ad
end
