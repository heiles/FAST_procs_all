;tslincor - do linear correction pitch,roll
pro tslincor,za,pitchcor,rollcor
;
; do linear correction to go tiltsensor to theodolite(ao9)
; still need to do dx,dy correction
; from 31jan00 data. floorangle: pitch:.6152, roll:.1231 
;
	pitchcor= 9.754 - .9916*za
	rollcor =  .3662 - .02198*za
	return
end
