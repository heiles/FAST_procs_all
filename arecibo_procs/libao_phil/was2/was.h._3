;
; header files for was
;
; archived 30jan05. 
; version until fits version .9 of fits file released (
; 3feb05..
;
; hdr that is specific to was...
; note: rp is reference pixel (counts from 1).
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
    OBJECT  :	'' ,$; 16a Name of source observed                        
    CRVAL1  :   0D ,$; Center Frequency hz
    CDELT1  :   0D ,$; Frequency Interval hz                            
    CRPIX1  :   0D ,$; Pixel of Center Frequency                      
    CRVAL2  :   0d ,$; requested source RA deg                           
    CRVAL3  :   0d ,$; requested source DEC deg                          
    EQUINOX :   0d ,$; requested source DEC deg                          
    CRVAL4  :   0d ,$; Polarization (neg -> Pol, Pos -> Stokes)       
    CRVAL5  :   0d ,$; hours since midnight from obsdate              
    DATE_OBS:   '' ,$; a8 yyyymmdd start of this obs                     
    TSYS    :   0d ,$; last computed Tsys                             
    BANDWID :   0d ,$; Overall Bandwidth of spectrum                  
    RESTFRQV:   0d ,$; Rest freq at band center                       
	CRVAL1V :   0d ,$; Requested Velocity
    CRDELT1V:   0d ,$; delta vel at ref pixel
    CRPIX1V :   0d ,$; ref pixel for vel
    CUNIT1V : ''   ,$; units of crval1v m/s or Z
    CTYP1V  : ''   ,$; units of for velocity
    SPECSYS : ''   ,$; frame for velocity
    MJD_OBS :   0d ,$; julian day at exporsure start
    LST     :   0d ,$; Local Mean Siderial Time                       
    EXPOSURE:   0d ,$; Exposure                                       

    ENC_AZIMUTH:0d ,$; Encoder Azimuth on sky (not feed)              
   ENC_ELEVATIO:0d ,$; Encoder Elevation                              
   ENC_ALTEL:   0d ,$; Encoder Elevation of other Carriage House      

    CROFF2  :   0d ,$; Ra offset applied at req_time                  
    CROFF3  :   0d ,$; Dec offset applied at req_time                 

	OFFC1   :   0d ,$;29 rad engineering offset
	OFFC2   :   0d ,$;30 rad engineering offset
    OFF_TIME:   0d ,$; seconds from midnight ast                      
    RATE_C1 :   0d ,$; rate of change of ra                           
    RATE_C2 :   0d ,$; rate of change of dec                          
    OFF_CS  :   0L ,$; Coordinate system of offs                      
    RATE_CS :   0L ,$; Coordinate system of rates                     
    RATE_DUR:   0d ,$; How long has rate been applied                 
    CUR_TOL  :  0d ,$; computed great circle tolerance                
    REQ_TOL  :  0d ,$; requested tolerance                            
	 model_offaz:  0d ,$;39 deg pointing model offset az
  model_offza:  0d ,$;40 deg pointing model offset za
   beam_offaz:  0d ,$;41 deg alfa offset az
   beam_offza:  0d ,$;42 deg alfa offset za
   user_offaz:  0d ,$;43 deg user commanded offset az
   user_offza:  0d ,$;44 deg user commanded offset za
  rfeed_offaz:  0d ,$;45 deg rotated offset this beam az
  rfeed_offza:  0d ,$;46 deg rotated offset this beam za
 prfeed_offaz:  0d ,$;47 deg offset to center prfeed beam az
 prfeed_offza:  0d ,$;48 deg offset to center prfeed beam za
  beam_offRaJ:  0d ,$;49 deg tot ra offset to this beam
 beam_offDecJ:  0d ,$;50 deg tot dec offset to this beam
      crval2a:  0d ,$;51 hr  true ra pointing this beam on sky
      crval3a:  0d ,$;52 deg true dec pointing this beam on sky
      crval2b:  0d ,$;53 deg true az pointing this beam on sky
      crval3b:  0d ,$;54 deg true za pointing this beam on sky
      crval2c:  0d ,$;55 deg raj ant pointing without rx offset
      crval3c:  0d ,$;56 deg decj ant pointing without rx offset
      crval2g:  0d ,$;57 deg true gal l pointing this beam
      crval3g:  0d ,$;58 deg true gal b pointing this beam
      croff2b:  0d ,$;59 deg true az off to commanded map center
      croff3b:  0d ,$;60 deg true za off to commanded map 
     alfa_ang:  0d ,$;46 deg alfa rotation angle
  para_ang   :  0d ,$; parallactic angle             

    OBS_MODE :  '' ,$; a8 Name of pattern ONOFF CAL OFFON DRIFT ON OFF   
    OBS_NAME :  '' ,$; a8 Name of lowest obs ON OFF CALON CALOFF DRIFT   
    BACKENDMODE : ''  ,$; a24 backend mode string
    CALTYPE  : ''  ,$; a8 Cal type                                       
    FRONTEND : ''  ,$; Receiver name                                  
   PLAT_POWER:  0d ,$; Power from platform meter                      
  CNTRL_POWER:  0d ,$; Power from control room meter                  
   TOT_POWER :  0d ,$; Scaled Power in zero-lag                       
    TCAL     :  dblarr(64) ,$; data                                           

    SYN1     :  0d ,$; platform synthesizer                           
    SYNFRQ   : dblarr(4),$; control room synthesizers                      
	PATTERN_SCAN:  0L ,$; unique number for pattern YDDDnnnnn
    SCAN_NUMBER :  0L ,$; unique num for low-level observation YDDDnnnnn
    PATTERN_NUMBER:  0L ,$;  sequential observation number of obs_scans
    TOTAL_PATTERN :  0L ,$; total number of PATTERN_numbers
    ENC_TIME :  0L ,$; Time when enc_AZ and enc_ZA measured           
    LAGS_IN  :  0L ,$; number of Lags - same as bytes of data/4       
    WAPPMASK :  0L ,$; which other wapps or alfas enabled
    NTCAL    :  0L ,$; number of valid tcal pairs

    PRFEED   :  0B  ,$;82 alfa feed on paraxial ray this scan
    NIFS     :  0B  ,$; number of ifs in this observation              
    IFVAL    :  0b  ,$; which polarization, 0-1 or 0-3 for stokes      
    ATTN_COR :  0b  ,$; Correlator attenuator 0-15                     
    UPPERSB  :  0b  ,$; True if spectrum flipped                      
    INPUT_ID :  0b  ,$; WAPP number 0-3 or 0-7 for ALFA                
    MASTER   :  0b  ,$; 0 greg 1 carriage house                        

    ONSOURCE :  0b  ,$;   if onsource at enc_time                       
    BLANKING :  0b  ,$;   Blanking turned on                            
    LBWHYB   :  0b  ,$; LBandWide Hybrid is in (for circular pol)      
    SHCL     :  0b  ,$; true if receiver shutter closed                
    SBSHCL   :  0b  ,$; true if Sband receiver shutter closed          

    RFNUM    :  0b  ,$; platform position of the receiver selectror    
    CALRCVMUX:  0b  ,$; platform cal selector
    ZMNORMAL :  0b  ,$; platform transfer switch to reverse channels, t
    RFATTN   :  bytarr(2),$; platform attenuator position                   
    IFNUM    :  0b  ,$; platform if selector, 1/300 2/750, 3/1500, 4/10
    IFATTN   :  bytarr(2),$; platform IF attenuator positions               
    FIBER    :  0b  ,$; true if platform fiber is chosen (always the ca
    AC2SW    :  0b  ,$; platform ac power to various instruments and ot

    PHBSIG   :  0b  ,$; platform converter combiner signal phase adjust
    HYBRID   :  0b  ,$; platform converter combiner hybrid             
    PHBLO    :  0b  ,$; settings                                       

    XFNORMAL :  0b  ,$; control room transfer switch true = deflt      
    NOISE    :  0b  ,$; control room noise on                          
    GAIN     :  bytarr(2),$; gain of control room amps                      
    INPFRQ   :  0b  ,$; control room input distributor position        
    MIXER    :  bytarr(4),$; control room mixer source switches             
    VLBAINP  :  0b  ,$; control room vlba input switch position        
    AMPINP   :  bytarr(4),$; control room amplifier input source switches   
    EXTINP   :  bytarr(4),$; control room external input selector switches  
    SYNDEST  :  bytarr(4),$; control room synthesizer destinations          
    CALSRC   :  0b  ,$; control room cal source bit                    
    CAL      :  0b  ,$; is cal bit on 

    VIS30MHZ :  0b  ,$; control room greg 1 ch 0                       
    PWRMET   :  0b  ,$; control room power meter input switch          
    BLANK430 :  0b  } ; control room 430 blanking on                   

a={wasfhdrB , $
    OBJECT  :	bytarr(16),$;2 16a Name of source observed                      
    CRVAL1  :   0D ,$;3 Center Frequency hz
    CDELT1  :   0D ,$;4 Frequency Interval hz                            
    CRPIX1  :   0D ,$;5 Pixel of Center Frequency                      
    CRVAL2  :   0d ,$;6 requested source RA deg                           
    CRVAL3  :   0d ,$;7 requested source DEC deg                          
	EQUINOX :   0d ,$;8  equinox for ra,dec pos 
    CRVAL4  :   0d ,$;9 Polarization (neg -> Pol, Pos -> Stokes)       
    CRVAL5  :   0d ,$;10 hours since midnight from obsdate              
    DATE_OBS: bytarr(16),$;11 a8 yyyymmdd start of this obs                     
    TSYS    :   0d ,$;12 last computed Tsys                             
    BANDWID :   0d ,$;13 Overall Bandwidth of spectrum                  
    RESTFRQV:   0d ,$;14 Rest freq at band center                       
    CRVAL1V :   0d ,$;15 Requested Velocity                             
    CRDELT1V:   0d ,$;16 delta vel at ref pixel
    CRPIX1V :   0d ,$;17 ref pixel for vel
    CUNIT1V : bytarr(8),$;18 units of crval1v m/s or Z
    CTYP1V  : bytarr(8),$;19 units of for velocity
    SPECSYS : bytarr(8),$;20 frame for velocity
    MJD_OBS :   0d ,$;21 julian day at exporsure start
    LST     :   0d ,$;22 Local Mean Siderial Time                       
    EXPOSURE:   0d ,$;23 Exposure                                       

    ENC_AZIMUTH:0d ,$;24 Encoder Azimuth on sky (not feed)              
   ENC_ELEVATIO:0d ,$;25 Encoder Elevation                              
   ENC_ALTEL:   0d ,$;26 Encoder Elevation of other Carriage House      

    CROFF2  :   0d ,$;27 Ra offset applied at req_time                  
    CROFF3  :   0d ,$;28 Dec offset applied at req_time                 
	OFFC1   :   0d ,$;29 rad engineering offset
	OFFC2   :   0d ,$;30 rad engineering offset
    OFF_TIME:   0d ,$;31 seconds from midnight ast                      
    RATE_C1 :   0d ,$;32 rate of change of ra                           
    RATE_C2 :   0d ,$;33 rate of change of dec                          
    OFF_CS  :   0L ,$;34 Coordinate system of offs                      
    RATE_CS :   0L ,$;35 Coordinate system of rates                     
    RATE_DUR:   0d ,$;36 How long has rate been applied                 
    CUR_TOL  :  0d ,$;37 computed great circle tolerance                
    REQ_TOL  :  0d ,$;38 requested tolerance                            
  model_offaz:  0d ,$;39 deg pointing model offset az           
  model_offza:  0d ,$;40 deg pointing model offset za         
   beam_offaz:  0d ,$;41 deg alfa offset az
   beam_offza:  0d ,$;42 deg alfa offset za
   user_offaz:  0d ,$;43 deg user commanded offset az        
   user_offza:  0d ,$;44 deg user commanded offset za         
  rfeed_offaz:  0d ,$;45 deg rotated offset this beam az     
  rfeed_offza:  0d ,$;46 deg rotated offset this beam za
 prfeed_offaz:  0d ,$;47 deg offset to center prfeed beam az     
 prfeed_offza:  0d ,$;48 deg offset to center prfeed beam za
  beam_offRaJ:  0d ,$;49 deg tot ra offset to this beam
 beam_offDecJ:  0d ,$;50 deg tot dec offset to this beam
      crval2a:  0d ,$;51 hr  true ra pointing this beam on sky
      crval3a:  0d ,$;52 deg true dec pointing this beam on sky
      crval2b:  0d ,$;53 deg true az pointing this beam on sky
      crval3b:  0d ,$;54 deg true za pointing this beam on sky
      crval2c:  0d ,$;55 deg raj ant pointing without rx offset
      crval3c:  0d ,$;56 deg decj ant pointing without rx offset
      crval2g:  0d ,$;57 deg true gal l pointing this beam
      crval3g:  0d ,$;58 deg true gal b pointing this beam
      croff2b:  0d ,$;59 deg true az off to commanded map center
      croff3b:  0d ,$;60 deg true za off to commanded map center
     alfa_ang:  0d ,$;61 deg alfa rotation angle
     para_ang:  0d ,$;62 deg parallactic angle               

    OBSMODE  : bytarr(8),$;63 a8 Name of pattern ONOFF CAL OFFON DRIFT ON OFF   
    OBS_NAME : bytarr(8),$;64 a8 Name of lowest obs ON OFF CALON CALOFF DRIFT   
    BACKENDMODE: bytarr(24),$;65 a24 back mode string
    CALTYPE  : bytarr(8),$;$66 a8 Cal type                                      
    FRONTEND : bytarr(8),$;67 Receiver name                                  
   PLAT_POWER:  0d ,$;68 Power from platform meter                      
  CNTRL_POWER:  0d ,$;69 Power from control room meter                  
   TOT_POWER :  0d ,$;70 Scaled Power in zero-lag                       
    TCAL     :  dblarr(64) ,$;71 data                                           

    SYN1     :  0d ,$;72 platform synthesizer                           
    SYNFRQ   : dblarr(4),$;73 control room synthesizers                      
	PATTERN_SCAN:  0L ,$;74 unique number for pattern YDDDnnnnn
    SCAN_NUMBER :  0L ,$;75 unique num for low-level observation YDDDnnnnn
    PATTERN_NUMBER:  0L ,$;76  sequential observation number of obs_scans
    TOTAL_PATTERN :  0L ,$;77 total number of PATTERN_numbers
    ENC_TIME :  0L ,$;78 Time when enc_AZ and enc_ZA measured           
    LAGS_IN  :  0L ,$;79 number of Lags - same as bytes of data/4       
    WAPPMASK :  0L ,$;80 which other wapps or alfas enabled
    NTCAL    :  0L ,$;81 number of valid tcal pairs
 
    PRFEED   :  0B  ,$;82 alfa feed on paraxial ray this scan
    NIFS     :  0B  ,$;83 number of ifs in this observation              
    IFVAL    :  0b  ,$;84 which polarization, 0-1 or 0-3 for stokes      
    ATTN_COR :  0b  ,$;85 Correlator attenuator 0-15                     
    UPPERSB  :  0b  ,$;86 True if spectrum flipped                      
    INPUT_ID :  0b  ,$;87 WAPP number 0-3 or 0-7 for ALFA                
    MASTER   :  0b  ,$;88 0 greg 1 carriage house                        

    ONSOURCE :  0b  ,$;89   if onsource at enc_time                       
    BLANKING :  0b  ,$;90   Blanking turned on                            
    LBWHYB   :  0b  ,$;91 LBandWide Hybrid is in (for circular pol)      
    SHCL     :  0b  ,$;92 true if receiver shutter closed                
    SBSHCL   :  0b  ,$;93 true if Sband receiver shutter closed          

    RFNUM    :  0b  ,$;94 platform position of the receiver selectror    
    CALRCVMUX:  0b  ,$;95 platform cal selector
    ZMNORMAL :  0b  ,$;96 platform transfer switch to reverse channels, t
    RFATTN   :  bytarr(2),$;97 platform attenuator position                   
    IFNUM    :  0b  ,$;98 platform if selector, 1/300 2/750, 3/1500, 4/10
    IFATTN   :  bytarr(2),$;99 platform IF attenuator positions               
    FIBER    :  0b  ,$;100 true if platform fiber is chosen (always the ca
    AC2SW    :  0b  ,$;101 platform ac power to various instruments and ot

    PHBSIG   :  0b  ,$;102 platform converter combiner signal phase adjust
    HYBRID   :  0b  ,$;103 platform converter combiner hybrid             
    PHBLO    :  0b  ,$;104 settings                                       

    XFNORMAL :  0b  ,$;105 control room transfer switch true = deflt      
    NOISE    :  0b  ,$;106 control room noise on                          
    GAIN     :  bytarr(2),$;107 gain of control room amps                      
    INPFRQ   :  0b  ,$;108 control room input distributor position        
    MIXER    :  bytarr(4),$;109 control room mixer source switches             
    VLBAINP  :  0b  ,$;110 control room vlba input switch position        
    AMPINP   :  bytarr(4),$;111 control room amplifier input source switches   
    EXTINP   :  bytarr(4),$;112 control room external input selector switches  
    SYNDEST  :  bytarr(4),$;113 control room synthesizer destinations          
    CALSRC   :  0b  ,$;114 control room cal source bit                    
    CAL      :  0b  ,$;115 is cal bit on 

    VIS30MHZ :  0b  ,$;116 control room greg 1 ch 0                       
    PWRMET   :  0b  ,$;117 control room power meter input switch          
    BLANK430 :  0b  } ;118 control room 430 blanking on                   
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
