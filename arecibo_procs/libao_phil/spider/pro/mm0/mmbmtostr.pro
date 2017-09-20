;+
;NAME:
;mmbmtostr - move  mueller beam processed arrays to a structure
;SYNTAX: mmbmtostr,nrc,beamin_arr,beamout_arr,hb_arr,mm_arr
;ARGS:
;	nrc			  : int	index into beamin,beamout to use
;	beamin_arr[M]  : holds info input to beam fits
;	beamout_arr[M] : holds info output from beam fits
;	hb_arr[4]      : {hdr} first header of each strip of pattern
;RETURNS:
;	mm			  :{} struct holding the combined info.
;
;DESCRIPTION:
;	mmtostr takes the data from the mueller matrix fitting and loads
;it into a structure that is used in the archiving.
;
;
;30jun01.. fixup eta mainbeam, eta sidelobe
;21oct02. carl modifed to work with newcal, eliminating the intermediate
;         hdr params.
;09dec04.. phil update to merge this format with the old format..
;
;-
pro mmbmtostr, nrc,  beamin_arr,beamout_arr, hbarr,mm_arr


	beamout= beamout_arr[ nrc]
	beamin= beamin_arr[ nrc]

	b2dfit= beamout.b2dfit
;
; 	info added for compatability with old system
;   old database used start time of cal. i've switched here to use start time of
;   first strip..
;
	  mm_arr[nrc].ra1950 = hbarr[0].pnt.r.reqposrd[0] * !radeg/15.
	  mm_arr[nrc].dec1950= hbarr[0].pnt.r.reqposrd[1] * !radeg
	  mm_arr[nrc].utsec  = (hbarr[0].std.stscantime + 3600*4L) mod 86400L
	  mm_arr[nrc].bandwd = (hbarr[0].cor.bwnum eq 0)?100.: $
						   (50./(2^(hbarr[0].cor.bwnum-1)))
	  mm_arr[nrc].lst    =  hbarr[0].pnt.r.lastrd*!radeg/15.

	  mm_arr[nrc].npol    = 4 				; until we FIX it..
	  mm_arr[nrc].nstrips = 4               ; till we FIX it..
		
;
;	 take az offsets (max-min)/hpbwguess and round
;
	  mm_arr[nrc].beamsperstrip  = round((max(beamin.azoffsets[*,0]) - $
	                               min(beamin.azoffsets[*,0]))/$
									   beamin.hpbw_guess)
	  mm_arr[nrc].samplesperstrip= n_elements(beamin.azoffsets[*,0])


;GET RCEIVER DESIDERATA...

getrcvr, 0., rcvr_name, beamin.rcvrn, nocorrcal, circular, mmprocname=mmprocname

call_procedure, mmprocname, beamout.b2dfit[ 17,0], m_tot, m_astron, $
       deltag, epsilon, alpha, phi, chi, psi, angle_astron ;;;;;, /zero_deltag 
;
;   mueller matrix correction parameters read from the rcvr routine, whether
;they were applied or not.
;
        mm_arr[nrc].mmparm.deltag = deltag
        mm_arr[nrc].mmparm.epsilon= epsilon
        mm_arr[nrc].mmparm.alpha  = alpha
        mm_arr[nrc].mmparm.phi    = phi
        mm_arr[nrc].mmparm.chi    = chi
        mm_arr[nrc].mmparm.psi    = psi
        mm_arr[nrc].astronAngle= angle_astron;feed to astronomical system
;
;
        mm_arr[nrc].az      = beamout.b2dfit[ 19,0]    ;mean azimuth pattern
        mm_arr[nrc].za      = beamout.b2dfit[ 19,1]    ;mean ZA PATTern

;		mean parallactic angle for pattern
        mm_arr[nrc].parAngle= beamout.b2dfit[ 18,0]   

;hpbw used for pat( len=3*hpbw) Amin
        mm_arr[nrc].bmWidScan=beamin.hpbw_guess

        mm_arr[nrc].fit.tsys    = beamout.b2dfit[ 0,0]    ;deg K
        mm_arr[nrc].fit.tsys_err= beamout.b2dfit[ 0,1]     ;error. deg K
        ; sigma of fit residuals deg K
        mm_arr[nrc].fit.sigmaPnts= beamout.b2dfit[10,0]
        mm_arr[nrc].fit.dtsysDza      = beamout.b2dfit[1,0]; K/deg
        mm_arr[nrc].fit.dtsysDza_err  = beamout.b2dfit[1,1]; K/deg
        mm_arr[nrc].fit.tsrc          = beamout.b2dfit[2,0]; K/deg
        mm_arr[nrc].fit.tsrc_err      = beamout.b2dfit[2,1]; K/deg
        mm_arr[nrc].fit.gain          = beamout.b2dfit[16,0];

;az offset center of fit.GC Amin
        mm_arr[nrc].fit.azerr         = beamout.b2dfit[3,0 ]
;error in above. GC Amin
        mm_arr[nrc].fit.azerr_err     = beamout.b2dfit[3,1 ]
;za offset center of fit.Amin
        mm_arr[nrc].fit.zaerr         = beamout.b2dfit[4,0 ]
;error in above. Amin
        mm_arr[nrc].fit.zaerr_err     = beamout.b2dfit[4,1 ]
        mm_arr[nrc].fit.bmWidAvg      = beamout.b2dfit[5,0 ];avg hpbw Amin
        mm_arr[nrc].fit.bmWidAvg_err  = beamout.b2dfit[5,1 ];
        ;(maxhpbw-minhpbw)/2 amin
        mm_arr[nrc].fit.bmWidDelta    = beamout.b2dfit[6,0 ]
        mm_arr[nrc].fit.bmWidDelta_err= beamout.b2dfit[6,1 ];error
        ;posAngle, hpbw major axis deg
        mm_arr[nrc].fit.bmPhi         = beamout.b2dfit[7,0 ]
        mm_arr[nrc].fit.bmPhi_err     = beamout.b2dfit[7,1 ]; deg
        ; coma(alpha in fit). units:hpbw
        mm_arr[nrc].fit.coma          = beamout.b2dfit[8,0 ]
        mm_arr[nrc].fit.coma_err      = beamout.b2dfit[8,1 ]; error
        ; posAngle coma lobe Deg
        mm_arr[nrc].fit.comaPhi       = beamout.b2dfit[9,0 ]
        mm_arr[nrc].fit.comaPhi_err   = beamout.b2dfit[9,1 ]; error

;OLD (units already tsrc)
; mm_arr[nrc].fit.slHgt = beamout.b2dfit[13,0 ]/beamout.b2dfit[2,0 ]
; sidelobe mean ampl/mainbm
; <pjp005> .. divided by Tsrc..
        mm_arr[nrc].fit.slHgt= beamout.b2dfit[13,0 ] /beamout.b2dfit[2,0]

        mm_arr[nrc].fit.slhgtCoef    = beamout.fhgt ; complex hgt coeffs
        mm_arr[nrc].fit.slcenCoef    = beamout.fcen ; comples cen coeffs
        mm_arr[nrc].fit.slhpbwCoef   = beamout.fhpbw; complex hpbw coeffs

        mm_arr[nrc].fit.etaMb    = beamout.b2dfit[14,0 ];main beam efficiency
        mm_arr[nrc].fit.etaSl    = beamout.b2dfit[15,0 ];sidelobe  efficiency
;
;           fits to phase=a + B(freq-cfr) [0,1]= [a,b]
;
        mm_arr[nrc].fit.calPhase = [beamin.calphase_zero[0], $
                                       beamin.calphase_slope[0]]
;calphase at band cntr (rad) and slope (rad/MHz)
        mm_arr[nrc].fit.calPhase_err= [beamin.calphase_zero[1],$
                                          beamin.calphase_slope[1]]

        mm_arr[nrc].fit.srcPhase   = [beamin.srcphase_zero[0], $
                                         beamin.srcphase_slope[0]]
                  ;calphase at band cntr (rad) and slope (rad/MHz)
    mm_arr[nrc].fit.srcPhase_err  = [beamin.srcphase_zero[1], $
                                        beamin.srcphase_slope[1]]
;
;       NOW THE POLARIZATION INFO,1,2,3 ARE FITQ,FITU,FITV
;   <pjp002> get rid of comment

        fp=REPLICATE({MUELLERFITPOL},3)
;    
     FOR j=1,3 do begin
            fp[j-1].offset   =beamout.b2dfit[10+j*10+0,0 ]; zero offset kelvins 
            fp[j-1].offset_err=beamout.b2dfit[10+j*10+0,1 ]; zero offset kelvins
            fp[j-1].doffDza    =beamout.b2dfit[10+j*10+1,0 ]; kelv/deg
            fp[j-1].doffDza_err=beamout.b2dfit[10+j*10+1,1 ]; kelv/deg
            fp[j-1].src        =beamout.b2dfit[10+j*10+2,0 ]/$
                                mm_arr[nrc].fit.tsrc;fract of I 
            fp[j-1].src_err    =beamout.b2dfit[10+j*10+2,1 ]/$
                    mm_arr[nrc].fit.tsrc;fract of I
            fp[j-1].squintAmp  =beamout.b2dfit[10+j*10+3,0 ];squint ampl arcmin
            fp[j-1].squintAmp_err=beamout.b2dfit[10+j*10+3,1 ];squint ampl amin
            fp[j-1].squintPA=beamout.b2dfit[10+j*10+4,0 ];squint position angle 
                                                  ;(az/za sys) deg
            fp[j-1].squintPA_err=beamout.b2dfit[10+j*10+4,1 ];
            fp[j-1].squashAmp  =beamout.b2dfit[10+j*10+5,0 ];squash amplitude 
                                                      ;arcmin hpbw units
            fp[j-1].squashAmp_err=beamout.b2dfit[10+j*10+5,1 ];error
            fp[j-1].squashPA=beamout.b2dfit[10+j*10+6,0 ];squash position angle 
                                                      ;(az/za sys) deg
            fp[j-1].squashPA_err=beamout.b2dfit[10+j*10+6,1 ];error
    ENDFOR
    mm_arr[nrc].fitQ=fp[0]
    mm_arr[nrc].fitU=fp[1]
    mm_arr[nrc].fitV=fp[2]
    polSrcSq= (mm_arr[nrc].fitq.src^2 + mm_arr[nrc].fitu.src^2)
    mm_arr[nrc].polSrc=sqrt(polSrcSq)
    mm_arr[nrc].polSrc_err=sqrt($
     	 (mm_arr[nrc].fitq.src^2 * mm_arr[nrc].fitq.src_err^2 + $
          mm_arr[nrc].fitu.src^2 * mm_arr[nrc].fitu.src_err^2) / polSrcSq)

        mm_arr[nrc].paSrc=modanglem(!radeg * .5 *$
                        atan(mm_arr[nrc].fitu.src,mm_arr[nrc].fitq.src))

        mm_arr[nrc].paSrc_err=!radeg*.5*sqrt( $
        (mm_arr[nrc].fitq.src^2 * mm_arr[nrc].fitu.src_err^2 + $
         mm_arr[nrc].fitu.src^2 * mm_arr[nrc].fitq.src_err^2) / $
            (polSrcSq^2))

return
end
