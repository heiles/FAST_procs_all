function modangle360, angles, c180=c180

;+
; PURPOSE: convert angles to the interval 0 to 360 degrees, or -180 to 180.
;
; CALLING SEQUENCE:
;
;	RESULT= MODANGLE360( angles)
;
; INPUTS:
;
;	ANGLES: an array of angles. Units are DEGREES.
;
; KEYWORD PARAMETERS:
;
;	C180: makes the interval -180 to 180 instead of 0 to 360.
;
; OUTPUTS:
;
;	RESULT, the converted angles.
;
; RELATED PROCEDURES/FUNCTIONS:
;
;	MODANGLEM (-90 T0 90), MODANGLE (0 TO 180)
;
; EXAMPLE:
; 
; MODIFICATION HISTORY:
;-

mangles = angles mod 360.
mangles = mangles + 360.*(mangles lt 0.)

if keyword_set( c180) then begin
indx= where( mangles gt 180., count)
if (count ne 0) then mangles[indx]= mangles[indx]- 360.
endif

return, mangles
end
