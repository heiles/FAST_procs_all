;tscor - do dx,dy and linear correction pitch,roll
pro tscor,az,za,pitchcor,rollcor
;
; do linear correction to go tiltsensor to theodolite(ao9)
; still need to do dx,dy correction
; from 31jan00 data. floorangle: pitch:.6152, roll:.1231 
;
	tsdxdycor,az,za,pitchcor1,rollcor1
	tslincor,za,pitchcor2,rollcor2	
	pitchcor= pitchcor1+pitchcor2
	rollcor = rollcor1 +rollcor2
	return
end
