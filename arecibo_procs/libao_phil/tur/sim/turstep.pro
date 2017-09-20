;
; simulate tertiary motion
pro	 turstep,i,pi
;
;DESCRIPTION: compute pi  step
;ARGS:	pi	{pi} - hold pi info
; setup
;	 pi.curPos[0] = xxxx
;	 pi.reqPos[0] = curPos[0]
;	 pi.velKi[0]  = 0
;	 pi.reqVel[0]=  initVel  encoder cnts/interval
;
; first computation starts on index 1
;
	pi.curPos[i]= pi.curPos[i-1] + pi.reqVel[i-1]*pi.k0*pi.ke/(pi.stepsPerSec)
	pi.posErr[i]= pi.reqPos[i] - pi.curPos[i]
	pi.velKp[i] = pi.Kp * pi.posErr[i]
	if (abs(pi.posErr[i]) lt pi.kiThreshHold) then  begin
		pi.AccumErr= pi.AccumErr + pi.ki* pi.posErr[i]
	endif else begin
		pi.AccumErr=0.
	endelse
	pi.velKi[i] =pi.accumErr
	pi.velKf[i] =pi.kf*(pi.reqPos[i]-pi.reqPos[i-1])
	pi.reqVelnl[i]= pi.velKp[i]+pi.velKi[i]+pi.velKf[i]
	pi.reqVel[i]  = pi.reqvelnl[i]
;
;   acceleration limit
;
	accel= pi.reqVel[i]- pi.reqVel[i-1]
	if (accel gt pi.maxAccDacPerI) then $ 
		pi.reqVel[i]=pi.reqVel[i-1] + pi.maxAccDacPerI else $
    if (accel lt -pi.maxAccDacPerI) then $
			pi.reqVel[i]=pi.reqVel[i-1] -  pi.maxAccDacPerI
;
;	velocity limit
;
	if (pi.reqVel[i] gt pi.maxReqVelDac)  then $
			pi.reqVel[i]= pi.maxReqVelDac else $
	if (pi.reqVel[i] lt -pi.maxReqVelDac) then pi.reqVel[i]= -pi.maxReqVelDac
	return
end
