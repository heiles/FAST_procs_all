;
;	compute tert trajectory 
; first 
; @terinit once
; .run tersetup   .. to setup the parameters
;
pro  tercmp,pi,posEnd,vel=vel,pos=pos
;
	len=n_elements(posEnd);
	velSt=0 					; in dac cnts
	posSt=pi.encCenter
	if n_elements(vel) ne 0 then velSt=vel
	if n_elements(pos) ne 0 then posSt=pos
	velSt =(-pi.maxReqVelDac > (pi.maxReqVelDac < (velSt)))
	posSt =(pi.minPosEnc   > (pi.maxPosEnc < (posSt)))
	posEnd=(pi.minPosEnc   > (pi.maxPosEnc < (posEnd)))

	pi.reqPos[0] =posSt
	pi.curPos[0] =posSt
	pi.reqVel[0] =velSt
	pi.reqVelnl[0] =pi.reqVel[0]
	if (len eq 1) then  begin
		pi.reqPos[1:*]=posEnd
	endif else begin
		pi.reqPos[1:*]=posEnd[1:*]
	endelse
	pi.accumErr=0.
	for i=1L,pi.stepsToDo-1 do terStep,i,pi
	return
end
