pro cross_uncal_to_cal, uncal_cross, gainchnls, $
                        xx_counts_per_k, xx_bandpass, $
                        yy_counts_per_k, yy_bandpass, $
                        cal_cross, tsys_cross, mean_med_on=mean_med_on, $
                        pswitch=pswitch, uncal_cross_ref=uncal_cross_ref, $
                        mean_med_ref=mean_med_ref, $
                        no_intensitycal=no_intensitycal

;+
; NAME: 
;       CROSS_UNCAL_TO_CAL
;
; PURPOSE: 
;       Given a set of uncalibrated UNCAL_CROSS xy or yx spectra
;       (e.g. online and offline, onsrc and offsrc; onfrq or offfrq),
;       return CAL_CROSS, the set of intensity calibrated spectra in units
;       of Kelvins, one for each original ON or, if MEAN_MED_ON is set,
;       either the mean or median of the CAL_CROSS spectra. In other words,
;       it does the same for cross (xy,yx) spectra as SELF_UNCAL_TO_CAL
;       does for self (xx,yy) spectra.
;
;       Normally it returns UNCAL_CROSS/BANDPASS. BANDPASS is the
;       channel-by-channel geometric mean of XX_BANDPASS and YY_BANDPASS.
;       If PSWITCH is set it returns (UNCAL_CROSS - MEAN_MED_REF)/BANDPASS,
;       using matched pairs of UNCAL_CROSS and MEAN_MED_REF unless
;       MEAN_MED_REF is set, in which case you can use the mean or median
;       of MEAN_MED_REF.
;
;       The inputs XX_COUNTS_PER_K and YY_COUNTS_PER_K come from
;       INTENSITYCAL_SELF applied separately to the XX and YY calon/caloff
;       spectra. If you set no_intensitycal, set these inputs equal to
;       an arbitrary nonzero number, such as unity.
;
;       The inputs XX_BANDPASS and YY_BANDPASS come from SELF_UNCAL_TO_CAL
;       applied separately to the XX and YY self spectra.
;
; CALLING SEQUENCE:
;       CROSS_UNCAL_TO_CAL, uncal_cross, gainchnls,
;                           xx_counts_per_k, xx_bandpass, 
;                           yy_counts_per_k, yy_bandpass,
;                           cal_cross, tsys_cross [,
;                           MEAN_MED_ON=mean_med_on][, 
;                           PSWITCH=pswitch][,
;                           UNCAL_CROSS_REF=uncal_cross_ref][,
;                           MEAN_MED_REF=mean_med_ref], 
;                           NO_INTENSITYCAL=no_intensitycal
;
; INPUTS:
;       UNCAL_CROSS[ nchnls,nONspectra] - the array of raw correlator XY or
;                                         YX SWON spectra
;
;       GAINCHNLS - the particular chnls that were included when deriving
;                   counts_per_k
;
;       XX_COUNTS_PER_K - the counts per K for XX determined by
;                         INTENSITYCAL_SELF
;
;       XX_BANDPASS - the XX bandpass shapes determined by
;                     SELF_UNCAL_TO_CAL
;
;       YY_COUNTS_PER_K - the counts per K for YY determined by
;                         INTENSITYCAL_SELF
;
;       YY_BANDPASS - the YY bandpass shapes determined by SELF_UNCAL_TO_CAL
;
; OUTPUTS: 
;       CAL_CROSS - the array of calibrated cross spectra, units K, unless
;                   MEAN_MED_ON is set in which case the array is meaned or
;                   medianed to produce a single spectrum.
;
;       TSYS_CROSS - the calibrated crosscorrelated temp averaged over
;                    GAINCHNLS, weighted by the gain (bandpass)
;
;
; KEYWORDS:
;       MEAN_MED_ON = if set to 1, return mean of CAL_CROSS spectra instead
;                     of all of them. If set to 2, return the median.
;
;       /PSWITCH: if set, CAL_ON is equal to (UNCAL_CROSS -
;                 MEAN_MED_REF)/BANDPASS instead of the usual
;                 UNCAL_CROSS/BANDPASS. For Stokes I, this is just a matter
;                 of subtracting 'unity'. But for the other Stokes
;                 parameters, it's not. For example, for Stokes V it's like
;                 (V_ON-V_OFF)/BANDPASS, where BANDPASS comes from I_OFF.
;                 PSWITCH is set, you MUST supply the optional input
;                 MEAN_MED_REF and its dimensions must satisfy the comments
;                 below.
;
;       /NO_INTENSITYCAL: if set, it does not apply intensity
;       calibration; it only divides by the bandpass, so the intensities
;       are in units of the off-source system temperature. If you set
;       /NO_INTENSITYCAL, then XX_COUNTS_PER_K and YY_COUNTS_PER_K can
;       be set to any nonzero number, such as unity.
;
;       UNCAL_CROSS_REF = The reference spectra for the case of switched
;                         spectra. PSWITCH must be set.
;
;       MEAN_MED_REF = if nonzero and PSWITCH is set, use the mean or
;                      median of the UNCAL_CROSS_REF (instead of paired
;                      UNCAL_CROSS - UNCAL_CROSS_REF spectra) to calculate
;                      calibrated switched spectra. MEAN_MED_REF=1 uses the
;                      mean and MEAN_MED_REF=2 uses the median.
;
; MODIFICATION HISTORY:
;        Summer 2007  Written by CH. 
;        May/June 2008  Enhanced/documented/clarified by CH.
;        JUL2013 added /no_intensitycal option, for AO data. It was
;            originally done incorrectly (reversed 'if') in 
;            SELF_UNCAL_TO_CAL and maybe also here. There was a note
;            about fixing it in 31jul2015 for here, but not for 
;            SELF_UNCAL_TO_CAL.
;        31jul2016: the sense of the 'if' is correct, both for
;        '...SELF...' and '...CROSS...'
;- 

; DO BASIC CHECKS ON INPUTS...
if keyword_set( pswitch) then $
   if (n_elements( uncal_cross_ref) eq 0) then $
      message, "***ERROR***: you set PSWITCH and didn't supply UNCAL_CROSS_REF"

szref_in= size( uncal_cross_ref)
szon= size( uncal_cross)

; TAKE GEOMETRIC MEAN OF XX,YY_COUNTS_PER_K AND BANDPASS SHAPES...
counts_per_k= sqrt( abs( xx_counts_per_k* yy_counts_per_k))
bandpass= sqrt( abs( xx_bandpass* yy_bandpass))

;if keyword_set( no_intensitycal) then fctr=counts_per_k $
;   else fctr= mean( uncal_off[ gainchnls,*])
;                      
;***** CH 17jul2013 replaced the commented-out version by the commented
;version.            
;***** CH 31jul2015. the previous and following 'if' statements were all
;present without comment-out. seems contrary to the above 17jul2013
;statement. so we commented the two (preceding and following) out.
;if keyword_set( no_intensitycal) eq 0 then fctr=counts_per_k $
;   else fctr= mean( uncal_off[ gainchnls,*])

;The following statement was modified in july2015 and july2016 is now
;verified as being correct.
if keyword_set( no_intensitycal) then fctr=counts_per_k $
   else fctr= mean( bandpass[ gainchnls,*])

; DEFINE REFERENCE SPECTRUM FOR SWITCHING...default is zero
if keyword_set( pswitch) then begin
   if (n_elements( mean_med_ref) gt 0) and (szref_in[ 0] gt 1) then begin
      case mean_med_ref of
         0 : reference = uncal_cross_ref
         1 : reference = total( uncal_cross_ref, 2) / szref_in[ 2]
         2 : reference = median( uncal_cross_ref, DIMENSION=2)
         else : message, 'MEAN_MED_REF must be set to 0, 1, or 2.'
      endcase
   endif else reference = uncal_cross_ref
endif else reference = 0.0

szref= size( reference)

; FIRST DEAL WITH MULTIPLE-ON-SPECTRA CASE...
if szon[ 0] gt 1 then begin

   cal_cross= fltarr( szon[1], szon[ 2])

   for nsw= 0, szon[ 2]-1 do begin

   ;!!!!
   ; EXTRANEOUS!!! REFERENCE=0 IF PSWITCH ISN'T SET...

      if keyword_set( pswitch) then begin

         if (szref[ 0] gt 1) $
            then cal_cross[ *, nsw]= (fctr/counts_per_k) $
                                     * (uncal_cross[ *, nsw] $
                                        - reference[ *, nsw]) $
                                     / bandpass $
            else cal_cross[ *, nsw]= (fctr/counts_per_k) $
                                     * (uncal_cross[ *, nsw] - reference) $
                                     / bandpass 

      endif else cal_cross[ *, nsw]= (fctr/counts_per_k) $
                                     * uncal_cross[ *, nsw] / bandpass 

   endfor

   ; DO WE WANT TO AVERAGE OR MEDIAN ALL THE CALIBRATED ON SPECTRA OVER
   ; TIME AND RETURN A SINGLE CALIBRATED ON...
   if keyword_set( mean_med_on) then begin
      if (mean_med_on eq 1) $
         then cal_cross = total( cal_cross, 2) / szon[ 2] $
         else cal_cross = median( cal_cross, DIMENSION=2)
   endif

endif else begin

   ;!!!!
   ; EXTRANEOUS!!! REFERENCE=0 IF PSWITCH ISN'T SET...

   ; NOW DEAL WITH SINGLE-ON-SPECTRUM CASE...
   if keyword_set( pswitch) $
      then cal_cross= (fctr/counts_per_k)* (uncal_cross- reference)/ bandpass $
      ;else cal_on= (fctr/counts_per_k)* uncal_cross/ bandpass
      else cal_cross= (fctr/counts_per_k)* uncal_cross/ bandpass
     ;^^^^^^^^^^^^
     ;!!!!!!!!!!!!

endelse

tsys_cross= (mean( uncal_cross[ gainchnls,*])) / counts_per_k

end ; cross_uncal_to_cal
