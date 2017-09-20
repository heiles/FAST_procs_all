common colors, r_orig, g_orig, b_orig, r_curr, g_curr, b_curr

SETENV,'SHELL=/bin/sh'


;------------------- BEFORE STARTING -------------------------
;------------------- BEFORE STARTING -------------------------
;if you have not defined the environment variable CARLPATH equal to the
;subdirectory in which this file is located, then co it here by
;uncommenting the following statement do it here using IDL, as follows:

SETENV,'CARLPATH=/home/heiles/idl/gen/'

; (where we are assuming that this files resides in /home/heiles/idl/gen)
;-------------------------------------------------------------
;-------------------------------------------------------------

print, 'STARTUP FILE IS .../idl/gen/idlstartup_school.pro'

;------------------------THE USUAL PATHS---------------------------

;MAKE SURE WE COMPILE OUR OWN VERSIONS OF ADDPATH AND WHICH...
!path= expand_path( getenv( 'CARLPATH') + 'idl/gen/path/') + ':' + !path
.run addpath
.run which
addpath, getenv( 'CARLPATH')+ 'idl/gen', /expand

;OBSERVATORY COORDINATES for FAST...
defsysv, '!obsnlat', 25.652939d0
defsysv, '!obselong', 106.856594d0
defsysv, '!obswlong', 360.d0 - 106.856594d0

;-------------------DO I\O STABDARD IDL SETUP STUFF----------------------

; WE'RE GOING TO SET THE PLOT DEVICE TO X WINDOWS...
set_plot, 'X'
                                                                                
; SET THE NUMBER OF LINES YOU WANT IDL TO SAVE FOR UP-ARROW CALLBACK...
!EDIT_INPUT=200

; SET THE X WINDOWS VISUAL CLASS...
;repeat begin &$
;   print, format = $
;'($," <t>rue, <d>irect, <n>othing, or <s>ystem: ")' &$
;   mode = strlowcase(get_kbrd(1)) & print &$
   mode = 't'
;   case (mode) of &$
;     't' : device, True_Color=24,   retain=2 &$     ; TRUECOLOR
;     'n' : print, 'no visual class selected' &$
;     'q' : exit &$
;    else : if (mode ne 's') then print, 'Try again! (<q> to quit!)' &$
;   endcase &$
;endrep until (strpos('gp2tdns',mode) ne -1)

; USE UNDOCUMENTED DEVELOPERS KEYWORD /INSTALL_COLORMAP TO ENSURE
; PROPER DIRECTCOLOR BEHAVIOR ON LINUX MACHINES...
if ( mode ne 'n') then if strmatch(getenv('OSTYPE'),'linux') then device, /INSTALL_COLORMAP

; GET IDL COLOR INFORMATION AND SET UP SYSTEM VARIABLES WITH BASIC
; PLOT COLOR NAMES...
if ( mode ne 'n') then setcolors, /SYSTEM_VARIABLES, PSEUDO256=(mode eq '2')
if ( mode ne 'n') then $
        defsysv, '!pcolr', [!gray, !red, !green, !blue, !yellow, !magenta, !cyan, $
        !orange, !forest, !purple]
if ( mode ne 'n') then defsysv, '!grey', !gray
 
;stop
                                                                                
; SET THE CURSOR TO A THIN CROSS (33) OR 
;*****tim's favorite***** THIN CROSS WITH DOT (129)...
; CARL'S PREFERENCE IS AN ARROW POINTER (46)
defsysv, '!cursor_standard', 46
if ( mode ne 'n') then device, CURSOR_STANDARD=!cursor_standard
if ( mode ne 'n') then window, 0, xsize=300, ysize=225 ;, retain=2
if ( mode ne 'n') then window, 1, xsize=300, ysize=225 ;, retain=2

delvar, mode
                                                                                
; BELOW I'M REDEFINING SOME KEY COMBINATIONS...
; GET RID OF THE PRINT LINES IF THE OUTPUT BUGS YOU...
; OR GET RID OF THE DEFINITIONS IF YOU'RE NOT GOING TO USE THEM...
                                                                                
; REDEFINE SOME KEYS...
define_key, /control, '^F', /forward_word
print, 'Redefining CTRL-F : Move cursor forward one word'
define_key, /control, '^B', /back_word
print, 'Redefining CTRL-B : Move cursor backward one word'
define_key, /control, '^K', /delete_eol
print, 'Redefining CTRL-K : Delete to end of line'
define_key, /control, '^U', /delete_line
print, 'Redefining CTRL-U : Delete to beginning of line'
define_key, /control, '^D', /delete_current
print, 'Redefining CTRL-D : Delete current character under cursor'
define_key, /control, '^W', /delete_current
print, 'Redefining CTRL-W : Delete word to left of cursor', format='(A,%"\N")'

print, 'to use a 256-entry color table, turn off decomposed color: DEVICE, DEC=0'
print, ''
print, 'STARTUP FILE IS .../idl/gen/idlstartup_school.pro'
