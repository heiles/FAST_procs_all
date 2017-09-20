;+;
;  GENERATE THE SCNDATA STRUCTURE
;
;scndata contains specified parameters for the beetle scans that should not
;change unless the datataking program is changed.
;
; JUN 19, 2007; Tim changes tcal??_board to fltarr(8) because now the
; spectrometer can handle 8 IFs and our spider scans were failing when we
; have >4 boards.
;-

scndata= { scndata, $

;FRACTION OF CHNLS TO ELIMINATE AT EACH END
badfraction_lowend: 0. , $ normally set this equal to 1/16.
badfraction_hiend: 0. , $ normally set this equal to 1/16.

;;CHNLS TO USE FOR CONTINUUM, ALSO FOR CALIBRATION...
;    nchnls: 0, $; tot nr chnls in spectra
;     chnls: intarr( ncontchnls), $; channels to use in computing continuum
;phasechnls: intarr( ncontchnls), $; channels to get continuum phase
; gainchnls: intarr( ncontchnls), $; channels to get continuum gain

;THE EXPECTED NR OF POINTS PER STRIP, NR POINTS WITH CAL...
	ptsperstrip: 0, $; number of datapoints per strip 60
	ptsforcal:   0, $; number of points at beginning for calon/caloff 2
	nrstrips:    0, $; number of strips in pattern 4

;THE SCAN INDICES FOR ON-SOURCE-PEAK AND OFF-SOURCE...
   onscans: intarr( 8), $; indices for on-src peaks for each scan
  offscans: intarr( 8), $; indices for off-src points for each scan

;THESE ARE THE INDICES FOR CALON, OFF WHEN OFF SOURCE ONLY.
indxcalon: intarr( 2* ptsforcal), $; indices of cal on
indxcaloff: intarr( 2* ptsforcal), $; indices of cal off

;FIRST GUESS FOR DPDF...
dpdf:       0., $; assumed phase slope wrt freq, rad/MHz

;DATA ABOUT CALS...
;tcalxx_board: fltarr(4), $; xx cal temps for the four boards
;tcalyy_board: fltarr(4) $; yy cal temps for the four boards

; FOR THE NEW GBT ACS SPECTROMETER, WE CAN HAVE UP TO 8 BOARDS,
; AND THE LINES ABOVE WERE FAILING FOR THE CASE WHERE WE HAD >4
; BOARDS...
tcalxx_board: fltarr(8), $; xx cal temps for the eight boards
tcalyy_board: fltarr(8) $; yy cal temps for the eight boards
}
