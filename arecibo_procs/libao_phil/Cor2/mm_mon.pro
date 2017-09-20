;+
;NAME:
;mm_mon - monitor online datataking calibration scans
;SYNTAX: @mm_mon
;ARGS:
;   If the following variables are setn they will be used rather thean
; the defaults:

;  startscan=scannumber if you don't want to start at the beginnning.
;  usecal=1  By default the gui uses /share/olcor/calfile to write calibrate
;            scans. When you are doing long tracks on sources the line oriented
;            code used /share/olcor/corfile for the output file.  By default
;            the code used corfile. To use calfile set usecal=1 before running 
;            the script.
;  usebrd=n  By default board 0 is used. setting this varible will proces
;            a different board (0..3)
;useextfile  If set then the user is supplying the external filename in the
;            variable extfile. I you want to switch back to the online
;            files, be sure and set this variable to zero.
;
;You need to use carls startup script if you are using this routine:
;setenv IDL_STARTUP ~heiles/allcal/idlprocs/xxx/start_cross3.idl
;before you start idl.
;-
;ALLCAL.IDL. QUICK-LOOK REDUCTION OF CORCROSSCH DATA
;INVOKE THIS FILE WHEN YOU DEFINE THE DISK FILE NAME.
;AFTER THAT, JUST DEFINE STARTSCAN AND BOARD AND TYPE @goallcal,
;   as in the last few lines below.
retall
@~heiles/allcal/idlprocs/xxx/start_cross3.idl

;DEFINE COMMON VARIABLES, AND SOME OTHER IMPORTANT NUMBERS...
@~heiles/allcal/idlprocs/xxx/setupcross_allcal.idl

;COMPILE THE PROCS THAT DO HIGHER-ORDER STUFF...
.run print_hdr
.run beam_describe
.run sqfit_allcal
.run xpyfit_allcal
.run get_offsets
.run print_beamfits
.run plot_beamfits
.run cross3_gencal
.run phasecal_allcal

;DEFINE THE DATAPATH AND READ THE ENTIRE FILE FOR THE FIRST TIME...
;DEFINE THE INPUT FILENAME...
datapath = '/share/olcor/'

useextfileL=keyword_set(useextfile)
if useextfileL  then filename = extfile 
if keyword_set(usecal) and (not useextfileL) then $
            filename = datapath + 'calfile'
if (not keyword_set(usecal)) and (not useextfileL) $
    then filename = datapath + 'corfile'

;******************** USE THE LINES BELOW ONLY FOR 430 CH ******************
;********* COMMENT TNEM OUT FOR THE OTHER RECEIVERS!!!! *******************
tcalxx_board = 27.5 + fltarr(4)
tcalyy_board = 39
tcalxx_430ch = 47.5 
tcalyy_430ch = 31. 
tcalxx_board = 31 +fltarr(4)
tcalyy_board = 31 +fltarr(4)

if not keyword_set(use430ch) then tcalxx_board = -[ 10.77,10.81,10.64,10.33]
if not keyword_set(use430ch) then tcalyy_board = -[ 9.18, 9.38, 9.32, 9.62]



;FOR TESTING...

sl=0
free_lun, lun
close, lun

openr, lun, filename, /get_lun

board=0
if n_elements(usebrd) gt 0 then board=usebrd
if not keyword_set(startscan) then startscan=0
print,'Using board:',board
cross3_gencal, board, startscan=startscan,/monitor

