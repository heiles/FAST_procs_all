;+
;unbalmomentaz - compute unbalanced momment on azimuth arm
; SYNTAX:
;  unbmom=unbalmomentaz(zaGr,zaCh,grweight=grweight,
;             chweight=chweight,chcwweight=chcwweight,$
;             chcwRadius=chcwRadius,grradius=grradius,grzaoff=grzaoff,$
;             azARmUnbal=azArmUnbal)
; ARGS:		
;   zaGr[N]	    : gregorian za (optic axis)
;   zach[N]	    : carriage house za
;
; keywords:		
; grWeight: float dome weight in kips .def:210 kips 
; chWeight: float carriage house weight .def:35 kips 
; chcwWeight: float counter weight on carriage house side (in kips). def:45
; grradius:   float radius in feet for dome center of mass. def:430.
;                  (this is used for gr and ch)
; chcwradius: float distance (in feet) from center bearing to ch counter
;                   weight. Def:145 ft.
; grzaoff:   float offset in deg from za dome center of mass to za of optic 
;                  axis. def: 1.913 degrees.
;azArmUnbal: float residual azimuth arm unbalance. includes 
;                  vertex shelter and stairs on ch side going down to lower
;                  chord. def 864:
; RETURNS:
; unbmom[N]  : float unbalanced moments in kip feet
;
;DESCRIPTION:
;	see http://www.naic.edu/~phil/hardware/telescope/unbalanced_moments_azarm_mar10.html for how this is computed.
;-
function unbalmomentaz,zagr,zach,grweight=grweight,$
             chweight=chweight,chcwweight=chcwweight,$
             chcwRadius=chcwRadius,grradius=grradius,grzaoff=grzaoff,$
			azarmUnbal=azarmUnbal

;
	if n_elements(grWeight) eq 0 then grWeight=215.
	if n_elements(chWeight) eq 0 then chWeight=35.
	if n_elements(chcwWeight) eq 0 then chcwWeight=45.
	if n_elements(chcwradius) eq 0 then chcwradius=145.
	if n_elements(grradius) eq 0 then grradius=430.
	if n_elements(grzaoff) eq 0 then grzaoff=1.913
	if n_elements(azarmUnbal) eq 0 then azArmUnbal=864.
	chRadius=grRadius
	

	return,grRadius*(grWeight*sin((zagr-grzaoff)*!dtor))  - $
	       (chRadius*chWeight*sin(zach*!dtor)  + $
			chcwRadius*chcwweight + azArmUnbal)
end
