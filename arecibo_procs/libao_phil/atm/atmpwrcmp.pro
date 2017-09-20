;+
;NAME:
;atmpwrcmp - decode/compute power profile
;SYNTAX: istat=atmpwrcmp(d,dcdpwr,usecal=usecal)
;ARGS:
;   d[n] :{rd}   array of rawdat power profile data.
;KEYWORDS: 
;  usecal:       if set then decode and return the cal with the data.
;
;RETURNS:
;   istat   :int    1 ok, 0 error
;   dcdpwr[m]:float  array holding decoded power data starting at first
;                    height (d.h.sps.rcvwin[0].startusec)
;DESCRIPTION:
;   Decode and compute power for power profile data using the barker
;code or the 88 baud length code. The decoding is done with the 
;theoretical codes (not the transmitter samples). All of the
;ipps in d[n] are averaged together. By default the routine
;decodes only the first receive window. If /usecal is included, then
;the cal receive window (if it exists) will be part of the decoding.
;
;EXAMPLE:
;   usedome=0
;   istat=atmget(lun,d,nrecs=1000,nrectype='rpwrb')
;   istat=atmcmppwr(d,dcdpwr,/usecal)
;
;;  figure out how to label the plot
;
;   za=(keyword_set(usedome))?d[0].h.std.grttd/10000. $
;                            :d[0].h.std.chttd/10000.
;   lab=string(format=$
; '("power profile tm:",a," az:",f6.2," scan:",i9)',$
;       fisecmidhms3(d[0].h.std.time),d[0].h.std.azttd*.0001,d[0].h.std.scannumber)
;
;;  compute the height from the range   
;
;   range=(findgen(n_elements(dcdpwr))*d[0].h.sps.gw  + d[0].h.sps.rcvwin[0].startusec)*.15
;   hght =range*cos(za*!dtor)
;    
;   maxhght=(long(hght[n_elements(hght)-1L])+49L)/50L *50L
;   maxpow=max(dcdpwr)
;   maxpow=long(maxpow+49)/50l * 50
;   hor,0,maxpow
;   ver,0,maxhght
;   plot,dcdpwr,hght,title=lab,xtitle='power',ytitle='altitude [km]' 
;-
function atmpwrcmp,d,dcdpwr,usecal=usecal
;
    common atmpwr,cmatmpwr_codelen,cmatmpwr_code,cmatmpwr_spccode,$
                  cmatmpwr_fftlen;

    if not keyword_set(cmatmpwr_codelen) then begin
        cmatmpwr_codelen=0
        cmatmpwr_fftlen=0
    endif

    codelen=long(d[0].h.sps.CODELENUSEC/d[0].h.sps.baudLen+.5)
    smpTx  =d[0].h.sps.smpInTxPulse
    smpHght=d[0].h.sps.rcvwin[0].numSamples  ; just use first rcv window
    if keyword_set(usecal) then begin
        if (d[0].h.sps.numrcvwin eq 2) then begin
            smpHght=smpHght+ (d[0].h.sps.rcvwin[1].numsamples)
        endif
    endif
    smp1ipp=d[0].h.ri.smppairipp
    rcvWinStartUsec=d[0].h.sps.rcvwin[0].startusec
    ippsRec=d[0].h.ri.ippsPerBuf
    gw     =d[0].h.sps.gw
    ;
    dcdHghts=smpHght-(codelen-1)
    nrecs=n_elements(d)
    ippToAvg=nrecs*ippsRec
;
;   figure out fftlen to use
;
    ipow2=0
    itemp=smpHght
    done=0
    while (itemp gt 1) do begin &$
        itemp=itemp/2 &$
        ipow2=ipow2+1 &$
    endwhile
    if (2^ipow2) lt smpHght then ipow2=ipow2+1
    fftlen=2^ipow2
;
;   see if we have to remake the xform of the code
;
    if (fftlen ne cmatmpwr_fftlen) or (cmatmpwr_codelen ne codelen) then begin
        case codelen of
            88: cmatmpwr_code =[$
  1.,-1.,-1., 1.,-1.,-1.,-1.,-1.,-1., 1., 1., 1.,-1., 1., 1.,-1.,-1., 1.,-1.,$
  1., 1.,-1.,-1.,-1., 1.,-1.,-1., 1., 1.,-1., 1.,-1., 1., 1., 1., 1.,-1., 1.,$
 -1., 1.,-1., 1., 1., 1.,-1.,-1.,-1.,-1.,-1.,-1., 1.,-1.,-1., 1.,-1., 1.,-1.,$
 -1.,-1.,-1.,-1.,-1., 1.,-1., 1., 1.,-1.,-1., 1., 1., 1.,-1.,-1.,-1., 1.,-1.,$
  1., 1.,-1.,-1., 1., 1., 1.,-1.,-1.,-1., 1.,-1.]
            13: cmatmpwr_code= [1., 1., 1.,1.,1.,-1.,-1.,1.,1.,-1.,1.,-1.,1.]
          else: begin
                    print,'unknown codelen for power:',codel
                    goto,errcode
                end
        endcase
        cmatmpwr_codelen=n_elements(cmatmpwr_code)
        cmatmpwr_spccode=fft([complex(cmatmpwr_code,0),$
                              complexarr(fftlen-codelen)])
        cmatmpwr_fftlen=fftlen
        cmatmpwr_codelen=codelen
    endif
;
;   
    dcdpwr=fltarr(dcdHghts)
    b=complexarr(fftlen,ippToAvg)
    b[0:smpHght-1,*]=(reform(d.d1,smp1Ipp,ippsrec*nrecs))[smpTx:smpTx+smpHght-1,*]
    for i=0L,ippToAvg-1 do begin
        dcdpwr=dcdpwr+ (abs(fft(conj(fft(b[*,i]))*cmatmpwr_spccode))^2)[0:dcdHghts-1]   
    endfor
    dcdpwr=dcdpwr*((cmatmpwr_fftlen*1.)^3/ippToAvg)
    return,1
errcode:
    return,0
end
