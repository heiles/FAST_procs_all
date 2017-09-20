;+
;NAME:
; calmfit - fit curves to cal on/off data
;SYNTAX: istat=calmfit(d,nsteps,nloops,fitI,fitIAvg,fitISum,verb=verb,$
;                      bw=bw,indAvgA=indAvgA,indAvgB=indAvgB,$
;                      masktoUseA=masktouseA,masktouseB,avgstop=avgstop,
;                      dopol=dopol, _extra=e,
;ARGS:
;   d[n]: {mcal} : data input from mcalinp. Uses
;                  (spcCalOn - spcCalOff)/spcaloff.
;  nsteps: int   ; number of 100 Mhz steps to move through the entire band
;  nloops: int   ; number of entire band was measured
; fitI[nloops]   :{ }    ; results of the fitting each loop
;      fitIAvg   :{ }    ; fit to the average of the loops
;      fitISum   :{ }    ; summary of the average fit
;
;KEYWORDS:
;       verb     :int    ; passed to corblauto for plotting
;       bw       :float  ; bandwidth in Mhz each measurement (25Mhz)
;      indAvgA[ma]:long   ; indices of nloops to use when averaging polA
;      indAvgB[mb]:long   ; indices of nloops to use when averaging polB
;      maskToUseA[mm,j]:long ;mask array polA for each fit. if j=0 then use
;                            the same mask for each fit.1==> use,0=-> ignore
;      maskToUseB[mm,k]:long ;mask array polB for each fit. if k=0 then use
;                            the same mask for each fit.1==> use,0=-> ignore
;      dopol      : int   if provided then only process the pols specified
;                         by dopol. 0=polA,1=polB. default is both pols
;      avgStop:           if set then stop after plotting each avg
;                         so the user can look at the plot output.
;     _extra:             ; passed to corblauto(). 
;                          deg=deg   (polynomial fit order)
;                          fsin=fins (harmonic fit order)
;DESCRIPTION:
;   mcalinp() inputs a set of calon/calOff -1 spectra. CalMfit will
;fit a function to the spectra covering the entire receiver bandpass. 
;Each entry in d holds 100 Mhz worth of data. nsteps of these will
;cover the entire bandpass and there are nloops copies. Since there can
;be multiple passes through the entrie band, d has dimensions of 
;d[nlags,nsteps,nloops]).
;
;corblauto is used to fit to the spectra calon/caloff-1 for a complete
;pass through the receiver band. The fit is repeated nloops time (once for
;each pass through the band). For each fit the following data is returned:
;
;help,fitI,/st
;** Structure <8445c7c>, 7 tags, length=329324, data length=329324, refs=2:
;   NP              LONG             20480  ; number pnts across band
;   FRQSTP          FLOAT         0.0976562 ; freq step Mhz
;   FRQMIN          FLOAT           4000.00 ; minFreq
;   FRQMAX          FLOAT           6000.00 ; max freq
;   FITI            STRUCT    -> <Anonymous> Array[1] ; fit coef.
;   YFIT            FLOAT     Array[20480, 2]; fit evaluated at freq points
;   MASK            FLOAT     Array[20480, 2]; mask used for fit (non
;                                              zero values).
;
;   A robust average by channel is taken for the nloops through the band. A
;fit to this average spectrum is then done and returned in fitIAvg. By default
;all of the passes through the data are used when computing the average. The
;keywords indAvgA, indAvgB let you specify which passes through the data should
;be included when making the averages.
;
;   fitISum holds summary info for the average:
;** Structure <8438ab4>, 11 tags, length=163896, data length=163896, refs=1:
;   NP              LONG             20480
;   NLAGS           LONG               256
;   NSBC            INT              4
;   NSTEPS          INT             20
;   FRQSTP          FLOAT         0.0976562
;   FRQMIN          FLOAT           4000.00
;   FRQMAX          FLOAT           6000.00
;   NLOOPS          LONG                 7
;   AVGD            FLOAT     Array[20480, 2]
;   USEAVGA         INT       Array[7]
;   USEAVGB         INT       Array[7]
;It also includes the averaged data in .avgD
;
;
;NOTE:  if nloops eq 1 then fitiavg is not returned, since it is  the same
; as fitI. fitISum will be returned.
;-
;history:
; 28sep06 .. if numloops =1 use it
;            if numloops =2 average
;            if numloops =3 robavgbychan
function  calmfit,d,nsteps,nloops,fitI,fitIAvg,fitISum,verb=verb ,_extra=e,$
              bw=bw,indAvgA=indavgA,indAvgB=indAvgB,masktouseA=masktouseA,$
              masktouseB=masktouseB,avgstop=avgstop,dopol=dopol


    if n_elements(verb) eq 0 then verb=-1
    if n_elements(bw) eq 0   then bw=25.            ; default 25 Mhz
    if n_elements(indAvgA) eq 0   then indAvgA=indgen(nloops)
    if n_elements(indAvgB) eq 0   then indAvgB=indgen(nloops)
    iret=0
    polToDo=lonarr(2) 
    if n_elements(dopol) eq 1 then begin
        polToDo[dopol]=1
    endif else begin
        polToDo+=1
    endelse

    nlags=n_elements(d[0].spon[*,0])
    nsbc=4
    npol=2
    np=nlags*nsbc*nsteps
    ya=reform(d.spcal[*,0],np,nloops)           ; the data 1 pass at a time
    yb=reform(d.spcal[*,1],np,nloops)
    a=size(masktouseA)
    B=size(masktouseb)
    case a[0] of
        1:maxDimMaskA=1
        0:begin
            maxDimMaskA=0
            masktouseA=''
          end
        else: maxDimMaskA=a[2]  ; assume 2d 
    endcase
    case b[0] of
        1:maxDimMaskB=1
        0:begin
            maxDimMaskB=0
            masktouseB=''
          end
        else: maxDimMaskB=a[2]  ; assume 2d 
    endcase
;
    frqStp=bw/(nlags*1.)
    frqMin= d[0].freq - (bw/2.)
    frqMax= frqMin +  nsteps*nsbc*bw
    fitISum={ np      : np      ,$; number of points in a strip
        nlags : nlags   ,$; number of lags in 1 sbc
        nsbc  : nsbc    ,$; number of sbc
        nsteps: nsteps  ,$; 1 pass thru data
        frqStp: 0.      ,$; 1 channel
        frqMin: 0.      ,$; 1 freq
        frqMAx: 0.      ,$; 1 freq
        nloops: 0L      ,$; passes thru the data
        avgD  : fltarr(np,2),$; data after being averaged
        useAvgA: intarr(nloops),$; we used for averaging a
        useAvgB: intarr(nloops) $; we used for averaging B
    }
    fitISum.useAvgA[indAvgA]=1
    fitISum.useAvgB[indAvgB]=1
    fitISum.frqStp=frqStp
    fitISum.frqMin  =frqMin
    fitISum.frqMax  =frqMax
    fitISum.nloops  =nloops
    for iloop=0,nloops-1 do begin
        if polToDo[0] eq 1 then begin
        a=where(indAvgA eq iloop,useIt)
        print,'indvid fits loop:',iloop,' polA use in Avg:',useIt
        istat=corblauto(ya[*,iloop],yfitA,maska,coefA,verb=verb,raw=np,/double,$
                _extra=e,masktouse=masktouseA[*,(iloop< ((maxDimMaskA-1)>0))])
        empty
        iret=iret or istat
        endif
        if polToDo[1] eq 1 then begin
        a=where(indAvgB eq iloop,useIt)
        print,'                          polB use in Avg:',useIt
        istat=corblauto(yb[*,iloop],yfitB,maskB,coefB,verb=verb,raw=np,/double,$
                _extra=e,masktouse=masktouseB[*,(iloop< ((maxDimMaskB-1)>0))])
        empty
        iret=iret or istat
        endif
        if iloop eq 0 then begin
            coefA= polToDo[0] ? coefA:coefB
            a={$
                np : np    ,$; number of points
             frqStp: frqStp,$; each channel
             frqMin: frqMin  ,$; freq first channel of pass
             frqMax: frqMax  ,$; freq first channel of pass
             fitI  : coefA   ,$; from fit
             yfit  : fltarr(np,npol) ,$ 
             mask  : fltarr(np,npol)}
            fitI=replicate(a,nloops) 
        endif
;
;   fill in fitI we fit a,b separately .. stuff them into
;   first board of the coef array
;
        if polToDo[0] eq 0 then begin
            coefA=coefB
            yfitA=yfitB
            maskA=maskB
        endif
        if polToDo[1] eq 0 then begin
            coefB=coefA
            yfitB=yfitA
            maskB=maskA
        endif
        fitI[iloop].fitI=coefA
        fitI[iloop].fitI.pol[1,0]       =1  ; cram polB into its normal slot
        fitI[iloop].fitI.coefAr[*,1,0]  =coefB.coefAr[*,0,0]
        fitI[iloop].fitI.rms[1,0]       =coefB.rms[0,0]
        fitI[iloop].fitI.maskFract[1,0] =coefB.maskFract[0,0]
        fitI[iloop].yfit[*,0]           =yfitA
        fitI[iloop].yfit[*,1]           =yfitB
        fitI[iloop].mask[*,0]           =maskA.b1
        fitI[iloop].mask[*,1]           =maskB.b1
    endfor
;
;   also fit the average
;
    if nloops eq 1 then begin
        fitISum.avgD[*,0]=ya
        fitISum.avgD[*,1]=yb
        fitIAvg=fitI
    endif else begin
        fitISum.avgD[*,0]=avgrobbychan(ya[*,indAvgA],rms=rmsa)
        fitISum.avgD[*,1]=avgrobbychan(yb[*,indAvgB],rms=rmsb)
        fitIAvg=fitI[0]
        print,'                         AvgA'
        maskAvgA=(maxDimMaskA eq 0)?'':$
        (maxDimMaskA eq 1)?maskToUseA :  total(maskToUseA,2)/(maxDimMaskA*1.)
        istat=corblauto(fitISum.avgD[*,0],yfitA,maska,coefA,verb=verb,raw=np,$
            /double,_extra=e,masktouse=maskavgA)
        if keyword_set(avgstop) then begin
            print,'Return to continue'
            key=checkkey(/wait)
        endif
        iret=iret or istat
        empty
        print,'                         AvgB'
        maskAvgB=(maxDimMaskB eq 0)?'':$
        (maxDimMaskB eq 1)?maskToUseB :  total(maskToUseB,2)/(maxDimMaskB*1.)
        istat=corblauto(fitISum.avgD[*,1],yfitB,maskB,coefb,verb=verb,raw=np,$
            /double,_extra=e,masktouse=maskavgB)
        if keyword_set(avgstop) then begin
            print,'Return to continue'
            key=checkkey(/wait)
        endif
        iret=iret or istat
        empty
        fitIAvg.fitI=coefA
        fitIAvg.fitI.pol[1,0]       =1  ; cram polB into its normal slot
        fitIAvg.fitI.coefAr[*,1,0]  =coefB.coefAr[*,0,0]
        fitIAvg.fitI.rms[1,0]       =coefB.rms[0,0]
        fitIAvg.fitI.maskFract[1,0] =coefB.maskFract[0,0]
        fitIAvg.yfit[*,0]           =yfitA
        fitIAvg.yfit[*,1]           =yfitB
        fitIAvg.mask[*,0]           =maskA.b1
        fitIAvg.mask[*,1]           =maskB.b1
    endelse

    return,iret
end
