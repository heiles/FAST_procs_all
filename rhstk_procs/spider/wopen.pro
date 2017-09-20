function wopen, query
;+
;NAME:
;WOPEN -- return list of all open windows, or whether a list of windows
;         are open
;
; PURPOSE:
;       Quick way to find all open windows, or whether a particular
;       window is open
;
; CALLING SEQUENCE:
;       result= wopen( query)
;
; INPUTS:
;       QUERY; 
;       if specified as an array, it tells whether the specified
;               windows are open by returning an array of 1's and 0's. 
;       if a single number, returns a 1 0r 0 (not an array) if the 
;               window is open or closed, respectively. 
;        if not specified, returns an array of the open windows.
;
;EXAMPLE
;       result = wopen( 32) returns 0 if wwindow 32 is closed, 1 if open
;
; RESTRICTIONS:
;       The current device must be X Windows.
;
; MODIFICATION HISTORY:
;       Written CARL, who finally got fed up
;-

; ARE YOU USING X WINDOWS DEVICE...
if (!d.name ne 'X') then begin
  message, 'DEVICE not set to X Windows.', /INFO
  return, -1
endif

; FIND THE OPEN WINDOWS...
device, window_state=openwindows
openwindows = where(openwindows,Nopen)

nqq= n_elements( query)
if nqq ne 0 then  begin
bout= bytarr( nqq)
for nq=0, nqq-1 do begin
indx= where( openwindows eq query[ nq], count)
bout[ nq]= count eq 1
endfor
if n_elements( bout) eq 1 then bout= bout[0]
endif


if nqq eq 0 then bout= openwindows
return, bout

end




