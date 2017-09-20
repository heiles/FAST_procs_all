pro pos, x, y, _REF_EXTRA=_extra
;+
; NAME:
;       POS
;     
; PURPOSE:
;       To return the cursor position.
;     
; CALLING SEQUENCE:
;       POS [,X, Y] [, /SILENT] 
;           [, /DATA | , /DEVICE, | , /NORMAL]
;           [, /CHANGE | , /DOWN | , /NOWAIT | , /UP | , /WAIT] 
;     
; INPUTS:
;       None.
;
; OUTPUTS:
;       None.
;
; OPTIONAL OUTPUTS:
;       X - the cursor's current column position.
;       Y - the cursor's current row position.
;
; KEYWORDS:
;       /SILENT : Do not print cursor position.
;       /DATA : Set this keyword to return X and Y in data coordinates.
;               This is the default.
;       /NORMAL : Return the normalized cursor position.
;       /DEVICE : Return the cursor position in device units.
;       /CHANGE : Set this keyword to wait for pointer movement or 
;                 button transition within the currently selected window.
;       /DOWN : Set this keyword to wait for a button down transition
;               within the currently selected window.
;       /NOWAIT : Set this keyword to read the pointer position and 
;                 button status and return immediately. If the pointer 
;                 is not within the currently selected window, the device 
;                 coordinates -1, -1 are returned.
;       /UP : Set this keyword to wait for a button up transition within 
;             the current window.
;       /DOWN : Set this keyword to wait for a button down transition within 
;               the currently selected window.
;
; COMMON BLOCKS:
;       None.
;
; MODIFICATION HISTORY:
;       Written by Tim Robishaw, Berkeley in ancient times.
;-

cursor, x, y, _EXTRA=_extra
if not keyword_set(SILENT) $
  then print, 'x = '+strtrim(x,2)+', y = '+strtrim(y,2)

end; pos
