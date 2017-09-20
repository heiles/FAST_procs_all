pro phasecal_cross, caldiffxy, caldiffyx, phasechnls, dpdf, frq, $
                    ozero, oslope, phase_observed, $
                    sigma_phasefit=sigma_phasefit

;+
; NAME:
;       PHASECAL_CROSS
;
; PURPOSE: 
;       Least squares fit for the phase of the correlated cal versus
;       frequency, and return the phase offset OZERO and slope OSLOPE. The
;       phase versus frequency is fit to the equation...  phase = ozero +
;       oslope*frq
;
; CALLING SEQUENCE:
;
;       PHASECAL_CROSS, caldiffxy, caldiffyx, phasechnls, dpdf, frq, $
;                    ozero, oslope, phase_observed, $
;                    sigma_phasefit=sigma_phasefit
;
; INPUTS: 
;       CALDIFFXY[ nchnls] - the XY [CALON - CALOFF] correlated outputs
;
;       CALDIFFYX[ nchnls] - the YX [CALON - CALOFF] correlated outputs
;
;       PHASECHNLS: the particular chnls to include in the fit (from
;                   structure SCNDATA).
;
;       DPDF: the initial guess for (dphase/dfreq). UNITS ARE RADIANS/MHZ. 
;
;       FRQ[ nchnls]: the aray of frequencies, centered at the frequency at
;                     which you want the zero of phase to be
;                     calculated. UNITS ARE MHZ.
;
; KEYWORDS: 
;       SIGMA_PHASEFIT, the sigma of the phasegradient fit
;
; OUTPUTS:
;       OZERO[2] - the zero intercept and its 1sigma error, in RADIANS
;
;       OSLOPE[2] - the phase slope and its 1sigma error, in RADIANS/MHz
;
;       PHASE_OBSERVED - the array of observed (not the fitted) phases of
;                        the cal deflection, UNITS ARE RADIANS
;
; MODIFICATION HISTORY:
;
;-

phasegradient_fit, frq[phasechnls], $
                   caldiffxy[phasechnls], caldiffyx[phasechnls], dpdf, $
                   coeffs, sigcoeffs, aphi, sigaphi, sigma_phasefit, tfit

; CONVERT COEFFS AND APHI TO OZERO AND OSLOPE IN 
;    PHASE = OZERO + OSLOPE*(FREQ-FREQZERO)
; IN THE 2-ELEMENT ARRAYS, FIRST ONE IS VALUE AND SECOND IS ERROR.
; ***** THE UNITS ARE RADIANS ********
ozero=fltarr(2)
oslope=fltarr(2)
;ozero[0] = !dtor * aphi
;ozero[1] = !dtor * sigaphi
ozero[0] = aphi
ozero[1] = sigaphi

;STOP
;oslope[0] = !dtor * coeffs[2]
;oslope[1] = !dtor * sigcoeffs[2]
oslope[0] = coeffs[2]
oslope[1] = sigcoeffs[2]

;if correctoption eq 1 then phasecorr_xyyx, xy, yx, frq, ozero, oslope, xyc, yxc
;if correctoption eq -1 then phasecorr_xyyx, xy, yx, frq, [0.,0.], oslope, xyc, yxc
;if correctoption eq 0 then begin
;    xyc=xy
;    yxc=yx
;endif

phase_observed = atan(caldiffyx, caldiffxy)

end ; phasecal_cross


