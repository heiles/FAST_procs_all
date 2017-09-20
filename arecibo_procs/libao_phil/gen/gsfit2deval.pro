;+
;NAME:
;gsfit2deval - evaluate coef returned from gsfit2d
;SYNTAX: z=gsfit2deval,x,y,fitcoef 
;ARGS:
;       x[npts]: x pos 
;       y[npts]: y pos 
;    fitcoef[m]: float. coef from  gsfit2d
;RETURNS:
;     z[npts]: float  fit evalutated at x,y
;DESCRIPTION:
; Evaluate the Fit returned from gsfit2d at the
;requested x,y positions
;
;z(x,y)= a0 + a1*exp[-xp^2/sigxp^2 - yp^2/sigyp^2] + a7*za
;
;The units are:
;a0 - constant
;a1 : amplitude
;a2 : xoffset ,az coord direction units:amin
;a3 : yoffset ,za coord direction      :amin
;a4 : sigx^2  ,in prime coordinate system: fwhm amin
;a5 : sigy^2  ,in prime coordinate system: fwhm amin
;a6 : theta   ,rotate unprimed to primed aligned along ellipsoid of beam,Deg
;a7 : zaslope ,The za slope in amplitude units per deg za
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
; we convert postions to arcminutes and angles to radians before calling
; fit, we then back convert when done
;
;
;   get the x,y values in the prime system (aligned with the ellipitcal beam).
;
;-
function gsfit2deval,x,y,coef

	a=coef
    fwhm2tosig2=1.D/(4.D*alog(2.)); fwhm^2 to sig^2
	fwhm=a[4]
	a[4]=fwhm*fwhm*fwhm2tosig2
	fwhm=a[5]
	a[5]=fwhm*fwhm*fwhm2tosig2
;
; convert rotation theta to radians
;
	a[6]=a[6]*!dtor
	costh =cos(a[6])
    sinth =sin(a[6])
    xm =  x - a[2]
    ym =  y - a[3]
    xp = xm*costh  + ym*sinth
    yp =-xm*sinth  + ym*costh
    sigX2=(1d-16 > a[4])
    sigY2=(1d-16 > a[5])
    if n_elements(a) gt 7 then begin
        return,a[0] + a[7]*y + a[1]*exp(-(xp*xp)/sigX2 - (yp*yp)/sigY2)
    endif else begin
        return,a[0] + a[1]*exp(-(xp*xp)/sigX2 - (yp*yp)/sigY2)
    endelse
end
