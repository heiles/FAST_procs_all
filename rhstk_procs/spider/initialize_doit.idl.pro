@setup_initialize_gbtcal.idl
@muellerparams_carl.h
;the following sets up initial guesses for the nonlinear least-squares
;fit that calculates the mueller matrix parameters. if that fit doesn't
;converge, you might want to try different initial guesses.
;@muellerparams_init.idl

if wopen(0) eq 0 then window,0,xs=200,ys=200
if wopen(1) eq 0 then window,1,xs=200,ys=200

print, 'begin restore...', gbtdatapath+ gbtdatafile
begintime= systime(1)
restore, gbtdatapath+ gbtdatafile, /ver
print, 'restore took ', systime(1)- begintime, ' seconds'

scndata.ptsperstrip= n_elements( strip[0].subscan)
totpts= scndata.ptsperstrip+ scndata.ptsforcal
; CARLON GIVES THE CENTRAL TWO POSITIONS IN A STRIP...
carlon= [scndata.ptsforcal/2+ ptsperstrip/2, $
        scndata.ptsforcal/2+ ptsperstrip/2+ 1]
; ONSCANS IS NOW THE CENTRAL TWO POSITIONS IN EACH STRIP FOR AN ENTIRE
; SPIDER SCAN, I.E., THE FIRST FOUR STRIPS (THESE ARE THE INDICES FOR
; ONLY THE FIRST SPIDER SCAN)...
ONSCANS= [ [carlon], totpts+ [carlon], 2*totpts+ [carlon], $
           3*totpts+ [carlon]]

; CARLOFF GIVES THE FIRST AND LAST POSITIONS IN A STRIP...
carloff= [scndata.ptsforcal/2 , scndata.ptsforcal/2 +ptsperstrip-1]
; OFFSCANS IS NOW THE FIRST AND LAST POSITIONS IN EACH STRIP FOR AN
; ENTIRE SPIDER SCAN, I.E., THE FIRST FOUR STRIPS (THESE ARE THE INDICES
; FOR ONLY THE FIRST SPIDER SCAN)...
OFFSCANS= [ [carloff], totpts+ [carloff], 2*totpts+ [carloff], $
           3*totpts+ [carloff]]
; THE SUBSCAN INDICES FOR ON-SOURCE-PEAK AND OFF-SOURCE...
scndata.onscans = onscans
scndata.offscans = offscans

;stop

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


; CHECK TO SEE IF THESE ARE ACS DATA...
; IF ACS, STRIP GOES CALON,CALOFF -> DATA -> CALON,CALOFF
; IF SP, STRIP GOES CALOFF,CALON -> DATA -> CALOFF, CALON
swap_calonoff_acs, gbtdatafile, scndata

;stop

board= getboardnr( gbtdatafile)
sourcename= getsourcename( gbtdatafile)
rcvr_name= getrcvrname( gbtdatafile)

