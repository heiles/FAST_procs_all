function sign, value
;+
; NAME:
;       SIGN
;   
; PURPOSE:
;       Returns the sign of the input value(s).
;
; CALLING SEQUENCE:
;       Result = SIGN(value)
;
; INPUTS:
;       value : a number.
;
; KEYWORD PARAMETERS:
;       None.
;
; OUTPUTS:
;       Returns the sign of the input value(s).
;
; COMMON BLOCKS:
;       None.
;
; EXAMPLE:
;       IDL> print, sign([-3,0,3])
;            -1.00000      0.00000      1.00000
;
; MODIFICATION HISTORY:
;   10 Feb 2004  Written by Tim Robishaw, Berkeley
;-
return, -1.0 + 1.0 * (value eq 0) + 2.0 * (value gt 0) 
end; sign
