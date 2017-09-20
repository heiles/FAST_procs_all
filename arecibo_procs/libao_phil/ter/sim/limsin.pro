;+
;NAME  
;	limsin - print maxVelocity,accelSecs for no vel,acceleratio limiting
; SYNTAX: limsin,maxVelDac,accMaxSec,maxVelInPerSec,maxFrq,maxAmp
; ARGS:
;		maxVelDac[nvel] - maximum vel in dac counts
;		accMaxSec[nacc] - maximum secs to reach 2048 dac counts
;       maxVelInPerSec  float for this axis at maxDac Value.
;		maxFrq[nvel,nacc]- return max frq in hz
;		maxAmp[nvel,nacc]- return max amp in inches for max frq
;-
pro limsin,maxVelDac,AccMaxSec,maxVelInPerSec,maxFrq,maxAmp
	numvel=n_elements(maxVelDac)
	numacc=n_elements(accMaxSec)
	maxFrq=fltarr(numVel,numAcc)
	maxAmp=fltarr(numVel,numAcc)
	for i=0,numAcc-1 do begin
		maxFrq[*,i]=(2048./maxVelDac)/(accMaxSec[i]*2.*!pi)
	    maxAmp[*,i]=maxVelInPerSec*maxVelDac/(2048.*maxFrq[*,i]*2.*!pi)
	end
	return
end
