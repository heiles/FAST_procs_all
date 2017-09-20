;
;   mueller matrix structures
; 09dec04 - i copied the old version and merged in the 
;           extra stuff that carl has added for the new version.
;           I also added something that i think needs to be stored..
; 04aug07 - <pjp002> added a few elements to muellerparams_carl.
;           Carl had added these to mmlsfit.pro
;
;key
;N  this is from the new version not in the old version
;O  this is in the old version but not in the new version
;P  this was added by phil
;U  old,new but units changed
;	structure definitions to hold results of x102 mueller0,2 processing
;
; name changes
;  muellerfitI_carl -> muellerfitI
;  mueller_carl     -> mueller
;  muellerparams_carl stays as muellerparams_carl
;
;
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
;<O>	  slCoef: complexarr(8,/nozero),$; hold sidelobe fit. sl/mainbeam 
 	   slhgtCoef: complexarr(8),$;<N> sidelobe fit for Gaussian heights(degK)
       slcenCoef: complexarr(8),$;<N> sidelobe fit for Gaussian centers (Amin)
      slhpbwCoef: complexarr(8),$;<N> sidelobe fit for Gaussian hpbw's  (Amin0
 
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
;
; similar to muellerparams. It has extra junk that carl added. This struct is 
; computed by the mm4 routine when doing the full analysis and saved to disc
;
a= {muellerparams_carl, $

;   info to keep track of where it came from

    scan1  :         0L, $; scannumber first strip of first pattern used
    scan2  :         0L, $; scannumber first strip of last pattern used
    npat   :         0L, $; number of patterns used
    srcname:        '' , $;
    cfr    :        0. , $; center freq Mhz
    brd    :        0  , $; 0..3
    rcvnum :        0  , $; rcvr number
    julday :        0.D, $; modified julian day at utsec.
;
;   the fit
;
    deltag :       0.0, $;
    epsilon:       0.0, $;
    alpha  :         0.,$;
    phi    :         0., $;
    chi    :         0., $;
    psi    :         0., $ ;
    fixpsi  :        0,   $ ;

    sigdeltag :       0., $;
    sigepsilon:       0., $;
    sigalpha  :       0., $;
    sigphi    :       0., $;
    sigchi    :       0., $;
    sigpsi    :       0., $ ;
    sigfixpsi  :       0,   $ ;

    qsrc  :       0.0, $
    usrc  :       0.0, $
    polsrc  : 0.0, $  ; <pjp002>
    pasrc   : 0., $   ; <pjp002>

   sigqsrc: 0., $
   sigusrc: 0., $
   sigpolsrc : 0., $ ; <pjp002>
   sigpasrc : 0., $  ; <pjp002>

   sigma:  0., $
   problem:  0,  $
   m7:  0,  $ whether done with m7 (1) or not (0). m7 uses cumcorr,
        $which might be good for interference excision.
   m_tot: fltarr( 4,4) $ ; the mueller matrix
}

a= {mueller, $
       srcname  :   '', $; source name
       srcflux  :   0., $; source flux Jy
		   scan :   0L, $; scan number
          ra1950:   0., $;<O> ra  1950
         dec1950:   0., $;<O> dec 1950
        rcvnum  :   0L, $; receiver number.. ch=100
        rcvnam  :   '', $; receiver name
        utsec   :   0L, $;<O> utc start secmidnite cal on start of pattern
        julday  :   0.D,$;<U> flt->dbl reduced julian day at utsec
        bandwd  :   0., $;<O> bandwidth mhz
        cfr     :   0., $; cfr Mhz center of band..topocentric
      fchnl_0   :   0., $;<N> frq in smallest channel
      fchnl_max :   0., $;<N> frq in largest channel
          nchnls:   0,  $;<N>  nr of chnls in spectra
		    npol:   0B, $;<P> 2-->no stokes, 4--> stokes
		 nstrips:   0B, $;<P> 2  cross, 4 spider
	beamsPerStrip:  0B, $;<P> beams per strip . default 6
  samplesPerStrip:  0 , $;<P> assume 1 sec samples

		brd     :   0 , $; correlator board number .0-3,0-7 alfa
        calTemp :fltarr(2),$; cal values used in processing. kelvins xx,yy
        lst     :   0., $;<O> lst center of pattern
        az   	:   0., $; mean azimuth pattern deg
        za   	:   0., $; mean za pattern  deg
        parAngle:   0., $; mean parallactic angle for pattern
     astronAngle:   0., $; angle to rotate to astronmical system
	alfaRotAngle:   0., $;<P> angle alfa set at.. degrees.
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
;	 mueller matrix parameters read from file
;
a= {mmparams, $
	      rcvNum:  0   ,$;receiver number
		    year:  0   ,$; year when this data valid
		     day:  0   ,$; daynumber when data valid
 	      corcal:  0   ,$; 1 if corcal available
 	    circular:  0   ,$; 1 if native circular feed
             cfr:  0.  ,$;freq in Mhz where the parameters are computed.
           alpha:  0.  ,$;alpha parameter (in radians)
         epsilon:  0.  ,$;epsilon parameter
             phi:  0.  ,$;phi angle in radians
             psi:  0.  ,$;psi angle in radians
             chi:  0.  ,$;chi angle in radians
          deltag:  0.  ,$;difference in cal values
     astronAngle:  0.  ,$;astronomical angle (degrees)
        m_astron: fltarr(4,4)};matrix to apply after the mueller matrix
;                         correction to move to sky coordinates.
