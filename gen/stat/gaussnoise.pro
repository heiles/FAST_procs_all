function gaussnoise, dimension, mean, sigma, DOUBLE=double
;+
; NAME:
;       GAUSSNOISE
;     
; PURPOSE:
;       Creates pseudo-random Gaussian distribution with specified
;       mean and standard deviation.
;     
; CALLING SEQUENCE:
;       RESULT = GAUSSNOISE(DIMENSION, MEAN, SIGMA)
;     
; INPUTS:
;       DIMENSION - Number of elements for desired noise distribution. 
;       MEAN - Mean of desired distribution.
;       SIGMA - Standard deviation of desired distribution.
;
; KEYWORDS:
;       /DOUBLE - Return distribution in double-precision floating-point.
;
; OUTPUTS:
;       Returns pseudo-random Gaussian distribution with specified
;       mean and standard deviation.
;
; EXAMPLE:
;    IDL> plot, gaussnoise(1024, 10.0, 0.07)
;
; MODIFICATION HISTORY:
;   15 Jul 2003  Written by Tim Robishaw, Berkeley
;-

on_error, 2

; DID WE SEND IN ENOUGH INFORMATION...
if (N_params() gt 3) $
  then message, 'Syntax: RESULT = GAUSSNOISE(dim, mean, sigma, /DOUBLE)'

; SET THE DEFAULTS...
if (N_elements(MEAN) eq 0) then mean = keyword_set(DOUBLE) ? 0d0 : 0.0
if (N_elements(SIGMA) eq 0) then sigma = keyword_set(DOUBLE) ? 1d0 : 1.0

; CREATE A NORMALLY-DISTRIBUTED PSEUDO-RANDOM DISTRIBUTION WITH
; MEAN OF ZERO AND STANDARD DEVIATION OF UNITY...
noise = randomn(seed,dimension,DOUBLE=keyword_set(DOUBLE))

; SCALE DISTRIBUTION TO DESIRED PARAMETERS...
mn_noise = total(noise, DOUBLE=keyword_set(DOUBLE)) / dimension
sd_noise = sqrt(total((noise-mn_noise)^2,DOUBLE=keyword_set(DOUBLE)) $
                / (dimension-1))

return, (noise-mn_noise)/sd_noise * sigma + mean

end; gaussnoise


