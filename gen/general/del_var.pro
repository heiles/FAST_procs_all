pro del_var, variable
;+
; NAME:
;       DEL_VAR
;
; PURPOSE:
;       Program deletes an IDL variable from memory management.
;       Unlike DELVAR, it can be called from program modules.
;
; CALLING SEQUENCE:
;       DEL_VAR, variable
;
; INPUTS:
;       variable: variable to be deleted
;
; OUTPUTS:
;       None.
;
; COMMON BLOCKS:
;       None.
;
; SIDE EFFECTS:
;       The variable is now undefined.
;
; EXAMPLE:
;       Define a variable...
;       IDL> f = 1024
;       IDL> help, f
;       F               INT       =     1024
;
;       Delete the variable...
;       IDL> del_var, f
;       IDL> help, f
;       F               UNDEFINED = <Undefined>
;
; MODIFICATION HISTORY:
;   15 Feb 2004  Written by Tim Robishaw, Berkeley
;-

if (N_elements(variable) ne 0) then throwaway = temporary(variable)

end; del_var
