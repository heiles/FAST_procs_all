function get_rmsf, phi, lambdasq, $
                   WEIGHT=weight_in, $
                   PHI_RMSF=phi_rmsf, $
                   FWHM=fwhm, $
                   LAMBDA0SQ=lambda0sq
;+
; NAME:
;       GET_RMSF
;
; PURPOSE:
;       Return the Rotation Measure Spread Function.
;
; CALLING SEQUENCE:
;       Result = GET_RMSF(phi, lambdasq [, WEIGHT=vector][,
;                         PHI_RMSF=variable][,FWHM=variable][,
;                         LAMBDA0SQ=variable])
;
; INPUTS:
;       PHI - Faraday depth vector ; a floating point vector that must have
;             the same size as fdf_dirty ; there must be a 1-to-1
;             correspondence between the channels in fdf and the Faraday
;             depths in this array ; phi must be monotonically increasing
;             and regularly spaced
;
;       LAMBDASQ - the lambda-squared sampling of the original Stokes
;                  measurements in inverse meters squared; a floating point
;                  vector; the size of this vector is independent of the
;                  size of fdf and phi.  !!NOTA BENE!!: If channels in the
;                  original Q or U spectra have been blanked out, then the
;                  user must be sure to NOT pass in the value(s) of
;                  lambda-squared for these channels, otherwise the RMSF
;                  will be incorrect and the cleaning will fail.  The user
;                  can also choose to send in all of the original values of
;                  lambda-squared and just set the weight(s) of the
;                  corresponding blanked channels to zero via the WEIGHT
;                  keyword.
;
; KEYWORD PARAMETERS:
;       WEIGHT = the weight function (a.k.a. the sampling function) for the 
;                complex polarized surface brightness; floating point vector 
;                that must have the same length as the LAMBDASQ array.  If
;                not set, a uniform weighting is assumed.
;
; OUTPUTS:
;       Returns the complex Rotation Measure Spread Function.
;
;
; EXAMPLE:
;
;
;
; MODIFICATION HISTORY:
;	Written by Tim Robishaw, USyd  04 Aug 2011
;-

; GET THE SIZE OF THE FARADAY DEPTH AND LAMBDA-SQUARED ARRAYS...
nphi = N_elements(phi)
nlambdasq = N_elements(lambdasq)

; IF THE WEIGHT KEYWORD IS NOT PASSED IN THEN WE JUST USE UNIFORM
; WEIGHTING...
if (N_elements(WEIGHT_IN) gt 0) then begin
   ; MAKE SURE LAMBDASQ AND WEIGHT ARRAYS ARE THE SAME SIZE...
   if (N_elements(weight) ne nlambdasq) $
      then message, 'LAMBDASQ and WEIGHT vectors must have the same size.'
   weight = weight_in
endif else weight = fltarr(nlambdasq)+1.0

; BdB EQUATIONS (24) AND (38) GIVE THE INVERSE SUM OF THE WEIGHTS...
K = 1d0 / total(weight,/DOUBLE)

; GET THE MEAN OF THE LAMBDA-SQUARED DISTRIBUTION...
; THIS IS EQUATION (32) OF BdB05...
lambda0sq = K * total(weight * lambdasq,/DOUBLE)

; THE RMSF WILL HAVE TWICE THE EXTENT OF OUR FARADAY DISPERSION FUNCTION...
sample_phi = findgen(2*nphi)-nphi/2
phi_rmsf = interpol(phi,lindgen(nphi),sample_phi)

; GET THE THEORETICAL FWHM OF RMSF...
; THIS IS EQUATION (61) OF BdB05...
fwhm = 2d0*sqrt(3.0)/(max(lambdasq)-min(lambdasq))

icomp = dcomplex(0,1)

; CALCULATE THE RMSF IF IT HASN'T ALREADY BEEN PASSED IN...
; THIS IS EQUATION (26) OF BdB05...
;if (N_elements(RMSF) eq 0) then $
return, K * total(rebin(reform(weight,1,nlambdasq,/OVERWRITE),2*nphi,nlambdasq,/SAMPLE) * $
                  exp(-2d0 * icomp * phi_rmsf # (lambdasq - lambda0sq)),2,/DOUBLE)

end
