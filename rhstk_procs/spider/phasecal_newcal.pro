pro phasecal_newcal, scndata, frq, stokesc1, phasechnls, indxs, $
	indxcalon, indxcaloff, correctoption, $
	phase_observed, ozero, oslope, $
	cumcorr=cumcorr, totalquiet=totalquiet

;+
;PURPOSE: Least squares fit for the phase of the correlated cal versus
;frequency, and correct the data if requested by CORRECTOPTION.

;INPUTS: 
;	FRQ[ 2048]: the aray of frequencies, centered at the frequency
;at which you want the zero of phase to be calculated. Units are MHz.

;	DPDF (from SCNDATA_DPDF): the initial guess for (dphase/dfreq),
;radians/MHz. (from structure SCNDATA)

;	STOKESC1[2048, 4, *]: the input Stokes parameters

;	PHASECHNLS: the particular chnls to include in the fit (from 
;structure SCNDATA).

;	INDXS: the set of indices for the third elements of STOKESC1 to
;correct, if correction is chosen as the option.

;	INDXCALOFF: the set of indices in the third element of STOKESC1
;to use as caloff for the calibration.

;	INDXCALON: the set of indices in the third element of STOKESC1
;to use as calON for the calibration.

;KEYWORD: CUMCORR excises interference from the calon/caloff spectra

;	CORRECTOPTION: 
;		if 1, it corrects STOKESC1; 
;		if 0, it does no correction;
;		if -1, it corrects for the slope but not the phase.
;

;OUTPUT:

;	if CORRECTOPTION is 1, then STOKESC1 are returned as
;phase-calibrated stokes parameters.

;	PHASE_OBSERVED is the array of observed phases of the cal
;deflection. 
;
;	OZERO and OSLOPE are the linear fit coefficients and errors,
;the units are **** RADIANS ***** and ***** RADIANS/MHZ *****
;-

;common plotcolors

;EXTRACT OLD NAMES FROM STRUCTURE SCNDATA...
dpdf= scndata.dpdf
;phasechnls= scndata.phasechnls

;SUBTERFUGE TO MAKE THE SUBSCRIPTED STOKESC1 A 3-D ARRAY...
indxcaloff_ = indxcaloff
if (n_elements(indxcaloff) eq 1) then indxcaloff_ = [indxcaloff, indxcaloff]
indxcalon_ = indxcalon
if (n_elements(indxcalon) eq 1) then indxcalon_ = [indxcalon, indxcalon]

;DETERMINE THE PHASE VARIATION WITH FREQUENCY OF THE CAL DEFLN

xy_calon =  stokesc1[*,2,indxcalon_]
xy_caloff = stokesc1[*,2,indxcaloff_]
yx_calon =  stokesc1[*,3,indxcalon_]
yx_caloff = stokesc1[*,3,indxcaloff_]

;CORRECT THESE SELECTED XY AND YX FOR INTERFERENCE, IF DESIRED...
IF KEYWORD_SET( CUMCORR) THEN BEGIN

FOR NSC= 0, N_ELEMENTS( INDXCALON)- 1 DO BEGIN
zz= xy_calon[ *, 0, nsc]
cumfilter, zz, n_elements( zz)/4, 3., /correct, /median
xy_calon[ *,0, nsc]= zz
zz= yx_calon[ *, 0, nsc]
cumfilter, zz, n_elements( zz)/4, 3., /correct, /median
yx_calon[ *,0, nsc]= zz
ENDFOR

FOR NSC= 0, N_ELEMENTS( INDXCALOFF)- 1 DO BEGIN
zz= xy_caloff[ *, 0, nsc]
cumfilter, zz, n_elements( zz)/4, 3., /correct, /median
xy_caloff[ *,0, nsc]= zz
zz= yx_caloff[ *, 0, nsc]
cumfilter, zz, n_elements( zz)/4, 3., /correct, /median
yx_caloff[ *,0, nsc]= zz
ENDFOR

ENDIF


calonxy= total( xy_calon[*, 0, indxcalon_],3)/ n_elements( indxcalon_)
calonyx= total( yx_calon[*, 0, indxcalon_],3)/ n_elements( indxcalon_)
caloffxy= total( xy_caloff[*, 0, indxcaloff_],3)/ n_elements( indxcaloff_)
caloffyx= total( yx_caloff[*, 0, indxcaloff_],3)/ n_elements( indxcaloff_)

caldiffxy=calonxy-caloffxy
caldiffyx=calonyx-caloffyx

;THE SCHEME IS TO USE PHASEFIT_F.PRO ONLY, NO AFTER-THE-FACT LINEAR FIT.

;stop, 'stop: phasecal_newcal, 1'
phasefit_mar01, frq[phasechnls], $
	caldiffxy[phasechnls], caldiffyx[phasechnls], dpdf, $
	coeffs, aphi, sigaphi, sigcoeffs, sigma, tfit

;CONVERT COEFFS AND APHI TO OZERO AND OSLOPE IN 
;		PHASE = OZERO + OSLOPE*(FREQ-FREQZERO)
;	IN THE 2-ELEMENT ARRAYS, FIRST ONE IS VALUE AND SECOND IS ERROR.
;	***** THE UNITS ARE RADIANS ********
ozero=fltarr(2)
oslope=fltarr(2)
ozero[0] = !dtor * aphi
ozero[1] = !dtor * sigaphi

;STOP
oslope[0] = !dtor * coeffs[2]
oslope[1] = !dtor * sigcoeffs[2]
phase_fit = ozero[0] + oslope[0]*frq
phase_observed = atan(caldiffyx, caldiffxy)

;THESE PLOT STATEMENTS ARE FOR CHECKING THINGS...
;wset,10
;plot, frq, phase_observed, xtit='freq',tit='UNCORRECTED CAL PHASE', $
;        yra=[-!pi, !pi], /ysty
;oplot, frq, ozero[0] + oslope[0]*frq, color=!magenta
; 
;stop, 'stop: phasecal_newcal, 1'
;;STOP
;wset,1

;******* OZERO AND OSLOPE ARE THE FIRST-STEP ZERO AND SLOPE LS FIT RESULTS****
;****************** PHASE_FIT IS THE CORRESPONDING PHASE ANGLE VS FREQ ********

if (correctoption eq -1) then ozero= [0,0]

;STOP, 'one: phasecal'

;USE THE FIRST-STEP RESULTS TO DEROTATE THE RE AND IM FOR ALL STOKES PARAMS...
if (correctoption ne 0) then begin
;stop
if keyword_set( totalquiet) ne 1 then $
   print, 'FITTED DPDF = '+strtrim(string(coeffs[2],form='(f7.2)'),2) $
          + ' +/- ' + strtrim(string(sigcoeffs[2],form='(f7.2)'),2) + ' DEG/MHz'
   phase_fit = ozero[0] + oslope[0]*frq
   ntimes = n_elements(indxs)
   for nr=0,ntimes-1 do begin
      reunrotated = stokesc1[*,2,indxs[nr]]
      imunrotated = stokesc1[*,3,indxs[nr]]
      angrotate, reunrotated, imunrotated, $
                 (-!radeg*phase_fit), rerotated, imrotated
      stokesc1[*,2,indxs[nr]] = rerotated
      stokesc1[*,3,indxs[nr]] = imrotated
   endfor
endif

;STOP, 'two: phasecal'

return
end


