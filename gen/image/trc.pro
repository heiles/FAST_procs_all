pro trc, x, y, reset=reset, _REF_EXTRA=_extra
;+
; NAME:
;       TRC
;
; PURPOSE:
;       A wrapper to call TR_RDPLOT with useful settings.
;
; CALLING SEQUENCE:
;       TRC [, x, y] [, COLOR=color] [, /DATA|/DEVICE|/NORMAL]
;           [, /NOCLIP] [, THICK=thick]
;
; KEYWORD PARAMETERS:
;        RESET: resets plot stuff when problems occur
;       Accepts all keywords for TR_RDPLOT.  For full documentation:
;       IDL> doc_library, 'tr_rdplot'
;
; OPTIONAL OUTPUTS:
;       x - x position of last cursor click, or all if ACCUM is set
;       y - y position of last cursor click, or all if ACCUM is set
;
; SIDE EFFECTS:
;       The active window will have a full cursor drawn in it.
;
; NOTES:
;       Say you have a preferred cursor that is not the IDL default.  There
;       are two ways to have this cursor restored after running this
;       routine: (1) define a system variable named !cursor_standard and
;       store the value in this variable; (2) pass the CURSOR_STANDARD
;       keyword to this routine with the value of your preferred cursor.
;       See IDL help on the DEVICE keyword CURSOR_STANDARD for more.
;
; MODIFICATION HISTORY:
;	Written by Carl Heiles, Berkeley 2006
;	T. Robishaw Cleaned up a little bit. 01 Nov 2006
;	Added /ACCUMULATE as a default. T. Robishaw  15 Nov 2006
;       Added CURSOR_STANDARD keyword to TR_RDPLOT. Changed _EXTRA keyword
;       to _REF_EXTRA.  T. Robishaw  03 Jul 2007
;-

on_error, 2

if keyword_set( reset) then begin
   RESET_RDPLOT
   return
endif


; SET BACK TO USER'S CURSOR PREFERENCE WHEN DONE...
defsysv, '!cursor_standard', EXISTS=cursor_defined
if cursor_defined $
   then cursor_standard=!cursor_standard

; CALL TR_RDPLOT WITH USEFUL OPTIONS...
tr_rdplot, x, y, /ACCUMULATE, $
           ; MAKE A THICK GREEN FULL-SCREEN CURSOR...
           /FULL, COLOR=!green, THICK=3, $
           ; PRINT OUT THE RESULTS...
           /PRINT, $
           ; AND SET THE CURSOR BACK TO MY PREFERENCE...
           CURSOR_STANDARD=cursor_standard, $
           _EXTRA=_extra

end ; trc

