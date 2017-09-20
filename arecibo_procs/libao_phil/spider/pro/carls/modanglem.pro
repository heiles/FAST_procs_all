function modanglem, angles

;+
; CALLING SEQUENCE:
;
;	RESULT= MODANGLEM( angles)
;
; INPUTS:
;
;	angles, in degrees
; OUTPUTS:
;
;	RESULT, the angles converted to the interval -90 t0 90.
;
; RELATED PROCEDURES/FUNCTIONS:
;
;	MODANGLE, MODANGLE360
;
;-

mangles = angles
indx = where( mangles lt 0., count)
if (count ne 0) then $
	mangles[indx] = mangles[indx] + 180.*(1 + fix(abs(mangles[indx]))/180)

mangles = mangles mod 180.
indx = where(mangles gt 90., count)
if (count ne 0) then mangles[indx] = mangles[indx]-180.

return, mangles
end
