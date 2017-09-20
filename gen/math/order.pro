function order, value
;+
; NAME:
;        ORDER
;     
; PURPOSE:
;        To return the order of magnitude of a number.
;     
; CALLING SEQUENCE:
;        result = ORDER(value)
;     
; INPUTS:
;        value : a number.
;     
; OUTPUTS:
;        Returns the order of magnitude of the input value.
;
; EXAMPLE:
;        IDL> print, order(1.989d33)
;                  33
;
; NOTES:
;       The "order of magnitude" of a number is defined as the floor
;       of the base-10 logarithm of that number.
;
; MODIFICATION HISTORY:
;    21 Jun 2002  Written by Tim Robishaw, Berkeley
;-

return, floor(alog10(abs(value) + (value eq 0)))

end; order
