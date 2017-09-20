pro host
;+
; NAME:
;       HOST
;
; PURPOSE:
;       Print the host name IDL session is running on.
;
; CALLING SEQUENCE:
;       HOST
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
; COMMON BLOCKS:
;       None.
;
; MODIFICATION HISTORY:
;   04 Mar 2003  Written by Tim Robishaw, Berkeley
;-
print, getenv('HOST')
end; host

