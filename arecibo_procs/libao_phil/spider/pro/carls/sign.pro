function sign, x

;+
; PURPOSE: Obtain the sign of a variables or set therof. 
;
; CALLING SEQUENCE:
;
;	RESULT= sign( INPUT)
;
; INPUTS:
;
;	INPUT: a set of numbers
;
; OUTPUTS:
;
;	RESULT: same array as input. +1 if positive, -1 if negative.
;-

sign = x

indx = where( x gt 0., count)

if (count ne 0) then sign[ indx] = 1.

indx = where( x lt 0., count)
if (count ne 0) then sign[ indx] = -1.
return, sign
end

