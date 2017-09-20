pro intensitycal_self, calon, caloff, gainchnls, tcal, $
                       counts_per_k, bandpass_from_cal, $
                       length=length, tsys_caloff=tsys_caloff
;+
; NAME: 
;       INTENSITYCAL_SELF
;
; PURPOSE: 
;       Given a set of CALON and CALOFF spectra, and the cal temp, derive
;       the gain (COUNTS_PER_K) for a set of spectral channels (GAINCHNLS),
;       either by the median or mean of those channels.
;
; CALLING SEQUENCE:
;       INTENSITYCAL_SELF, calon, caloff, gainchnls, tcal,
;                          counts_per_k, bandpass_from_cal
;                          [, LENGTH=length] [, TSYS_CALOFF=tsys_caloff]
;
; INPUTS:
;       CALON[ nchnls,nspectra] - the raw correlator XX (or YY) data, all
;                                 with cal ON
;
;       CALOFF[ nchnls,nspectra] - the raw correlator XX (or YY) data,
;                                  all with cal OFF
;
;       GAINCHNLS - the particular chnls to include in the fit.
;
;	TCAL - the cal value for XX or YY.
;
; KEYWORDS:
;       LENGTH = length to fourier filter the cal-derived bandpass.
;
;       TSYS_CALOFF =; this is returned as the cal-off system temp
;       averaged over channels.
;
; OUTPUTS: 
;       COUNTS_PER_K - the counts per K averaged over GAINCHNLS.
;
;       BANDPASS_FROM_CAL - the bandpass shape determined from the cal
;                           deflection, in the original measurements units
;                           (this is CALON-CALOFF). This is normally not
;                           used.
;
; MODIFICATION HISTORY: 
;        Summer 2007  Written by CH.  Documented/clarified May 2008.
;- 

sz = size( calon)

; CALCULATE COUNTS_PER_K...
chnlavgcalon = mean( calon[ gainchnls, *])
chnlavgcaloff = mean( caloff[ gainchnls, *])
counts_per_k = (chnlavgcalon - chnlavgcaloff) / tcal

;------------ CALCULATE BANDPASS_FROM_CAL -----------------

; XXCALOFFAVG[nchnls] IS THE AVERAGE OF THE CALOFF SPECTRA...
if sz[ 0] gt 1 then begin
   xxcalonavg = total( calon, 2) / sz[ 2]
   xxcaloffavg = total( caloff, 2) / sz[ 2]
endif else begin
   xxcalonavg = calon
   xxcaloffavg = caloff
endelse

; THE BANDPASS SHAPE IS THE DIFFERENCE BETWEEN THE CALON AND THE CALOFF...
bandpass_from_cal = xxcalonavg - xxcaloffavg

; GET TSYS FROM CALOFF SPECTRA...
tsys_caloff = chnlavgcaloff / counts_per_k

; IF LENGTH IS SET, THEN WE FOURIER FILTER THE BANDPASS...
if n_elements( length) ne 0 then $
   if (length ne sz[1]) and (length ne 0l) then $
      fft_fltr, bandpass_from_cal, length, /INPLACE

end ; intensitycal_self
