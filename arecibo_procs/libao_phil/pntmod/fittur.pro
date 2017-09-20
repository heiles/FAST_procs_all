;+
; fitturfunc - nonlinear fit to turret swings
;
; SYNTAX:
;	fitturfunc,t,a,f,pder
; 
; ARGS:
;    t[npts] : independant variable time (in seconds).
;    a[6]    : parameters to fit for
;    f[npts] : return value of function here
;    pder[6] : return partial derivatives with respect to each parameter.
;
; DESCRIPTION:
;  evaluate the function and optionally it's partial derivatives
;  for the curvefit routine of idl:
;
;  z(x,y)=A*exp(-(x-x0)**2/sigx**2)*exp(-(y-y0)**2/sigy**2)
;
;  let:
;  x=  zaOffsetDeg + zaVelDegPerSec * t      .. x along zenith direction
;  y=  turAmpDeg*sin(turW * t + turPhaseRd)  .. y along turet
;
; a[0] - A      :amplitude of gaussian
; a[1] - x0     :za correction (degrees). This value should be added to the
;		  	     computed position to point at the source.
; a[2] - sigx**2: units (deg**2)
; a[3] - y0     :turret correction ( turret degrees). 
;			     This value should be added to the computed position to point at
;			     the source.
; a[4] - sigy**2: units (turret deg**2)
; a[5] - turPhaseRd (radians)
;
; note that we are fitting for sigx**2 and sigy**2 not sigx, sigy (just to
; go faster.
;-
pro fitturfunc,t,a,z,pdzda

	common fitturcom,ftcI,turW
	a2= a[2] > 1d-8				; don't divide by zero sigx**2
	a4= a[4] > 1d-8				; don't divide by zero sigy**2
	xp= ftcI.zaOffDeg  + ftcI.zaVel * t -a[1]  ; x position za - offset x
	yp= ftcI.turAmpDeg * sin(turW*t + a[5]) -a[3] ; y position turret - offsety
	xE=-(xp*xp)/a2	; 
	yE=-(yp*yp)/a4	; 
	z=a[0]*exp(xE)*exp(yE)		; the x,y exponential
	if n_params() ge 4 then begin
		pdzda[*,0]=z/a[0]							 ; dz/dAmplitude
		pdzda[*,1]=z * 2.D * xp/a2				 ; dz/dx0
		pdzda[*,2]=z * xE / (-a2) 					 ; dz/d(sigx**2) 
		pdzda[*,3]=z * 2.D * yp/a4				 ; dz/dy0
		pdzda[*,4]=z * yE / (-a4) 					 ; dz/d(sigy**2) 
		pdzda[*,5]=-pdzda[*,3]*ftcI.turAmpDeg*cos(turW*t+a[5]);dz/d(turretPhase)
	endif
	return
end
;+
; fittur - fit tur turret swing data (1 strip).
;
; SYNTAX: 
;    fittur,y,ftcI,yfit
;   ARGS:
;        y[npts]   :  measured values for 1 polarization
;        ftcI   : {ftcI} hold info on how to do the fit
;   KEYWORDS:
;        tmcon  : float. timeconstant. if defined, use this rather than
;				         value in structure (in case we correctd for tmcon)
;   RETURNS:
;        ftcI.p    .. fitted values
;        ftcI.chisq.. chisq for fit
;        ftcI.niter.. it took
;
; a[0] - A      :amplitude of gaussian
; a[1] - x0     :za correction (degrees). This value should be added to the
;                computed position to point at the source.
; a[2] - sigx**2: units (deg**2)
; a[3] - y0     :turret correction ( turret degrees).
;                This value should be added to the computed position to point at
;                the source.
; a[4] - sigy**2: units (turret deg**2)
; a[5] - turPhaseRd (radians)

;
pro fittur,y,yfit,tol=tol, itmax=itmax,tmcon=tmcon
	common fitturcom,ftcI,turW

	tol  =.001D
	itmax=30
	if n_elements(tmcon) eq 0 then tmcon=ftci.tmCon
;	tol  =.0001D
; 	itmax=50
	npts=n_elements(y)
	fwhm2tosig2=1.D/(4.* 0.693147180560D)  ;fwhm**2 to sig**2 (1/(4*ln2)
;
; 	load the initial values
;
	a=dblarr(6)
	a[0]=ftcI.pinp.amp			; amplitude
	a[1]=ftcI.pinp.zaErrA/3600.D		; asec to deg ..za error degrees
	fwhmD=ftcI.pinp.zaWdA/3600.D;		; full width half max .. degrees
	a[2]=fwhmD*fwhmD*fwhm2tosig2;   ; convert fwhm**2 to sig**2

	a[3]=ftcI.pinp.azErrA/ftcI.turScl;gc asec to tur deg .. az err
	fwhmD=abs(ftcI.pinp.azWdA/ftcI.turScl);to fwhm..tur deg
	a[4]=fwhmD*fwhmD*fwhm2tosig2    ; convert fwhm**2 to sig**2
	a[5]=ftcI.pinp.PhaseD *!dtor  ; turret phase in radians
	turW=ftcI.turFrq * !pi * 2.D  ; convert to radians/second
;
;   compute the time steps
;
	tm=findgen(npts)/ftcI.sampleRate  - tmcon
	weights=fltarr(npts) + 1.D/(ftcI.sigma*ftcI.sigma)
 	yfit=curvefit(tm,y,weights,a,chisq=chisq,$
			   function_name='fitturfunc',iter=iter,tol=tol,itmax=itmax)
;
; now move return values to ftcI
;
	ftcI.p.amp  =a[0]			; amplitude digitizer counts
	ftcI.p.zaErrA=a[1]*3600.D		; degrees to asecs
	ftcI.p.zaWdA =sqrt(a[2]/fwhm2tosig2)*3600.D; sig**2 ->fwhm^2 then asecs

	ftcI.p.azErrA=a[3]*ftcI.turScl;deg->asec 
	ftcI.p.azWdA =sqrt(a[4]/fwhm2tosig2)*abs(ftcI.turScl);
	ftcI.p.phaseD=a[5]*!radeg
	ftcI.chisq=chisq
	ftcI.niter=iter
;;	stop
	return
end
