;+
;NAME:
;atmclp - coded long pulse (ri)
;SYNTAX: istat=atmclp(lun,spcBuf1,spcBuf2,nrec=nrec,baudLen=baudLen,
;                          spclen=spclen,txSmpSkip=txSmpSkip,$
;                          dinfo=dinfo,hdr=hdr,dotm=dotm,tmi=tmi
;ARGS:
;   lun:    int     lun that points at data file
;KEYWORDS:
;    nrec:  long    number of records to process (default is 1000).
;                   warning.. this is the number of records, not ipps
;                   unless ipps/buf = 1.
; baudlen:  float   By default the baudlen is taken from the header. Some
;                   of the datataking files have set the baudlen
;                   equal to the codelength. If this is found then the
;                   baudlen is set by default to 1 usec. You can force the
;                   the baudlen by setting this keyword (the units are usecs).
;spclen  : long     The length of the spectra to do. By default it is
;                   rounded up to the next power of 2.
;txSmpSkip:float    The number of usecs to skip before taking the first
;                   tx sample. This takes in account the filter delay for the
;                   tx samples. The default is 2 usecs.
;dotm     :         if set then do detailed tming.. if not, just do
;                   total times.
;RETURNS:
;spcbuf1[spclen,nhghts]: float   the averaged spectra vs heights for the
;                                first fifo (normally ch1 for dual beam).
;spcbuf2[spclen,nhghts]: float   the averaged spectra vs height if two
;                                fifos were used (normally gr for dual beam).
; dinfo  :  {}      Structure holding info that was used in the computation
;                   (see below)
; hdr    :  {}      header from the first record averaged. 
; tmI    :  {}      Timing info  (see timing info below for a description). If 
;                   dotm=1 then you get detailed info. If not, then just the totals.
;
;DESCRIPTION:
;   Input and process coded long pulse data taken in raw data mode with 
;the radar interface. It will read nrec records (default 1000) starting
;from the current location on disc (pointed to by lun). It will read the
;requested number of records into a buffer (so don't make it too large). It
;will stop reading prematurely if it finds a data record of a different
;type (mracf, power, tp).
;
;   For each ipp the processing step is:
;   1. extract the tx samples using txSmpSkip to determine which
;      tx Sample to start on.
;   2. compute the complex conjugate of these samples.
;   3. for each height:
;       - multiply the data by the code.
;       - zero extend to spclen
;       - fft the data
;       - compute power and accumulate
;       - compute how many samples to skip to get to the next starting
;         height (usually baudlen/sampLen).
;   4. After accumulating divide by the number of accumulations;
;   5. Shift each spectra so that dc is in the center (for a 4096 length
;      xform, shift right by 2048)
;
;   6. fill in the dinfo structure with the info that was used for the
;      computation. Dinfo contaings:
;
;   GWUSEC      FLOAT     0.200000 
;   BAUDLENUSEC FLOAT     1.00000       
;   CODELENGW   LONG      2500
;   NHGHTS      LONG      601
;   HGHTSTEPGW  LONG      5
;   IPPAVGED    LONG      1000
;   SPCLEN      LONG      4096
;   TXSMPSKIP   LONG      10
;   NUMFIFO     INT       2
;
;   7. also return the header from the first ipp used in the variable hdr.
;      Interesting info is in the sps portion of the header (although the
;      baudlen may be incorrect).
;
;WARNING:
;   This routine was tested on one set of data (dual beam, 1 ipp/buf, 5Mhz bw, 1 usec
;buad). The results looked pretty good (ie we saw the plasma line..), but a detailed 
;comparison with the asp version has not been done. 
;
;TIMING INFO:
;
; Timing info can be returned if tmi=tmi keyword is provided. The tmI 
; structure holds times for different parts of the code. Each time
; structure has the number of times the code was timed, the total sum
; and the total sum of squares. The routine printtmI,tmi can be used
; to print this info out.
;    An example output is:
;
;IDL> printtmi,tmi
;tmTot:675.096 read: 3.987 
;
;  CODECONJ Ntot:  1000 tmTot:  0.4328 avgTm0.000433 sig:0.000006
;    CODEM1 Ntot:601000 tmTot: 51.1495 avgTm0.000085 sig:0.000005
;      FFT1 Ntot:601000 tmTot:122.8049 avgTm0.000204 sig:0.000008
;    ACCUM1 Ntot:601000 tmTot:135.5683 avgTm0.000226 sig:0.000006
;    CODEM2 Ntot:601000 tmTot: 51.2731 avgTm0.000085 sig:0.000004
;      FFT2 Ntot:601000 tmTot:122.8776 avgTm0.000204 sig:0.000007
;    ACCUM2 Ntot:601000 tmTot:135.2315 avgTm0.000225 sig:0.000006
;   BUF1TOT Ntot:601000 tmTot:322.3068 avgTm0.000536 sig:0.000013
;   BUF2TOT Ntot:601000 tmTot:322.0795 avgTm0.000536 sig:0.000012
;
; All times are in seconds. the columns are:
;
;totmeasTm  total wall time
;read:      total time for reading data.
;sectionNm  The section of code that was timed.
;Ntot  is how many times this section was timed., 
;tmTot is the total time for this section.
;avgTm is the average time for 1 execution of this code
;sig   is the sigma for the Ntot measurements
;
; The sections are:
; CODECONJ : extract and conjugate the tx samples
; CODEM1   : extract hght data, multiply by code, 0 extend.
;  FFT1    : compute the fft (using fttw)
;  accum1  : compute the power and accumulate
; BUF1TOT  : total time for buf1. includes some data manipulation times
;            not included in the above times
; The xxx2 : same as xxx1 but for the second fifo (if present)
;
;totmeasTm : this is just the sum of the measured times. It does not
;            include the overhead of timing (about 2usecs per call).
;
;
; The example above had 1000 codeconj so 1000 ipps were processed (10 secs
; of data).
; You'll notice that computing the power and accumulating is taking
; longer than the fft. 
; For this computer fftw in C took about 44 usecs for a 1k xform. So it
;should take about 211 usecs for a 4k. It is averaging 204 so there doesn't
;look like there is any speed up time in the fft.
; Code speedup would probably come by writing an external module
;that was passed a tx rec, hght rec, and then it did the fftw and
;power, accumulate, returing the averaged buf. This might give you
; 50% speed up.
;-
;
function atmclp,lun,nrec=nrec,spcBuf1Avg,spcbuf2Avg,baudLen=baudLen,$
            spclen=spclen,txSmpSkip=txSmpSkip,hdr=hdr,dinfo=dinfo,tmI=tmI,$
            dotm=dotm
;
;   time info
;
    forward_function timeit
    a={ nsmp : 0L,$
        sum  : 0D,$
        sumSq: 0D}
    tmHiRes=keyword_set(dotm)
    tmI = {$
            tmTot: 0D, $
            read : 0D, $
            codeConj: a ,$
            codeM1  : a ,$
            fft1    : a ,$
            accum1  : a ,$  
            codeM2  : a ,$
            fft2    : a ,$
            accum2  : a ,$  
            buf1tot : a ,$
            buf2tot : a }
    tmI.tmTot=systime(1)

    txUsecSkipDef=2.            ; if not specified, skip 2 usecs from start
    baudLenDef=1.               ; in case not set in hdr correctly and no inp 
    baudLenL=0.                 ; local copy baudlen
    if n_elements(nrec) eq 0 then nrec=1000L
    if n_elements(baudLen) ne 0 then baudLenL=baudLen
;
;   read the data, 1 rec to get ipps/rec then rest of the records
;   
    rectype='rclp'              ; want codelp rawdat data
    now=sysTime(1)
    istat=atmget(lun,d,/search,nrec=nrec,rectype=rectype)
    tmI.read=sysTime(1) - now
    if istat le 0 then return,istat     ; eof or error
    nread=n_elements(d)         ; how many recs we got 
;
;   header info
;
    if arg_present(hdr) then hdr=d[0].h
    spipp  =d[0].h.ri.smppairipp
    ippsbuf=d[0].h.ri.ippsperbuf
    baudlenUsec=(baudLenL eq 0.)?d[0].h.sps.baudlen:baudLenL; they overrode it?
    gwUsec=d[0].h.sps.gw
    numFifo=(d[0].h.ri.fifonum eq 12)? 2:1
;
    codeLenUsec=d[0].h.sps.codelenusec
    codeLenGw  =round(codeLenUsec/gwUsec)
    smpInTx    =d[0].h.sps.smpInTxPulse  ; includes extra samples
    if (codeLenUsec eq baudlenUsec) then baudLenUsec=baudLenDef
    codelenBauds=round(codeLenUsec/baudlenUsec)
;
;    txSkip about 2 usecs in gw samples or at least 1 sample
;
    txSmpSkipL=(n_elements(txSmpSkip) ne 0)?txSmpSkip:$
                                    round(txUsecSkipDef/gwUsec) > 1
;
;   round spectr up to next power of 2 if they didn't request one
;
    if n_elements(spclen) eq 0 then begin
        pwr2=long(alog10(codeLenGw)/alog10(2.))
        if 2.^pwr2 lt codeLenGw then pwr2=pwr2+1L
        spcLen=2L^pwr2
    endif
;
;    grab the tx samples we want
;
    txInd1=txSmpSkipL       ; first tx smp to use
    txInd2=(txInd1 + codeLenGw - 1) < (smpInTx - 1L)    ; smaller of the 2
    codeLenGw=txInd2-txInd1+1L                  ; we actually used

    hghtStep=round(baudlenUsec/gwUsec)          ;independant hght samples
    ndataSmp=d[0].h.sps.rcvwin[0].numsamples
    nhghts=(ndataSmp-codeLenGw)/hghtStep + 1L

    spcBuf1Avg                     =fltarr(spcLen,nhghts)
    if numFifo eq 2 then spcBuf2Avg=fltarr(spcLen,nhghts)
    spcCmpBuf                      =complexarr(spcLen) ;cmp spectra here,0 fills
    spcOutBuf                      =fltarr(spcLen);compute spectra here,0 fills
    bw=1./gwUsec
;
;   now loop over records
;
    nd1=0L
    d1nd1=0L
    codeLenGw_m1=codeLenGw -1L
    for iavg=0L,nread - 1 do begin    &$
            if (iavg mod 10) eq 0 then print,'rec:',iavg
;
;       loop over ipps in buf
;
        for i=0,ippsbuf-1 do begin    &$
            ic=spipp*i                &$;start code ipp in databuf
            ih=ic +  smpintx          &$;start height ipp in databuf

            now=sysTime(1)
            codeDat=conj(d[iavg].d1[ic+txInd1:ic+txInd2]) &$
            tmI.codeConj=timeit(sysTime(1)-now,tmI.codeConj)
;
;           loop over heights
;
            d1=d[iavg].d1[ih:ih+ndatasmp-1l]
            d2=d[iavg].d2[ih:ih+ndatasmp-1L]

            ih2=0L
            if tmHiRes then begin
                for ihght=0,nhghts-1 do begin &$
                    tmbuf1=sysTime(1)
                    spcCmpBuf[0:codeLenGw-1]=d1[ih2:ih2+codeLenGw_m1]*$
                                          codeDat &$
                    tmI.codeM1=timeit(sysTime(1)-tmbuf1,tmI.codeM1)
                    now=sysTime(1)
                    spcOutBuf=fftw(spcCmpBuf) &$
                    tmI.fft1 =timeit(sysTime(1)-now,tmI.fft1)
                    now=sysTime(1)
                    spcBuf1Avg[*,ihght]+=$
                        float(spcOutBuf)^2+imaginary(spcoutBuf)^2
                    done=systime(1)
                    tmI.accum1 =timeit(done-now,tmI.accum1)
                    tmI.buf1tot=timeit(done-tmbuf1,tmI.buf1tot)

                    if numFifo eq 2 then begin
                        tmbuf2=sysTime(1)
                        spcCmpBuf[0:codeLenGw-1]=d2[ih2:ih2+codeLenGw_m1]*$
                                          codeDat  &$
                        tmI.codeM2=timeit(sysTime(1)-tmbuf2,tmI.codeM2)
                        now=sysTime(1)
                        spcOutBuf=fftw(spcCmpBuf) &$
                        tmI.fft2=timeit(sysTime(1)-now,tmI.fft2)
                        now=sysTime(1)
                        spcBuf2Avg[*,ihght]+=$
                            float(spcOutBuf)^2+imaginary(spcoutBuf)^2
                        done=systime(1)
                        tmI.accum2 =timeit(done-now,tmI.accum2)
                        tmI.buf2tot=timeit(done-tmbuf2,tmI.buf2tot)
                    endif
                    ih2=ih2+hghtStep &$
                endfor  ; height loop
;

            endif else begin
                for ihght=0,nhghts-1 do begin &$
                    spcCmpBuf[0:codeLenGw-1]=d1[ih2:ih2+codeLenGw_m1]*$
                                          codeDat &$
                    spcOutBuf=fftw(spcCmpBuf) &$
                    spcBuf1Avg[*,ihght]+=$
                        float(spcOutBuf)^2+imaginary(spcoutBuf)^2
                    if numFifo eq 2 then begin
                        spcCmpBuf[0:codeLenGw-1]=d2[ih2:ih2+codeLenGw_m1]*$
                                          codeDat  &$
                        spcOutBuf=fftw(spcCmpBuf) &$
                        spcBuf2Avg[*,ihght]+=$
                            float(spcOutBuf)^2+imaginary(spcoutBuf)^2
                    endif
                    ih2=ih2+hghtStep &$
                endfor  ; height loop
            endelse
        endfor      ; ipp buf loop
    endfor          ; rec loop
;
;   put spectra in the center
; 
    spcBuf1Avg=shift(spcBuf1Avg/(nread*ippsbuf*1.),spclen/2)
    if numfifo eq 2 then  $
        spcBuf2Avg=shift(spcBuf2Avg/(nread*ippsbuf*1.),spclen/2)
;
;   return info structure used
;
    dinfo={ $
        gwUsec     : gwUsec,$
        baudLenUsec: baudLenUsec,$
        codeLenGw  : codeLenGw,$
        nhghts     : nhghts,$
        hghtStepGw : hghtStep,$
        ippAvged   : nread*ippsbuf,$
        spcLen     : spclen,$
        txSmpSkip  : txSmpSkipL,$
        numFifo    : numFifo ,$
          bwMhz   : bw}
    tmI.tmTot=systime(1) - tmI.tmTot
    return,nread
end

function timeit,dif,a
        a.nsmp =a.nsmp+1
        a.sum  =a.sum+dif
        a.sumsq=a.sumsq + dif*dif
    return,a
end
pro  printtmi,tmI
    lab=string(format='("tmTot:",f7.3," read:",f6.3)',$
                    tmI.tmtot,tmI.read)
    print,lab
    nms=tag_names(tmI)
    measTot=0.
    for i=2,n_elements(nms)-1 do begin
        a=tmI.(i)
        nsmp=a.nsmp
        if nsmp eq 0 then begin
            avg=0D
            sumSq=0D
            nsmp=1 
        endif else begin
            avg =a.sum/nsmp
            sumSq=a.sumsq
        endelse
        lab=string(format=$
        '(a10," Ntot:",i6," tmTot:",f8.4," avgTm",f8.6," sig:",f8.6)',$
            nms[i],nsmp,a.sum,avg,sqrt(sumSq/nsmp - avg*avg))
        print,lab
        if (i le n_elements(nms)-3) then measTot=measTot+a.sum
    endfor
    print,format='("totmeasTm:",f8.3)',measTot
    return
end

