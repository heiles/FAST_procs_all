;+
;NAME:
;wuse - set window for plotting
;SYNTAX: winuse,winnum 
;ARGS:
; winnum: int	window number to use
;KEYWORDS:
; 	Any extra keywords are passed to window,winnun
;
;DESCRIPTION:
;	Set plotting window to winnum. If the window is not currently
;available then call window,winnum,_extra=e
; If the window is currently available then call wset,winnum
;-
;
pro wuse,winnum,_extra=e
;
;   see if post script.. scaleable pixels
	if (!d.flags eq 1) then return
    device,window_state=w
    nw=n_elements(w)
    if winNum lt nw then begin
		if w[winnum] eq 1 then begin
           wset,winnum
           return
	    endif
    endif
	window,winnum,_extra=e
    return
end
