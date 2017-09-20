;+
;NAME:
;pdevsim - simulate pdev compuations.
;SYNTAX: pdevsim,lenfft,toavg,noiseRms,sineAmp,spcAvg,pshift=pshift,$
;                   doplot=doplot,dohist=dohist,nopfb=nopfb
;ARGS:
;   lenfft: long    length of fft to use. needs to be a power of 2.
;     toavg: long    number of spectra to average.
;  noiseRms: float   rms in A/D counts for noise
;  sineAmp:  float  amplitude of sine wave in a/d counts
;KEYWORDS: 
;   pshift: long    bit map telling when to do downshifts in butterfly.
;  nopfb  :         if set then no polyphase filtering
;RETURNS:
;   spcAvg[lenfft] the averaged spectrum with dc in the center (shift(spcavg,lenfft/2))
;DESCRIPTION:
;   simulate the pdev spectrometer polyphase filter bank, fft, and power stages.
;This routine differs from pdev in that it computes spectrum of PolA, not 2*spectrum of PolA
;   Spc
;
;-
pro  pdevsim,lenfft,toavg,noiseRms,sinAmp,spcAvg,pshift=pshift,$
            sinCycles=sinCycles,doplot=doplot,plotstat=plotstat,$
            dohist=dohist,nopfb=nopfb
    common pdevsimrand,seedc
    common colph,decomposedph,colph
;
    if (n_elements(plotstat) eq 0) then plotStat=0
    usePlotStat=plotStat ne 0
    if usePlotStat then begin
        !p.multi=[0,1,4]
        xpl=lindgen(lenfft) - lenfft/2
    endif
;
    if n_elements(doplot) eq 0 then doplot=0
    if n_elements(dohist) eq 0 then dohist=0
    usepfb= keyword_set(nopfb) eq 0
    startShift=6    ; 12 bit a/d -> to upper 12 of 18 bit reg
    rmsReq=noiseRms
    nbfly=round(alog10(lenfft)/alog10(2))
    if n_elements(pshift) eq 0 then begin
        pshift='1ff5'xL
    endif
    seed=(n_elements(seedc) lt 2)?systime(/seconds):seedc
    coefBits=16L
    pfbOvr=4L
    pfbMax=2L^15
    if n_elements(sinCycles) eq 0 then sinCyles=round(lenfft/10.)
    useSin=sinAmp ne 0.
    if useSin then begin
        sgn=(sincycles lt 0)?-1.:1.
        sr=mksin(lenfft,sinCycles)*sinAmp
        si=mksin(lenfft,sinCycles,phase=-.25*sgn)*sinAmp
    endif
;
; get the pfb 
;
    if usepfb then begin
        dir='/share/megs/phil/x101/pdev/mocksw0706/'
        case 1 of  &$
    (lenfft lt 100) : nm=string(format='("pfb.",i2.2,".hamming")',lenfft) &$
    (lenfft lt 1000): nm=string(format='("pfb.",i3.3,".hamming")',lenfft) &$
        else            : nm=string(format='("pfb.",i4.4,".hamming")',lenfft) &$
        endcase
        pfbnm=dir + nm 
;   print,pfbnm
        istat=pdevinppfb(pfbnm,lenfft,pfbfilt)
;
; preload the data
;
        xpfb=lonarr(lenfft,pfbOvr)
        ypfb=lonarr(lenfft,pfbOvr)
        for i=0,pfbOvr-1 do begin
            if usesin then begin
                xpfb[*,i]=round(randomn(seed,lenfft) * rmsReq + sr) &$
                ypfb[*,i]=round(randomn(seed,lenfft) *rmsReq   + si) &$
            endif else begin
                xpfb[*,i]=round(randomn(seed,lenfft) * rmsReq) &$
                ypfb[*,i]=round(randomn(seed,lenfft) *rmsReq ) &$
            endelse
            if rmsReq gt 0 then begin
                a=rms(xpfb[*,i],/quiet) &$
                xpfb[*,i]=round(xpfb[*,i]*(rmsReq/a[1]) )
                a=rms(ypfb[*,i],/quiet) &$
                ypfb[*,i]=round(ypfb[*,i]*(rmsReq/a[1]))
            endif
        endfor
        i1=(lenfft*(pfbOvr-1))      ;; where we insert new data in pfb block
        xpfb=ishft(reform(xpfb,lenfft*pfbOvr),startShift); to upper 12 bits
        ypfb=ishft(reform(ypfb,lenfft*pfbOvr),startShift)
    endif
;
;   print,"x:",xpfb[0:9,0]/64
;   print,"y:",ypfb[0:9,0]/64
;   print,'seed0',seed[0]
    spcAvg=lon64arr(lenfft)
    for i=0L,toAvg-1 do begin
        if usepfb then begin
            xpfb=shift(xpfb,-lenfft)
            ypfb=shift(ypfb,-lenfft)
        endif
        if rmsReq eq 0 then begin
            xx=(round(sr))&$
            yy=(round(si)) &$
        endif else begin
            if usesin then begin
                xx=round(randomn(seed,lenfft) * rmsReq + sr) &$
                yy=round(randomn(seed,lenfft) *rmsReq  + si) &$
            endif else begin
                xx=round(randomn(seed,lenfft) * rmsReq ) &$
                yy=round(randomn(seed,lenfft) *rmsReq  ) &$
            endelse
        endelse
;;          a=rms(xx,/quiet) &$
;;          xx=round(xx*rmsReq/a[1])
        xx=ishft(xx,startShift)
;;          a=rms(yy,/quiet) &$
;;          yy=round(yy*rmsReq/a[1])
        yy=ishft(yy,startShift)
        if usepfb then begin
            xpfb[i1:*]=xx
            ypfb[i1:*]=yy
; apply the filter
;
            xx=total(reform((xpfb*pfbfilt)/pfbMax,lenfft,pfbOvr),2)
            yy=total(reform((ypfb*pfbfilt)/pfbMax,lenfft,pfbOvr),2)
        endif
        if dohist then begin
            a=long(rmsreq)*64L*3L 
            b=histogram(xx,binsize=1,min=-a,max=a,loc=loc)
            ver
            plot,loc,b
            b=histogram(yy,binsize=1,min=-a,max=a,loc=loc)
            oplot,loc,b,col=colph[2]
            print,'xmit to continue, s to stop'
            key=checkkey(/wait)
            if key eq 's' then stop

        endif
        if useplotstat then begin
            a=rms(xx,/quiet)
            b=rms(yy,/quiet)
        endif
        cs=1.7
        fftint,xx,yy,lenfft,bshift=pshift,doplot=doplot,cosar=cosar,sinar=sinar
        spc=(xx*xx + yy*yy)
        spcAvg+=spc
        if (useplotstat) then begin
            if (i mod plotstat) eq 0 then begin
            plot,xx,title='x rms:' + string(a[1]) + ' i:'+ string(i),charsize=cs
            plot,yy,title='y rms:' + string(b[1]),charsize=cs
            a=rms(spc,/quiet)
            tit=string(format='("spc,mean,rms:",f8.1,1x,f8.1)',a)
            plot,xpl,spc,title=tit,charsize=cs
            a=rms(spcAvg,/quiet)
            tit=string(format='("spcAvg,rms:",(f8.3))',a[1]/a[0])
            plot,xpl,spcAvg,title=tit,charsize=cs
            empty
            endif
        endif
    endfor
    spcAvg/=toAvg
    spcAvg=shift(spcAvg,lenfft/2)
    seedc=seed
    return
end
