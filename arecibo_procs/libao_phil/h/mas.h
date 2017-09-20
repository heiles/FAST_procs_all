;
; header files for mas mock arecibo spectrometer
;
; notes: true below --> data mas interpolated to the data sample
;                      (i think the start of the data sample)
;
; hdr that is specific to mas...
; created via:
; fits_mkhdr.pl < /share/megs/phil/svn/pdev/include/fits_header.h > junk.out
; edit junk.out:
;  1.  remove last line with fill
;  2.  in line before last } remove , 
; cp junk.out to here 2 times
;  first occurence:
;    masfhdrb -> masfhdr
;    bytearr >=8 ==> ' '
; history:
;29may08 updated..
;
a={masfhdr ,$
          tdim1:          '',$;(   0)Dimensions of data pointed to in the heap 
          tdim2:          '',$;(  32)Dimensions of status pointed to in the heap 
         object:          '',$;(  64)Name of source observed 
         crval1:          0D,$;(  80)Center frequency 
         cdelt1:          0D,$;(  88)Frequency interval 
         crpix1:          0D,$;(  96)Pixel of center frequency 
         crval2:          0D,$;( 104)Actual RA J2000 pointing this beam on sky 
         crval3:          0D,$;( 112)Actual DEC J2000 pointing this beam on sky 
         crval4:          0D,$;( 120)Polarization (neg -> Pol, pos -> Stokes) 
         crval5:          0D,$;( 128)Seconds since midnight from obsdate (UTC) 
         cdelt5:          0D,$;( 136)time difference (wall) between spectra in a row 
        azimuth:          0D,$;( 144)Actual AZ pointing this beam on sky   
       elevatio:          0D,$;( 152)Actual EL pointing this beam on sky   
           glon:          0D,$;( 160)Actual galactic l pointing this beam on sky 
           glat:          0D,$;( 168)Actual galactic b pointing this beam on sky 
      datexxobs:          '',$;( 176)Start of this observation (UTC) - YYYY-MM-DD 
       mjdxxobs:          0D,$;( 192)MJD number at exposure start of 1st spc of row 
            lst:          0D,$;( 200)Local mean sidereal time 1st spc of row
       exposure:          0D,$;( 208)Exposure (integration) time of current record (dump) 
       duration:          0D,$;( 216)Duration of the dump (Wall time)
           tsys:          0D,$;( 224)Last computed Tsys - set to 1.0 if unavailable 
        bandwid:          0D,$;( 232)Overall bandwidth of spectrum 
        restfrq:          0D,$;( 240)Rest frequency used for doppler correction 
        specsys:          '',$;( 248)Velocity frame for CRVAL1 (always TOPOCENT for AO data) 
        req_sys:          '',$;( 256)User-requested velocity frame 
        req_vel:          0D,$;( 264)Requested velocity or z in frame REQ_SYS 
   req_vel_unit:          '',$;( 272)Specifies units of REQ_VEL: either m/s or Z 
   req_vel_type:          '',$;( 280)Velocity type for REQ_VEL 
        req_raj:          0D,$;( 288)Requested RA J2000 position 
       req_decj:          0D,$;( 296)Requested Dec J2000 position 
      req_posc1:          0D,$;( 304)Requested long (usually RA) in REQ_COORDSYS 
      req_posc2:          0D,$;( 312)Requested lat (usually DEC) in REQ_COORDSYS 
      req_cspos:          '',$;( 320)Coordinate system used for REQ_POSC1 and REQ_POSC2 
      req_offc1:          0D,$;( 328)requested offset from posc1
      req_offc2:          0D,$;( 336)requested offset from posc2 
      req_csoff:          '',$;( 344)Coordinate system used for req_offc1,2 
    req_pnttime:          0D,$;( 352)timestamp pntData non interpData. pos,off,rate..
     req_ratec1:          0D,$;( 360)requested rate for c1 
     req_ratec2:          0D,$;( 368)requested rate for c2 
     req_csrate:          '',$;( 376)Coordinate system used for req_ratec1,2 
    req_equinox:          0D,$;( 384)Equinox of  REQ_POSC1 and REQ_POSC2 
       rate_dur:          0D,$;( 392)How long has req_ratec1,2  been applied        
       enc_time:          0D,$;( 400)Time when encoders were read out (UTC) 
    enc_azimuth:          0D,$;( 408)Azimuth encoder read-out at ENC_TIME 
   enc_elevatio:          0D,$;( 416)Elevation encoder read-out at ENC_TIME 
      enc_altel:          0D,$;( 424)Elevation encoder of other carriage house 
        cur_err:          0D,$;( 432)Actual great circle tracking error 
    allowed_err:          0D,$;( 440)Maximum allowed tracking error   
         az_err:          0D,$;( 448)Azimuth tracking error (actualPos-requested) 
         el_err:          0D,$;( 456)Elevation tracking error (actualPos-requested) 
    model_offaz:          0D,$;( 464)Pointing model offset AZ at curpos  
    model_offza:          0D,$;( 472)Pointing model offset ZA at curpos  
     user_offaz:          0D,$;( 480)User selected pointing offset AZ (great circle) 
     user_offza:          0D,$;( 488)User selected pointing offset ZA    
     beam_offaz:          0D,$;( 496)ALFA unrotated offset AZ            
     beam_offza:          0D,$;( 504)ALFA unrotated offset ZA            
    rfeed_offaz:          0D,$;( 512)Rotated offset this beam AZ         
    rfeed_offza:          0D,$;( 520)Rotated offset this beam ZA         
   prfeed_offaz:          0D,$;( 528)Offset to center prfeed beam AZ     
   prfeed_offza:          0D,$;( 536)Offset to center prfeed beam ZA     
    beam_offraj:          0D,$;( 544)Total RA offset to this beam        
   beam_offdecj:          0D,$;( 552)Total DEC offset to this beam       
      map_offra:          0D,$;( 560)Actual RA J2000 offset req_raj/decj 
     map_offdec:          0D,$;( 568)Actual DEC J2000 offset to req_raj/decj
      map_offaz:          0D,$;( 576)Actual AZ offset to req_raj/decj (great circle?)
      map_offza:          0D,$;( 584)Actual ZA offset to req_raj/decj 
       alfa_ang:          0D,$;( 592)ALFA rotation angle 
       para_ang:          0D,$;( 600)Parallactic angle 
       vel_bary:          0D,$;( 608)Projected barycentric velocity (incl. VEL_GEO) 
        vel_geo:          0D,$;( 616)Projected geocentric velocity 
        vel_obs:          0D,$;( 624)Observers projected velocity in req_sys
       frontend:          '',$;( 632)Receiver name 
        backend:          '',$;( 640)Backend name 
    backendmode:          '',$;( 648)Backend mode description 
        caltype:          '',$;( 672)diode calibration mode 
        obsmode:          '',$;( 680)Name of observation pattern (e.g. ONOFF) 
       scantype:          '',$;( 688)Type of scan (as part of pattern - e.g. ON OFF) 
     pattern_id:          0L,$;( 696)Unique number for observation pattern YDDDnnnnn 
        scan_id:          0L,$;( 700)Unique number for scan YDDDnnnnn 
         recnum:          0L,$;( 704)Sequential number of current record (dump) 
     total_recs:          0L,$;( 708)Requested total number of records (dumps) in scan 
        chan_in:          0L,$;( 712)Number of freq channels input this spc
       bad_data:          0L,$;( 716)0->good data <>0->problem (see COMMENT) 
    plat_powerA:          0D,$;( 720)platform power meter reading polA 
    plat_powerB:          0D,$;( 728)platform power meter reading polb 
   cntrl_powerA:          0D,$;( 736)control room power meter polA 
   cntrl_powerB:          0D,$;( 744)control room power meter polB 
           syn1:          0D,$;( 752)Platform synthesizer 
           syn2:          0D,$;( 760)2nd lo synth value this band 
      tot_power:          0D,$;( 768)Scaled power in zero-lag. -1 for fft bkends 
   tcal_numCoef:          0L,$;( 776)Number of coef. in polyFit for tcal 
          fill1:          0L,$;( 780)for 8byte alignment 
     tcal_coefA:   dblarr(4),$;( 784)Polyfit tcal polA. order(deg) 0,1,2,3 
     tcal_coefB:   dblarr(4),$;( 816)polyfit tcal polB 
    backendmask:   bytarr(8),$;( 848)Which backend boards enabled 
      num_beams:          0B,$;( 856)Number of beams in this observation (1, 7 or 8) 
        num_ifs:          0B,$;( 857)Number of IFs for this beam (1 - 8 or 1 - 2) 
       num_pols:          0B,$;( 858)Number of pols for this IF and this beam (1, 2 or 4) 
           beam:          0B,$;( 859)Number of this beam (1, 0 - 6 or 0 - 7) 
            ifn:          0B,$;( 860)Number of this IF (1 - 8 or 1 - 2) 
            pol:          0B,$;( 861)Number of this pol (1, 2 or 4) 
         prfeed:          0B,$;( 862)ALFA beam used as pointing center 
       input_id:          0B,$;( 863)spectrometer board number (engineering parameter) 
        uppersb:          0B,$;( 864)True if spectrum flipped 
       attn_cor:          0B,$;( 865)Correlator attenuator: 0-15 dB 
         master:          0B,$;( 866)0=Gregorian dome 1=Carriage house 
       onsource:          0B,$;( 867)True if on-source at ENC_TIME 
       blanking:          0B,$;( 868)Blanking turned on 
         lbwhyb:          0B,$;( 869)LBandWide Hybrid is in (for circular pol) 
           shcl:          0B,$;( 870)True if receiver shutter closed 
         sbshcl:          0B,$;( 871)True if S-band receiver shutter closed 
          rfnum:          0B,$;( 872)Platform position of the receiver selector 
      calrcvmux:          0B,$;( 873)Platform cal selector 
       zmnormal:          0B,$;( 874)Platform transfer switch to reverse channels, true normal 
         rfattn:   bytarr(2),$;( 875)Platform attenuator positions 
         if1sel:          0B,$;( 877)Platform IF selector, 1/300 2/750, 3/1500, 4/10GHz1500, 5-thru 
         ifattn:   bytarr(2),$;( 878)Platform IF attenuator positions 
          fiber:          0B,$;( 880)True if platform fiber chosen (usually true) 
          ac2sw:          0B,$;( 881)Platform AC power to various instruments etc. 
         phbsig:          0B,$;( 882)Platform converter combiner signal ph adjust 
         hybrid:          0B,$;( 883)Platform converter combiner hybrid 
          phblo:          0B,$;( 884)Platform converter combiner LO phase adjust 
       xfnormal:          0B,$;( 885)Control room transfer switch true = default 
        ampgain:   bytarr(2),$;( 886)Gain of control room amplifiers 
          noise:          0B,$;( 888)Control room noise on 
         inpfrq:          0B,$;( 889)Control room input distributor position 
          mixer:          0B,$;( 890)Control room mixer source switches 
        vlbainp:          0B,$;( 891)Control room VLBA input switch position 
        syndest:          0B,$;( 892)Control room synthesizer destination for this board
         calsrc:          0B,$;( 893)Control room cal source bit 
            cal:          0B,$;( 894)Is cal bit turned on 
       vis30mhz:          0B,$;( 895)Control room greg 1 ch 0 
       blank430:          0B $;( 896)Control room 430 blanking on 
}
;

a={masfhdrb ,$
          tdim1:  bytarr(32),$;(   0)Dimensions of data pointed to in the heap 
          tdim2:  bytarr(32),$;(  32)Dimensions of status pointed to in the heap 
         object:  bytarr(16),$;(  64)Name of source observed 
         crval1:          0D,$;(  80)Center frequency 
         cdelt1:          0D,$;(  88)Frequency interval 
         crpix1:          0D,$;(  96)Pixel of center frequency 
         crval2:          0D,$;( 104)Actual RA J2000 pointing this beam on sky 
         crval3:          0D,$;( 112)Actual DEC J2000 pointing this beam on sky 
         crval4:          0D,$;( 120)Polarization (neg -> Pol, pos -> Stokes) 
         crval5:          0D,$;( 128)Seconds since midnight from obsdate (UTC) 
         cdelt5:          0D,$;( 136)time difference (wall) between spectra in a row 
        azimuth:          0D,$;( 144)Actual AZ pointing this beam on sky   
       elevatio:          0D,$;( 152)Actual EL pointing this beam on sky   
           glon:          0D,$;( 160)Actual galactic l pointing this beam on sky 
           glat:          0D,$;( 168)Actual galactic b pointing this beam on sky 
      datexxobs:  bytarr(16),$;( 176)Start of this observation (UTC) - YYYY-MM-DD 
       mjdxxobs:          0D,$;( 192)MJD number at exposure start of 1st spc of row 
            lst:          0D,$;( 200)Local mean sidereal time 1st spc of row
       exposure:          0D,$;( 208)Exposure (integration) time of current record (dump) 
       duration:          0D,$;( 216)Duration of the dump (Wall time)
           tsys:          0D,$;( 224)Last computed Tsys - set to 1.0 if unavailable 
        bandwid:          0D,$;( 232)Overall bandwidth of spectrum 
        restfrq:          0D,$;( 240)Rest frequency used for doppler correction 
        specsys:   bytarr(8),$;( 248)Velocity frame for CRVAL1 (always TOPOCENT for AO data) 
        req_sys:   bytarr(8),$;( 256)User-requested velocity frame 
        req_vel:          0D,$;( 264)Requested velocity or z in frame REQ_SYS 
   req_vel_unit:   bytarr(8),$;( 272)Specifies units of REQ_VEL: either m/s or Z 
   req_vel_type:   bytarr(8),$;( 280)Velocity type for REQ_VEL 
        req_raj:          0D,$;( 288)Requested RA J2000 position 
       req_decj:          0D,$;( 296)Requested Dec J2000 position 
      req_posc1:          0D,$;( 304)Requested long (usually RA) in REQ_COORDSYS 
      req_posc2:          0D,$;( 312)Requested lat (usually DEC) in REQ_COORDSYS 
      req_cspos:   bytarr(8),$;( 320)Coordinate system used for REQ_POSC1 and REQ_POSC2 
      req_offc1:          0D,$;( 328)requested offset from posc1
      req_offc2:          0D,$;( 336)requested offset from posc2 
      req_csoff:   bytarr(8),$;( 344)Coordinate system used for req_offc1,2 
    req_pnttime:          0D,$;( 352)tmStamp pntData for unInterpData..poscx,offcx,ratecx
     req_ratec1:          0D,$;( 360)requested rate for c1 
     req_ratec2:          0D,$;( 368)requested rate for c2 
     req_csrate:   bytarr(8),$;( 376)Coordinate system used for req_ratec1,2 
    req_equinox:          0D,$;( 384)Equinox of  REQ_POSC1 and REQ_POSC2 
       rate_dur:          0D,$;( 392)How long has req_ratec1,2  been applied        
       enc_time:          0D,$;( 400)Time when encoders were read out (UTC) 
    enc_azimuth:          0D,$;( 408)Azimuth encoder read-out at ENC_TIME 
   enc_elevatio:          0D,$;( 416)Elevation encoder read-out at ENC_TIME 
      enc_altel:          0D,$;( 424)Elevation encoder of other carriage house 
        cur_err:          0D,$;( 432)Actual great circle tracking error 
    allowed_err:          0D,$;( 440)Maximum allowed tracking error   
         az_err:          0D,$;( 448)Azimuth tracking error (actualPos-requested) 
         el_err:          0D,$;( 456)Elevation tracking error (actualPos-requested) 
    model_offaz:          0D,$;( 464)Pointing model offset AZ at curpos  
    model_offza:          0D,$;( 472)Pointing model offset ZA at curpos  
     user_offaz:          0D,$;( 480)User selected pointing offset AZ (great circle) 
     user_offza:          0D,$;( 488)User selected pointing offset ZA    
     beam_offaz:          0D,$;( 496)ALFA unrotated offset AZ            
     beam_offza:          0D,$;( 504)ALFA unrotated offset ZA            
    rfeed_offaz:          0D,$;( 512)Rotated offset this beam AZ         
    rfeed_offza:          0D,$;( 520)Rotated offset this beam ZA         
   prfeed_offaz:          0D,$;( 528)Offset to center prfeed beam AZ     
   prfeed_offza:          0D,$;( 536)Offset to center prfeed beam ZA     
    beam_offraj:          0D,$;( 544)Total RA offset to this beam        
   beam_offdecj:          0D,$;( 552)Total DEC offset to this beam       
      map_offra:          0D,$;( 560)Actual RA J2000 offset req_raj/decj 
     map_offdec:          0D,$;( 568)Actual DEC J2000 offset to req_raj/decj
      map_offaz:          0D,$;( 576)Actual AZ offset to req_raj/decj (great circle?)
      map_offza:          0D,$;( 584)Actual ZA offset to req_raj/decj 
       alfa_ang:          0D,$;( 592)ALFA rotation angle 
       para_ang:          0D,$;( 600)Parallactic angle 
       vel_bary:          0D,$;( 608)Projected barycentric velocity (incl. VEL_GEO) 
        vel_geo:          0D,$;( 616)Projected geocentric velocity 
        vel_obs:          0D,$;( 624)Observers projected velocity in req_sys
       frontend:   bytarr(8),$;( 632)Receiver name 
        backend:   bytarr(8),$;( 640)Backend name 
    backendmode:  bytarr(24),$;( 648)Backend mode description 
        caltype:   bytarr(8),$;( 672)diode calibration mode 
        obsmode:   bytarr(8),$;( 680)Name of observation pattern (e.g. ONOFF) 
       scantype:   bytarr(8),$;( 688)Type of scan (as part of pattern - e.g. ON OFF) 
     pattern_id:          0L,$;( 696)Unique number for observation pattern YDDDnnnnn 
        scan_id:          0L,$;( 700)Unique number for scan YDDDnnnnn 
         recnum:          0L,$;( 704)Sequential number of current record (dump) 
     total_recs:          0L,$;( 708)Requested total number of records (dumps) in scan 
        chan_in:          0L,$;( 712)Number of freq channels input this spc
       bad_data:          0L,$;( 716)0->good data <>0->problem (see COMMENT) 
    plat_powerA:          0D,$;( 720)platform power meter reading polA 
    plat_powerB:          0D,$;( 728)platform power meter reading polb 
   cntrl_powerA:          0D,$;( 736)control room power meter polA 
   cntrl_powerB:          0D,$;( 744)control room power meter polB 
           syn1:          0D,$;( 752)Platform synthesizer 
           syn2:          0D,$;( 760)2nd lo synth value this band 
      tot_power:          0D,$;( 768)Scaled power in zero-lag. -1 for fft bkends 
   tcal_numCoef:          0L,$;( 776)Number of coef. in polyFit for tcal 
          fill1:          0L,$;( 780)for 8byte alignment 
     tcal_coefA:   dblarr(4),$;( 784)Polyfit tcal polA. order(deg) 0,1,2,3 
     tcal_coefB:   dblarr(4),$;( 816)polyfit tcal polB 
    backendmask:   bytarr(8),$;( 848)Which backend boards enabled 
      num_beams:          0B,$;( 856)Number of beams in this observation (1, 7 or 8) 
        num_ifs:          0B,$;( 857)Number of IFs for this beam (1 - 8 or 1 - 2) 
       num_pols:          0B,$;( 858)Number of pols for this IF and this beam (1, 2 or 4) 
           beam:          0B,$;( 859)Number of this beam (1, 0 - 6 or 0 - 7) 
            ifn:          0B,$;( 860)Number of this IF (1 - 8 or 1 - 2) 
            pol:          0B,$;( 861)Number of this pol (1, 2 or 4) 
         prfeed:          0B,$;( 862)ALFA beam used as pointing center 
       input_id:          0B,$;( 863)spectrometer board number (engineering parameter) 
        uppersb:          0B,$;( 864)True if spectrum flipped 
       attn_cor:          0B,$;( 865)Correlator attenuator: 0-15 dB 
         master:          0B,$;( 866)0=Gregorian dome 1=Carriage house 
       onsource:          0B,$;( 867)True if on-source at ENC_TIME 
       blanking:          0B,$;( 868)Blanking turned on 
         lbwhyb:          0B,$;( 869)LBandWide Hybrid is in (for circular pol) 
           shcl:          0B,$;( 870)True if receiver shutter closed 
         sbshcl:          0B,$;( 871)True if S-band receiver shutter closed 
          rfnum:          0B,$;( 872)Platform position of the receiver selector 
      calrcvmux:          0B,$;( 873)Platform cal selector 
       zmnormal:          0B,$;( 874)Platform transfer switch to reverse channels, true normal 
         rfattn:   bytarr(2),$;( 875)Platform attenuator positions 
         if1sel:          0B,$;( 877)Platform IF selector, 1/300 2/750, 3/1500, 4/10GHz1500, 5-thru 
         ifattn:   bytarr(2),$;( 878)Platform IF attenuator positions 
          fiber:          0B,$;( 880)True if platform fiber chosen (usually true) 
          ac2sw:          0B,$;( 881)Platform AC power to various instruments etc. 
         phbsig:          0B,$;( 882)Platform converter combiner signal ph adjust 
         hybrid:          0B,$;( 883)Platform converter combiner hybrid 
          phblo:          0B,$;( 884)Platform converter combiner LO phase adjust 
       xfnormal:          0B,$;( 885)Control room transfer switch true = default 
        ampgain:   bytarr(2),$;( 886)Gain of control room amplifiers 
          noise:          0B,$;( 888)Control room noise on 
         inpfrq:          0B,$;( 889)Control room input distributor position 
          mixer:          0B,$;( 890)Control room mixer source switches 
        vlbainp:          0B,$;( 891)Control room VLBA input switch position 
        syndest:          0B,$;( 892)Control room synthesizer destination for this board
         calsrc:          0B,$;( 893)Control room cal source bit 
            cal:          0B,$;( 894)Is cal bit turned on 
       vis30mhz:          0B,$;( 895)Control room greg 1 ch 0 
       blank430:          0B $;( 896)Control room 430 blanking on 
}
;
;	structure to hold filename after parsing.
;
    a={ masfnmpars , $
        dir  : '' , $;
        fname: '',$;
        proj : '',$;
        date : 0L,$;
	    src  : '',$; only valid for psrfits
        bm   : 0 ,$; 0-6
        band : 0 ,$; 0,1 
        grp  : 0 ,$; 0,1
        num  : 0L }

