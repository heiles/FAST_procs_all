pro wd, n, OPEN=open
;+
;NAME:
;WD -- delete all open windows
;     
; PURPOSE:
;       Quick way to delete open windows.
;     
; EXPLANATION:
;       Deletes the open window the user specifies.
;       Can delete all windows by just calling WD with no parameters.
;       Can just print open windows by setting the /OPEN keyword.
;     
; CALLING SEQUENCE:
;       WD [,WINDOW][,/OPEN]
;     
; INPUTS:
;       WINDOW : The number(s) of the window(s) you want to delete. 
;                If no number is input, then all the windows are
;                deleted.
;     
; OUTPUTS:
;       None.
;
; KEYWORDS:
;       /OPEN : Just print the window number of each open window.
;
; COMMON BLOCKS:
;       None.
;
; SIDE EFFECTS:
;       Windows will be deleted.
;
; RESTRICTIONS:
;       The current device must be X Windows.
;
; PROCEDURES CALLED:
;       WDELETE
;
; EXAMPLE:
;       Print all the open windows:
;          IDL> wd, /open
;
;       Kill all windows:
;          IDL> wd
;
;       Kill windows 4, 5, & 6:
;          IDL> wd, [4,5,6]
;
; MODIFICATION HISTORY:
;       Written Tim Robishaw, Berkeley in ancient times.
;-

; ARE YOU USING X WINDOWS DEVICE...
if (!d.name ne 'X') then begin
  message, 'DEVICE not set to X Windows.', /INFO
  return
endif

; FIND THE OPEN WINDOWS...
device, window_state=openwindows
openwindows = where(openwindows,Nopen)

; DO WE JUST WANT TO SEE WHICH WINDOWS ARE OPEN...
if not keyword_set(OPEN) then begin

    ; IF NO INPUT...
    if (N_params() eq 0) then begin

        ; DELETE ALL THE OPEN WINDOWS...
	; NOTE: OLD VERSIONS OF IDL, WDELETE IS NOT VECTORIZED...
	for i = 0, Nopen-1 do wdelete, openwindows[i]
        return

    endif else begin

        ; DELETE THE REQUESTED WINDOWS...
        for i = 0, N_elements(n)-1 do $
          if (total(openwindows eq n[i]) gt 0) $
            then wdelete, n[i]  $
            else message, 'Window '+strtrim(n[i],2)+' not open.', /INFO

    endelse

   ; WHICH WINDOWS ARE OPEN NOW...
   device, window_state=openwindows
   openwindows = where(openwindows,Nopen)

endif

; TELL US ABOUT THE OPEN WINDOWS...
if (Nopen eq 0) $
  then message, 'No windows open.', /INFO $
  else message, 'Windows still active: '+$
       strjoin(strtrim(openwindows,2),' '), /INFO

end; wd

