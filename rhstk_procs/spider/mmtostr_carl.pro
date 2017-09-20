
pro mmtostr_carl, nrc, nrcmax, board, beamin_arr, beamout_arr, a, fp


;+
;NAME:
;mmtostr - move  mueller processed arrays to a structure
;
;30jun01.. fixup eta mainbeam, eta sidelobe
;21oct02. carl modifed to work with newcal, eliminating the intermediate hdr params.
; Jun 19, 2007: Tim adds backend tag to A structure.
;
;-

i=nrc
beamout= beamout_arr[ nrc]
beamin= beamin_arr[ nrc]

b2dfit= beamout.b2dfit

;THE FOLLOWING MUST BE DEFINED BEFOREHAND...
;    A=REPLICATE({MUELLER_carl}, NRCMAX)
;        FP=REPLICATE({MUELLERFITPOL},3)

;    for i=0,numpat-1 do begin

        a[i].srcname= beamout.sourcename
        a[i].scan   = beamin.scannr
        a[i].brd    = board
        a[i].cfr     = beamout.b2dfit[ 17,0]        ;center freq band Mhz
        a[i].srcflux= b2dfit[ 12,0]
        a[i].rcvnum  = beamin.rcvrn
	a[i].rcvnam  = beamin.rcvrname
        a[i].backend = beamin.backend ;!!!!!!!!! Tim adds Jun 19, 2007

; GET RECEIVER DESIDERATA...
gbtrcvr, beamin.rcvrname, beamin.rcvrn, $
	nocorrcal, circular, mmprocname=mmprocname

;!!!!!!!!!!!!!!!!!!!!!!
; HERE WE ARE FORCING A RECEIVER FILE TO BE OPENED...
; WHICH DOESN'T MAKE MUCH SENSE IF WE'RE TRYING TO MEASURE THE MM
; FOR THE FIRST TIME AND DON'T HAVE A RECEIVER FILE YET!!!

if (strlen(mmprocname) gt 0) then begin
   call_procedure, mmprocname, beamout.b2dfit[ 17,0], m_tot, m_astron, $
                   deltag, epsilon, alpha, phi, chi, psi, angle_astron 
;;;;;, /zero_deltag 
endif else begin

   ; TIM ADDS THIS JUN 29, 2007... DOESN'T CHANGE OUTPUTS...
   m_tot=fltarr(4,4)
   m_astron=fltarr(4,4)
   deltag=0.0
   epsilon=0.0
   alpha=0.0
   phi=0.0
   chi=0.0
   psi=0.0
   angle_astron=0.0
endelse

;stop

;
;   mueller matrix correction parameters read from the rcvr routine, whether
;they were applied or not.
;
            a[i].mmparm.deltag = deltag
            a[i].mmparm.epsilon= epsilon
            a[i].mmparm.alpha  = alpha
            a[i].mmparm.phi    = phi
            a[i].mmparm.chi    = chi
            a[i].mmparm.psi    = psi
            a[i].astronAngle= angle_astron    ;feed to astronomical system

        a[i].calTemp = [beamin.tcalxx, beamin.tcalyy] ; tcalXX, tcalyy K

        a[i].az      = beamout.b2dfit[ 19,0]    ;mean azimuth pattern
        a[i].za      = beamout.b2dfit[ 19,0]    ;mean ZA PATTern
        a[i].parAngle= beamout.b2dfit[ 18,0]    ;mean parallactic angle for pattern

        a[i].bmWidScan   = beamin.hpbw_guess   ;hpbw used for pat( len=3*hpbw) Amin
        a[i].mmcor   = 0                       ;mm corrected?0-no,1-az/za,2-sky
        a[i].fit.tsys    = beamout.b2dfit[ 0,0]    ;deg K
        a[i].fit.tsys_err= beamout.b2dfit[ 0,0]     ;error. deg K
        a[i].fit.sigmaPnts= beamout.b2dfit[10,0]  ; sigma of fit residuals deg K
        a[i].fit.dtsysDza      = beamout.b2dfit[1,0]; K/deg
        a[i].fit.dtsysDza_err  = beamout.b2dfit[1,1]; K/deg
        a[i].fit.tsrc          = beamout.b2dfit[2,0]; K/deg
        a[i].fit.tsrc_err      = beamout.b2dfit[2,1]; K/deg
        a[i].fit.gain          = beamout.b2dfit[16,0];

        a[i].fit.azerr         = beamout.b2dfit[3,0 ];az offset center of fit.GC Amin
        a[i].fit.azerr_err     = beamout.b2dfit[3,1 ];error in above. GC Amin
        a[i].fit.zaerr         = beamout.b2dfit[4,0 ];za offset center of fit.Amin
        a[i].fit.zaerr_err     = beamout.b2dfit[4,1 ];error in above. Amin
        a[i].fit.bmWidAvg      = beamout.b2dfit[5,0 ];avg hpbw Amin
        a[i].fit.bmWidAvg_err  = beamout.b2dfit[5,1 ];
        a[i].fit.bmWidDelta    = beamout.b2dfit[6,0 ];(maxhpbw-minhpbw)/2 amin
        a[i].fit.bmWidDelta_err= beamout.b2dfit[6,1 ];error
        a[i].fit.bmPhi         = beamout.b2dfit[7,0 ];posAngle, hpbw major axis deg
        a[i].fit.bmPhi_err     = beamout.b2dfit[7,1 ]; deg
        a[i].fit.coma          = beamout.b2dfit[8,0 ]; coma(alpha in fit). units:hpbw
        a[i].fit.coma_err      = beamout.b2dfit[8,1 ]; error
        a[i].fit.comaPhi       = beamout.b2dfit[9,0 ]; posAngle coma lobe Deg
        a[i].fit.comaPhi_err   = beamout.b2dfit[9,1 ]; error

;OLD (units already tsrc)        a[i].fit.slHgt     = beamout.b2dfit[13,0 ]/beamout.b2dfit[2,0 ];sidelobe/mainbm
        a[i].fit.slHgt     = beamout.b2dfit[13,0 ] ;sidelobe mean ampl/mainbm

        a[i].fit.slhgtCoef    = beamout.fhgt ; complex hgt coeffs
        a[i].fit.slcenCoef    = beamout.fcen ; comples cen coeffs
        a[i].fit.slhpbwCoef    = beamout.fhpbw; complex hpbw coeffs

        a[i].fit.etaMb         = beamout.b2dfit[14,0 ];main beam efficiency
        a[i].fit.etaSl         = beamout.b2dfit[15,0 ];sidelobe  efficiency
;
;           fits to phase=a + B(freq-cfr) [0,1]= [a,b]
;
        a[i].fit.calPhase   = [beamin.calphase_zero[0], beamin.calphase_slope[0]]
				  ;calphase at band cntr (rad) and slope (rad/MHz)
        a[i].fit.calPhase_err= [beamin.calphase_zero[1], beamin.calphase_slope[1]]

        a[i].fit.srcPhase   = [beamin.srcphase_zero[0], beamin.srcphase_slope[0]]
				  ;calphase at band cntr (rad) and slope (rad/MHz)
	a[i].fit.srcPhase_err  = [beamin.srcphase_zero[1], beamin.srcphase_slope[1]]
;
;       NOW THE POLARIZATION INFO,1,2,3 ARE FITQ,FITU,FITV

;        FP=REPLICATE({MUELLERFITPOL},3)
;    
     FOR j=1,3 do begin
            fp[j-1].offset     =beamout.b2dfit[10+j*10+0,0 ]; zero offset kelvins 
            fp[j-1].offset_err =beamout.b2dfit[10+j*10+0,1 ]; zero offset kelvins 
            fp[j-1].doffDza    =beamout.b2dfit[10+j*10+1,0 ]; kelv/deg
            fp[j-1].doffDza_err=beamout.b2dfit[10+j*10+1,1 ]; kelv/deg
            fp[j-1].src        =beamout.b2dfit[10+j*10+2,0 ]/a[i].fit.tsrc;fract of I 
            fp[j-1].src_err    =beamout.b2dfit[10+j*10+2,1 ]/a[i].fit.tsrc;fract of I
            fp[j-1].squintAmp  =beamout.b2dfit[10+j*10+3,0 ];squint amplitude arcmin
            fp[j-1].squintAmp_err=beamout.b2dfit[10+j*10+3,1 ];squint amplitude arcmin
            fp[j-1].squintPA   =beamout.b2dfit[10+j*10+4,0 ];squint position angle 
                                                  ;(az/za sys) deg
            fp[j-1].squintPA_err=beamout.b2dfit[10+j*10+4,1 ];
            fp[j-1].squashAmp  =beamout.b2dfit[10+j*10+5,0 ];squash amplitude 
                                                      ;arcmin hpbw units
            fp[j-1].squashAmp_err=beamout.b2dfit[10+j*10+5,1 ];error
            fp[j-1].squashPA   =beamout.b2dfit[10+j*10+6,0 ];squash position angle 
                                                      ;(az/za sys) deg
            fp[j-1].squashPA_err=beamout.b2dfit[10+j*10+6,1 ];error
    ENDFOR
        a[i].fitQ=fp[0]
        a[i].fitU=fp[1]
        a[i].fitV=fp[2]
        polSrcSq= (a[i].fitq.src^2 + a[i].fitu.src^2)
        a[i].polSrc=sqrt(polSrcSq)
        a[i].polSrc_err=sqrt($
         (a[i].fitq.src^2 * a[i].fitq.src_err^2 + $
          a[i].fitu.src^2 * a[i].fitu.src_err^2) / polSrcSq)

        ;a[i].paSrc=modanglem(!radeg * .5 *atan(a[i].fitu.src,a[i].fitq.src))
        a[i].paSrc=modangle(!radeg * .5 *atan(a[i].fitu.src,a[i].fitq.src),180.0,/NEGPOS)

        a[i].paSrc_err=!radeg*.5*sqrt( $
         (a[i].fitq.src^2 * a[i].fitu.src_err^2 + $
          a[i].fitu.src^2 * a[i].fitq.src_err^2) / (polSrcSq^2))

return

end
