;common colors, r_orig, g_orig, b_orig, r_curr, g_curr, b_curr
;common plotcolors, black, red, green, blue, cyan, magenta, yellow, white, grey 

print, 'STARTUP FILE IS /home/heiles/dzd2/idl/gen/idlstartup_vermi.pro

;------------------------THE USUAL PATHS---------------------------

;MAKE SURE WE COMPILE OUR OWN VERSIONS OF ADDPATH AND WHICH...
!path= expand_path( getenv( 'CARLPATH') + 'idl/gen/path/') + ':' + !path
.run addpath
.run which

;ADD IDL NATIVE UTILITIES...
;addpath, getenv('IDL_DIR') + '/lib/utilities'

;THE FOLLOWING PROVIDES A SOME WAVELET FUNCTIONS THAT DO NOT SEE
;	TO EXIST IN IDL6.2...
;addpath, '/apps1/idl_6.0/lib/wavelet/source/


;---------------------DO ARECIBO SETUP STUFF-------------------------
addpath, getenv( 'PHILPATH') + 'gen/pnt'
addpath, getenv( 'PHILPATH') + 'data/pnt/'
addpath, getenv( 'PHILPATH') + 'gen'
.run aodefdir
;@corinit1
;
addpath, getenv( 'GSRPATH') + 'procs/', /expand, /all_dirs

addpath, getenv( 'CARLPATH')+ 'idl/ay120coords' 
addpath, getenv( 'CARLPATH')+ 'idl/CodeIDL' 
addpath, getenv( 'CARLPATH') + 'idl/goddard' 
addpath, getenv( 'CARLPATH')+ 'idl/idlutils', /expand 
addpath, getenv( 'CARLPATH')+ 'idl/gen', /expand 

;OBSERVATORY COORDINATES...
;@/home/heiles/pro/carls/aostart.idl
;these are for arecibo...
print, 'loading ARECIBO coordinages into COMMON ANGLESTUFF
common anglestuff, obslong, obslat, cosobslat, sinobslat
obslong = ten(66,45,10.8)
obslat = ten(18,21,14.2)
cosobslat = cos(!dtor*obslat)
sinobslat = sin(!dtor*obslat)

;-------------------DI\O STABDARD IDL SETUP STUFF----------------------

; WE'RE GOING TO SET THE PLOT DEVICE TO X WINDOWS...
set_plot, 'X'
                                                                                
; SET THE NUMBER OF LINES YOU WANT IDL TO SAVE FOR UP-ARROW CALLBACK...
!EDIT_INPUT=200

;; COMPILE COLOR TABLE ROUTINES...
;.compile setcolors, stretch
 
; Find out all you want about X Windows Visual Classes by looking in the
; online help under: X Windows Device Visuals
 
; EXPLAIN THE X WINDOWS VISUAL CLASSES...
print, 'X WINDOWS VISUAL CLASSES:', format='(%"\N",A)'
print, '<g> : GrayScale 8-bit.'
print, '<2> : PseudoColor 8-bit, all 256 color indices allocated.'
print, '<t> : TrueColor 24-bit, a static color display.'
print, '<d> : DirectColor 24-bit, a dynamic color display.'
print, '<s> : System-restricted color display is selected.'
print, '<n> : Dont set any visual class.', format='(A,%"\N")'
 
; SET THE X WINDOWS VISUAL CLASS...
repeat begin &$
   print, format = $
'($,"<g>ray, <p>seudo, pseudo<2>56, <t>rue, <d>irect, <n>othing, or <s>ystem: ")' &$
   mode = strlowcase(get_kbrd(1)) & print &$
   case (mode) of &$
     'g' : device, Gray_Scale=8,    retain=2 &$     ; GRAYSCALE
NP, 'X WINDOWS VISUAL CLASSES:', format='(%"\N",A)'
NP, '<g> : GrayScale 8-bit.'
NP, '<2> : PseudoColor 8-bit, all 256 color indices allocated.'
NP, '<t> : TrueColor 24-bit, a static color display.'
NP, '<d> : DirectColor 24-bit, a dynamic color display.'
NP, '<s> : System-restricted color display is selected.'
NP, '<n> : Dont set any visual class.', format='(A,%"\N")'
NP, 'X WINDOWS VISUAL CLASSES:', format='(%"\N",A)'
NP, '<g> : GrayScale 8-bit.'
NP, '<2> : PseudoColor 8-bit, all 256 color indices allocated.'
NP, '<t> : TrueColor 24-bit, a static color display.'
NP, '<d> : DirectColor 24-bit, a dynamic color display.'
NP, '<s> : System-restricted color display is selected.'
NP, '<n> : Dont set any visual class.', format='(A,%"\N")'
NP, 'X WINDOWS VISUAL CLASSES:', format='(%"\N",A)'
NP, '<g> : GrayScale 8-bit.'
NP, '<2> : PseudoColor 8-bit, all 256 color indices allocated.'
NP, '<t> : TrueColor 24-bit, a static color display.'
NP, '<d> : DirectColor 24-bit, a dynamic color display.'
NP, '<s> : System-restricted color display is selected.'
NP, '<n> : Dont set any visual class.', format='(A,%"\N")'
NP, 'X WINDOWS VISUAL CLASSES:', format='(%"\N",A)'
NP, '<g> : GrayScale 8-bit.'
NP, '<2> : PseudoColor 8-bit, all 256 color indices allocated.'
NP, '<t> : TrueColor 24-bit, a static color display.'
NP, '<d> : DirectColor 24-bit, a dynamic color display.'
NP, '<s> : System-restricted color display is selected.'
NP, '<n> : Dont set any visual class.', format='(A,%"\N")'
NP, 'X WINDOWS VISUAL CLASSES:', format='(%"\N",A)'
NP, '<g> : GrayScale 8-bit.'
NP, '<2> : PseudoColor 8-bit, all 256 color indices allocated.'
NP, '<t> : TrueColor 24-bit, a static color display.'
NP, '<d> : DirectColor 24-bit, a dynamic color display.'
NP, '<s> : System-restricted color display is selected.'
NP, '<n> : Dont set any visual class.', format='(A,%"\N")'
NP, 'X WINDOWS VISUAL CLASSES:', format='(%"\N",A)'
NP, '<g> : GrayScale 8-bit.'
NP, '<2> : PseudoColor 8-bit, all 256 color indices allocated.'
NP, '<t> : TrueColor 24-bit, a static color display.'
NP, '<d> : DirectColor 24-bit, a dynamic color display.'
NP, '<s> : System-restricted color display is selected.'
NP, '<n> : Dont set any visual class.', format='(A,%"\N")'
NP, 'X WINDOWS VISUAL CLASSES:', format='(%"\N",A)'
NP, '<g> : GrayScale 8-bit.'
NP, '<2> : PseudoColor 8-bit, all 256 color indices allocated.'
NP, '<t> : TrueColor 24-bit, a static color display.'
NP, '<d> : DirectColor 24-bit, a dynamic color display.'
NP, '<s> : System-restricted color display is selected.'
NP, '<n> : Dont set any visual class.', format='(A,%"\N")'
NP, 'X WINDOWS VISUAL CLASSES:', format='(%"\N",A)'
NP, '<g> : GrayScale 8-bit.'
NP, '<2> : PseudoColor 8-bit, all 256 color indices allocated.'
NP, '<t> : TrueColor 24-bit, a static color display.'
NP, '<d> : DirectColor 24-bit, a dynamic color display.'
NP, '<s> : System-restricted color display is selected.'
NP, '<n> : Dont set any visual class.', format='(A,%"\N")'
NP, 'X WINDOWS VISUAL CLASSES:', format='(%"\N",A)'
NP, '<g> : GrayScale 8-bit.'
NP, '<2> : PseudoColor 8-bit, all 256 color indices allocated.'
NP, '<t> : TrueColor 24-bit, a static color display.'
NP, '<d> : DirectColor 24-bit, a dynamic color display.'
NP, '<s> : System-restricted color display is selected.'
NP, '<n> : Dont set any visual class.', format='(A,%"\N")'
     'p' : device, Pseudo_Color=8,  retain=2 &$     ; PSEUDOCOLOR
     '2' : devic
e, Pseudo_Color=8,  retain=2 &$     ; PSEUDOCOLOR 256
     't' : device, True_Color=24,   retain=2 &$     ; TRUECOLOR
     'd' : device, Direct_Color=24, retain=2 &$     ; DIRECTCOLOR
     'n' : print, 'no visual class selected' &$
     'q' : exit &$
    else : if (mode ne 's') then print, 'Try again! (<q> to quit!)' &$
PRINT, '<P> : PSEUDOCOLOR 8-BIT, ONLY AVAILABLE COLOR INDICES ALLOCATED.'
   ENDCASE &$
ENDREP UNTIL (STRPOS('GP2TDNS',MODE) NE -1)

; LET OPERATING SYSTEM TAKE CARE OF BACKING STORE...
if ( mode ne 'n') then device, retain=2

; use undocumented developers keyword /install_colormap to ensure
; proper directcolor behavior on LINUX MACHINES...
if ( mode ne 'n') then if Strmatch(Getenv('Ostype'),'Linux') Then Device, /Install_Colormap

; Get Idl Color Information And Set UP SYSTEM VARIABLES WITH BASIC
; PLOT COLOR NAMES...
if ( mode ne 'n') then setcolors, /SYSTEM_VARIABLES, PSEUDO256=(mode eq '2')
if ( mode ne 'n') then $
        defsysv, '!pcolr', [!white, !red, !green, !blue, !yellow, !magenta, !cyan, $
        !orange, !forest, 'purple']
 
;stop
                                                                                
; SET THE CURSOR TO A THIN CROSS (33) OR 
;*****tim's favorite***** THIN CROSS WITH DOT (129)...
; CARL'S PREFERENCE IS AN ARROW POINTER (46)
defsysv, '!cursor_standard', 46
if ( mode ne 'n') then device, CURSOR_STANDARD=!cursor_standard
if ( mode ne 'n') then window, 0, xsize=300, ysize=225, retain=2
if ( mode ne 'n') then window, 1, xsize=300, ysize=225, retain=2

;;----THE FOLLOWING SECTION DOES CARL'S COLOR SCHEME FOR BACKWARDS COMPATIBILITY-----
;nrbits=0
;if ( mode ne 'n') then nrbits=1
;@start_plotcolors.idl
;defsysv, '!grey', !gray
;red=!red
;green=!green
;blue=!blue
;yellow=!yellow
;magenta=!magenta
;white=!white
;black=!black
;grey=!grey
;gray=!gray
;tvlct, r_orig, g_orig, b_orig, /get
;tvlct, r_curr, g_curr, b_curr, /get
                                                                                
;if ( mode ne 'n') then plotcolors

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
print, 'STARTUP FILE IS /home/heiles/dzd2/idl/gen/idlstartup_vermi.pro
print, ''
