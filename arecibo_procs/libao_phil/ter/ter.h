;
; structures for tertiary
;----------------------------------------------
; pI LOOP STRUCTURE FOR simulation
;
a={pi , $
     maxSteps     : 0L,$; 2000 10 secs
       stepsPerSec: 0L,$; intervals per second
     lenInches    : 0.,$;
     totTurns     : 0L,$; in length
     motRpmMax    : 0.,$; motor rpms at maxDaCnts
     maxDacCnts   : 0L,$; 2047
     encCenter    : 0L,$; encoder center position
	 encToIn      : 0.,$; encoder cnts to inches
     kE           : 0.,$; encoder counts/revolution

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
     maxPosEnc    : 0L,$; computed
     minPosEnc    : 0L,$; computed
     stepsToDo    : 0L,$; requested to compute
     kF           : 0.,$; feed foward
     kI           : 0.,$; ki
     kP           : 0.,$; kp
     k0           : 0.,$; k0  dac cnts to encCnts/Interval
	 accumErr     : 0.,$; accumulated error for Ki
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
; log data struture
;	
a={terlog0, $
		enccur	: lonArr(5),$; current encoder	
		encreq	: lonArr(5),$; requested encoder
		pot   	: lonArr(5),$; pot value
		velCmd	: lonArr(5),$; dac values
		velFb 	: lonArr(5),$; vel feedback 4ms integration
		tmMs 	:         0L}; vel feedback 4ms integration
;
; after 19nov00
;
a={terlog, $
		enccur	: lonArr(5),$; current encoder	
		encreq	: lonArr(5),$; requested encoder
		pot   	: lonArr(5),$; pot value
		velCmd	: lonArr(5),$; dac values
		velFb 	: lonArr(5),$; vel feedback 4ms integration
		monPort : lonArr(5),$; vel feedback 4ms integration
		tmMs 	:         0L}; vel feedback 4ms integration

;
; tertiary focus routines.
; emulate what i did in tcl and c
;
;  connection points 1-5
;
a={terState,    origDc: fltarr(4,5) ,$;con points origin in dome centerline
                origFoc:fltarr(4,5) ,$;con points origin in focus
                dcToFocM:fltarr(4,4),$;
                focToDcM:fltarr(4,4),$;
                encPosOrig: fltarr(3),$;V,H,T .. use left..
                dcToFocDeg: 0.   ,$; Dc to Focus z axis..
                dP12         : 0.    ,$; fixed distance p12
                dP35         : 0.    ,$; fixed distance p35
                dP14         : 0.    ,$; fixed distance p14
                dP24         : 0.    } ; fixed distance p24
common terfocstate,terstate
	terstate={terstate}


