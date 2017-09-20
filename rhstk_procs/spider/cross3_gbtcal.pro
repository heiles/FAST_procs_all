 pro cross3_gbtcal, boardspecified, scndata, nrc,   $ 
        calbefore, strip, calafter, $ 
	tcalxx, tcalyy, cfr, scannr0, sourcename, stokesc1, $
	ozerofinal, oslopefinal, srcozerofinal, srcoslopefinal, $
	azmidpnt, zamidpnt, $
	cumcorr= cumcorr, totalquiet= totalquiet, phaseplot= phaseplot, $
	nocal=nocal

;+

;PROCESSES ALL FOUR STRIPS IN A SINGLE PATTERN
;it calibrates using calon-caloff
;THE CAL IS USED FOR TWO PURPOSES:

;	1. AMPLITUDE CALIBRATION. This assumes that the gain of each
;spectral channel is proportional to the power in the cal-off spectrum.
;It then determines the temperature scale from the cal deflection and the
;values of tcalxx, tcalyy, which are the cal values as found either from
;phil's file or inputted by the user.

;	If the cal value in the arrays tcalxx_board and tcalyy_board is
;negative, it uses the value from Phil's files. It it is positive, it
;uses that value. 

;	2. PHASE CALIBRATION. If the system has a correlated cal
;(nocal=0 as determined from the routine getrcvr.pro), then it assumes
;the cal phase is zero and corrects all 240 phases to the cal phase. this
;phase calibration includes a linear variation with frequency, using
;carl's patented routine! 

;*****INPUTS:

;	There are several inputs passed through the structure SCNDATA.  
;These are of the nature of which points in the strip to use for on source 
;and for off source values, and which points have the cal on and off. 
;Here are some of the more important:

;VARIABLES CONTAINED IN THE STRUCTURE SCNDATA:
;	INDXCALON, INDXCALOFF: the index numbers within the pattern for
;calon and caloff, equal to [0,0] and [1,1]. These are arrays because in
;principle there could be more than one index used for calibration; if
;there is only one, avoiding errors requires making them arrays with two
;identical elements.

;	ONSCANS, OFFSCANS: Arrays of index numbers within the pattern
;used for calculating source deflections, onsource - offsource.

;	DPDF, the initial guess for the phase slope in radians per MHz.
;The slope arises primarily in the i.f. and its sign depends on whether
;the final sideband is upper or lower; the program determines this from
;whether the spectrum is flipped. In the unlikely event that the slope
;becomes determined from other causes, this may need to be
;changed--however, the fitting routine is pretty robust and even a guess
;with the wrong sign isn't very serious in most (all?) cases.

;	TCALXX_BOARD, TCALYY_BOARD: See the above discussion of
;AMPLITUDE CALIBRATION.

;	CHNLS, PHASECHNLS, GAINCHNLS: the array of channels over which
;sums are taken to determine continuum power. Normally equals
;indgen(128). I always set these arrays equal to each other; some
;calculations use different ones, which allows different channels to be
;used for phase and intensity sums, but i'm not sure if this is
;consistently defined. If you want to make these arrays different, you
;need to check to see how the program differentiates between them, and
;whether it does so consistently. 

;OTHER INPUTS:
;
;	NRC: the pattern number (contains four strips)
;
;	DATA: the data structure
;
;*****OUTPUTS:
;
;	TCALXX, TCALYY: THE CAL TEMPS ACTUALLY USED.
;	CFR, THE CENTER FREQ
;	SCANNR0, THE SCAN NR OF THE FIRST STRIP IN THE PATTERN
;	SOURCENAME, THE SOURCE NAME
;	STOKESC1, the calibrated stokes parameters in order x+y, x-y,
;xy, yx (Re and Im crosscorrel products). Noe that this order differs 
;from the order of the UNCALIBRATED data.

;KEYWORDS:

;	set CUMCORR to excise interference from the calon/caloff spectra

;	set NOCAL to inhibit phase calibration by the cal. in this case
;it uses the source deflection. this is for testing only.

;	set PHASEPLOT to plot phase vs freq for each calibration.

;	TOTALQUIET suppresses all printed output for duncan

;HISTORY: 13feb2012, CH determined that:
;       for SPECTRAL PROCESSOR we must divide spectral numbers by inttime
;       for ACS, we must NOT divide by inttimeK
;program changed accordingly, see below.
;-

internal_scan_nr= 4* nrc

;DEFINE THE CALS...
IF ( SCNDATA.TCALXX_BOARD[BOARDSPECIFIED] GT 0.) THEN BEGIN
   tcalxx = scndata.tcalxx_board[boardspecified]
   tcalyy = scndata.tcalyy_board[ boardspecified]
ENDIF ELSE BEGIN
   tcalxx= strip[ internal_scan_nr].tcalxx
   tcalyy= strip[ internal_scan_nr].tcalyy
ENDELSE

scannr0= strip[ internal_scan_nr].scannum
sourcename= strip[ internal_scan_nr].sname
nchnls= strip[ internal_scan_nr].nchan

skel= lindgen(nchnls)
contchnls = [skel[ nchnls* scndata.badfraction_lowend: $
                   nchnls- nchnls* scndata.badfraction_hiend]]
gainchnls= contchnls
phasechnls= contchnls

;DEFINE THE CFR and FREQUENCY SCALE for phase fit...

;27JUL03: CHK FOR CFR BEING ARRAY INSTEAD OF A CONSTSANT...
cfr= strip[ internal_scan_nr].subscan[0].freq/1e6
if ( (size( cfr))[ 0] eq 1) then cfr= cfr[ 0]

fctr= (strip[ internal_scan_nr].subscan[0].bandwdth* $
       strip[ internal_scan_nr].subscan[0].bwsign)/ 1.0e6
freq = cfr+ $
       ( (findgen( nchnls)- ((nchnls/2)- 1))/(nchnls-1.))* fctr
frq = freq-cfr

dpdf_use = scndata.dpdf

;-----------------NOW FOR CALIBRATIONS------------------------------

;*******THE FOLLOWING SECTION DOES PROPER INTENSITY CALIBRATION******

if (keyword_set( totalquiet) ne 1) then $
print, 'PROCESSING SCAN NR, FREQ, BOARD, SRC ', scannr0,cfr, boardspecified, $
	sourcename, format='(a, i10, f9.1, i3, 3x, a)'

;DEFINE UNCAL AND CAL STOKES PARAMS FOR EACH PATTERN.
;THE CALIBRATED VERSION OF STOKES WILL BE STOKESC1.
;stokesc1 = fltarr( nchnls, 4, 8*scndata.ptsperstrip, /nozero)
;stokes= fltarr( nchnls, 4, 8*scndata.ptsperstrip)

stokes= fltarr( nchnls, 4, scndata.ptsforcal+ scndata.ptsperstrip, 4)
stokesc1= fltarr( nchnls, 4, (scndata.ptsforcal+ scndata.ptsperstrip)* 4)
azmidpnt= fltarr( scndata.ptsforcal+ scndata.ptsperstrip, 4)
zamidpnt= fltarr( scndata.ptsforcal+ scndata.ptsperstrip, 4)

;----------------- INTENSITY CALIBRAITON ----------------------------

totpts= scndata.ptsforcal+ scndata.ptsperstrip

;FOR THE SPECTRAL PROCESSOR, we must normallize the spectral numbers to
;the inttime.
if strip[0].backend eq 'SpectralProcessor' then begin
; GO THROUGH EACH STRIP IN SPIDER SCAN...
FOR NRSTRIP= 0,3 DO BEGIN 
   ;!!!!!!!!!!!!!!!!!!!!!!!!!!!
   ; HOW DOES THIS WORK OUT FOR PTSFORCAL IS > 4??
   ; THIS DEFINITELY LOOKS HARDWIRED TO HAVE ONE CALON/OFF PAIR
   ; I.E., IT SEEMS TO ASSUME PTSFORCAL = 4!!
   ;!!!!!!!!!!!!!!!!!!!!!!!!!!!!

   ; GET THE AZ/ZA VALUES FOR THE CALBEFORE...
   azmidpnt[ 0:1, nrstrip]= calbefore[ internal_scan_nr+ nrstrip].subscan.az
   zamidpnt[ 0:1, nrstrip]= calbefore[ internal_scan_nr+ nrstrip].subscan.za

   ; STORE STOKES PARAMS FOR FIRST OF CALBEFORE PAIR...
   stokes[ *,*, 0, nrstrip]= $
      calbefore[ internal_scan_nr+ nrstrip].subscan.spec[ *, 0, *]/ $
      calbefore[ internal_scan_nr+ nrstrip].inttime

   ; STORE STOKES PARAMS FOR SECOND OF CALBEFORE PAIR...
   stokes[ *,*, 1, nrstrip]= $
      calbefore[ internal_scan_nr+ nrstrip].subscan.spec[ *, 1, *]/ $
      calbefore[ internal_scan_nr+ nrstrip].inttime

   ; GET THE AZ/ZA VALUES FOR THE CALAFTER...
   azmidpnt[ totpts-2:totpts-1, nrstrip]= $
      calafter[ internal_scan_nr+ nrstrip].subscan.az
   zamidpnt[ totpts-2:totpts-1, nrstrip]= $
      calafter[ internal_scan_nr+ nrstrip].subscan.za

   ; STORE STOKES PARAMS FOR FIRST OF CALAFTER PAIR...
   stokes[ *,*, totpts-2, nrstrip]= $
      calafter[ internal_scan_nr+ nrstrip].subscan.spec[ *, 0, *]/ $
      calafter[ internal_scan_nr+ nrstrip].inttime

   ; STORE STOKES PARAMS FOR SECOND OF CALAFTER PAIR...
   stokes[ *,*, totpts-1, nrstrip]= $
      calafter[ internal_scan_nr+ nrstrip].subscan.spec[ *, 1, *]/ $
      calafter[ internal_scan_nr+ nrstrip].inttime

   ; GET THE AZ/ZA VALUES FOR THE STRIP...
   azmidpnt[ 2:totpts-3, nrstrip]= strip[ internal_scan_nr+ nrstrip].subscan.az
   zamidpnt[ 2:totpts-3, nrstrip]= strip[ internal_scan_nr+ nrstrip].subscan.za

   ; STORE STOKES PARAMS FOR THE STRIP...
   stokes[ *,*, 2:totpts-3, nrstrip]= $
      strip[ internal_scan_nr+ nrstrip].subscan.spec[ *,0, *]/ $
      strip[ internal_scan_nr+ nrstrip].inttime
ENDFOR
ENDIF ELSE BEGIN ;#######################################################

;FOR THE SPECTROMETER, the output nr is already normalized to inttime. 
; GO THROUGH EACH STRIP IN SPIDER SCAN...
FOR NRSTRIP= 0,3 DO BEGIN 
   ;!!!!!!!!!!!!!!!!!!!!!!!!!!!
   ; HOW DOES THIS WORK OUT FOR PTSFORCAL IS > 4??
   ; THIS DEFINITELY LOOKS HARDWIRED TO HAVE ONE CALON/OFF PAIR
   ; I.E., IT SEEMS TO ASSUME PTSFORCAL = 4!!
   ;!!!!!!!!!!!!!!!!!!!!!!!!!!!!

   ; GET THE AZ/ZA VALUES FOR THE CALBEFORE...
   azmidpnt[ 0:1, nrstrip]= calbefore[ internal_scan_nr+ nrstrip].subscan.az
   zamidpnt[ 0:1, nrstrip]= calbefore[ internal_scan_nr+ nrstrip].subscan.za

   ; STORE STOKES PARAMS FOR FIRST OF CALBEFORE PAIR...
   stokes[ *,*, 0, nrstrip]= $
      calbefore[ internal_scan_nr+ nrstrip].subscan.spec[ *, 0, *]

   ; STORE STOKES PARAMS FOR SECOND OF CALBEFORE PAIR...
   stokes[ *,*, 1, nrstrip]= $
      calbefore[ internal_scan_nr+ nrstrip].subscan.spec[ *, 1, *]

   ; GET THE AZ/ZA VALUES FOR THE CALAFTER...
   azmidpnt[ totpts-2:totpts-1, nrstrip]= $
      calafter[ internal_scan_nr+ nrstrip].subscan.az
   zamidpnt[ totpts-2:totpts-1, nrstrip]= $
      calafter[ internal_scan_nr+ nrstrip].subscan.za

;*********** note changes: 0.5*inttime for cals replaced by inttime
;            07feb2012 by ch
   ; STORE STOKES PARAMS FOR FIRST OF CALAFTER PAIR...
   stokes[ *,*, totpts-2, nrstrip]= $
      calafter[ internal_scan_nr+ nrstrip].subscan.spec[ *, 0, *]

   ; STORE STOKES PARAMS FOR SECOND OF CALAFTER PAIR...
   stokes[ *,*, totpts-1, nrstrip]= $
      calafter[ internal_scan_nr+ nrstrip].subscan.spec[ *, 1, *]

   ; GET THE AZ/ZA VALUES FOR THE STRIP...
   azmidpnt[ 2:totpts-3, nrstrip]= strip[ internal_scan_nr+ nrstrip].subscan.az
   zamidpnt[ 2:totpts-3, nrstrip]= strip[ internal_scan_nr+ nrstrip].subscan.za

   ; STORE STOKES PARAMS FOR THE STRIP...
   stokes[ *,*, 2:totpts-3, nrstrip]= $
      strip[ internal_scan_nr+ nrstrip].subscan.spec[ *,0, *];/ $
;      strip[ internal_scan_nr+ nrstrip].inttime
ENDFOR
ENDELSE

stokes= reform( stokes, nchnls, 4, (scndata.ptsforcal+ scndata.ptsperstrip)* 4)

;STOP, 'stop in cross3_gbtcal'

;CALIBRATE INTENSITIES...
scans=indgen( 4*totpts)

intensitycal_gbtcal_1, scndata, gainchnls, tcalxx, tcalyy, $
                       scans, scannr0, stokes, stokesc1, nchnls, $
                       cumcorr=cumcorr
;intensitycal_gbtcal, scndata, tcalxx, tcalyy, $
;	4*scndata.ptsperstrip, scannr0, stokes, stokesc1, nchnls, $
;	cumcorr=cumcorr

;STOP

;*************THE FOLLOWING SECTION DOES PROPER PHASE CALIBRATION **************
;FOR THIS, WE WILL USE THE CHANNEL RANGE SELECTED ABOVE.
;THE ZERO POINT IN FREQUENCY FOR THIS FIT IS FREQZERO, DEFINED ABOVE.

;IF NOCAL IS ****NOT**** SET (SAME AS NOCORRCAL BEING 0), THEN
;	PHASE-CORRECT ALL DATA TO THE OFF-SOURCE ***CAL*** DEFLECTION...
;IF NOCAL ***IS*** SET (SAME AS NOCORRCAL BEING 1), THEN
;	DETERMINE THE PHASE SLOPE FROM THE OFF-CAL SOURCE DEFLECTION AND 
;	SET THE PHASE ZERO TO ZERO.

;stop, 'one'

correctoption= 1
if (keyword_set( nocal) eq 1) then correctoption= -1
;if ( nocorrcal eq 1) then correctoption= -1
IF (correctoption eq 1) then BEGIN
   
   phasecal_newcal, scndata, frq, stokesc1, phasechnls, scans, $
        scndata.indxcalon, scndata.indxcaloff, correctoption, $
                    phase_cal_observed, ozerofinal, oslopefinal, $
                    cumcorr=cumcorr, totalquiet=totalquiet
   ;phasecal_gbtcal, scndata, dpdf_use, frq, stokesc1, phasechnls, $
   ;	4*scndata.ptsperstrip, $
   ;	scndata.indxcalon, scndata.indxcaloff, correctoption, $
   ;	phase_cal_observed, ozerofinal, oslopefinal, $
   ;	cumcorr=cumcorr
   
   ;stop,'two'
   
ENDIF ELSE BEGIN
   
   phasecal_newcal, scndata, frq, stokesc1, phasechnls, scans, $
                    scndata.onscans, scndata.offscans, correctoption, $
                    phase_cal_observed, ozerofinal, oslopefinal, $
                    cumcorr=cumcorr, totalquiet=totalquiet
   ;phasecal_gbtcal, scndata, dpdf_use, frq, stokesc1, phasechnls, $
   ;	4*scndata.ptsperstrip, $
   ;	scndata.onscans, scndata.offscans, correctoption, $
   ;	phase_cal_observed, ozerofinal, oslopefinal, $
;	cumcorr=cumcorr
ENDELSE

;NOW DETERMINE THE PHASE OF THE SOURCE DEFLECTION...
;stop
phasecal_newcal, scndata, frq, stokesc1, phasechnls, scans, $
                 scndata.onscans, scndata.offscans, 0, $
                 phase_src_observed, srcozerofinal, srcoslopefinal, $
                 cumcorr=cumcorr, totalquiet=totalquiet

;phasecal_newcal, scndata, frq, stokesc1, phasechnls, scans, $
;        scndata.indxcalon, scndata.indxcaloff, 0, $
;        phase_src_observed, srcozerofinal, srcoslopefinal, $
;        cumcorr=cumcorr
;phasecal_gbtcal, scndata, dpdf_use, frq, stokesc1, phasechnls, $
;	4*scndata.ptsperstrip, $
;	scndata.onscans, scndata.offscans, 0, $
;	phase_src_observed, srcozerofinal, srcoslopefinal, $
;	cumcorr=cumcorr

; MAKE A PLOT OF THE CAL AND SOURCE PHASE FOR THIS SPIDER PATTERN...
if keyword_set( phaseplot) then $
   phaseplot, scannr0, frq, phase_cal_observed, phase_src_observed, $
              ozerofinal, oslopefinal, srcozerofinal, srcoslopefinal

;STOP, 'one before end'

stokesc1= reform( $
          stokesc1, nchnls, 4, (scndata.ptsforcal+ scndata.ptsperstrip), 4)

;ENDFOR

;stop, 'STOP AT cross3_gbtcal_1'

end
 
