pro self_uncal_to_cal, uncal_on, uncal_off, gainchnls, counts_per_k, $
                       cal_on, bandpass, tsys_online, tsys_offline, $
                       mean_med_on=mean_med_on, median_bp=median_bp, $
                       pswitch=pswitch, mean_med_off=mean_med_off, $
                       length=length, no_intensitycal=no_intensitycal


;+
; NAME: 
;       SELF_UNCAL_TO_CAL
;
; PURPOSE: 
;       Given a set of uncalibrated UNCAL_ON and UNCAL_OFF xx or yy spectra
;       (e.g. online and offline, onsrc and offsrc; onfrq or offfrq),
;       return CAL_ON, the intensity calibrated total power ON spectra in
;       units of Kelvins, one for each original ON or, if MEAN_MED_ON is
;       set, either the mean or median of the CAL_ON spectra.
;
;       Normally it returns UNCAL_ON/BANDPASS. BANDPASS is the mean or
;       median of UNCAL_OFF. If PSWITCH is set it returns
;       (UNCAL_ON-UNCAL_OFF)/BANDPASS, using matched pairs of UNCAL_ON and
;       UNCAL_OFF unless MEAN_MED_OFF is set, in which case you can use the
;       mean or median of UNCAL_OFF.
;
; CALLING SEQUENCE:
;       SELF_UNCAL_TO_CAL, uncal_on, uncal_off, gainchnls, counts_per_k,
;                          cal_on, bandpass, tsys_online, tsys_offline
;                          [, MEAN_MED_ON=mean_med_on][,
;                          MEDIAN_BP=median_bp][, /PSWITCH][,
;                          MEAN_MED_OFF=mean_med_off][, LENGTH=length],
;                          NO_INTENSITYCAL=no_intensitycal


;
; INPUTS:
;       UNCAL_ON[ nchnls,nONspectra] - the array of raw correlator XX or YY
;                                      ON spectra
;
;       UNCAL_OFF[ nchnls,nOFFspectra] - the array of raw correlator XX or
;                                        YY OFF spectra, nOFFspectra must
;                                        be matched to nONspectra unless:
;                                        1. UNCAL_OFF is a single spectrum,
;                                        or 2. MEAN_MED_OFF is set.
;
;       GAINCHNLS - the particular chnls that were included when deriving
;                   counts_per_k
;
;       COUNTS_PER_K - the counts per K determined by a previous call to
;                      INTENSITYCAL_SELF
;
; OUTPUTS: CAL_ON - the array of calibrated bandpass-corrected ON-SRC
;                   total system spectra or their mean or median if
;                   CAL_ON_MEAN_MED is set.  ('calibrated' means
;                   UNCAL_ON/BANDPASS in Kelvins. CAL_ON includes
;                   the receiver and on-source-sky temps unless PSWITCH
;                   is set, in which case CAL_ON is ON-SRC - OFF-SRC.).
;
;       BANDPASS - the offline bandpass shape from the average or median of
;                  the offline spectra.
;
;       TSYS_ONLINE - the on-line system temp averaged over GAINCHNLS,
;                     weighted by the gain (bandpass)
;
;       TSYS_OFFLINE - the off-line system temp averaged over GAINCHNLS,
;                      weighted by the gain (bandpass)
;
; KEYWORDS:
;       MEAN_MED_ON: if nonzero, return the mean or median of the
;                    calibrated CAL_ON spectra instead of all of them as an
;                    array. MEAN_MED_ON = 1 uses the mean and MEAN_MED_ON=2
;                    uses the median.
;
;       MEDIAN_BP: Normally, the bandpass is calculated from the mean of
;                  the UNCAL_OFF. If MEDIAN_BP is set, it uses the median.
;
;       /PSWITCH: if set, CAL_ON is equal to (UNCAL_ON-UNCAL_OFF)/BANDPASS
;                 instead of the usual UNCAL_ON/BANDPASS. For Stokes I,
;                 this is just a matter of subtracting 'unity'. But for the
;                 other Stokes parameters, it's not. For example, for
;                 Stokes V it's like (V_ON-V_OFF)/BANDPASS, where BANDPASS
;                 comes from I_OFF.
;
;       /NO_INTENSITYCAL: if set, it does not apply intensity
;       calibration; it only divides by the bandpass, so the intensities
;       are in units of the off-source system temperature. If you set
;       /NO_INTENSITYCAL, then COUNTS_PER_K can be set to any nonzero
;       number, such as unity.
;
;       MEAN_MED_OFF: if nonzero and PSWITCH is set, use the mean or median
;                     of the UNCAL_OFF (instead of paired
;                     UNCAL_ON-UNCAL_OFF spectra) to calculate calibrated
;                     switched spectra. MEAN_MED_OFF=1 uses the mean and
;                     MEAN_MED_OFF=2 uses the median.
;
;       LENGTH = fourier filter the bandpass to this length. This reduces
;                grass noise. For example, if spectra are 1024 channels and
;                LENGTH=256, it effectively smooths over 4 channels.
;
; OBSOLETE OPTIONAL INPUT:
;       DEGREE: replaces the bandpass gain spectrum with a polynomial fit
;               of degree 'degree' over a chnl range that removes twice the
;               chnls at the edge that is specified by 'gainchnls'. DON'T
;               USE THIS UNLESS YOU KNOW WHAT YOU ARE DOING!! (I think it
;               is most suitable for Arecibo, where the IF Filter shape is
;               really flat).  An older note (from intensitycal_gbtfs_1)
;               says: degree=10 is recommended for HI at the GBT spectral
;               processor. However, I don't understand this and am not sure
;               it is correct (note on 28 jun 07)
;
; MODIFICATION HISTORY:
;        Summer 2007  Written by CH. Documented/clarified may/june 2008.
;       25 may 2010: fixed typos in which 'mean_med_off' was sometimes
;               written as 'mean_med_ref'
;       CH 17jul2013 -- fixed apparent error in checking for no_intensitycal.
;
;       JUL2013 added /no_intensitycal option, for AO data. It was             
;            originally done incorrectly (reversed 'if') There was a note            
;            about fixing it in the '...CROSS' version written
;            on31jul2015, but that note did not appear here and the
;            correction was not made here.
;       31jul2016: the sense of the 'if' is correct, both for
;        '...SELF...' and '...CROSS...' On 31jul2016, it as already
;        correct in '...CROSS...' but it was NOT correct here in '...SELF...'

; CHK CIRCS UNDER WHICH THESE MUST BE EQUAL...
szoff= size( uncal_off)
szon= size( uncal_on)
if array_equal( szoff, szon) eq 0 and keyword_set( pswitch) then $
   message, 'INCOMPATIBLE uncal_off and uncal_on array sizes with PSWITCH set!!'

; FCTR IS THE MEAN COUNTS IN THE SELECTED CHNL RANGE FROM ALL THE OFF SPECTRA...
;if keyword_set( no_intensitycal) then fctr=counts_per_k $
;   else fctr= mean( uncal_off[ gainchnls,*]) 
;***** CH 17jul2013 replaced the commented-out version by the commented version.
;if keyword_set( no_intensitycal) eq 0 then fctr=counts_per_k $
;   else fctr= mean( uncal_off[ gainchnls,*]) 

;the folloowing statement is verified as being correct on 31jul2016.
if keyword_set( no_intensitycal) then fctr=counts_per_k $
   else fctr= mean( uncal_off[ gainchnls,*]) 

; GET THE BANDPASS FROM COMBINING THE UNCAL_OFF SPECTRA...
if (szoff[ 0] gt 1) then begin
   if keyword_set( median_bp) $
      then bandpass = median( uncal_off, DIMENSION=2) $
      else bandpass = total( uncal_off, 2) / szoff[ 2] 
endif else begin
   bandpass = uncal_off
endelse

; DEFINE REFERENCE SPECTRUM FOR SWITCHING...
; DEFAULT IS ZERO...
;stop
if keyword_set( pswitch) then begin
   if (n_elements( mean_med_off) gt 0) and (szoff[ 0] gt 1) then begin
      case mean_med_off of
         0 : reference = uncal_off
         1 : reference = total( uncal_off, 2) / szoff[ 2]
         2 : reference = median( uncal_off, DIMENSION=2)
         else : message, 'MEAN_MED_OFF must be set to 0, 1, or 2.'
      endcase
   endif else reference= uncal_off
endif else reference=0.

;stop, 'STOP in self_uncal_to_cal'

szref= size( reference)

; FOURIER FILTER THE BANDPASS IF LENGTH SPECIFIED...
if n_elements( length) ne 0 then $
   if (length ne szoff[1]) and (length ne 0l) then $
      fft_fltr, bandpass, length, /INPLACE

;vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
;THIS SECTION IS OBSOLETE...MAYBE REINSTITUTE IT SOMETIME...
;polynomial fit if desired...
;IF KEYWORD_SET( DEGREE)  THEN begin
;   polytreat_sw, bandpass_from_sw, gainchnls, degree
;   PRINT, '********* -----------> !!!DANGER!!! <----------------- *************'
;   PRINT, '           DEGREE IS NONZERO SO YOU ARE CALLING POLYTREAT
;   PRINT, '********************************************************************'
;ENDIF
;^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

; DIVIDE EACH ON SPECTRUM BY BANDPASS AND SCALE TO GET KELVINS; 
; subtract offs if PSWITCH is set...

;stop
; FIRST DEAL WITH MULTIPLE-ON-SPECTRA CASE...
if (szon[ 0] gt 1) then begin

   cal_on= fltarr( szon[1], szon[ 2])

   for nsw= 0, szon[ 2]-1 do begin

   ;!!!!
   ; EXTRANEOUS!!! REFERENCE=0 IF PSWITCH ISN'T SET...

;stop
      if keyword_set( pswitch) then begin

         if (szref[ 0] gt 1) $
            then cal_on[ *, nsw] = (fctr/counts_per_k) $
                                   * (uncal_on[ *, nsw] - reference[ *, nsw]) $
                                   / bandpass $
            else cal_on[ *, nsw] = (fctr/counts_per_k) $
                                   * (uncal_on[ *, nsw] - reference) $
                                   / bandpass
      endif else cal_on[ *, nsw] = (fctr/counts_per_k) $
                                   * uncal_on[ *, nsw] / bandpass
   endfor

   ; DO WE WANT TO AVERAGE OR MEDIAN ALL THE CALIBRATED ON SPECTRA OVER
   ; TIME AND RETURN A SINGLE CALIBRATED ON...
   if keyword_set( mean_med_on) then begin
      if (mean_med_on eq 1) $
         then cal_on = total( cal_on, 2) / szon[ 2] $
         else cal_on = median( cal_on, DIMENSION=2)
   endif

endif else begin

   ;!!!!
   ; EXTRANEOUS!!! REFERENCE=0 IF PSWITCH ISN'T SET...

   ; NOW DEAL WITH SINGLE-ON-SPECTRUM CASE...
   if keyword_set( pswitch) $
      then cal_on = (fctr/counts_per_k)* (uncal_on - reference) / bandpass $
      else cal_on = (fctr/counts_per_k)* uncal_on / bandpass 

endelse

tsys_online = (mean( uncal_on[ gainchnls,*])) / counts_per_k
tsys_offline = fctr/counts_per_k

;stop
end ; self_uncal_to_cal
