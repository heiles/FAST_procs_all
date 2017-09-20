;
; header files for was
;
; hdr that is specific to was...
; note: rp is reference pixel (counts from 1).
;
; verions history:
; 1      256 length wideband
;		 versionL: i generate as 20040901
;
; 2      
;		 versionL: i generate as 20041022
;        512 length wideband
;        g_dac   went bytarr(14) to 0B
; 3 28oct04 added
;	 versionL - i generate at 20041028
;    CRVAL2A    actual RaJ in hours
;    CRVAL3A    actual DecJ in degrees
;    CRVAL2B    actual Az in degrees
;    CRVAL3B    actual Za in degrees
;    OBSMODE    CALON CALOFF BASKET, etc
;    EQUINOX    2000
;    ALFA_ANG   rotation of ALFA in degrees (-90 .. 90 I think)
;    G_POSTM    Timestamp for ra/dec in hours after midnight
;    G_AZZATM   Timestamp for az/za in hours after midnight
;    G_LO1      The LO1 freq
;    G_LO2      The LO2 freq
; 4 30oct04
;	 versionL:20041030
;	 version as long added to std header
;	 crpix1 -> 0 based to 1 based.
; 5 15jul05 -> added obs_name, object the b.b1.hf
;              this was added sometime back in version 3 of the fits header
;
; ------------------------------------------------------------------
; 
; version 3 . 28oct04
; added 11 columns..
;    version 
;    CRVAL2A    actual RaJ in hours
;    CRVAL3A    actual DecJ in degrees
;    CRVAL2B    actual Az in degrees
;    CRVAL3B    actual Za in degrees
;    OBSMODE    CALON CALOFF BASKET, etc
;    EQUINOX    2000
;    ALFA_ANG   rotation of ALFA in degrees (-90 .. 90 I think)
;    G_POSTM    Timestamp for ra/dec in hours after midnight
;    G_AZZATM   Timestamp for az/za in hours after midnight
;    G_LO1      The LO1 freq
;    G_LO2      The LO2 freq
;
; questions? g_ext g_wband difference ??
;			 g_time at start or end of integration
;
a={galfhdr , $
	 version : 0L,$;
     CRVAL1  : 0D,$; freq at ref pixel nb
     CDELT1  : 0d,$; freq step at ref pixel
     CRPIX1  : 0d,$; ref pixel count from 1
     CRVAL2A : 0d,$; 28oct04 beam ra hr
     CRVAL3A : 0d,$; 28oct04 beam dec deg
     CRVAL2B : 0d,$; 28oct04 actual az in deg
     CRVAL3B : 0d,$; 28oct04 actual za in deg
     CRVAL4  : dblarr(2),$; polazization code
     BANDWID : 0d,$; bandwidth in hz narrow band 
     RESTFREQ: 0d,$; rest freq hz 
     FRONTEND: '',$; 'ALFA'
     IFVAL   : bytarr(2),$;  0
     ALFA_ANG: 0d,$; rot angle of alfa. 28oct04
	 OBSMODE : '',$; 'Basketwe' 28oct04 a8
	 OBS_NAME: '',$;  step in pattern ??
	 OBJECT  : '',$;  source name
	 EQUINOX : 0d,$; 2000.0     28oct04  2000.
	 jd_obs  : 0d,$; from g_time  added by me
	 sec1970 : 0d,$; for  g_time  added by me
     G_WIDE  : lonarr(512,2),$;wide band spectra
     G_ERR   : intarr(2) ,$; 
     G_SEQ   : intarr(2) ,$; seq number. initializes when galspect starts.
;					 increments on each 1 sec tick. Always incrementing			
;					 it is 16 bits of the 32bit status word sent back
;					 to galcpu with each spectra
     G_BEAM  : 0B,$; alfa beam count from 0
     G_WSHIFT: 0B,$; 
     G_NSHIFT: 0B,$;
     G_WPFB  : 0 ,$;
     G_NPFB  : 0 ,$;
     G_MIX   : 0D,$; hz.digital mixing value to go from center wb to center nb
     G_EXT   : 0D,$; hz. cfr for wide band signal
     G_ADC   : 0D,$; hz. adc clock rate             
     G_WCENTER: 0D,$;
     G_WBAND : 0D ,$;hz cfr wide band signal
     G_WDELT : 0D ,$;hz freq step for wide band signal
     G_DAC   : bytarr(2) ,$; ??
     G_TIME  : lonarr(2),$; sec1970, usecs. at start of integ??
     G_LO1   : 0D,$; The lo1 freq mhz?? 28oct04
     G_LO2   : 0D,$; The lo2 freq mhz?? 28oct04 
     G_POSTM : 0D,$; timestatmp for ra/dec in hours after midnite 28oct04
     G_AZZATM: 0D $; timestatmp for az/za in hours after midnite 28oct04
	 }
;
; this is what is on disc in the table header
; the std header includes:
;
;EXTNAME = 'GXFITS  '        / name of this binary table extension            
;DATE-OBS= '2004-10-30T08:47:33'                                                
;OBS_ID  = 'Diag    '                                                           
;BACKEND = 'GALFA   '                                                           
;G_BEAMS =                    7                                                 
;SITELAT =           18.3435001                                                 
;SITELONG=          -66.7533035                                                 
;SITEELEV=                 496.                                                 
;VERSION =             20041030                           
; galfhdrB is not used in any code.. it is just for reference
; 
a={galfhdrB , $
     CRVAL1  : 0D,$;
     CDELT1  : 0d,$;
     CRPIX1  : 0d,$;
	 CRVAL2A : 0d,$; 28oct04 beam ra hr
     CRVAL3A : 0d,$; 28oct04 beam dec deg
     CRVAL2B : 0d,$; 28oct04 actual az in deg
     CRVAL3B : 0d,$; 28oct04 actual za in deg
     CRVAL4  : dblarr(2),$; pola then polb
     BANDWID : 0d,$;
     RESTFREQ: 0d,$;
     FRONTEND: 0B,$;
     IFVAL   : 0B,$;
	 ALFA_ANG: 0d,$; 28oct04
     OBSMODE : bytarr(2),$; 28oct04 a8
     OBS_NAME: bytarr(2),$; 18jul05
     OBJECT  : bytarr(2),$; 18jul05
     EQUINOX : 0d,$; 28oct04  2000.

     G_WIDE  : lonarr(512),$;
     G_ERR   : 0   ,$;
     G_SEQ   : 0 ,$;
     G_BEAM  : 0B,$;
     G_WSHIFT: 0B,$;
     G_NSHIFT: 0B,$;
     G_WPFB  : 0 ,$;
     G_NPFB  : 0 ,$;
     G_MIX   : 0D,$;
     G_EXT   : 0D,$;
     G_ADC   : 0D,$;             
     G_WCENTER: 0D,$;
     G_WBAND : 0D,$;
     G_WDELT : 0D,$;
     G_DAC   : 0B,$;
     G_TIME  : lonarr(2),$; 
	 G_LO1   : 0D,$; The lo1 freq mhz?? 28oct04
     G_LO2   : 0D,$; The lo2 freq mhz?? 28oct04 
     G_POSTM : 0D,$; timestatmp for ra/dec in hours after midnite 28oct04
     G_AZZATM: 0D $; timestatmp for az/za in hours after midnite 28oct04
	}
; ------------------------------------------------------------------
; 
; version 2 . 22oct04 ..
;  g_wide  went 256->512 entries
;  g_dac   went bytarr(14) to 0B
;  to identify
;
;  g_wide = 256 and no crval2a
;
; this is what is on disc
;
a={galfhdrV2B , $
     CRVAL1  : 0D,$;
     CDELT1  : 0d,$;
     CRPIX1  : 0d,$;
     CRVAL2  : 0d,$; no data here
     CRVAL3  : 0d,$;
     CRVAL4  : 0d,$;
     BANDWID : 0d,$;
     RESTFREQ: 0d,$;
     FRONTEND: 0B,$;
     IFVAL   : 0B,$;
     G_WIDE  : lonarr(512),$;
     G_ERR   : 0 ,$;
     G_SEQ   : 0 ,$;
     G_BEAM  : 0B,$;
     G_WSHIFT: 0B,$;
     G_NSHIFT: 0B,$;
     G_WPFB  : 0 ,$;
     G_NPFB  : 0 ,$;
     G_MIX   : 0D,$;
     G_EXT   : 0D,$;
     G_ADC   : 0D,$;             
     G_WCENTER: 0D,$;
     G_WBAND : 0D,$;
     G_WDELT : 0D,$;
     G_DAC   : 0B,$;
     G_TIME  : lonarr(2)}
; ------------------------------------------------------------------
;
; version 1. 256 wideband channels
; identify: g_wide =256
	 ;
a={galfhdrV1 , $
	 VERSION : '1',$;
     CRVAL1  : 0D,$;
     CDELT1  : 0d,$;
     CRPIX1  : 0d,$;
     CRVAL2  : 0d,$; no data here
     CRVAL3  : 0d,$;
     CRVAL4  : dblarr(2),$;
     BANDWID : 0d,$;
     RESTFREQ: 0d,$;
     FRONTEND: '',$;
     IFVAL   : bytarr(2),$;
	 jd_obs  : 0d,$; added
	 sec1970 : 0d,$; added
     G_WIDE  : lonarr(256,2),$;
     G_ERR   : intarr(2) ,$;
     G_SEQ   : intarr(2) ,$;
     G_BEAM  : 0B,$;
     G_WSHIFT: 0B,$;
     G_NSHIFT: 0B,$;
     G_WPFB  : 0 ,$;
     G_NPFB  : 0 ,$;
     G_MIX   : 0D,$;
     G_EXT   : 0D,$;
     G_ADC   : 0D,$;             
     G_WCENTER: 0D,$;
     G_WBAND : 0D,$;
     G_WDELT : 0D,$;
     G_DAC   : bytarr(14),$;
     G_TIME  : lonarr(2)}
;
; this is was is on disc
;
a={galfhdrV1B , $
     CRVAL1  : 0D,$;
     CDELT1  : 0d,$;
     CRPIX1  : 0d,$;
     CRVAL2  : 0d,$;
     CRVAL3  : 0d,$;
     CRVAL4  : 0d,$;
     BANDWID : 0d,$;
     RESTFREQ: 0d,$;
     FRONTEND: 0B,$;
     IFVAL   : 0B,$;
     G_WIDE  : lonarr(256),$;
     G_ERR   : 0 ,$;
     G_SEQ   : 0 ,$;
     G_BEAM  : 0B,$;
     G_WSHIFT: 0B,$;
     G_NSHIFT: 0B,$;
     G_WPFB  : 0 ,$;
     G_NPFB  : 0 ,$;
     G_MIX   : 0D,$;
     G_EXT   : 0D,$;
     G_ADC   : 0D,$;             
     G_WCENTER: 0D,$;
     G_WBAND : 0D,$;
     G_WDELT : 0D,$;
     G_DAC   : bytarr(14),$;
     G_TIME  : lonarr(2)}
;
; struct to hold g_err decoding
; g_err definition
; two bit coding:
; 0 - 0  to 15  errors in previous 1 sec
; 1 - 16 to 255 errors in previous 1 sec
; 2 - 256 to 4095  errors in previous 1 sec
; 3 - > 4096  errors in previous 1 sec
; note that pola,b will always have the same errors for a given beam.
;
a= {g_errst, $
	wbUpShSat : 0 , $; 01 wide band upshift saturation
	wbFftOvr  : 0 , $; 23 widt band fft overflow
	nbUpShSat : 0 , $; 45 narrow band upshift saturation
	nbFftOvr  : 0 , $; 67 narrow band fft overflow
	nbLpSat   : 0 , $; 89 narrow band low pass filter saturation
	nbMixSat  : 0 , $; 10 11 narrow band mixer saturation
	  adcSat  : 0 }  ; 12 13 adc input saturation
;
; ------------------------------------------------------------------
;
; structure for gal archive.
;
;   The archive record consists of:

a={slgal ,$
    scan      :         0L, $; scannumber this entry
    rowStart  :         0L, $; row in fits file start of scan 0 based.
    fileindex :         0L, $; lets you point to a filename array
    stat      :         0B ,$; not used yet..
    rcvnum    :         0B ,$; receiver number 1-16, 17=alfa
    numfrq    :         0B ,$; number of freq,cor boards used this scan
    rectype   :         0B ,$;1-calon,2-caloff,3-posOn,4-posOff
    numrecs   :         0L ,$; number of groups(records in scan)
    freq      :   fltarr(8),$;topocentric freqMhz center each subband
    julday    :         0.D,$; julian day start of scan
    srcname   :         ' ',$;source name (max 12 long)
    procname  :         ' ',$;procedure name used.
    stepName  :         ' ',$;name of step in procedure this scan
    projId    :         '' ,$; from the filename
    patId     :         0L ,$; groups scans beloging to a known pattern

   secsPerrec :         0. ,$; seconds integration per record
    channels  :   intarr(8),$; number output channels each sbc
    bw        :   fltarr(8),$; bandwidth used Mhz
    backendmode:  strarr(8),$; lag config each sbc
    lag0      :  fltarr(2,8),$; lag 0 power ratio (scan average)
    blanking  :         0B  ,$; 0 or 1

    azavg     :         0. ,$; actual encoder azimuth average of scan
    zaavg     :         0. ,$; actual encoder za      average of scan
	encTmSt   :         0. , $; secs Midnite ast when encoders read
;								start of scan

    raHrReq   :         0.D,$; requested ra ,  start of scan  J2000
    decDReq   :         0.D,$; requested dec,  start of scan J2000.

;                       Delta end-start real angle for requested position
    raDelta   :         0. ,$; delta ra last-first recs. Amins real angle
   decDelta   :         0. ,$; delta dec (last-frist)Arcminutes real  angle

    pntErrAsec :         0. ,$; avg great circle pnt error


;     alfa related

     alfaAngle:         0.  , $; alfa rotation angle used in deg
     alfaCen :          0B  $; alfa pixel that is centered on ra/dec position
	}
