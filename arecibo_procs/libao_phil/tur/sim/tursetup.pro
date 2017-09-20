;
; define an axis
;
pro tursetup,pi,fname=fname,freq=freqk,maxvel=maxvel,accsec=accsec,kf=kf,$
				kithr=kithr,ax=ax

	pi={pi}
	pi.maxSteps   =2000         ; compute for this long..
    pi.stepsPerSec=200
    pi.maxDacCnts =2047
    pi.Ke         =4096.         ; encoder counts/revolution
    pi.encToDeg   =360./(4096.*210./5.) ; convert encoder to degrees
;
; 	input the setup file from disc
;
	if n_elements(fname) eq 0 then begin
		fname=aodefdir() + 'ter/sim/setup.datdef'
	endif
;
;	input the file info
;
	openr,lun,fname,/get_lun 
	ftemp=1.
	itemp=1L
	test=' '
;
	readf,lun,ffKa,test
	readf,lun,ffKi,test
	readf,lun,ffKp,test
	readf,lun,ffKd,test
	readf,lun,ffKf,test
	 
	readf,lun,lKa,test
	readf,lun,lKi,test
	readf,lun,lKp,test
	readf,lun,lKd,test
	readf,lun,lKf,test

	readf,lun,maxVel,test
	readf,lun,maxAcc,test
	readf,lun,maxPosStepC,test
	pi.freq=ftemp
;
	readf,lun,ftemp,test
	pi.damping=ftemp
;
	readf,lun,itemp,test
	pi.maxReqVelDac=itemp
;
	readf,lun,ftemp,test
	secsTillmaxDacCnts=ftemp
;
	readf,lun,ftemp,test
    kfl=ftemp
;
	readf,lun,itemp,test
	pi.kiThreshHold=itemp
	free_lun,lun
;
;	now process any keywords passed in
;
	if n_elements(freq)   ne 0   then pi.freq=freq;
	if n_elements(maxvel) ne 0 then pi.maxReqVelDac=(2047<maxvel)
	if n_elements(accsec) ne 0 then secsTillmaxDacCnts=accsec;
	if n_elements(kf) 	  ne 0     then kfl=kf
	if n_elements(kithr)  ne 0  then pi.kiThreshHold=kithr

	axToUse='tilt'
	if n_elements(ax) ne 0 then  begin
		case ax of
			'hor':axToUse='hor'
			'ver':axToUse='ver'
			'tilt':axToUse='tilt'
			else: message,'illegal axis req..hor,ver, or tilt'
		endcase
	endif

	axisprof,pi,axToUse
;
; 	determine loop response
;
;
	pi.maxAccDacPerI= pi.maxDacCnts/(pi.stepsPerSec*secsTillMaxDacCnts) + .5
	if pi.maxAccDacPerI le 0  then pi.maxAccDacPerI=1
;
; computed
;
	pi.maxPosEnc= pi.encCenter + (pi.totTurns/2.)*pi.Ke
	pi.minPosEnc= pi.encCenter - (pi.totTurns/2.)*pi.Ke
	pi.stepsToDo=pi.maxSteps
	pi.K0=pi.motRpmMax/60.*(1./pi.maxDacCnts)

	w=2.*!pi * pi.freq
	pi.Kp=(2.*pi.damping*w)/(pi.K0*pi.Ke)
	pi.Ki=(w*w)/(pi.K0*pi.Ke)/pi.stepsPerSec
	pi.encToIn= pi.leninches/(pi.totturns*pi.ke)
;
;	kf converts encoder counts/interval to dac cnts..
;   k0=rev/sec per dacCnt
;
	pi.Kf=kfl*(1./(pi.k0*pi.kE/pi.stepsPerSec))
;
	return
end
