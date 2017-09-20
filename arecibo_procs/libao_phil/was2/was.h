;
; header files for was
;
; notes: true below --> data was interpolated to the data sample
;                      (i think the start of the data sample)
;
; hdr that is specific to was...
; note: rp is reference pixel (counts from 1).
;
; modified 01feb05  updates for fits file version 1.0
;                   previous header version in was.h._3
;
; modified 25oct04. modified b1.hf .. added:
;        version:   'v1.0'
; 		 crval2a,crval3a,2b,3b,2c,3c,2g,3b, 
;		 croff2b,3b
;  CRVAL1V :   0d ,$; Requested Velocity
;  CRPIX1V :   0d ,$; ref pixel for vel
;  CUNIT1V : ''   ,$; units of crval1v m/s or Z
;  CTYP1V  : ''   ,$; units of for velocity
;SPECSYS   : ''   ,$; frame for velocity
;   bandwid:
;date_obs  :
;
;
a={washdr , $
    version     :'1.0'  ,$; version number 
	rpfreq	    : 0.D	,$; reference pixel frequency in Mhz
	chanfreqStep: 0.D   ,$; freq step between channels. (mhz)
	rpRestFreq  : 0.D   ,$; rest frequency for reference pixel (Mhz).
	rpChan  	: 0L	,$; reference pixel channel number (count from 1)
	numChan     : 0L    ,$;
	exp         : 0.D   ,$; integration time secs

	crval2      : 0.D   ,$;
	crval3      : 0.D   ,$;
	equinox     : 0.D   ,$; 25oct04
	crval2a     : 0.D   ,$; 25oct04
	crval3a     : 0.D   ,$; 25oct04
	crval2b     : 0.D   ,$; 25oct04
	crval3b     : 0.D   ,$; 25oct04
	crval2c     : 0.D   ,$; 25oct04
	crval3c     : 0.D   ,$; 25oct04
	crval2g     : 0.D   ,$; 25oct04
	crval3g     : 0.D   ,$; 25oct04 
	crval5      : 0.D   ,$;
	date_obs    : ''    ,$; 25oct04
	lst         : 0.D   ,$; 25oct04
	bandwid     : 0.D   ,$; 25oct04
	crval1v     : 0.D   ,$; 25oct04
    crpix1v     : 0.D   ,$; 25oct04
    cunit1v     : ''    ,$; 25oct04
    ctype1v     : ''    ,$; 25oct04
    specsys     : ''    ,$; 25oct04

	mjd_obs     : 0.D   ,$;
	croff2      : 0.D   ,$;
	croff3      : 0.D   ,$;
	croff2b     : 0.D   ,$; 25oct04
	croff3b     : 0.D   ,$; 25oct04
	off_cs      : ''    ,$;
	rate_ra     : 0.D   ,$;
	rate_dec    : 0.D   ,$;
	rate_cs     : ''    ,$;
	rate_dur    : 0.d   ,$;
	rate_time   : 0.d   ,$; day.fract when rate applied (ast)

	beam_az     : 0.d   ,$; unrotated beam az offset for alfa deg
	beam_za     : 0.d   ,$; unrotated beam za offset for alfa deg
	alfa_ang    : 0.d   ,$; rotation angle deg
	para_ang    : 0.d   ,$; parallactic angle deg
	obs_mode    : ''    ,$; pattern name
	obs_name    : ''    ,$; step in pattern name
	projid      : ''     $; project id
						 }; 

a={wasfhdr , $
    TDIM1   :   ''  ,$;2 5feb05  Dimensions of data pointed to in the heap
    OBJECT  :   ''  ,$;3 16a Name of source observed                      
    CRVAL1  :   0D ,$;4 Center Frequency hz
    CDELT1  :   0D ,$;5 Frequency Interval hz                            
    CRPIX1  :   0D ,$;6 Pixel of Center Frequency                      
    CRVAL2  :   0d ,$;7 requested source RA deg                           
    CRVAL3  :   0d ,$;8 requested source DEC deg                          
    CRVAL4  :   0d ,$;9 Polarization (neg -> Pol, Pos -> Stokes)       
    CRVAL5  :   0d ,$;10 secs since midnight from obsdate  UTC             
    RADESYS :   '' ,$ ;11 5feb05 Coordinate system for CRVAL2 and CRVAL3 */
	EQUINOX :   0d ,$; 12 Epoch of requested source RA, DEC
    DATE_OBS:   '' ,$;13 a8 yyyymmdd start of this obs utc
    TSYS    :   0d ,$;14 last computed Tsys                             
    BANDWID :   0d ,$;15 Overall Bandwidth of spectrum                  
    RESTFRQV:   0d ,$;16 Rest freq at band center                       
    CRVAL1V :   0d ,$;17 Requested Velocity or z                             
    CDELT1V:    0d ,$;18 5feb05 change nm delta vel at ref pixel
    CRPIX1V :   0d ,$;19 Pixel of center channel
    CUNIT1V :   '' ,$;20 Specifies units of CRVAL1V and CDELT1V
    CTYPE1V :   '' ,$;21 5feb05 nmchange Velocity type, units for velocity
    SPECSYSV:   '' ,$;22 5feb05 nmchange Velocity frame, frame for velocity
    MJD_OBS :   0d ,$;23 Modified Julian day number at exposure start
    LST     :   0d ,$;24 Local Mean Siderial Time                       
    EXPOSURE:   0d ,$;25 Exposure                                       

    ENC_TIME:   0d ,$;26 5feb05 Time when encoders were read out (UTC) 
    ENC_AZIMUTH:0d ,$;27  Azimuth encoder read-out at ENC_TIME
   ENC_ELEVATIO:0d ,$;28 Elevation encoder read-out at ENC_TIME 
   ENC_ALTEL:   0d ,$;29 Encoder Elevation of other Carriage House      

    CROFF2  :   0d ,$;30 hr True RAJ offset to commanded map center
    CROFF3  :   0d ,$;31 deg True DECJ offset to commanded map center
	OFFC1   :   0d ,$;32 rad engineering offset
	OFFC2   :   0d ,$;33 rad engineering offset
    OFF_TIME:   0d ,$;34 05feb05(to utc) seconds from midnight utc
    RATE_C1 :   0d ,$;35 Rate of change offset (eng)
    RATE_C2 :   0d ,$;36 Rate of change offset (eng)
    OFF_CS  :   0L ,$;37 Coordinate system of offs                      
    RATE_CS :   0L ,$;38 Coordinate system of rates                     
    RATE_DUR:   0d ,$;39 How long has rate been applied                 
    CUR_ERR  :  0d ,$;40 5feb05 nmchange asec Actual great circle tracking error
  ALLOWED_ERR:  0d ,$;41 5feb05 nmchn asec Maximum allowed tracking error
  az_err     :  0d ,$;42 asec 5feb05 Azimuth tracking error
  el_err     :  0d ,$;43 asec 5feb05 Elevation tracking error

  model_offaz:  0d ,$;44 deg pointing model offset az           
  model_offza:  0d ,$;45 deg pointing model offset za         
   beam_offaz:  0d ,$;46 deg ALFA unrotated offset az
   beam_offza:  0d ,$;47 deg ALFA unrotated offset za
   user_offaz:  0d ,$;48 deg User selected pointing offset az (gcircle)
   user_offza:  0d ,$;49 deg User selected pointing offset za
  rfeed_offaz:  0d ,$;50 deg rotated offset this beam az     
  rfeed_offza:  0d ,$;51 deg rotated offset this beam za
 prfeed_offaz:  0d ,$;52 deg offset to center prfeed beam az     
 prfeed_offza:  0d ,$;53 deg offset to center prfeed beam za
  beam_offRaJ:  0d ,$;54 deg tot ra offset to this beam
 beam_offDecJ:  0d ,$;55 deg tot dec offset to this beam
     azimuth :  0d ,$;56 deg 5feb05 True az pointing this beam on sky 
    elevation:  0d ,$;57 deg 5feb05 True el pointing this beam on sky 
      crval2a:  0d ,$;58 hr  true ra pointing this beam on sky
      crval3a:  0d ,$;59 deg true dec pointing this beam on sky
      crval2c:  0d ,$;60 deg  Ra J2000 ant pointing without rx offset
      crval3c:  0d ,$;61 deg Dec J2000ant pointing without rx offset
      crval2g:  0d ,$;62 deg true gal l pointing this beam
      crval3g:  0d ,$;63 deg true gal b pointing this beam
      croff2b:  0d ,$;64 deg true az off to commanded map center
      croff3b:  0d ,$;65 deg true za off to commanded map center
     alfa_ang:  0d ,$;66 deg alfa rotation angle
     para_ang:  0d ,$;67 deg parallactic angle               

    FRONTEND :  '' ,$;68 Receiver name                                  
    BACKENDMODE: '',$;69 a24 back mode string
    CALTYPE  :  '',$;$70 a8 Cal type                                      

    OBSMODE  :  ''  ,$;71  Name of pattern ONOFF CAL OFFON DRIFT ON OFF   
    SCANTYPE :  '',$;72  Name of lowest obs ON OFF CALON CALOFF DRIFT   
   PATTERN_ID:  0L ,$;73 unique number for pattern YDDDnnnnn
     SCAN_ID :  0L ,$;74 Unique number for scan YDDDnnnnn
     SUBSCAN :  0L ,$;75  Sequential number of current subscan (dump)
TOTAL_SUBSCAN:  0L ,$;76 Total number of subscans (dumps) in scan
    LAGS_IN  :  0L ,$;77 number of Lags - same as bytes of data/4       
    BAD_DATA :  0UL,$;78 0->good data <>0->problem (see COMMENT)

   PLAT_POWER:  0d ,$;79 Power from platform meter                      
  CNTRL_POWER:  0d ,$;80 Power from control room meter                  
    SYN1     :  0d ,$;81 platform synthesizer                           
    SYNFRQ   : dblarr(4),$;82 control room synthesizers                      
   TOT_POWER :  0d ,$;83 Scaled Power in zero-lag                       
    WAPPMASK :  0L ,$;84 which other wapps or alfas enabled
    NTCAL    :  0L ,$;85 number of valid tcal pairs
	 
    TCAL_FRQ :  dblarr(32) ,$;86Frequencies for Tcal-values in TCAL_VAL
    TCAL_VAL :  dblarr(32) ,$;87Tcal-values for frequencies in TCAL_FRQ

 
    PRFEED   :  0B  ,$;88 alfa feed on paraxial ray this scan
    NIFS     :  0B  ,$;89 number of ifs in this observation              
    IFVAL    :  0b  ,$;90 which polarization, 0-1 or 0-3 for stokes      
    INPUT_ID :  0b  ,$;91 WAPP number 0-3 or 0-7 for ALFA                
	 
    UPPERSB  :  0b  ,$;92 True if spectrum flipped                      
	attn_cor :  0b  ,$;93 Correlator attenuator: 0-15 
    MASTER   :  0b  ,$;94 0 greg 1 carriage house                        

    ONSOURCE :  0b  ,$;95   if onsource at enc_time                       
    BLANKING :  0b  ,$;96   Blanking turned on                            
    LBWHYB   :  0b  ,$;97 LBandWide Hybrid is in (for circular pol)      
    SHCL     :  0b  ,$;98 true if receiver shutter closed                
    SBSHCL   :  0b  ,$;99 true if Sband receiver shutter closed          

    RFNUM    :  0b  ,$;100 platform position of the receiver selectror    
    CALRCVMUX:  0b  ,$;101 platform cal selector
    ZMNORMAL :  0b  ,$;102 platform transfer switch to reverse channels, t
    RFATTN   :  bytarr(2),$;103 platform attenuator position                   
    IFNUM    :  0b  ,$;104 platform if selector, 1/300 2/750, 3/1500, 4/10
    IFATTN   :  bytarr(2),$;105 platform IF attenuator positions               
    FIBER    :  0b  ,$;106 true if platform fiber is chosen (always the ca
    AC2SW    :  0b  ,$;107 platform ac power to various instruments and ot

    PHBSIG   :  0b  ,$;108 platform converter combiner signal phase adjust
    HYBRID   :  0b  ,$;109 platform converter combiner hybrid             
    PHBLO    :  0b  ,$;110 settings                                       

    XFNORMAL :  0b  ,$;111 control room transfer switch true = deflt      
    NOISE    :  0b  ,$;112 control room noise on                          
    AMPGAIN  :  bytarr(2),$;113 gain of control room amps                      
    INPFRQ   :  0b  ,$;114 control room input distributor position        
    MIXER    :  bytarr(4),$;115 control room mixer source switches             
    VLBAINP  :  0b  ,$;116 control room vlba input switch position        
    AMPINP   :  bytarr(4),$;117 control room amplifier input source switches   
    EXTINP   :  bytarr(4),$;118 control room external input selector switches  
    SYNDEST  :  bytarr(4),$;119 control room synthesizer destinations          
    CALSRC   :  0b  ,$;120 control room cal source bit                    
    CAL      :  0b  ,$;121 is cal bit on 

    VIS30MHZ :  0b  ,$;122 control room greg 1 ch 0                       
    PWRMET   :  0b  ,$;123 control room power meter input switch          
    BLANK430 :  0b  } ;124 control room 430 blanking on                   

a={wasfhdrB , $
    TDIM1   :   bytarr(16),$;2 5feb05  Dimensions of data pointed to in the heap
    OBJECT  :	bytarr(16),$;3 16a Name of source observed                      
    CRVAL1  :   0D ,$;4 Center Frequency hz
    CDELT1  :   0D ,$;5 Frequency Interval hz                            
    CRPIX1  :   0D ,$;6 Pixel of Center Frequency                      
    CRVAL2  :   0d ,$;7 requested source RA deg                           
    CRVAL3  :   0d ,$;8 requested source DEC deg                          
    CRVAL4  :   0d ,$;9 Polarization (neg -> Pol, Pos -> Stokes)       
    CRVAL5  :   0d ,$;10 secs since midnight from obsdate  UTC             
    RADESYS :   bytarr(8),$;11 5feb05 Coordinate system for CRVAL2 and CRVAL3 */
	EQUINOX :   0d ,$; 12 Epoch of requested source RA, DEC
    DATE_OBS: bytarr(16),$;13 a8 yyyymmdd start of this obs utc
    TSYS    :   0d ,$;14 last computed Tsys                             
    BANDWID :   0d ,$;15 Overall Bandwidth of spectrum                  
    RESTFRQV:   0d ,$;16 Rest freq at band center                       
    CRVAL1V :   0d ,$;17 Requested Velocity or z                             
    CDELT1V:    0d ,$;18 5feb05 change nm delta vel at ref pixel
    CRPIX1V :   0d ,$;19 Pixel of center channel
    CUNIT1V : bytarr(8),$;20 Specifies units of CRVAL1V and CDELT1V
    CTYPE1V : bytarr(8),$;21 5feb05 nmchange Velocity type, units for velocity
    SPECSYSV: bytarr(8),$;22 5feb05 nmchange Velocity frame, frame for velocity
    MJD_OBS :   0d ,$;23 Modified Julian day number at exposure start
    LST     :   0d ,$;24 Local Mean Siderial Time                       
    EXPOSURE:   0d ,$;25 Exposure                                       

    ENC_TIME:   0d ,$;26 5feb05 Time when encoders were read out (UTC) 
    ENC_AZIMUTH:0d ,$;27  Azimuth encoder read-out at ENC_TIME
   ENC_ELEVATIO:0d ,$;28 Elevation encoder read-out at ENC_TIME 
   ENC_ALTEL:   0d ,$;29 Encoder Elevation of other Carriage House      

    CROFF2  :   0d ,$;30 hr True RAJ offset to commanded map center
    CROFF3  :   0d ,$;31 deg True DECJ offset to commanded map center
	OFFC1   :   0d ,$;32 rad engineering offset
	OFFC2   :   0d ,$;33 rad engineering offset
    OFF_TIME:   0d ,$;34 05feb05(to utc) seconds from midnight utc
    RATE_C1 :   0d ,$;35 Rate of change offset (eng)
    RATE_C2 :   0d ,$;36 Rate of change offset (eng)
    OFF_CS  :   0L ,$;37 Coordinate system of offs                      
    RATE_CS :   0L ,$;38 Coordinate system of rates                     
    RATE_DUR:   0d ,$;39 How long has rate been applied                 
    CUR_ERR  :  0d ,$;40 5feb05 nmchange asec Actual great circle tracking error
  ALLOWED_ERR:  0d ,$;41 5feb05 nmchn asec Maximum allowed tracking error
  az_err     :  0d ,$;42 asec 5feb05 Azimuth tracking error
  el_err     :  0d ,$;43 asec 5feb05 Elevation tracking error

  model_offaz:  0d ,$;44 deg pointing model offset az           
  model_offza:  0d ,$;45 deg pointing model offset za         
   beam_offaz:  0d ,$;46 deg ALFA unrotated offset az
   beam_offza:  0d ,$;47 deg ALFA unrotated offset za
   user_offaz:  0d ,$;48 deg User selected pointing offset az (gcircle)
   user_offza:  0d ,$;49 deg User selected pointing offset za
  rfeed_offaz:  0d ,$;50 deg rotated offset this beam az     
  rfeed_offza:  0d ,$;51 deg rotated offset this beam za
 prfeed_offaz:  0d ,$;52 deg offset to center prfeed beam az     
 prfeed_offza:  0d ,$;53 deg offset to center prfeed beam za
  beam_offRaJ:  0d ,$;54 deg tot ra offset to this beam
 beam_offDecJ:  0d ,$;55 deg tot dec offset to this beam
     azimuth :  0d ,$;56 deg 5feb05 True az pointing this beam on sky 
    elevation:  0d ,$;57 deg 5feb05 True el pointing this beam on sky 
      crval2a:  0d ,$;58 hr  true ra pointing this beam on sky
      crval3a:  0d ,$;59 deg true dec pointing this beam on sky
      crval2c:  0d ,$;60 deg  Ra J2000 ant pointing without rx offset
      crval3c:  0d ,$;61 deg Dec J2000ant pointing without rx offset
      crval2g:  0d ,$;62 deg true gal l pointing this beam
      crval3g:  0d ,$;63 deg true gal b pointing this beam
      croff2b:  0d ,$;64 deg true az off to commanded map center
      croff3b:  0d ,$;65 deg true za off to commanded map center
     alfa_ang:  0d ,$;66 deg alfa rotation angle
     para_ang:  0d ,$;67 deg parallactic angle               

    FRONTEND : bytarr(8),$;68 Receiver name                                  
    BACKENDMODE: bytarr(24),$;69 a24 back mode string
    CALTYPE  : bytarr(8),$;$70 a8 Cal type                                      

    OBSMODE  : bytarr(8),$;71  Name of pattern ONOFF CAL OFFON DRIFT ON OFF   
    SCANTYPE : bytarr(8),$;72  Name of lowest obs ON OFF CALON CALOFF DRIFT   
   PATTERN_ID:  0L ,$;73 unique number for pattern YDDDnnnnn
     SCAN_ID :  0L ,$;74 Unique number for scan YDDDnnnnn
     SUBSCAN :  0L ,$;75  Sequential number of current subscan (dump)
TOTAL_SUBSCAN:  0L ,$;76 Total number of subscans (dumps) in scan
    LAGS_IN  :  0L ,$;77 number of Lags - same as bytes of data/4       
    BAD_DATA :  0UL,$;78 0->good data <>0->problem (see COMMENT)

   PLAT_POWER:  0d ,$;79 Power from platform meter                      
  CNTRL_POWER:  0d ,$;80 Power from control room meter                  
    SYN1     :  0d ,$;81 platform synthesizer                           
    SYNFRQ   : dblarr(4),$;82 control room synthesizers                      
   TOT_POWER :  0d ,$;83 Scaled Power in zero-lag                       
    WAPPMASK :  0L ,$;84 which other wapps or alfas enabled
    NTCAL    :  0L ,$;85 number of valid tcal pairs
	 
    TCAL_FRQ :  dblarr(32) ,$;86Frequencies for Tcal-values in TCAL_VAL
    TCAL_VAL :  dblarr(32) ,$;87Tcal-values for frequencies in TCAL_FRQ

 
    PRFEED   :  0B  ,$;88 alfa feed on paraxial ray this scan
    NIFS     :  0B  ,$;89 number of ifs in this observation              
    IFVAL    :  0b  ,$;90 which polarization, 0-1 or 0-3 for stokes      
    INPUT_ID :  0b  ,$;91 WAPP number 0-3 or 0-7 for ALFA                
	 
    UPPERSB  :  0b  ,$;92 True if spectrum flipped                      
	attn_cor :  0b  ,$;93 Correlator attenuator: 0-15 
    MASTER   :  0b  ,$;94 0 greg 1 carriage house                        

    ONSOURCE :  0b  ,$;95   if onsource at enc_time                       
    BLANKING :  0b  ,$;96   Blanking turned on                            
    LBWHYB   :  0b  ,$;97 LBandWide Hybrid is in (for circular pol)      
    SHCL     :  0b  ,$;98 true if receiver shutter closed                
    SBSHCL   :  0b  ,$;99 true if Sband receiver shutter closed          

    RFNUM    :  0b  ,$;100 platform position of the receiver selectror    
    CALRCVMUX:  0b  ,$;101 platform cal selector
    ZMNORMAL :  0b  ,$;102 platform transfer switch to reverse channels, t
    RFATTN   :  bytarr(2),$;103 platform attenuator position                   
    IFNUM    :  0b  ,$;104 platform if selector, 1/300 2/750, 3/1500, 4/10
    IFATTN   :  bytarr(2),$;105 platform IF attenuator positions               
    FIBER    :  0b  ,$;106 true if platform fiber is chosen (always the ca
    AC2SW    :  0b  ,$;107 platform ac power to various instruments and ot

    PHBSIG   :  0b  ,$;108 platform converter combiner signal phase adjust
    HYBRID   :  0b  ,$;109 platform converter combiner hybrid             
    PHBLO    :  0b  ,$;110 settings                                       

    XFNORMAL :  0b  ,$;111 control room transfer switch true = deflt      
    NOISE    :  0b  ,$;112 control room noise on                          
    AMPGAIN  :  bytarr(2),$;113 gain of control room amps                      
    INPFRQ   :  0b  ,$;114 control room input distributor position        
    MIXER    :  bytarr(4),$;115 control room mixer source switches             
    VLBAINP  :  0b  ,$;116 control room vlba input switch position        
    AMPINP   :  bytarr(4),$;117 control room amplifier input source switches   
    EXTINP   :  bytarr(4),$;118 control room external input selector switches  
    SYNDEST  :  bytarr(4),$;119 control room synthesizer destinations          
    CALSRC   :  0b  ,$;120 control room cal source bit                    
    CAL      :  0b  ,$;121 is cal bit on 

    VIS30MHZ :  0b  ,$;122 control room greg 1 ch 0                       
    PWRMET   :  0b  ,$;123 control room power meter input switch          
    BLANK430 :  0b  } ;124 control room 430 blanking on                   
;
; structure for was archive.
;
;   The archive record consists of:

a={slwas ,$
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
