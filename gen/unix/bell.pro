pro bell, n, WAIT=t_wait
;+
; NAME:
;       BELL
;
; PURPOSE:
;       To beep and alert the user.
;
; CALLING SEQUENCE:
;       BELL [, N][, WAIT=wait] 
;
; INPUTS:
;       None.
;
; OPTIONAL INPUTS:
;       N - number of times the bell should be rung.
;
; KEYWORD PARAMETERS:
;       WAIT - the number of seconds between beeps. 
;
; OUTPUTS:
;       None.
;
; NOTES:
;       Beep beep!
;
; MODIFICATION HISTORY:
;   28 Feb 2003  Written by Tim Robishaw, Berkeley
;-
if (N_params() eq 0) then n=1
if not keyword_set(T_WAIT) then t_wait=0.3
for j = 1, n do begin
    print, '', format='($,%"\A",A)'
    wait, t_wait
endfor
end; bell
