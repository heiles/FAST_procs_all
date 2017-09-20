;
;   correlator portion of header version 1
;11dec00 - updated mueller struct to new version
;        - polarized source,error now fractional polarization
;        - added fractional linear pol,error, src position angle and error.
a={hdrcorv1,          id:  bytarr(4,/nozero), $
                   ver:  bytarr(4,/nozero), $
       masterClkPeriod:         0L,$
               dumpLen:         0L,$
         dumpsPerInteg:         0L,$
              lagSbcIn:         0L,$
             lagSbcOut:         0L,$
              numSbcIn:         0L,$;num sbc/board before processing
             numSbcOut:         0L,$;num sbc/board after processing
                 bwNum:         0L,$;1=maxband (1/masterClkPeriod), 9=min band
             lagConfig:         0L,$;for correlator
                levels:         0L,$; 3,9
                stokes:         0L,$; true/false
         doubleNyquist:         0L,$; true/false*/
          chipTestMode:         0L,$; true/false*/
       blankingEnabled:         0L,$;
               startOn:         0L,$;0-imd,1-1sectick,10-10sectick,99-exttick
            dataFormat:         0L,$;1 raw acfs, 2 combined acfs, 3 spectra
            totCntsInc:         0L,$; true/false included with data*/
             pwrCntInc:         0L,$; true/false included with data */
               boardId:         0L,$; board number 6,7,8,9*/
           numBrdsUsed:         0L,$;hc22 h54 number boards used*/
                attnDb:  lonarr(2,/nozero),$; correl attenuator values 0..15*/
                pwrCnt:  fltarr(2,/nozero),$; pwrcnt, i,q avg for intergration
          lag0PwrRatio:  fltarr(2,/nozero),$;meas/optimum pwr for level setting
                  free:  lonarr(2,/nozero)};current length 30*4=120 bytes

;
;   correlator portion of header version 2
;
a={hdrcorv2,        id:  bytarr(4,/nozero), $
                   ver:  bytarr(4,/nozero), $
       masterClkPeriod:         0L,$
               dumpLen:         0L,$
         dumpsPerInteg:         0L,$
              lagSbcIn:         0L,$
             lagSbcOut:         0L,$
              numSbcIn:         0L,$;num sbc/board before processing
             numSbcOut:         0L,$;num sbc/board after processing
                 bwNum:         0L,$;1=maxband (1/masterClkPeriod), 9=min band
             lagConfig:         0L,$;for correlator
                 state:         0L,$;bitmask
                frqBuf:         0L,$;freq buf num 1...4
              cycleLen:         0L,$;cyclelen for cal and freq
                calCyc:   bytarr(8,/nozero),$;y,n..
                frqCyc:   bytarr(8,/nozero),$;1,2,3,4 as ascii
               boardId:         0L,$; board number 6,7,8,9*/
           numBrdsUsed:         0L,$;hc22 h54 number boards used*/
                attnDb:  lonarr(2,/nozero),$; correl attenuator values 0..15*/
                pwrCnt:  fltarr(2,/nozero),$; pwrcnt, i,q avg for intergration
          lag0PwrRatio:  fltarr(2,/nozero),$;meas/optimum pwr for level setting
                calOff:  fltarr(2,/nozero),$;cal off pwr sbc 1,2
                 calOn:  fltarr(2,/nozero),$;cal on pwr  sbc 1,2
				state2:         0L,$;
				  fill:         0L,$;
			   baudLen:         0L,$;
			   codeLen:         0L,$;
		     codeDelay:         0L,$;
		        cohAdd:         0L,$;
                 fill2:  lonarr(4,/nozero)};filler
;
; here's the full header version 2
;
@hdrStd.h
@hdrPnt.h
@hdrIfLo.h
@hdrDop.h
@hdrProc.h
a={hdr, std:{hdrstd}  ,$
        cor:{hdrcorv2},$
        pnt:{hdrpnt}  ,$
       iflo:{hdriflo} ,$
        dop:{hdrdop} ,$
       proc:{hdrproc} }

;
; to extract power monitoring
;
; 13sep01 .. added time
a={corpwr, scan:    0L,$; scan number
           rec :    0L,$; group number
		   time:    0L,$; seconds from midnite (end of rec)
           nbrds:   0L,$; number of boards
           az   :   0.,$; azimuth degrees end rec
           za   :   0.,$; za      degrees end rec
		   azErr:   0.,$; azErr little circle asecs end rec
		   zaErr:   0.,$; zaErr greate circle asecs end rec
           pwr  : fltarr(2,4) }
;
a={corcal,    h :	     {hdr}, $; header cal on this board	  
         calval :	  fltarr(2),$; intepolated cal value
         calscl :	  fltarr(2)} ; value to scale correlatr to kelvins
;
; record system temperatures on/off...
;
a={cortmp,    k :            0,$; units.1-->kelvins, 0--> tsysOff
		      p :  intarr(2,4),$; 1 - pola, 2-polb, 0, no data
            src :  fltarr(2,4),$;  on/off-1
             on :  fltarr(2,4),$;  on/off-1
            off :  fltarr(2,4),$;  on/off-1
		  calval:  fltarr(2,4),$; cal value in kelvins if k=1
		  calscl:  fltarr(2,4)} ; Kelvins/(calon-caloff) 
;
;
; scanlist structure created by getsl. used for randmon access to
; files
a={ sl,					    $
    scan      :         0L, $; scannumber this entry
    bytepos   :         0L,$; byte pos start of this scan
    stat      :         0B ,$; not used yet..
    rcvnum    :         0B ,$; receiver number 1-16
    numfrq    :         0B ,$; number of freq,cor boards used this scan
    rectype   :         0B ,$;1-calon,2-caloff,3-posOn,4-posOff
    numrecs   :         0L ,$; number of groups(records in scan)
    freq      :   fltarr(4),$;topocentric freqMhz center each subband
    srcname   :         ' ',$;source name (max 12 long)
    procname  :         ' '};procedure name used.
;
;	structure definitions to hold results of x102 mueller0,2 processing
;
a={ muellerfitI, $
;
;	 from b2d fit main beam
		tsys	:	0., $; system temp off source K
		tsys_err:	0., $; system temp off source K error
		gain    :   0., $; kelvins per jy.
;
		dtsysDza:	0., $; kelvins/deg
	dtsysDza_err:	0., $; kelvins/deg error 
;
		tsrc	:   0., $; source deflection K
		tsrc_err:   0., $; source deflection K error
	   sigmaPnts:   0., $; sigma of data-fit
;
	    azerr   :   0., $; pattern offset from center of beam.
       azerr_err:   0., $; error in above 
		zaerr   :   0., $; pattern offset from beam center Amin
       zaerr_err:   0., $; error in above 
;
		bmWidAvg:   0., $; avg hpbw arcmin
	bmWidAvg_err:   0., $; avg hpbw arcmin error
	  bmWidDelta:   0., $; (maxhpbw-minhpbw)/2.
  bmWidDelta_err:   0., $; (maxhpbw-minhpbw)/2. error
           bmPhi:   0., $; position angle of hpbw majAxis deg
       bmPhi_err:   0., $; position angle of hpbw majAxis deg
;
            coma:   0., $; alpha  units of hpbw
        coma_err:   0., $; alpha  units of hpbw
         comaPhi:   0., $; position angle coma lobe deg
     comaPhi_err:   0., $; position angle coma lobe deg error
;
 	   	   slHgt:   0., $; avg sidelobe hght/ mainbeam height
		  slCoef: complexarr(8,/nozero),$; hold sidelobe fit. sl/mainbeam 
		   etaMb:   0., $; eta main beam (efficiency) for given flux
		   etaSl:   0., $; eta sidelobe (efficiency) for given flux
	    calPhase:fltarr(2),$;atan(q/u)a+ b*(frq)  frq=-bw/2 to bw/2 [0,1]= [a,b]
    calPhase_err:fltarr(2),$; error in a,b
	    srcPhase:fltarr(2),$; a + b*(frq)  frq=-bw/2 to bw/2 [0,1]= [a,b]
    srcPhase_err:fltarr(2)} ; error in a,b
;
; q,u,v parameterization
;
a={ muellerfitpol,  $
		offset	  : 		0., $; zero offset in K	
		offset_err: 		0., $; zero offset in K	
		doffDza	  : 		0., $; zero offset in K	
	   doffDza_err: 		0., $;doffset / dza Kelvins/deg
	   		   src: 		0., $;src deflection. fraction of I
	   	   src_err: 		0., $;err  fraction of I
		 squintAmp: 		0., $;squint amplitude arcmin
	 squintAmp_err: 		0., $;squint amplitude arcmin
		  squintPA: 		0., $;squint position angle (az/za sys) deg
	  squintPA_err: 		0., $;squint position angle (az/za sys) deg

		 squashAmp: 		0., $;squash amplitude arcmin hpbw units
	 squashAmp_err: 		0., $;squash amplitude arcmin
		  squashPA: 		0., $;squash position angle (az/za sys) deg
	  squashPA_err: 		0.  };squash position angle (az/za sys) deg
;
a= {muellerparams, $
		 deltag	:	0., $; K totalpower. cal correction
		 epsilon:	0., $; totalpower. cal correction
		 alpha  :	0., $; totalpower. 
		 phi    :	0., $; totalpower. radians
		 chi    :	0., $; totalpower. radians
		 psi    :	0.  }; totalpower. radians

a= {mueller, $
       srcname  :   '', $; source name
       srcflux  :   0., $; source flux Jy
		   scan :   0L, $; scan number
          ra1950:   0., $; ra  1950
         dec1950:   0., $; dec 1950
        rcvnum  :   0L, $; receiver number.. ch=100
        rcvnam  :   '', $; receiver name
        utsec   :   0L, $; utc start secmidnite cal on start of pattern
        julday  :   0., $; reduced julian day at utsec
        bandwd  :   0., $; bandwidth mhz
        cfr     :   0., $; cfr Mhz center of band..topocentric
		brd     :   0 , $; correlator board number .0-3
        calTemp :fltarr(2),$; cal values used in processing. kelvins xx,yy
        lst     :   0., $; lst center of pattern
        az   	:   0., $; mean azimuth pattern deg
        za   	:   0., $; mean za pattern  deg
        parAngle:   0., $; mean parallactic angle for pattern
     astronAngle:   0., $; angle to rotate to astronmical system
	 paSrc      :   0., $; source position angle deg.
	 paSrc_err  :   0., $; error source position angle deg.
	 polSrc     :   0., $; total fractional linear pol.
	 polSrc_err :   0., $; err total fractional linear pol.
     bmWidScan  :   0., $; hpbw used in scan.. amin
	 mmcor      :   0 , $; muelMat cor. 0-no,1-to az/za 2 - to sky
			 fit:	{muellerfitI}   ,$;	
		 	fitQ:	{muellerfitpol} ,$;	
			fitU:	{muellerfitpol} ,$;	
			fitV:	{muellerfitpol} ,$;
	      mmparm:   {muellerparams} }; applied parameters for mueller matrix

a= {mmrcvind, $
		startind	: 0L,$; 
		  endind	: 0L,$;
		  rcvnum	: 0L}

;
;	flux structure
;   x=log10(freqMhz)
;   y=log10(S[ju])
;	y= a[0]+a[1]*x + a[2]*exp(-x)
;
;;a={fluxdata,$
;;	name	: ' '	,$;	source name
;;	code    :  0	,$;	code 1-good,2-bad,3-from flux.ca
;;	coef    :  fltarr(3),$;
;;	rms     :  0.   ,$; rms of fit to data 
;;	notes   : ' '   }
