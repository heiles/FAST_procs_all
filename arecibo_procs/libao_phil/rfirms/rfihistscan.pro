;+
;NAME:
;rfihistscan - compute rfi for rms spectra. add to histogra.
;SYNTAX: rfihistscan,b,hInfo,htotcnts,hrficnts,hrejcnts,han=han,$
;                   verbose=verbose, wait=wait,badSbc=badSbc
;ARGS:
;       b        : {corget} corget structure containing rms info for a scan.
;                   usually computed from routine corrms().
;       hInfo    : {rfihistInfo} structure telling routine how to bin the 
;                   histogram. User fills in before calling.
;   histAr[nchn,3]: long array containing the histogram (user allocates).
;                  [*,0=total,1=rfi,2=rejected]
;
;   han          : if set, then the input spectra were hanning smoothed
;                  prior to computing the rms.
; badSbc[2,8]    : if a one in a position, then ignore this
;                  sbc,pol... Used to get rid of alfa beams that are bad
;-
;modhistory:
;16sep01 - fractbad is now badchn/totchn before rebinning to histogram
;          resolution. Gives a better measure if we only have a few 
;          histogram bins across the bandpass.
;
pro rfihistscan,b,hInfo,histAr,han=han ,verbose=verbose,wait=wait,$
				badSbc=badSbc
;
; loop over sbc this scan
; if polarization, just use 1st sbc
;  
	if n_elements(badsbc) eq 0 then badSbc=lonarr(2,8)
    bwsinx=1.208            ; sinx/x instead of retangular 
    bwhan =1.5*1.5          ; seems to work. modSpecAnalyz ieeeII pg176
;                             has 1.5 but that may be applying it to the 
;                             voltage
    hanmult=1.
    if keyword_set(han) then  hanmult=bwhan
    if not keyword_set(wait) then wait=0
    nsbc=n_tags(b)
    if b.b1.h.cor.lagconfig eq 10 then nsbc=1
    secs=(b.b1.h.cor.dumpsperinteg * $
        ((b.b1.h.cor.dumplen)*(b.b1.h.cor.masterclkperiod*1d-9)))
	if secs eq 0 then secs=1.			; for now .. for alfa data..
    if verbose then corplot,b
    for sbc=0,nsbc-1 do begin
        a=size(b.(sbc).d)
        npol=a[0]
        nchn=a[1]
        chntoskip=long(nchn*hInfo.edgeFrac)
        chn1st=chntoskip
        chnend=(nchn-chntoskip)-1L
        nchn=chnend-chn1st + 1
;
;       get frequency array for part that we use
;
        frq      =(corfrq(b.(sbc).h))[chn1st:chnend]
;
;       map freq array entries into histogram array
;       frqSt is the center of the bin, remove .5 frqstep to get the left edge.
;
        frqTohInd=long((frq - (hInfo.frqSt-hInfo.frqstp*.5))/hInfo.frqstp + .5)
        if (frqTohInd[0] lt 0) then begin
            ind=where(frqTohInd lt 0)
            frqToHind[ind]=0        ; map to first index
        endif
        if frqTohind[nchn-1L] ge (hInfo.totChn) then begin
            ind=where(frqTohInd ge hInfo.totChn)
            frqToHind[ind]=hInfo.totChn-1L  ; map to last index
        endif
;
;   compute the clipping value for the data
;
        dblnyQuist=((b.(sbc).h.cor.state) and  1L) ne 0
        lev9      =((b.(sbc).h.cor.state) and '10000000'xul) ne 0
        if lev9 then begin
            if (dblnyQuist) then begin
                factor=1.02d        ; this is a guess. 98 %
            endif else begin
                factor=1.04d        ; ditto a guess 96 %
            endelse
        endif else begin            
            if  dblnyQuist then begin
                factor=1.12d        ; 3 level double nyquist
            endif else begin   
                factor=1.23d        ; 3 level normal sampling
            endelse
        endelse
		bw=(b.(sbc).h.cor.bwnum eq 0)?100e6:50e6/(2^(b.(sbc).h.cor.bwnum-1))
        bwchn=bwsinx*hanmult*bw/ $
                (b.(sbc).h.cor.lagsbcout)
;
;       expected sigma. note this uses rectangular channel widths rather
;       than the sin(x)/x .. so the bw should be a little larger..
;
        sigexp=factor/sqrt(bwchn*secs)
        clipVal=sigexp*hInfo.sigmaToClip
        ind=uniq(frqToHind)
        totind=frqToHind[ind]
;
;       loop over number of polarizations 
;
        for i=0,npol-1 do begin
			if badSbc[i,sbc] ne 0 then continue
;
;       find all data channels that are above clipping level
;
            dind=where(b.(sbc).d[chn1st:chnend,i] ge clipVal,cntbad)
            if (cntbad gt 0) then begin
                badind=frqTohInd[dind]
                badind=badind[uniq(badind)]
;               cntbad=n_elements(badind)
            endif
;           stop
;           fractbad=(cntbad*1./n_elements(totind) < 1.)
            fractbad=(cntbad*1./nchn < 1.)
            if verbose then begin
            ln=string(format=$
'("scn:",i9," sbc:",i2," pol:",i2," sigExp,clp:",f6.4,1x,f6.4," bad:",i4," frbad:",f5.2)',$
       b.b1.h.std.scannumber,sbc,i,sigexp,clipVal,cntbad,fractbad)
            print,ln
            endif
            if ( fractbad lt hInfo.rejectFrac) then begin
                histAr[totind,0]=histAr[totind,0]+1L
                if cntbad gt 0 then histAr[badind,1]=histAr[badind,1]+1L
            endif else begin
                histAr[totind,2]=histAr[totind,2]+1L    
            endelse
        endfor
    endfor
    if wait then begin
        print,'xmit to continue'
        ln=' '
        read,ln
    endif
    return
end
