;
; structures for turret
;----------------------------------------------
; pId LOOP STRUCTURE FOR simulation
;
;  T=.005 is the time step in seconds
;
;  P=exp(-Kf*T)*Ka*Kf*Kp
;  I=(1-exp(-Kf*T)*Ka*Ki*T
;  D=-(exp(-Kf*T)*Ka*(Kf^2)*Kd/T
;
;    values that define coef.
;
a={piCoef   , $
		Ka : 0.,$; used to generate pi
		Kf : 0.,$;
		Kp : 0.,$;
		Ki : 0.,$;
		Kd : 0.,$;
		T  : 0.,$; time step in seconds.
		P  : 0.,$;
		I  : 0.,$;
		D  : 0.}
	

a={pi , $
     maxSteps     : 0L,$; 2000 10 secs
    .  stepsPerSec: 0L,$; intervals per second
     motRpmMax    : 0.,$; motor rpms at maxDaCnts
     maxDacCnts   : 0L,$; 2047
	 encToDeg     : 0.,$; enc counts to degrees
	 degSecToDACnt: 0.,$; degs/sec to dacnt
	 degSec2ToDA5Ms:0.,$; deg/sec^2 to dacnts change in 5 Millisecs
	 Ke           : 0.,$; encoder counts/revolution
;
;
	picoef		  : {piCoef},$;

;
;	determines loop characteristics
;

		      freq:    0.,$; for band limitations
           damping: 0.,$; damping factor
     kiThreshHold  : 0L,$; when i term should turn on
     maxReqVelDac : 0L,$; say 1024
     maxAccDacPerI : 0L,$; max acceleration encoder cnts/interval
;
;	computed.. from above
;
     stepsToDo    : 0L,$; requested to compute
     k0           : 0.,$; k0  dac cnts to encCnts/Interval
	 accumErrP    : 0.,$; accumulated error for Ki
	 accumErrFF   : 0.,$; accumulated error for Ki feed foward
;
;	user reqeusts for trajectory
;
     reqPos       : lonarr(2000),$; where they want to be at each step
;
;	computed by program
;
     curPos       : lonarr(2000),$; curPos in encoder counts
     posErr       : lonarr(2000),$; curPos in encoder counts
     velKi        : fltarr(2000),$; velocity from ki term dac cnts
     velKp        : fltarr(2000),$; velocity from kp term dac cnts
     velKf        : fltarr(2000),$; velocity from kf term dac cnts
     reqVelnl     : lonarr(2000),$; requested velocity, no limitin
     reqVel       : lonarr(2000)} ; requested vel with limiting
;----------------------------------------------
