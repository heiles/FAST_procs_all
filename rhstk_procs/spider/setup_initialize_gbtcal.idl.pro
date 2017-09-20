;SETUPCROSS_GBTCAL.IDL.PRO.

;+
;PURPOSE:
;	Set up and initialize parameters that need it done only at the
;very beginning of using this program.

;OUTPUTS:
;	SCNDATA, a structure containing various info about the scan pattern.
;
;	AND some other variables that determine whether things are
;displayed/printed as the program runs or not. 
;-

;---------------- BEGIN USER INPUT PARAMETERS-------------------
;DEFINE THE NR OF CHNLS YOU EXPECT...
;nchnls = 256

;DEFINE THE NR OF PTS PER STRIP THAT YOU EXPECT...
ptsperstrip= 80
;ptsperstrip= 40
;ptsperstrip= 39
ptsforcal=4

;---------------- END USER INPUT PARAMETERS-------------------

;;CHNL RANGE TO INTEGRATE FOR GETTING CONTINUUM...
;skel=indgen(nchnls)
;contchnls = [skel[ nchnls/16: 15*(nchnls/16)]]
;ncontchnls= n_elements( contchnls)
;
;;WE WILL USE THE SAME CHANNELS TO GET BOTH GAIN AND PHASE...
;phasechnls= contchnls
;gainchnls= contchnls 

;DEFINE THE STRUCTURES...
@hdrMueller_carl.h

; THIS FLUXCOM STUFF IS NEVER IMPLEMENTED IN OUR CODE...
;---------- DEFINE THE SOURCE FLUX DESIDERATA --------
common fluxcom, fluxdata, fluxcominit, fluxfilename, salterfilename
afluxsrc= {fluxdata,$
    name    : ' '   ,$; source name
    code    :  0    ,$; code 1-good,2-bad,3-from flux.ca
    coef    :  fltarr(3),$;
    rms     :  0.   ,$; rms of fit to data
    notes   : ' '   }

filepath=  getenv('GBTPATH')
fluxfilename= filepath+ '/procs/fluxes/fluxsrc.dat'
salterfilename= filepath+ '/procs/fluxes/calibrators'


;----------DEFINE THE SCNDATA STRUCTURE---------------
;	WHICH CONTAINS THE EXPECTED NR CHNLS,
;	CHNLS TO USE FOR CONTINUUM, SPECIFIED CAL VALUES, ETC.
;CHANGE TO 12O, WHICH IS WHAT IT SHOULD BE...
@scndata.h
;scndata= {mueller}

;CHNLS TO USE FOR CONTINUUM, ALSO FOR CALIBRATION...
scndata.badfraction_lowend= 1./16.
scndata.badfraction_hiend= 1./16.

;scndata.nchnls= nchnls
;scndata.chnls= contchnls
;scndata.phasechnls= contchnls
;scndata.gainchnls= contchnls

;THE EXPECTED NR OF POINTS PER STRIP, NR POINTS WITH CAL...
scndata.ptsperstrip= ptsperstrip
scndata.ptsforcal= ptsforcal
scndata.nrstrips= 4
totpts= scndata.ptsperstrip+ scndata.ptsforcal

; JUN 26 2007: TR ADDS DEFAULT DPDF SETTING...
scndata.dpdf = +0.10

; CARLON GIVES THE CENTRAL TWO POSITIONS IN A STRIP...
carlon= [scndata.ptsforcal/2+ ptsperstrip/2, $
	scndata.ptsforcal/2+ ptsperstrip/2+ 1]
; ONSCANS IS NOW THE CENTRAL TWO POSITIONS IN EACH STRIP FOR AN ENTIRE
; SPIDER SCAN, I.E., THE FIRST FOUR STRIPS (THESE ARE THE INDICES FOR ONLY
; THE FIRST SPIDER SCAN)...
ONSCANS= [ [carlon], totpts+ [carlon], 2*totpts+ [carlon], $
           3*totpts+ [carlon]]

; CARLOFF GIVES THE FIRST AND LAST POSITIONS IN A STRIP...
carloff= [scndata.ptsforcal/2 , scndata.ptsforcal/2 +ptsperstrip-1]
; OFFSCANS IS NOW THE FIRST AND LAST POSITIONS IN EACH STRIP FOR AN ENTIRE
; SPIDER SCAN, I.E., THE FIRST FOUR STRIPS (THESE ARE THE INDICES FOR ONLY
; THE FIRST SPIDER SCAN)...
OFFSCANS= [ [carloff], totpts+ [carloff], 2*totpts+ [carloff], $
           3*totpts+ [carloff]]

; THE SUBSCAN INDICES FOR ON-SOURCE-PEAK AND OFF-SOURCE...
scndata.onscans = onscans
scndata.offscans = offscans

;!!!!!!!!!!!!!!!!!!!  
; THIS WILL FAIL FOR SPECTROMETER DATA, WHERE CALON IS NOW TAKEN BEFORE
; CALOFF!!! SO WE SWAP THE INDXCALON/INDXCALOFF (ONLY ONCE!) IN THE
; DOIT.IDL SCRIPTS AFTER THE FILENAME HAS BEEN DEFINED (WE CAN'T TELL
; WHETHER TO MAKE THE SWAP UNTIL THE FILENAME HAS BEEN DETERMINED)

; CAL ON AND OFF indices within a set of 4 scans...
; THESE CONTAIN ONLY THE CALON AND CALOFF POSITIONS FOR THE FIRST SPIDER
; SCAN, I.E., THE FIRST 4 STRIPS...
; HARDWIRE CALOFF,ON PAIR AT BEGINNING AND END OF STRIP DATA...
bx= [1, totpts-1]
indxcalon= [ bx, bx+totpts, bx+2*totpts, bx+3*totpts]
indxcaloff= indxcalon-1
scndata.indxcalon = indxcalon
scndata.indxcaloff = indxcaloff

;;---------DEFINE BEAMIN, BEAMOUT STRUCTURES------------
;@beaminout.h

;---------DEFINE VARIABLES THAT CONTROL THE OUTPUT DISPLAY-------

;KEYWAIT NONZERO SAYS STOP AFTER EVERY SCAN AND WAIT FOR A KEYSTROKE
;       BEFORE CONTINUING.
keywait=0

;NOPLOT = N SAYS PLOT THE PHASE CAL EVERY NTH TIME
noplot = 10l
noplot = 1l 
noplot = 0  

;---------IN MUELLER0, SPECIFY WHETHER TO PRINT, PLOT, KEYWAIT----------
noplott = 1
keywaitt= 0

;POINT TO WINDOW 0
device, window=opnd
if (opnd[0] ne 0) then wset,0

