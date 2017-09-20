;
; header files for spc wapp
;
;
; hdr that is specific to was...
; note: rp is reference pixel (counts from 1).
;
a={washdr , $
	rpfreq	    : 0.D	,$; reference pixel frequency in Mhz
	chanfreqStep: 0.D   ,$; freq step between channels. (mhz)
	rpRestFreq  : 0.D   ,$; rest frequency for reference pixel (Mhz).
	rpChan  	: 0L	,$; reference pixel channel number (count from 1)
	numChan     : 0L    }; number of channels this sbc

a={wasfhdr , $
    OBJECT  :	'' ,$;2 16a Name of source observed                        
    CTYPE1  :   '' ,$;3 16a Axis type and Doppler Correction               
    CRVAL1  :   0D ,$;4 Center Frequency hz
    CDELT1  :   0D ,$;5 Frequency Interval hz                            
    CRPIX1  :   0D ,$;6 Pixel of Center Frequency                      
    CRVAL2  :   0d ,$;7 requested source RA deg                           
    CRVAL3  :   0d ,$;8 requested source DEC deg                          
    EQUINOX :   '' ,$;9 requested source DEC deg                          
    CRVAL4  :   0d ,$;10 Polarization (neg -> Pol, Pos -> Stokes)       
    CRVAL5  :   0d ,$;11 hours since midnight from obsdate              
    OBSDATE :   '' ,$;12 a8 yyyymmdd start of this obs                     
    TSYS    :   0d ,$;13 last computed Tsys                             
    BANDWID :   0d ,$;14 Overall Bandwidth of spectrum                  
    RESTFREQ:   0d ,$;15 Rest freq at band center                       
    VELOCITY:   0d ,$;16 Requested Velocity                             
    JD      :   0d ,$;17 Julian Day Number at Exposure Start            
    LST     :   0d ,$;18 Local Mean Siderial Time                       
    EXPOSURE:   0d ,$;19 Exposure                                       
    ENC_AZIMUTH:0d ,$;20 Encoder Azimuth on sky (not feed)              
   ENC_ELEVATIO:0d ,$;21 Encoder Elevation                              
   ENC_ALTEL:   0d ,$;22 Encoder Elevation of other Carriage House      
    CROFF2  :   0d ,$;23 Ra offset applied at req_time                  
    CROFF3  :   0d ,$;24 Dec offset applied at req_time                 
    OFF_CS  :   '' ,$;25 Coordinate system of offs                      
    OFF_TIME:   0d ,$;26 seconds from midnight ast                      
    RATE_RA :   0d ,$;27 rate of change of ra                           
    RATE_DEC:   0d ,$;28 rate of change of dec                          
    RATE_CS :   '' ,$;29 Coordinate system of rates                     
    RATE_DUR:   0d ,$;30 How long has rate been applied                 
    RATE_TIME:  0d ,$;32 from midnight ast                              
    CUR_TOL  :  0d ,$;33 computed great circle tolerance                
    REQ_TOL  :  0d ,$;34 requested tolerance                            
    RAJ      :  0d ,$;35 (hr ) Ra J2000 back computed from az,za              
    DECJ     :  0d ,$;35 (deg)Dec J2000 back computed from az, za            
    OBS_MODE :  '' ,$;36 a8 Name of pattern ONOFF CAL OFFON DRIFT ON OFF   
    OBS_NAME :  '' ,$;37 a8 Name of lowest obs ON OFF CALON CALOFF DRIFT   
    BACKENDMODE : ''  ,$;38 a24 backend mode string
    CALTYPE  : ''  ,$;39 a8 Cal type                                       
    FRONTEND : ''  ,$;40 Receiver name                                  
   PLAT_POWER:  0d ,$;41 Power from platform meter                      
  CNTRL_POWER:  0d ,$;42 Power from control room meter                  
   TOT_POWER :  0d ,$;43 Scaled Power in zero-lag                       
    TCAL     :  dblarr(64) ,$;44 data                                           
    SYN1     :  0d ,$;45 platform synthesizer                           
    SYNFRQ   : dblarr(4),$;46 control room synthesizers                      
	PATTERN_SCAN:  0L ,$;47 unique number for pattern YDDDnnnnn
    SCAN_NUMBER :  0L ,$;48 unique num for low-level observation YDDDnnnnn
    PATTERN_NUMBER:  0L ,$;49  sequential observation number of obs_scans
    TOTAL_PATTERN :  0L ,$;50 total number of PATTERN_numbers
    ENC_TIME :  0L ,$;51 Time when enc_AZ and enc_ZA measured           
    LAGS_IN  :  0L ,$;52 number of Lags - same as bytes of data/4       
    WAPPMASK :  0L ,$;53 which other wapps or alfas enabled
    NTCAL    :  0L ,$;54 number of valid tcal pairs
    NIFS     :  0B  ,$;55 number of ifs in this observation              
    IFVAL    :  0b  ,$;56 which polarization, 0-1 or 0-3 for stokes      
    ATTN_COR :  0b  ,$;57 Correlator attenuator 0-15                     
    UPPERSB  :  0b  ,$;58 True if spectrum flipped                      
    WAPPNO   :  0b  ,$;59 WAPP number 0-3 or 0-7 for ALFA                
    MASTER   :  0b  ,$;60 0 greg 1 carriage house                        
    ONSOURCE :  0b  ,$;61   if onsource at enc_time                       
    BLANKING :  0b  ,$;62   Blanking turned on                            
    LBWHYB   :  0b  ,$;63 LBandWide Hybrid is in (for circular pol)      
    SHCL     :  0b  ,$;64 true if receiver shutter closed                
    SBSHCL   :  0b  ,$;65 true if Sband receiver shutter closed          
    RFNUM    :  0b  ,$;66 platform position of the receiver selectror    
    CALRCVMUX:  0b  ,$;67 platform cal selector
    ZMNORMAL :  0b  ,$;68 platform transfer switch to reverse channels, t
    RFATTN   :  bytarr(2),$;69 platform attenuator position                   
    IFNUM    :  0b  ,$;70 platform if selector, 1/300 2/750, 3/1500, 4/10
    IFATTN   :  bytarr(2),$;71 platform IF attenuator positions               
    FIBER    :  0b  ,$;72 true if platform fiber is chosen (always the ca
    AC2SW    :  0b  ,$;73 platform ac power to various instruments and ot
    PHBSIG   :  0b  ,$;74 platform converter combiner signal phase adjust
    HYBRID   :  0b  ,$;75 platform converter combiner hybrid             
    PHBLO    :  0b  ,$;76 settings                                       
    XFNORMAL :  0b  ,$;77 control room transfer switch true = deflt      
    NOISE    :  0b  ,$;78 control room noise on                          
    GAIN     :  bytarr(2),$;79 gain of control room amps                      
    INPFRQ   :  0b  ,$;80 control room input distributor position        
    MIXER    :  bytarr(4),$;81 control room mixer source switches             
    VLBAINP  :  0b  ,$;82 control room vlba input switch position        
    AMPINP   :  bytarr(4),$;83 control room amplifier input source switches   
    EXTINP   :  bytarr(4),$;84 control room external input selector switches  
    SYNDEST  :  bytarr(4),$;85 control room synthesizer destinations          
    CALSRC   :  0b  ,$;86 control room cal source bit                    
    CAL      :  0b  ,$;87 is cal bit on 
    VIS30MHZ :  0b  ,$;88 control room greg 1 ch 0                       
    PWRMET   :  0b  ,$;89 control room power meter input switch          
    BLANK430 :  0b  } ;90 control room 430 blanking on                   

a={wasfhdrB , $
    OBJECT  :	bytarr(16),$;2 16a Name of source observed                      
    CTYPE1  :   bytarr(8),$;3 16a Axis type and Doppler Correction             
    CRVAL1  :   0D ,$;4 Center Frequency hz
    CDELT1  :   0D ,$;5 Frequency Interval hz                            
    CRPIX1  :   0D ,$;6 Pixel of Center Frequency                      
    CRVAL2  :   0d ,$;7 requested source RA deg                           
    CRVAL3  :   0d ,$;8 requested source DEC deg                          
	EQUINOX : bytarr(8),$;9 equinox for ra,dec pos 
    CRVAL4  :   0d ,$;10Polarization (neg -> Pol, Pos -> Stokes)       
    CRVAL5  :   0d ,$;11 hours since midnight from obsdate              
    OBSDATE : bytarr(8),$;12 a8 yyyymmdd start of this obs                     
    TSYS    :   0d ,$;13 last computed Tsys                             
    BANDWID :   0d ,$;14 Overall Bandwidth of spectrum                  
    RESTFREQ:   0d ,$;15 Rest freq at band center                       
    VELOCITY:   0d ,$;16 Requested Velocity                             
    JD      :   0d ,$;17 Julian Day Number at Exposure Start            
    LST     :   0d ,$;18 Local Mean Siderial Time                       
    EXPOSURE:   0d ,$;19 Exposure                                       
    ENC_AZIMUTH:0d ,$;20 Encoder Azimuth on sky (not feed)              
   ENC_ELEVATIO:0d ,$;22 Encoder Elevation                              
   ENC_ALTEL:   0d ,$;22 Encoder Elevation of other Carriage House      
    CROFF2  :   0d ,$;23 Ra offset applied at req_time                  
    CROFF3  :   0d ,$;24 Dec offset applied at req_time                 
    OFF_CS  :   bytarr(8) ,$;25 Coordinate system of offs                      
    OFF_TIME:   0d ,$;26 seconds from midnight ast                      
    RATE_RA :   0d ,$;27 rate of change of ra                           
    RATE_DEC:   0d ,$;28 rate of change of dec                          
    RATE_CS :   bytarr(8),$;29 Coordinate system of rates                     
    RATE_DUR:   0d ,$;30 How long has rate been applied                 
    RATE_TIME:  0d ,$;32 from midnight ast                              
    CUR_TOL  :  0d ,$;32 computed great circle tolerance                
    REQ_TOL  :  0d ,$;33 requested tolerance                            
    RAJ      :  0d ,$;34 (deg) Ra J2000 back computed from az,za              
    DECJ     :  0d ,$;35 Dec J2000 back computed from az, za            
    OBSMODE  : bytarr(8),$;36 a8 Name of pattern ONOFF CAL OFFON DRIFT ON OFF   
    OBS_NAME : bytarr(8),$;37 a8 Name of lowest obs ON OFF CALON CALOFF DRIFT   
    BACKENDMODE: bytarr(24),$;38 a24 back mode string
    CALTYPE  : bytarr(8),$;39 a8 Cal type                                       
    FRONTEND : bytarr(8),$;40 Receiver name                                  
   PLAT_POWER:  0d ,$;41 Power from platform meter                      
  CNTRL_POWER:  0d ,$;42 Power from control room meter                  
   TOT_POWER :  0d ,$;43 Scaled Power in zero-lag                       
    TCAL     :  dblarr(64) ,$;44 data                                           
    SYN1     :  0d ,$;45 platform synthesizer                           
    SYNFRQ   : dblarr(4),$;46 control room synthesizers                      
	PATTERN_SCAN:  0L ,$;47 unique number for pattern YDDDnnnnn
    SCAN_NUMBER :  0L ,$;48 unique num for low-level observation YDDDnnnnn
    PATTERN_NUMBER:  0L ,$;49  sequential observation number of obs_scans
    TOTAL_PATTERN :  0L ,$;50 total number of PATTERN_numbers
    ENC_TIME :  0L ,$;51 Time when enc_AZ and enc_ZA measured           
    LAGS_IN  :  0L ,$;52 number of Lags - same as bytes of data/4       
    WAPPMASK :  0L ,$;53 which other wapps or alfas enabled
    NTCAL    :  0L ,$;54 number of valid tcal pairs
    NIFS     :  0B  ,$;55 number of ifs in this observation              
    IFVAL    :  0b  ,$;56 which polarization, 0-1 or 0-3 for stokes      
    ATTN_COR :  0b  ,$;57 Correlator attenuator 0-15                     
    UPPERSB  :  0b  ,$;58 True if spectrum flipped                      
    WAPPNO   :  0b  ,$;59 WAPP number 0-3 or 0-7 for ALFA                
    MASTER   :  0b  ,$;60 0 greg 1 carriage house                        
    ONSOURCE :  0b  ,$;61   if onsource at enc_time                       
    BLANKING :  0b  ,$;62   Blanking turned on                            
    LBWHYB   :  0b  ,$;63 LBandWide Hybrid is in (for circular pol)      
    SHCL     :  0b  ,$;64 true if receiver shutter closed                
    SBSHCL   :  0b  ,$;65 true if Sband receiver shutter closed          
    RFNUM    :  0b  ,$;66 platform position of the receiver selectror    
    CALRCVMUX:  0b  ,$;67 platform cal selector
    ZMNORMAL :  0b  ,$;68 platform transfer switch to reverse channels, t
    RFATTN   :  bytarr(2),$;69 platform attenuator position                   
    IFNUM    :  0b  ,$;70 platform if selector, 1/300 2/750, 3/1500, 4/10
    IFATTN   :  bytarr(2),$;71 platform IF attenuator positions               
    FIBER    :  0b  ,$;72 true if platform fiber is chosen (always the ca
    AC2SW    :  0b  ,$;73 platform ac power to various instruments and ot
    PHBSIG   :  0b  ,$;74 platform converter combiner signal phase adjust
    HYBRID   :  0b  ,$;75 platform converter combiner hybrid             
    PHBLO    :  0b  ,$;76 settings                                       
    XFNORMAL :  0b  ,$;77 control room transfer switch true = deflt      
    NOISE    :  0b  ,$;78 control room noise on                          
    GAIN     :  bytarr(2),$;79 gain of control room amps                      
    INPFRQ   :  0b  ,$;80 control room input distributor position        
    MIXER    :  bytarr(4),$;81 control room mixer source switches             
    VLBAINP  :  0b  ,$;82 control room vlba input switch position        
    AMPINP   :  bytarr(4),$;83 control room amplifier input source switches   
    EXTINP   :  bytarr(4),$;84 control room external input selector switches  
    SYNDEST  :  bytarr(4),$;85 control room synthesizer destinations          
    CALSRC   :  0b  ,$;86 control room cal source bit                    
    CAL      :  0b  ,$;87 is cal bit on 
    VIS30MHZ :  0b  ,$;88 control room greg 1 ch 0                       
    PWRMET   :  0b  ,$;89 control room power meter input switch          
    BLANK430 :  0b  } ;90 control room 430 blanking on                   
