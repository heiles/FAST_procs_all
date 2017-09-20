; GET IDL COLOR INFORMATION AND SET UP SYSTEM VARIABLES WITH BASIC
; PLOT COLOR NAMES...
setcolors, /SYSTEM_VARIABLES

; SET DOUBLE-PRECISION VALUES OF !DTOR AND !RADEG...
defsysv, '!ddtor', !dpi/180d, 1
defsysv, '!dradeg', 1d/!ddtor, 1
defsysv, '!stof', 2d*sqrt(2d*alog(2d)), 1
defsysv, '!ftos', 1d/!stof, 1
