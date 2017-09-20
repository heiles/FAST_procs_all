;+
;NAME:
;tdleveltilt - compute td motion to level 1az tilt
;SYNTAX: tdRefNew=tdleveltilt(Pamp,Pphase,Ramp,Rphase,tdRef
;ARGS:
; Pamp: float	amplitude of 1az pitch term (deg)
;Pphase: float  phase term from fit (degrees). see below
; Ramp: float	amplitude of 1az roll term (deg)
;Rphase: float 	phase term from roll fit (degrees).
;tdRef[3]:float tiedown reference position (inches)
;
;RETURNS:
;tdRefNew[3]:float	new reference position to get rid of tilt
;
;DESCRIPTION:
;	Compute the new tiedown reference position to remove a platform
;tilt measured via the tilt sensors. The fit parameters come from
;the fit:
;   pitchaz = Pamp*sin(az - PphaseDeg)
;   rollaz = Ramp*sin(az - RphaseDeg)
;-
;
function  tdleveltilt,pamp,pPhDeg,ramp,rPhDeg,tdRefOld
;
; 	tiedown azimuth values
;
tdAzRd=(findgen(3)*120 + 2.87)*!dtor
tdRadiusIn=192.*12.
tdInPerPlInch=1.2   ; for rocking. (should be 1.0??)
;
; azimuth for peak Pitch and Roll (using phase def of fits above)
;
azPPkRd= (pPhDeg + 90.)*!dtor
azRPkRd= (rPhDeg + 90.)*!dtor
;
; figure out the tiedown motion needed using just the pitch..
;
tdMotionTot=tdRadiusIn*(pAmp*!dtor)*tdInPerPlInch
azPkRd=azPPkRd
;
; now project the motion at the peak phase to each tiedown
;
tdChg=tdMotionTot*cos(azPkRd- tdAzRd)
tdRefNew=tdRefOld + tdChg
return,tdRefNew
end
