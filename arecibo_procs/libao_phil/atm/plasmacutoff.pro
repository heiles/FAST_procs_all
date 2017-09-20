;+
;NAME:
;plasmacutoff - process single pulse plasma cuttoff data
;SYNTAX: istat=plasmacuttof(lun,spc,spcH,spcN,spcLen=spcLen,toavg=toavg,$
;                           freq=freq,flip=flip,nonoise=nonoise,hdr=hdr)
;ARGS:
;   lun:    int file descriptor of file to read
;
;KEYWORDS:
;  spcLen: long length of transform to do. Default is 2048.
;               there must be at least this many samples of data and/or noise
;   toavg: long number of ipps to average default is 10000
;    flip:      if set then flip the frequency order of the spectra on return.
; nonoise:      if set then do not process the noise samples (even if they are
;               present).
;
;RETURNS:
; istat     : int    1 returned ok
;                    0 hit eof
;                    lt 0 trouble reading a record (bad header, etc)
; spc[m,n,l]: float  height spectra with noise subtraction.
;                    m=length of spectra
;                    n=number of height spectra computed
;                    l=number of antennas: 1 if 1 antenna, 
;                                          2 if both antennas (dome is 2nd)
;spcH[m,n,l]: float  height spectra without noise subtraction.
;spcN[m,l]  : float  noise spectra
;freq[m]    : float  frequency of the spectra in Mhz.
;    hdr    : {hdr}  header from first record read
;
;DESCRIPTION:
;   Input and process single pulse plasma cutoff data. Each record should
;contain only 1 ipp of data. The windows in the ipp can be:
;
; txSamples   - skipped
; hghtSamples - must be at least spcLen samples. The routine will compute
;               hghtSamples/spcLen height Spectra
;
; noiseSamples- if present (and nonoise is not set) then there must be
;               at least spclen noise samples. The routine will compute
;               (and average together) noiseSamples/spclen noise spectra
;               for each ipp.
;
;   The routine will read toavg ipps. For each ipp it will compute the
;height spectra and an average noise spectra. It then averages these 
;spectra over toavg ipp's. 
;
;   The height spectra with noise removal is returned in:
;   spc[spcLen,numHghtSpc,numAntennas]. 
;
;   The height spectra with no noise removed is returned in:
;   spcH[spcLen,numHghtSpc,numAntennas]. 
;
;   The noise spectra are returned in :
;   spcN[spcLen,numAntennas]. 
;
;   If the sps buffer has two receive windows, then the 2nd window is taken
;as the noise samples. If only one receive window is present, no noise
;subtraction is done.
;
;   The flip keyword will flip the frequency order of all of the spectra.
;If BBM sine (top) goes to digitizer (left) then you probably need 
;to set /flip.
;
;EXAMPLE:
;
;idl
;@phil
;@atminit
;openr,lun,'/share/aeron5/24Jul03.070',/get_lun
;   .. avg 10000 ipps
;
;istat=plasmacutoff(lun,spc,spch,spcN,spclen=2048,freq=freq,/flip)
;ver,0,5e8
;hor 
;; plot the ch spectra 
;stripsxy,freq,spcar[*,*,0],0,1e8,/step
;; over plot the dome spectra 
;stripsxy,freq,spcar[*,*,1],0,1e8,/step,/over
;
;NOTE:
;   The routine will not work:
;   1. if there are more than 1 ipp per record.
;   2. if there are fewer than spclen data or noise samples
;-
function plasmacutoff,lun,spcAr,spcArH,spcArN,toavg=toavg,spclen=spclen,$
        nonoise=nonoise,flip=flip,freq=freq,hdr=hdr
;
; assume ippbuf 1
;
;
    if not keyword_set(toavg)  then toavg=10000L
    if not keyword_set(spclen) then spclen=2048L
;
;   get the first rec
;
    istat=searchhdr(lun)
    point_lun,-lun,curpos
    istat=atmget(lun,d)
    if istat ne 1 then goto,errout
    point_lun,lun,curpos
    hdr=d.h
    gw      =d.h.ri.gw          ; in usecs
    spipp  =d.h.ri.smppairipp
    ippBuf =d.h.ri.ippsPerBuf
    if ippbuf ne 1 then message,'error: routine only works for ippbuf eq 1'
    fifo   =d.h.ri.fifonum
    nrecs  =toavg/ippBuf
    if (nrecs*ippBuf)  lt toavg then nrecs=nrecs+1
    numfifo=(fifo eq 12) ? 2 : 1
    numTxSmp=d.h.sps.smpinTxPulse
    nSampHght  =d.h.sps.rcvwin[0].numSamples
    if d.h.sps.numrcvwin gt 1 then begin
        nSampNoise =d.h.sps.rcvwin[1].numSamples
    endif else begin
        nSampNoise =0
    endelse
    doNoise=(nSampNoise gt 0) and (not keyword_set(nonoise))
;
;   figure out the number of data and noise spectra. see if we have to
;   add any zeros
;
    nSpcHght=nSampHght/spclen
    if nSpcHght eq 0 then message,'Not enough samples in window 1 for fft'
;
;   they asked for xform longer then length, zero pad
;
    if doNoise then begin
        nSpcNoise =nSampNoise/spclen
        if nSpcNoise eq 0 then message,$
            'Not enough samples in window 2 for 1 noise fft'
    endif
;
;    allocate the arrays
;
    if numFifo eq 2 then begin
        spcArH=(nspcHght eq 1)? fltarr(spclen,2):fltarr(spclen,nspcHght,2)
        if doNoise then spcArN=fltarr(spclen,2) 
    endif else begin
        spcArH=(nspcHght eq 1)? fltarr(spclen):fltarr(spclen,nspcHght)
        if doNoise then spcArN=fltarr(spclen) 
    endelse
;
;   loop reading 100 recs at a time
;
    recPerRead=(100 <    nrecs)
    numReads    =nrecs/recPerRead
    lastRead=recPerRead
    if numReads*recPerRead  ne nrecs then begin
        lastRead=nrecs-recPerRead*numReads
        numReads=numReads+1
    endif

    noiseSum=0L
    spcSum  =0L
    for i=0,numReads-1 do begin
        print,i
        reqRec=(i eq (numReads -1))?lastRead:recPerRead
        istat =atmget(lun,d,nrec=reqRec,/search)
        if istat lt 1 then break
        gotRec=n_elements(d)
        y1h=reform(d.d1[numTxSmp:numTxSmp+spclen*nSpcHght-1L],spclen,$
                nspcHght,gotRec)
        if numfifo eq 2 then $
            y2h=reform(d.d2[numTxSmp:numTxSmp+spclen*nSpcHght-1L],spclen,$
                nspcHght,gotRec)

        if doNoise then begin
            ii=numTxSmp+nSampHght
            y1N=reform(d.d1[ii:ii+nSpcNoise*spclen-1],spclen,$
                nSpcNoise,gotRec)
            if numFifo eq 2 then $
                y2N=reform(d.d2[ii:ii+nSpcNoise*spclen-1],spclen,$
                    nSpcNoise,gotRec)
        endif

        for j=0,gotRec-1 do begin
            for k=0,nSpcHght-1 do begin
                spcArH[*,k,0]=spcArH[*,k,0] + abs(fft(y1H[*,k,j],spclen))^2 
                if numFifo eq 2 then $
                    spcArH[*,k,1]=spcArH[*,k,1] + abs(fft(y2H[*,k,j],spclen))^2 
            endfor
            spcSum=spcSum+1
            if doNoise then begin
                for k=0,nSpcNoise-1 do begin
                    spcArN[*,0]=spcArN[*,0]     + abs(fft(y1N[*,k,j],spclen))^2 
                    noiseSum=noiseSum+1L
                    if numFifo eq 2 then $
                        spcArN[*,1]=spcArN[*,1] + abs(fft(y2N[*,k,j],spclen))^2 
                endfor
            endif
        endfor   ; 1 read
    endfor   ;     all reads
    if spcSum eq 0 then goto,errout
    spcArH=spcArH/spcSum
    for i=0,nSpcHght-1 do begin &$
        if keyword_set(flip) then begin &$
            spcArH[*,i,0]=reverse(shift(spcArH[*,i,0],spclen/2)) &$
            if numFifo eq 2 then spcArH[*,i,1]=$
                    reverse(shift(spcArH[*,i,1],spclen/2)) &$
        endif else begin &$
            spcArH[*,i,0]=shift(spcArH[*,i,0],spclen/2) &$
            if numFifo eq 2 then spcArH[*,i,1]=shift(spcArH[*,i,1],spclen/2)&$
        endelse &$
    endfor
    spcAr=spcArH
    if donoise then begin &$
        spcArN=spcArN/noiseSum &$
        if keyword_set(flip) then begin &$
            spcArN[*,0]=reverse(shift(spcArN[*,0],spclen/2)) &$
            if numFifo eq 2 then spcArN[*,1]=reverse(shift(spcArN[*,1],$
                    spclen/2)) &$
        endif else begin
            spcArN[*,0]=shift(spcArN[*,0],spclen/2) &$
            if numFifo eq 2 then spcArN[*,1]=shift(spcArN[*,1],spclen/2) &$
        endelse

        for i=0,nSpcHght-1 do begin &$
            spcAr[*,i,0]= spcAr[*,i,0] - spcArN[*,0] &$
            if numFifo eq 2 then spcAr[*,i,1]= spcAr[*,i,1]-spcArN[*,1] &$
        endfor &$
    endif
    freq=(findgen(spclen)/spclen - .5)/(gw)
    if keyword_set(flip) then freq=reverse(freq)* (-1.)
    return,1
errout:
    print,'error:',istat,' from atmget'
    return,0
end
