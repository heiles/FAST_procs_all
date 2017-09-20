;in the following line, define CARLPATH as the subdir where Carl's 
;IDL library files live. For example, if you were running IDL on the
;FAST server 192.168.1.216, the IDL library resides in /home/dli/heiles,
;so the line would be: 'setenv 'CARLPATH=/home/dli/heiles/'

;=====================================================

;setenv, 'CARLPATH=/home/dli/heiles/'
setenv, 'CARLPATH=~/dzd2/heiles/'

common colors, r_orig, g_orig, b_orig, r_curr, g_curr, b_curr

;MAKE SURE WE COMPILE OUR OWN VERSIONS OF ADDPATH AND WHICH...
.run $CARLPATH/idl/gen/path/addpath
addpath, getenv( 'CARLPATH') + 'idl/gen/path/'
.run which

;---------------------ADD CARL-RELATED PATHS-------------------------
addpath, getenv( 'CARLPATH')+ 'idl/ay120coords' 
addpath, getenv( 'CARLPATH')+ 'idl/CodeIDL' 
addpath, getenv( 'CARLPATH') + 'idl/goddard' 
addpath, getenv( 'CARLPATH') + 'idl/goddard_jan2007', /expand 
addpath, getenv( 'CARLPATH')+ 'idl/idlutils', /expand 
addpath, getenv( 'CARLPATH')+ 'idl/gen', /expand 

;OBSERVATORY COORDINATES for FAST...
defsysv, '!obsnlat', 25.652939d0
defsysv, '!obselong', 106.856594d0
defsysv, '!obswlong', 360.d0 - 106.856594d0

;-------------------DI\O STABDARD IDL SETUP STUFF----------------------

; WE'RE GOING TO SET THE PLOT DEVICE TO X WINDOWS...
set_plot, 'X'
                                                                             
;SET THE NUMBER OF LINES YOU WANT IDL TO SAVE FOR UP-ARROW CALLBACK...
!EDIT_INPUT=200

; GET IDL COLOR INFORMATION AND SET UP SYSTEM VARIABLES WITH BASIC
; PLOT COLOR NAMES...
setcolors, /SYSTEM_VARIABLES, PSEUDO256=0, /silent, names=names
defsysv, '!grey', !gray
if wopen(0) eq 0 then window, 0, xsize=300, ysize=225 ;, retain=2
 
print, "We define the following colors. When using, precede each name by '!':"
print, names

; SET THE CURSOR TO A THIN CROSS (33) OR 
;*****tim's favorite***** THIN CROSS WITH DOT (129)...
; CARL'S PREFERENCE IS AN ARROW POINTER (46)
defsysv, '!cursor_standard', 46
device, CURSOR_STANDARD=!cursor_standard

; REDEFINE SOME KEYS...
define_key, /control, '^F', /forward_word
;print, 'Redefining CTRL-F : Move cursor forward one word'
define_key, /control, '^B', /back_word
;print, 'Redefining CTRL-B : Move cursor backward one word'
define_key, /control, '^K', /delete_eol
;print, 'Redefining CTRL-K : Delete to end of line'
define_key, /control, '^U', /delete_line
;print, 'Redefining CTRL-U : Delete to beginning of line'
define_key, /control, '^D', /delete_current
;print, 'Redefining CTRL-D : Delete current character under cursor'
define_key, /control, '^W', /delete_current
;print, 'Redefining CTRL-W : Delete word to left of cursor'
;print, 'using /dzd2/heiles/idl/gen/fast_init.pro'
