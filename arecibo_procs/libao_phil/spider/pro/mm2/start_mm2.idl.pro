;THIS IS THE STARTUP FILE THAT YOU SHOULD USE WITH MUELLER0 ROUTINES...
;02nov02 <pjp001> addpath now phils version, ~heiles-> /home/heiles
print, 'THIS IS START_MM2.IDL'

common colors, r_orig, g_orig, b_orig, r_curr, g_curr, b_curr
common plotcolors, black, red, green, blue, cyan, magenta, yellow, white, grey 

!PATH = '/home/heiles/newcal/idlprocs/carls:' + !path

;addpath, '/home/phil/idl/Cor2'
;addpath, '/home/phil/idl/gen'
;addpath, '/home/phil/idl/h'
addpath, '/home/heiles/newcal/idlprocs/carls'
addpath, '/home/heiles/newcal/idlprocs/mm0'
addpath, '/home/heiles/newcal/idlprocs/mm2'
addpath, '/home/heiles/newcal/rcvrfiles'
addpath, '/home/heiles/newcal/plotting'

;print, 'setting nr lines saved to 100...'
!edit_input = 100

nrbits = '8'
print, string(7b)
;read, nrbits, prompt='0, pseudo, pseudo256, true, or direct: '
nrbits = 'pseudo'

.run start_setcolor.idlprc
if (nrbits ne '0') then plotcolors

define_key, /control, '^D', /delete_current
;print, 'redefining CTRL-D!!!!'

define_key, /control, '^K', /delete_eol
;print, 'redefining CTRL-K!!!!'

;@corinit

@aostart.idl

;@setup_initialize_mm2.idl

window, 0, xs=300, ys=225
window, 1, xs=300, ys=225

;plotcolors

