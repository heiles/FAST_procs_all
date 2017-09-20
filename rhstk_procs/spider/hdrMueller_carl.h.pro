;RUNNING HDRMUELLER_carlH...

;+
;   DEFINE VARIOUS MUELLER MATRIX STRUCTURES:
;	MUELLERFITI_carl
;	MUELLERFITPOL
;	MUELLERPARAMS
;	MUELLER_carl
;	MMRCVIND
;	MMPARAMS_carl
;	structure definitions to hold results of x102 mueller0,2 processing
;
;   Jun 19, 2007: Tim adds BackEnd to the list (for GBT ACS vs SP)
;-
;
; STRUCTURE 'muellerfitI_carl' CONTAINS BEAM PATTERN FOR STOKES I
a={ muellerfitI_carl, $
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

;CHANGE FROM PHILS VERSION.  slCoef: complexarr(8,/nozero),$; hold sidelobe fit. sl/mainbeam 

  slhgtCoef: complexarr(8),  $   ; hold sidelobe fit for Gaussian heights
  slcenCoef: complexarr(8),  $   ; hold sidelobe fit for Gaussian centers
  slhpbwCoef: complexarr(8), $  ;hold sidelobe fit for Gaussian hpbw's

		   etaMb:   0., $; eta main beam (efficiency) for given flux
		   etaSl:   0., $; eta sidelobe (efficiency) for given flux
	    calPhase:fltarr(2),$;atan(q/u)a+ b*(frq)  frq=-bw/2 to bw/2 [0,1]= [a,b]
    calPhase_err:fltarr(2),$; error in a,b
	    srcPhase:fltarr(2),$; a + b*(frq)  frq=-bw/2 to bw/2 [0,1]= [a,b]
    srcPhase_err:fltarr(2)} ; error in a,b
;
; STRUCTURE 'muellerpol' CONTAINS BEAM PATTERN FOR POLARIZED STOKES 
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
; STRUCTURE 'muellerparams' CONTAINS THE BASIC MATRIX PARAMETERS...
a= {muellerparams, $
		 deltag	:	0., $; K totalpower. cal correction
		 epsilon:	0., $; totalpower. cal correction
		 alpha  :	0., $; totalpower. 
		 phi    :	0., $; totalpower. radians
		 chi    :	0., $; totalpower. radians
		 psi    :	0.  }; totalpower. radians

; STRUCTURE 'mueller_carl' CONTAINS BASIC RCVR, CROSS, POSITION, TIME DATA...
a= {mueller_carl, $
       srcname  :   '', $; source name
       srcflux  :   0., $; source flux Jy
	   scan :   0L, $; scan number
;          ra1950:   0., $; ra  1950
;         dec1950:   0., $; dec 1950
       backend  : '', $ ; backend name ;!!!!! Tim adds this 6/19/07
        rcvnum  :   0L, $; receiver number.. ch=100
        rcvnam  :   '', $; receiver name
;        utsec   :   0L, $; utc start secmidnite cal on start of pattern
        julday  :   0.d0, $; reduced julian day at utsec
;        bandwd  :   0., $; bandwidth mhz
        cfr     :   0.d0, $; cfr Mhz center of band..topocentric
	bw        : 0.d0 , $; BW
	bwsign     : 0. , $; +/- 1; sign of freq increase with chnl nr
	nchnls: 0, $; nr of chnls in spectra
	brd     :   0 , $; correlator board number .0-3
   calTemp : fltarr(2), $; cal values used in processing. kelvins xx,yy


;;DATA ABOUT CALS AND CHANNEL RANGES, ADDED BY CARL...
;	dpdf:       0., $; assumed phase slope wrt freq, rad/MHz
;tcalxx_board: fltarr(4),$; xx cal temps for the four boards
;tcalyy_board: fltarr(4),$; yy cal temps for the four boards
;             nchnls: 0, $; tot nr chnls in spectra
;     chnls: intarr( ncontchnls),$; channels to use in computing continuum
;phasechnls: intarr( ncontchnls),$ channels to get continuum phase
; gainchnls: intarr( ncontchnls),$ channels to get continuum gain
;
;;DATA ABOUT SCANS, ADDED BY CARL...
;	ptsperstrip: 0, $; number of datapoints per strip 60
;	ptsforcal:   0, $; number of points at beginning for calon/caloff 2
;	nrstrips:    0, $; number of strips in pattern 4
;   onscans: intarr( 8), $; indices for on-src peaks for each scan
;  offscans: intarr( 8), $; indices for off-src points for each scan
;  indxcalon: intarr(2), $; indices of cal on
; indxcaloff: intarr(2), $; indices of cal off




;DATA ABOUT POSITIONS...
;        lst     :   0., $; lst center of pattern
        az   	:   0., $; mean azimuth pattern deg
        za   	:   0., $; mean za pattern  deg
        parAngle:   0., $; mean parallactic angle for pattern
     astronAngle:   0., $; angle to rotate to astronmical system
	 paSrc      :   0., $; source position angle deg.
	 paSrc_err  :   0., $; error source position angle deg.
	 polSrc     :   0., $; total fractional linear pol.
	 polSrc_err :   0., $; err total fractional linear pol.
     bmWidScan  :   0., $; hpbw used in scan.. amin
	 mmcor      :   0 , $; first digit 1: electronics corr;
			     ;  secd digit 1: sky corr
			     ;  third digit 1: aston corr
			 fit:	{muellerfitI_carl}   ,$;	
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
a= {mmparams_carl, $
	      rcvNum:  0   ,$;receiver number
		    year:  0   ,$; year when this data valid
		     day:  0   ,$; daynumber when data valid
 	      corcal:  0   ,$; 1 if corcal available
 	    circular:  0   ,$; 1 if native circular feed
             cfr:  0.d0  ,$;freq in Mhz where the parameters are computed.
           alpha:  0.  ,$;alpha parameter (in radians)
         epsilon:  0.  ,$;epsilon parameter
             phi:  0.  ,$;phi angle in radians
             psi:  0.  ,$;psi angle in radians
             chi:  0.  ,$;chi angle in radians
          deltag:  0.  ,$;difference in cal values
     astronAngle:  0.  ,$;astronomical angle (degrees)
        m_astron: fltarr(4,4),$;matrix to apply after the mueller matrix
;                         correction to move to sky coordinates.
		      mm: fltarr(4,4)}; the mueller matrix (without m_astron).
