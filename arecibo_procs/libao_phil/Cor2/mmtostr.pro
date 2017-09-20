;+
;NAME:
;mmtostr - move  mueller processed arrays to a structure
;-
;30jun01.. fixup eta mainbeam, eta sidelobe
;
function mmtostr,filesave1,norestore=norestore,rcvnum=rcvnum,b2dcfs=b2dcfs,$
                 hdrsrcname=hdrsrcname,hdr1info=hdr1info,hdr2info=hdr2info,$
                 strp_cfs=strp_cfs,hdrscan=hdrscan
;;  common hdrdata
;;  common timecoord

    on_error,1
    if not keyword_set(norestore) then restore,filesave1
;;  restore,filesave2,/verbose
;              0    1     2     3     4   5     6     7    8    9
    rcvnames=['0','327','430','610','4','lbw','lbn','sbw','sbh','cband',$
;              10   11    12    13    14   15    16
              'cbh','xb','sbn','13','14','15','16']
            
    sz=size(b2dcfs)
    if (sz[0] eq 2) then begin
        numpat=1 
    endif else begin
        numpat=sz[3]
    endelse
    a=replicate({mueller},numpat)
    for i=0,numpat-1 do begin
        a[i].srcname=hdrsrcname[i]
        a[i].scan   =hdrscan[i]
        a[i].brd    =hdr1info[6,i]
        a[i].cfr     = hdr1info[5,i]        ;center freq band Mhz
;
;   lookup the flux if needed
;
        flux=b2dcfs[12,0,i]
        if (flux le 0.) then begin
            flux=fluxsrc(a[i].srcname,a[i].cfr)
            if flux le 0. then flux=-1.
        endif
        a[I].srcflux=flux
        ind=indgen(4)*60+29     ; center of each strip
        a[i].ra1950  =total(hdr2info[ind,3,i])/4.
        a[i].dec1950 =total(hdr2info[ind,4,i])/4.
        a[i].rcvnum  = hdr1info[29,i]
        if a[i].rcvnum eq 100 then begin
            a[i].rcvnam  = '430ch'
        endif else begin
            a[i].rcvnam  = rcvnames[((a[i].rcvnum < 17)>0)]
        endelse
        a[i].utsec   = hdr1info[0,i]*3600        ;begin of cal
        a[i].julday  = hdr1info[2,i]        ;modified jul day
        a[i].bandwd  = hdr1info[4,i]        ;modified jul day
        a[i].calTemp = [hdr1info[8,i],hdr1info[9,i]]; tcalXX, tcalyy K
        a[i].lst     = total(hdr2info[ind,0,i])/4.; avg lst center each strip
        a[i].az      = b2dcfs[19,0,i]       ;mean azimuth pattern
        a[i].za      = b2dcfs[19,1,i]       ;mean ZA PATTern
        a[i].parAngle= b2dcfs[18,0,i]       ;mean parallactic angle for pattern
        a[i].astronAngle=hdr1info[31,i]     ;feed to astronomical system
        a[i].bmWidScan   = hdr1info[28,i]   ;hpbw used for pat( len=3*hpbw) Amin
        a[i].mmcor   = hdr1info[1,i]        ;mm corrected?0-no,1-az/za,2-sky
        a[i].fit.tsys    = b2dcfs[0,0,i]    ;deg K
        a[i].fit.tsys_err= b2dcfs[0,1,i]    ;error. deg K
        a[i].fit.sigmaPnts= b2dcfs[10,0,i]  ; sigma of fit residuals deg K
        a[i].fit.dtsysDza      = b2dcfs[1,0,i]; K/deg
        a[i].fit.dtsysDza_err  = b2dcfs[1,1,i]; K/deg
        a[i].fit.tsrc          = b2dcfs[2,0,i]; K/deg
        a[i].fit.tsrc_err      = b2dcfs[2,1,i]; K/deg
        a[i].fit.gain          = b2dcfs[16,0,i];
;
;   recompute gain if negative
;
        if (a[i].fit.gain le 0) and (a[i].srcflux ne 0) then begin
            a[i].fit.gain=.5*a[i].fit.tsrc/a[i].srcflux ; tsrc is I,flux is 1 pol 
        endif
        a[i].fit.azerr         = b2dcfs[3,0,i];az offset center of fit.GC Amin
        a[i].fit.azerr_err     = b2dcfs[3,1,i];error in above. GC Amin
        a[i].fit.zaerr         = b2dcfs[4,0,i];za offset center of fit.Amin
        a[i].fit.zaerr_err     = b2dcfs[4,1,i];error in above. Amin
        a[i].fit.bmWidAvg      = b2dcfs[5,0,i];avg hpbw Amin
        a[i].fit.bmWidAvg_err  = b2dcfs[5,1,i];
        a[i].fit.bmWidDelta    = b2dcfs[6,0,i];(maxhpbw-minhpbw)/2 amin
        a[i].fit.bmWidDelta_err= b2dcfs[6,1,i];error
        a[i].fit.bmPhi         = b2dcfs[7,0,i];posAngle, hpbw major axis deg
        a[i].fit.bmPhi_err     = b2dcfs[7,1,i]; deg
        a[i].fit.coma          = b2dcfs[8,0,i]; coma(alpha in fit). units:hpbw
        a[i].fit.coma_err      = b2dcfs[8,1,i]; error
        a[i].fit.comaPhi       = b2dcfs[9,0,i]; posAngle coma lobe Deg
        a[i].fit.comaPhi_err   = b2dcfs[9,1,i]; error
        if b2dcfs[2,0,i] le 1e-6 then begin
            a[i].fit.slHgt     = 0.
            a[i].fit.slCoef    = complexarr(8)
        endif else begin
            a[i].fit.slHgt     = b2dcfs[13,0,i]/b2dcfs[2,0,i];sidelobe/mainbm
;
;   do the sidelobe fit again..
;
            ft_sidelobes,strp_cfs[*,*,*,i],b2dcfs[*,*,i],fght,fcen,fhpbw
            a[i].fit.slCoef    = fght/b2dcfs[2,0,i]
        endelse
        a[i].fit.etaMb         = b2dcfs[14,0,i];main beam efficiency
        a[i].fit.etaSl         = b2dcfs[15,0,i];sidelobe  efficiency
        if (a[i].fit.etaMb lt 0.) and (a[i].srcflux gt 0.) then  begin
            a[i].fit.etaMb= a[i].fit.etaMb/(-a[i].srcflux)
        endif
        if (a[i].fit.etaSl lt 0.) and (a[i].srcflux gt 0.) then begin
            a[i].fit.etaSl= a[i].fit.etaSl/(-a[i].srcflux)
        endif
;
;           fits to phase=a + B(freq-cfr) [0,1]= [a,b]
;
        a[i].fit.calPhase      = hdr1info[20:21,i];calPhase vs freqs Rd/Mhz
        a[i].fit.calPhase_err  = hdr1info[22:23,i];error in [a,b]
        a[i].fit.srcPhase      = hdr1info[24:25,i];calPhase vs freqs Rd/Mhz
        a[i].fit.srcPhase_err  = hdr1info[26:27,i];error in [a,b]
;
;       now the polarization info,1,2,3 are fitQ,fitU,fitV
        fp=replicate({muellerfitpol},3)
;    
        for j=1,3 do begin
            fp[j-1].offset     =b2dcfs[10+j*10+0,0,i]; zero offset kelvins 
            fp[j-1].offset_err =b2dcfs[10+j*10+0,1,i]; zero offset kelvins 
            fp[j-1].doffDza    =b2dcfs[10+j*10+1,0,i]; kelv/deg
            fp[j-1].doffDza_err=b2dcfs[10+j*10+1,1,i]; kelv/deg
            fp[j-1].src        =b2dcfs[10+j*10+2,0,i]/a[i].fit.tsrc;fract of I 
            fp[j-1].src_err    =b2dcfs[10+j*10+2,1,i]/a[i].fit.tsrc;fract of I
            fp[j-1].squintAmp  =b2dcfs[10+j*10+3,0,i];squint amplitude arcmin
            fp[j-1].squintAmp_err=b2dcfs[10+j*10+3,1,i];squint amplitude arcmin
            fp[j-1].squintPA   =b2dcfs[10+j*10+4,0,i];squint position angle 
                                                  ;(az/za sys) deg
            fp[j-1].squintPA_err=b2dcfs[10+j*10+4,1,i];
            fp[j-1].squashAmp  =b2dcfs[10+j*10+5,0,i];squash amplitude 
                                                      ;arcmin hpbw units
            fp[j-1].squashAmp_err=b2dcfs[10+j*10+5,1,i];error
            fp[j-1].squashPA   =b2dcfs[10+j*10+6,0,i];squash position angle 
                                                      ;(az/za sys) deg
            fp[j-1].squashPA_err=b2dcfs[10+j*10+6,1,i];error
        endfor
        a[i].fitQ=fp[0]
        a[i].fitU=fp[1]
        a[i].fitV=fp[2]
        polSrcSq= (a[i].fitq.src^2 + a[i].fitu.src^2)
        a[i].polSrc=sqrt(polSrcSq)
        a[i].polSrc_err=sqrt($
         (a[i].fitq.src^2 * a[i].fitq.src_err^2 + $
          a[i].fitu.src^2 * a[i].fitu.src_err^2) / polSrcSq)

        a[i].paSrc=modanglem(!radeg * .5 *atan(a[i].fitu.src,a[i].fitq.src))

        a[i].paSrc_err=!radeg*.5*sqrt( $
         (a[i].fitq.src^2 * a[i].fitu.src_err^2 + $
          a[i].fitu.src^2 * a[i].fitq.src_err^2) / (polSrcSq^2))
;
;   mueller matric correctio parameters if applied
;
        if a[i].mmcor ne 0 then begin
            a[i].mmparm.deltag =hdr1info[14,i]  ;
            a[i].mmparm.epsilon=hdr1info[15,i]  ;
            a[i].mmparm.alpha  =hdr1info[16,i]  ;
            a[i].mmparm.phi    =hdr1info[17,i]  ;
            a[i].mmparm.chi    =hdr1info[18,i]  ;
            a[i].mmparm.psi    =hdr1info[19,i]  ;
        endif

    endfor
;
;   get rid of entries with Tsys < 20 (10deg K)
;
    ind=where(a.fit.tsys ge 20.,count)
    if count le 0 then return,''
    if count lt numpat then begin
            a=temporary(a[ind])
            numpat=count
    endif
    nrcv=n_elements(rcvnum)
    if (nrcv eq 1) then begin
        if (rcvnum eq 0) then nrcv=0 
    endif
            
    case nrcv of 
        0 : count=n_elements(a) 
        1 : begin
               ind=where(a.rcvnum eq rcvnum[0],count) 
               if count gt 0 then a=a[ind]
            end
        2 : begin
                ind=where((a.rcvnum eq rcvnum[0]) or $
                          (a.rcvnum eq rcvnum[1]),count)
               if count gt 0 then a=a[ind]
            end
        3 : begin
                ind=where((a.rcvnum eq rcvnum[0])  or  $
                      (a.rcvnum eq rcvnum[1])  or $
                      (a.rcvnum eq rcvnum[2]),count)
               if count gt 0 then a=a[ind]
            end
        4 : begin
                ind=where((a.rcvnum eq rcvnum[0])  or  $
                      (a.rcvnum eq rcvnum[1])  or $
                      (a.rcvnum eq rcvnum[2])  or $
                      (a.rcvnum eq rcvnum[3]),count)
               if count gt 0 then a=a[ind]
            end
        5 : begin 
                ind=wher((a.rcvnum eq rcvnum[0])  or  $
                      (a.rcvnum eq rcvnum[1])  or $
                      (a.rcvnum eq rcvnum[2])  or $
                      (a.rcvnum eq rcvnum[3])  or $
                      (a.rcvnum eq rcvnum[4]),count)
               if count gt 0 then a=a[ind]
            end
       else: message,'too many receiver nums requested'
    endcase
    if count eq 0 then return,''
    return,a
end
