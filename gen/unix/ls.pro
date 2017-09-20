pro ls
;+
; NAME:
;       LS
;
; PURPOSE:
;       List the contents of the current directory.
;
; CALLING SEQUENCE:
;       LS
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
; MODIFICATION HISTORY:
;   01 Mar 2003  Written by Tim Robishaw, Berkeley
;-
spawn, '\ls -lA | more'
end; ls
