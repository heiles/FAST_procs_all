function fillarr,del,min,max,fan=fan,transpose=transpose
;+
; NAME: 
;FILLARR --  generate an array from MIN to MAX with step size DEL. 
;
;
; PURPOSE:
;       This function generates an array from MIN to MAX with
;       step size DEL. If an integer number of steps cannot be
;       fit between MIN and MAX, then MAX will be adjusted to
;       be as close as the specified maximum as possible.
; CATEGORY:
;
;
;
; CALLING SEQUENCE:
;       f = fillarr(n, min, max [,fan=, transfan=, /double])
;
;
; INPUTS:
;
;       DEL:  The desired step size
;       MIN:  The value of the first array element in F
;       MAX:  The value of the last array element in F if
;             (MAX-MIN)/DEL is an integer. Adjusted otherwise.
;
; OPTIONAL INPUTS:
;
; KEYWORD PARAMETERS:
;
;       FAN:        Number of times the array is to be repeated.
;                   The final dimensions of F  will be 
;                   fix((MAX-MIN)/DEL) + 1 columns by FAN rows.
;
;       /TRANSPOSE  Final dimensions of F wil be FAN columns by 
;                   fix((MAX-MIN)/DEL) + 1 rows if FAN is specified. 
;
; OUTPUTS:
;
;       F:    Final array. If input parameters are double precision,
;             then F will be double as well. F is float otherwise.
;
;
; OPTIONAL OUTPUTS:
;
;
;
; COMMON BLOCKS:
;
;
;
; SIDE EFFECTS:
;
;
;
; RESTRICTIONS:
;
;
;
; PROCEDURE:
;
;
;
; EXAMPLE:
;
;         For an array that runs from 2 to 5 in steps of .7
;
;         IDL> f = fillarr(.7,2,5)
;         IDL> print, f
;            2.00000      2.70000      3.40000     4.10000    4.80000
;         
; MODIFICATION HISTORY:
; Written by John "JohnJohn" Johnson 21-Feb-2002
; 22-Feb-2002 JohnJohn- Fixed precision bug
; 23-Feb-2002 JohnJohn- Calculations performed in double precision. 
;                       Output in double precision if input is 
;                       double.
; 01-Mar-2002 JohnJohn- Much props to Tim Robishaw (Tdogg) for helping
;                       me understand machine precision and truly fix
;                       the precision bug.
;-

if n_params() lt 3 then begin 
    message,'INCORRECT NUMBER OF INPUTS. Syntax: f = fillarr(del,min,max)',/ioerror
endif

;if any of the input parameters are double, the return the answer in
;double precision.
doub = (size(del,/type) eq 5) and (size(min,/type) eq 5) and (size(max,/type) eq 5)

;ARG will go into N later. These are the only real calculations performed.
arg = (max-min)/del
;test for and correct rounding errors
rnd = round(arg)
eps = (machar(double=doub)).eps
if abs(rnd-arg) lt rnd*eps then arg = rnd else arg = fix(arg,type=3)

;N is the number of elements in the output array.
a = dindgen(arg+1)*del+min

if n_elements(fan) ne 0 then a = a##(dblarr(fan)+1)
if KEYWORD_SET(transpose) then a = transpose(a)

if not doub then a = float(a)

return,a 
end
