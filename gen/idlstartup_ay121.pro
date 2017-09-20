common colors, r_orig, g_orig, b_orig, r_curr, g_curr, b_curr

print, 'STARTUP FILE IS /home/global/ay121/idl/gen/idlstartup_ay121.pro

;------------------------THE USUAL PATHS---------------------------

;MAKE SURE WE COMPILE OUR OWN VERSIONS OF ADDPATH AND WHICH...

setenv, 'AY121PATH=/home/global/ay121/'

!path= expand_path( getenv( 'AY121PATH') + 'idl/gen/path/') + ':' + !path
.run addpath
.run which

;ADD IDL NATIVE UTILITIES...
;addpath, getenv('IDL_DIR') + '/lib/utilities'

addpath, getenv( 'AY121PATH')+ 'idl/ay120coords'
addpath, getenv( 'AY121PATH')+ 'idl/chart'
addpath, getenv( 'AY121PATH')+ 'idl/pc'
addpath, getenv( 'AY121PATH')+ 'idl/xband', /expand

addpath, getenv( 'AY121PATH')+ 'idl/CodeIDL'
addpath, getenv( 'AY121PATH') + 'idl/goddard'
addpath, getenv( 'AY121PATH')+ 'idl/goddard_jan2007', /expand
addpath, getenv( 'AY121PATH')+ 'idl/idlutils', /expand
addpath, getenv( 'AY121PATH')+ 'idl/colortest'
addpath, getenv( 'AY121PATH')+ 'idl/gen', /expand

;OBSERVATORY COORDINATES...
;@/home/heiles/pro/carls/aostart.idl
print, 'loading CAMPBELL HALL coordinates into COMMON ANGLESTUFF'
common anglestuff, obslong, obslat, cosobslat, sinobslat
obslong = ten(122.,9.,24.)
obslat = ten(37.,55.,6.)
cosobslat = cos(!dtor*obslat)
sinobslat = sin(!dtor*obslat)
defsysv, '!obsnlat', obslat
defsysv, '!obselong', 360.-obslong
defsysv, '!obswlong', obslong

;WHOAMI FOR TELESCOPE OPS...
defsysv, '!whoami', 'nobody'

;-------------------DI\O STABDARD IDL SETUP STUFF----------------------

; WE'RE GOING TO SET THE PLOT DEVICE TO X WINDOWS...
set_plot, 'X'
                                                                               ; SET THE NUMBER OF LINES YOU WANT IDL TO SAVE FOR UP-ARROW CALLBACK...
!EDIT_INPUT=200

;; COMPILE COLOR TABLE ROUTINES...
;.compile setcolors, stretch
 

; LET OPERATING SYSTEM TAKE CARE OF BACKING STORE...
mode= 't'
device, RETAIN=2

; USE UNDOCUMENTED DEVELOPERS KEYWORD /INSTALL_COLORMAP TO ENSURE
; PROPER DIRECTCOLOR BEHAVIOR ON LINUX MACHINES...
if ( mode ne 'n') then if strmatch(getenv('OSTYPE'),'linux') then $
        device, /INSTALL_COLORMAP

if ( mode ne 'n') then begin &$
    print, 'setting color decomposition OFF (meaning: setting a 256-entry colortable)' &$
      device, decomposed=0 &$
      setcolors, /SYSTEM_VARIABLES, /silent &$
endif

print, ''
if ( mode ne 'n') then print, 'WE DEFINE THE FOLLOWING COLORS: ', $
               '!black , ',  $
               '!red , ' ,   $
               '!orange , ', $
               '!green , ' ,  $
               '!forest , ', $
               '!yellow , ', $
               '!cyan , ',   $
               '!blue , ',   $
               '!magenta , ',$
               '!purple , ', $
               '!gray , ',   $
               '!white'

if ( mode ne 'n') then print, 'and WE DEFINE THE VECTOR !pcolr, which contains 10 of the above colors that are useful in most plots'

if ( mode ne 'n') then $
        defsysv, '!pcolr', [!gray, !red, !green, !blue, !yellow, !magenta, !cyan, $
        !orange, !forest, !purple]
 
; SET THE CURSOR TO A THIN CROSS (33) OR 
;*****tim's favorite***** THIN CROSS WITH DOT (129)...
; CARL'S PREFERENCE IS AN ARROW POINTER (46)
defsysv, '!cursor_standard', 46
if ( mode ne 'n') then device, CURSOR_STANDARD=!cursor_standard
if ( mode ne 'n') then window, 0, xsize=300, ysize=225, retain=2
if ( mode ne 'n') then window, 1, xsize=300, ysize=225, retain=2

delvar, mode
                                                                               ; BELOW I'M REDEFINING SOME KEY COMBINATIONS...
print, ''
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
print, 'Redefining CTRL-W : Delete word to left of cursor'
print, 'Redefining CTRL-A : Move cursor to beginning of line'
print, 'Redefining CTRL-E : Move cursor to end of line'

DEFSYSV, '!grey', !gray

;------------------------------------------
;device, decomposed=0
;setcolors, /sys
;print
;print
;print, 'THE DEFAULT IS NONDECOMPOSED COLORS (comgined color: 256 colors'
;print
;print, 'to use DECOMPOSED color (''millions of colors''), turn on decomposed color and set system colors by typing...'
;print, '           device, /decomposed'
;print, '           setcolors, /sys'
;print
;--------------------------------------------

device, decomposed=1
setcolors, /sys
print
print
print, 'THE DEFAULT IS DECOMPOSED COLORS ((''millions of colors'')'
print
print, 'to use NONDECOMPOSED color (combined color: 256 colors), turn off decomposed color and set system colors by typing...'
print, '           device, decomposed=0'
print, '           setcolors, /sys'
print

print, ''
print, 'STARTUP FILE IS /home/global/ay121/idl/gen/idlstartup_ay121.pro
print, ''
