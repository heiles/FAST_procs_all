pro pwd, name
;+
; NAME:
;       PWD
;
; PURPOSE:
;       Return the absolute path to the working directory.
;
; CALLING SEQUENCE:
;       PWD [,NAME]
;
; INPUTS:
;       None.
;
; KEYWORD PARAMETERS:
;       None.
;
; OUTPUTS:
;       None.
;
; OPTIONAL OUTPUTS:
;       NAME - the name of the directory.
;
; MODIFICATION HISTORY:
;   01 Mar 2003  Written by Tim Robishaw, Berkeley
;-
if (N_params() eq 0) $
  then spawn, 'pwd' $
  else spawn, 'pwd', name
end; pwd
