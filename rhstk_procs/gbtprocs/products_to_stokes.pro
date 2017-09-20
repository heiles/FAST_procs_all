pro products_to_stokes, gainchnls, cal_indx, cts_per_k_xx, cts_per_k_yy, $
;pro fsw_inband, gainchnls, cal_indx, cts_per_k_xx, cts_per_k_yy, $
                phase_zero, phase_slope, freq_bb, $
                xx1, xx0, yy1, yy0, $
                xy1, xy0, yx1, yx0, $
                stki_uncal, stkq_uncal, stku_uncal, stkv_uncal, $
                no_intensitycal=no_intensitycal, mean_med_off=mean_med_off

;+
;PURPOSE: turn calibrated self- and cross-products into Stokes
;       parameters that are not Mueller-calibrated.
;
;CALLING SEQUENCE:
;PRODUCTS_TO_STOKES, gainchnls, cal_indx, cts_per_k_xx, cts_per_k_yy, $
;                phase_zero, phase_slope, freq_bb, $
;                xx1, xx0, yy1, yy0, $
;                xy1, xy0, yx1, yx0, $
;                stki_uncal, stkq_uncal, stku_uncal, stkv_uncal, $
;                no_intensitycal=no_intensitycal, mean_med_off=mean_med_off
;
;INPUTS:
;       GAINCHNLS: A vector of spectral channel numbers that is being
;used to determine power gains
;       CAL_INDX: A vector that specifies which CAL goes with which
;SRC. For example, if SRC has 98 scans and CAL has 9 scans, CAL_INDX is
;a 98-element vector with values ranging from 0 to 8.
;       CTS_PER_K_XX, CTS_PER_K_YY: the counts per kelvin that tells
;the power gain for X and Y signal paths.
;       PHASE_ZERO: a 2-element vector telling the phase and its error
;for the zeroth baseband frequency. Units are RADIANS.
;       PHASE_SLOPE: a 2-element vector telling the phase slope and its
;error. Units are RADIANS per MHz.
;       XX1, XX0: xx product onsource, xx product offsource. These are
;arrays, for example xx1[512, 8, 98] (512 spectral channels, 8
;subscans, 98 scans)
;       YY1, YY0: same as for XX products immediately above.
;       XY1, XY0: same as for XX products above.
;       YX1, YX0: same as for XX products above.
;
;KEYWORDS:
;       NO_INTENSITYCAL: Set this keyword if you wish to NOT do
;intensity calibration. In some Arecibo reductions, the intensity
;calibration has been done previously, in which case this keyword should
;be set. Otherwise, don't set it.
;       MEAN_MED_OFF: if nonzero, use the mean or median of the
;off-source product spectra (instead of paired onsource/offsource
;spectra) to calculate calibrated switched spectra. MEAN_MED_OFF=1 uses
;the mean and MEAN_MED_OFF=2 uses the median.
;                                                               
;OUTPUTS
;       STKI_UNCAL, etc: The Mueller-uncalibrated Stokes arrays
;calculated from the calibrated xx, yy, xy, and yx product spectra.
;-

sz= size( xx1)
nchnls= sz[ 1]
nrscans= sz[ 3]
nrsubscans= sz[ 2]

xxcalsw= fltarr( nchnls, nrsubscans, nrscans)
yycalsw= fltarr( nchnls, nrsubscans, nrscans)
xxbandpass= fltarr( nchnls, nrscans)
yybandpass= fltarr( nchnls, nrscans)
xycalsw_phasecorr= fltarr( nchnls, nrsubscans, nrscans)
yxcalsw_phasecorr= fltarr( nchnls, nrsubscans, nrscans)

;BANDPASS CORRECT:
for nscn= 0l, nrscans-1l do begin
   self_uncal_to_cal, xx1[ *, *, nscn], xx0[ *, *, nscn], gainchnls, $
                 cts_per_k_xx[cal_indx[ nscn]], xxcal, xxbp, $
                 xxtsyson, xxtsysoff, $
                 no_intensitycal=no_intensitycal, mean_med_off=mean_med_off, $
                 /pswitch
xxcalsw[ *, *, nscn]= xxcal
xxbandpass[ *, nscn]= xxbp
   self_uncal_to_cal, yy1[ *, *, nscn], yy0[ *, *, nscn], gainchnls, $
                 cts_per_k_yy[cal_indx[ nscn]], yycal, yybp, $
                 yytsyson, yytsysoff, $
                 no_intensitycal=no_intensitycal, mean_med_off=mean_med_off, $
                 /pswitch
yycalsw[ *, *, nscn]= yycal
yybandpass[ *, nscn]= yybp
endfor

;INTENSITY CALIBRATE
xycalsw = fltarr( nchnls, nrsubscans, nrscans)
yxcalsw = fltarr( nchnls, nrsubscans, nrscans)

for nscn= 0l, nrscans-1l do begin
cross_uncal_to_cal, xy1[ *,*,nscn], gainchnls, $
                    cts_per_k_xx[cal_indx[ nscn]], xxbandpass[ *,nscn], $
                    cts_per_k_yy[cal_indx[ nscn]], yybandpass[ *,nscn], $
                    xycal, $
                    /pswitch, uncal_cross_ref=xy0, $
                    no_intensitycal=no_intensitycal
xycalsw[ *,*,nscn]= xycal

cross_uncal_to_cal, yx1[ *,*,nscn], gainchnls, $
                    cts_per_k_xx[cal_indx[ nscn]], xxbandpass[ *,nscn], $
                    cts_per_k_yy[cal_indx[ nscn]], yybandpass[ *,nscn], $
                    yxcal, $
                    /pswitch, uncal_cross_ref=yx0, $
                    no_intensitycal=no_intensitycal
yxcalsw[ *,*,nscn]= yxcal

;stop

;PHASE CORRECT
phasecorr_xyyx, xycalsw[*,*,nscn], yxcalsw[*,*,nscn], freq_bb, $
    phase_zero[ cal_indx[ nscn], 0], phase_slope[ cal_indx[ nscn], 0], $
    xy_phasecorr, yx_phasecorr
xycalsw_phasecorr[ *,*,nscn]= xy_phasecorr
yxcalsw_phasecorr[ *,*,nscn]= yx_phasecorr
endfor

stki_uncal= xxcalsw+ yycalsw
stkq_uncal= xxcalsw- yycalsw
stku_uncal= 2.* xycalsw_phasecorr
stkv_uncal= 2.* yxcalsw_phasecorr

return
end
