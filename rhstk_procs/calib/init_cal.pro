pro init_cal, gainchnls, tcalxx, tcalyy, freq_bb, dpdf_guess, $
              calxx1, calxx0, calyy1, calyy0, $
              calxy1, calxy0, calyx1, calyx0, $
              cts_per_k_xx, cts_per_k_yy, $
              phase_zero, phase_slope

;+
;PURPOSE: Calculate cts_per+k, phase slope, and phase zero.
;CALLING SEQUENCE: 
;
;INIT_CAL, gainchnls, tcalxx, tcalyy, freq_bb, dpdf_guess, $
;              calxx1, calxx0, calyy1, calyy0, $
;              calxy1, calxy0, calyx1, calyx0, $
;              cts_per_k_xx, cts_per_k_yy, $
;              phase_zero, phase_slope
;
;INPUTS:
;       GAINCHNLS, the vector of channels to use in deriving the output
;parameters. 
;       TCALXX, TCALYY, the equivalent temperature of the cals
;       FREQ_bb, the baseband frequency range of the spectra.
;       DPDF_GUESS, the guessed vaue for the phase slope (rad/MHz)
;       CALXX1[nchan, nr], the array of cal-on xx product spectra
;       CALXX0[nchan, nr], the array of cal-off xx product spectra
;       CALYY1, CALYY0, CALXY1, CALXY0, CALYX1, CALYX0, the arrays of
;cal-on and cal-off spectra for the other products
;
;OUTPUTS:
;       CTS_PER_K_XX, CTS_PER_K_YY, the counts/K for the x and y signal
;paths.
;       PHASE_ZERO, the phase difference between X and Y signal paths
;for freq_bb=0 MHz. Units are radians.
;       PHASE_SLOPE, the phase slope in radians/MHz.
;-

sz= size( calxx1)
nr_cal= sz[ 2]
nchnls= sz[ 1]

; INITIALIZE THE COUNTS_PER_K FOR EACH CAL...
   cts_per_k_xx= fltarr( nr_cal)
   cts_per_k_yy= fltarr( nr_cal)

;INITIALIZE THE PHASE ZERO AND SLOPE, and their uncertainties, for the
; XY products...
phase_zero= fltarr( nr_cal, 2)
phase_slope= fltarr( nr_cal, 2)
calxysw_phasecorr= fltarr( nchnls, nr_cal)
calyxsw_phasecorr= fltarr( nchnls, nr_cal)

;define the cal deflection...
calxxsw= calxx1- calxx0
calyysw= calxx1- calyy0
calxysw= calxy1- calxy0
calyxsw= calyx1- calyx0

;WE GO THROUGH EACH CALON/OFF PAIR
   for nc=0, nr_cal-1 do begin
      
;DETERMINE THE COUNTS PER KELVIN...
intensitycal_self, calxx1[ *,nc], calxx0[ *,nc], $
             gainchnls, tcalxx, counts_per_k_xx
      cts_per_k_xx[ nc]= counts_per_k_xx
intensitycal_self, calyy1[ *,nc], calyy0[ *,nc], $
             gainchnls, tcalyy, counts_per_k_yy
      cts_per_k_yy[ nc]= counts_per_k_yy

; LEAST-SQUARES FIT FOR THE PHASE OF THE CORRELATED CAL AS A FUNCTION
; OF FREQUENCY; WE RETURN THE PHASE SLOPE AND OFFSET
      phasecal_cross, calxysw[ *,nc], calyxsw[ *,nc], $
                      gainchnls, dpdf_guess, freq_bb, $
                      ozero, oslope, phase_observed, $
                      SIGMA_PHASEFIT=sigma_phasefit
      phase_zero[ nc, *]= ozero
      phase_slope[ nc, *]= oslope
      
;CHECK RESULTS MANUALLY...
phaseplot_08, 'Cal deflection phase (radians) vs bb freq', freq_bb, $
              calxysw[*,nc], calyxsw[ *,nc], $
;              calyx1[*,nc]- calyx0[ *,nc], $
              ozero, oslope
wait, 0.1
phasecorr_xyyx, calxysw[*,nc], calyxsw[*,nc], freq_bb, ozero, oslope, $
                calxy_phasecorr, calyx_phasecorr
calxysw_phasecorr[ *,nc]= calxy_phasecorr
calyxsw_phasecorr[ *,nc]= calyx_phasecorr
   endfor

end
