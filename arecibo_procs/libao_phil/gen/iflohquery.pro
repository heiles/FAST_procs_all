;*************************************************************************
; ifloquery - query bitmasks from iflo header. functions input
;             iflo header and return 1,0 for true,false
;
;*************************************************************************
;+
;NAME:
;iflohrfnum - return the receiver # for this record
;SYNTAX: istat=iflohrfnum(iflohdr,hdrpnt=hdrpnt)  
;ARGS:
;       iflohdr[]:{hdriflo}   .. iflo portion of header.
;RETURNS:
;       istat: int 1-16 receiver number.
;DESCRIPTION:
;   Return the receiver number used for this record. see 
;helpdt feeds (in sunos) for a list of receiver numbers.
;if iflohdr is an array than an array of rfnums will be returned.
;-  
function iflohrfnum,ifloh ,hdrpnt=hdrpnt
    on_error,1
    if keyword_set(hdrpnt) then begin
        if not pnthgrmaster(hdrpnt[0]) then return,100
    endif
    return, ishft(ifloh.if1.st1,-27) and '1f'XL
;   return, ishft((ifloh.if1.st1 and 'f8000000'XUL),-27)
end
;*************************************************************************
;+
;NAME:
;ifloh10gchybrid - return true if 10 ghz hybrid in use
;SYNTAX: istat=ifloh10gchybrid(iflohdr)  
;ARGS:
;       iflohdr:{hdriflo}   .. iflo portion of header.
;RETURNS:
;       istat: int 0 hybrid out, 1 hybrid in use
;DESCRIPTION:
;   Return 1 if the hybrid in the 10 ghz upconverter is in use.
;-  
function ifloh10gchybrid,ifloh 
    on_error,1
    ifnum    = ishft(ifloh.if1.st1,-24) and '3'XL
    hybridin = ishft(ifloh.if1.st1,-23) and '1'XL
;   return, (ifnum eq 4) and (hybridin eq 1)
end
;*************************************************************************
;+
;NAME:
;iflohcaltype - return the type of cal used.
;SYNTAX: istat=iflohcaltype(iflohdr)    
;ARGS:
;       iflohdr[]:{hdriflo}   .. iflo portion of header.
;RETURNS:
;       istat: int 0-7 setting for caltype.
;DESCRIPTION:
;   Return the setting of the caltype when this record was written.
;the values are:
; 0  - low correlated    cal (1 diode)
; 1  - high correlated   cal (1 diode)
; 2  - low crossed over  cal (2 diodes)
; 3  - high crossed over cal (2 diodes)
; 4  - low uncorrelated  cal (2 diodes)
; 5  - high uncorrelated cal (2 diodes)
; 6  - low  correlated 90 deg phase shift cal (1 diode)
; 7  - high correlated 90 deg phase shift cal (1 diode)
;   This is the setting of the cal switch. It does not mean that
;this is a cal record.
;EXAMPLE:
;   If you have read in a correlator record:
;   print,corget(lun,b) 
;   istat=iflohcaltype(b.b1.h.iflo)
;   will return the caltype in istat.
;   If iflohdr is an array then an array of ints will be returned each with a
;   cal type.
;SEE ALSO:
;chkcalonoff
;-
function iflohcaltype,ifloh
;
;   return caltype 0..7
;   
    on_error,1
    return, ishft((ifloh.if1.st2 and '0f000000'XL),-24)
end
;*************************************************************************
;+
;NAME:
;iflohlbwpol - check if hybrid used on lband wide.
;SYNTAX: istat=iflohlbwpol(iflohdr) 
;ARGS:
;       iflohdr[]:{hdriflo}
;RETURNS:
;       istat: int 1 circular pol hybrid in, 0 linear pol hybrid out.
;DESCRIPTION:
;   The lband wide receiver has an OMT that provides linear
;polarization. After the dewar there is a switchable hybrid that
;converts from linear to circular. You need to know this setting for
;lbw when you are using the cal values since the cals are injected as 
;linear and are averaged if the hybrid is inserted.
;EXAMPLE:
;   istat=corget(lun,b)
;   istat=iflohlbwpol(b.b1.h.iflo)
;
;NOTE: If iflohdr is an array, then an array of ints either 1 or 0.
;-
function iflohlbwpol,ifloh
;
;   return caltype 0..7
;   
    on_error,1
    if n_elements(ifloh) gt 1 then begin
        ind=where((iflohrfnum(ifloh) eq 5 )  and $
            ((ifloh.if1.st1 and '00200000'XL) eq 0),count)
        val=intarr(n_elements(ifloh))
        if (count gt 0) then val[ind]=1
        return,val
    endif
    if (iflohrfnum(ifloh[0]) eq 5 ) and $
            ((ifloh[0].if1.st1 and '00200000'XL) eq 0) $
        then return,1
    return,0
end
;*************************************************************************
;+
;NAME:
;iflohstat - decode status words for iflo
;SYNTAX: statInfo=iflohstat(iflohdr)
;ARGS:
;       iflohdr[]:{hdriflo}
;RETURNS:
;       statInfo[]{ifstat} decoded status structure
;DESCRIPTION:
;   The iflo header contains various info that is encoded in bitmaps 
;(if1.st1,if1.st2,if2.st1,if2.st4). This routine decodes these 
;bitmaps and returns them in a structure. The input can be 1 or more
;iflo headers.
; 
;Example:
;   print,corget(lun,b)
;   ifstat=iflohstat(b.b1.h.iflo)
;
;The definition of the structure is:
;            rfnum:  0 ,$;   rcvnum 1 to 16
;           if1num:  0 ,$;   1-300,2-750,3-1500 (2-12)Ghz,4-10000,5strthru
;    hybridIn10Ghz:  0 ,$;   for 10ghz upconverter
;         lo1HiSid:  0 ,$;   1 yes
;        lbwLinPol:  0 ,$;   1 lin, 0 circular
;         syn1rfOn:  0 ,$;   1st lo ,1 yes
;         syn2rfOn:  0 ,$;   sbtx synth,1 yes
;         lbFbA   :  0 ,$;   lbw filters (bit map) 1.. 9
;         lbFbB   :  0 ,$;   lbw filters (bit map) 1.. 9
;         useFiber:  0 ,$;   1 yes
;        calRcvMux:  0 ,$;   rcvNUmber for upstairs cal mux
;        calType  :  0 ,$;   0 Lcorcal,1 Hcorcal,2 Lxcal,3 Hxcal,4lcal,
;;                           5 Hcal,6 L90cal,7 H90cal
;        ac1Pwrsw :  0 ,$;   ac1 strip bits on /off
;        ac2Pwrsw :  0 ,$;   ac2 strip bits on /off
;        xfer1Sw  :  0 ,$;   1 normal, 0 switched
;      sbnShClosed:  0 ,$;   1 closed
;      lo2Hiside  :  0 ,$;   1--> high side. 4 bits
;;
;;   from if2
;;
;      if2inpFreq :  0 ,$;    0 spare,1 300, 2 750, 3 1500
;      vlbafrq2ghz:  0 ,$;    1 2000, 0 750
;          xfer2Sw:  0 ,$;    1 normal, 0 switched
;        blank430 :  0 ,$;    1 blank 0 no. was sbdoppler
;       noiseSrcOn:  0 ,$;    1 yes, 0 no
;      dualPol30If:  0 ,$;    1 2 pol, 0 bands polA
;      vis30MhzGr :  0 ,$;    1 greg, 0 ch
;      calTTlSrc  :  0 ,$;    1 to 8. cal ttl pulse source
;      pwrMetToIF :  0 ,$;    1 yes, 0 to front panel
;        useAlfa  :  0 ,$;    1 using alfa, 0 no
;        sigSrc   :  0 ,$;    1 0=gr,1=ch,2=noise
;      if2Stat4[4]: 
;             synDest:   0 ,$;    0-frontpanel,1-260to30conv,2-vlba/sb,3-mixers
;            mixerCfr:   0 ,$;    0-750,1-1250,2-1500,3-1750
;           ampInpSrc:   0 ,$;    0, 1-mixers,2-heliax,3=300Mhz IF
;          ampExtMask:   0        bit mask 7 outputs. 1->extinp, 0 from
;-
function iflohstat,iflohU
;
;
;       for the four separate output stages (mixers) of the 2nd if.
;
    a={if2Stat4,$
         synDest:   0 ,$;    0-frontpanel,1-260to30conv,2-vlba/sb,3-mixers
        mixerCfr:   0 ,$;    0-750,1-1250,2-1500,3-1750
       ampInpSrc:   0 ,$;    0, 1-mixers,2-heliax,3=300Mhz IF
      ampExtMask:   0}   ;    bit mask 7 outputs. 1->extinp, 0 from iflo

    a={ifstat, $
            rfnum:  0 ,$;   rcvnum 1 to 16 
           if1num:  0 ,$;   1-300,2-750,3-1500 (2-12)Ghz,4-10000,5strthru
    hybridIn10Ghz:  0 ,$;   for 10ghz upconverter
         lo1HiSid:  0 ,$;    1 yes
        lbwLinPol:  0 ,$;    1 lin, 0 circular
         syn1rfOn:  0 ,$;    1st lo ,1 yes
         syn2rfOn:  0 ,$;    sbtx synth,1 yes
         lbFbA   :  0 ,$;    lbw filters (bit map) 1.. 9
         lbFbB   :  0 ,$;    lbw filters (bit map) 1.. 9
         useFiber:  0 ,$;    1 yes

        calRcvMux:  0 ,$;    rcvNUmber for upstairs cal mux
        calType  :  0 ,$;    0 Lcorcal,1 Hcorcal,2 Lxcal,3 Hxcal,4lcal,
;                            5 Hcal,6 L90cal,7 H90cal
        ac1Pwrsw :  0 ,$;    ac1 strip bits on /off
        ac2Pwrsw :  0 ,$;    ac2 strip bits on /off
        xfer1Sw  :  0 ,$;    1 normal, 0 switched
      sbnShClosed:  0 ,$;    1 closed
      lo2Hiside  :  0 ,$;    1--> high side. 4 bits
      shClosed   :  0 ,$;    1--> non-sband  sband shutter closed
      cbLinPol   :  0 ,$;    1-> cband linear, 0->cband circular
       alfaFb    :  0 ,$;    0 wb, 1-filter in (100 Mhz)*/
       if750nb   :  0 ,$;    1--> if1 750 narrow band filter*/
       if2ghzwb  :  0 ,$;    1--> 2_12 ghz if wide band (2ghz)*/
       tilt      :  0 ,$;    1 mon tilt, 0 montemp*/
;
;   from if2
;
      if2inpFreq :  0 ,$;    0 spare,1 300, 2 750, 3 1500
      vlbafrq2ghz:  0 ,$;    1 2000, 0 750
          xfer2Sw:  0 ,$;    1 normal, 0 switched
        blank430 :  0 ,$;    1 if blank on, 0 off
       noiseSrcOn:  0 ,$;    1 yes, 0 no
      dualPol30If:  0 ,$;    1 2 pol, 0 bands polA
      vis30MhzGr :  0 ,$;    1 greg, 0 ch
      calTTlSrc  :  0 ,$;    1 to 8. cal ttl pulse source
      pwrMetToIF :  0 ,$;    1 yes, 0 to front panel
        useAlfa  :  0 ,$;    1 using alfa, 0 no
        sigSrc   :  0 ,$;    1 0=gr,1=ch,2=noise
        if2Stat4 : replicate({if2stat4},4)}

;
    on_error,1
    nhdr=n_elements(iflohu)
    ifloh=reform(iflohu,nhdr)
    ifstat=replicate({ifstat},nhdr)
    if nhdr gt 1 then begin
        ifstat.rfnum =reform(iflohrfnum(ifloh),nhdr)
    endif else begin
        ifstat.rfnum =iflohrfnum(ifloh)
    endelse
    ifstat.if1num       =ishft(ifloh.if1.st1,-24) and '7'XL
    ifstat.hybridIn10Ghz=ishft(ifloh.if1.st1,-23) and '1'XL
    ifstat.lo1hiSid     =ishft(ifloh.if1.st1,-22) and '1'XL
    ifstat.lbwLinPol    =ishft(ifloh.if1.st1,-21) and '1'XL
    ifstat.syn1rfOn     =ishft(ifloh.if1.st1,-20) and '1'XL
    ifstat.syn2rfOn     =ishft(ifloh.if1.st1,-19) and '1'XL
    ifstat.lbFba        =ishft(ifloh.if1.st1,-10) and '1ff'XL
    ifstat.lbFbb        =ishft(ifloh.if1.st1,-1)  and '1ff'XL
    ifstat.useFiber     =ifloh.if1.st1 and 1

    ifstat.calRcvMux    =ishft(ifloh.if1.st2,-28) and 'f'XL
    ifstat.calType      =ishft(ifloh.if1.st2,-24) and 'f'XL
    ifstat.ac1PwrSw     =ishft(ifloh.if1.st2,-20) and 'f'XL
    ifstat.ac2PwrSw     =ishft(ifloh.if1.st2,-16) and 'f'XL
    ifstat.xfer1Sw      =ishft(ifloh.if1.st2,-15) and '1'XL
    ifstat.sbnShClosed  =ishft(ifloh.if1.st2,-12) and '1'XL
    ifstat.lo2HiSide    =ishft(ifloh.if1.st2,-8)  and 'f'XL
    ifstat.shClosed     =ishft(ifloh.if1.st2,-7)  and '1'XL
    ifstat.cbLinPol     =ishft(ifloh.if1.st2,-6)  and '1'XL
    ifstat.alfaFb       =ishft(ifloh.if1.st2,-5)  and '1'XL
;   ifstat.free         =ishft(ifloh.if1.st2,-4)  and '1'XL
    ifstat.if750nb      =ishft(ifloh.if1.st2,-3)  and '1'XL
    ifstat.if2ghzwb     =ishft(ifloh.if1.st2,-2)  and '1'XL
;   ifstat.terAcOn      =ishft(ifloh.if1.st2,-4)  and '1'XL
    ifstat.tilt         =      ifloh.if1.st2      and '1'XL
;
    ifstat.if2inpFreq   =ishft(ifloh.if2.st1,-30)  and '3'XL
    ifstat.vlbaFrq2Ghz  =ishft(ifloh.if2.st1,-29)  and '1'XL
    ifstat.xfer2sw      =ishft(ifloh.if2.st1,-28)  and '1'XL
    ifstat.blank430     =ishft(ifloh.if2.st1,-27)  and '1'XL
    ifstat.noiseSrcOn   =ishft(ifloh.if2.st1,-26)  and '1'XL
    ifstat.dualPol30IF  =ishft(ifloh.if2.st1,-25)  and '1'XL
    ifstat.vis30MhzGr   =ishft(ifloh.if2.st1,-24)  and '1'XL
    ifstat.calTTLSrc    =ishft(ifloh.if2.st1,-20)  and '1'XL
    ifstat.pwrMetToIf   =ishft(ifloh.if2.st1,-19)  and '1'XL
    ifstat.useAlfa      =ishft(ifloh.if2.st1,-18)  and '1'XL
    ifstat.sigSrc       =ishft(ifloh.if2.st1,-16)  and '3'XL
    for i=0,3 do begin
        ifstat.if2Stat4[i].synDest   =ishft(ifloh.if2.st4[i],-30)  and '3'XL
        ifstat.if2Stat4[i].mixerCfr  =ishft(ifloh.if2.st4[i],-28)  and '3'XL
        ifstat.if2Stat4[i].ampInpSrc =ishft(ifloh.if2.st4[i],-26)  and '3'XL
        ifstat.if2Stat4[i].ampExtMask=ishft(ifloh.if2.st4[i],-19)  and '7f'XL
    endfor
    return,ifstat
end
