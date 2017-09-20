;+
;NAME:
;pdevlevels - compute pdev levels during computation
;SYNTAX: istat=pdevlevels(hsp,tp,pdevlevels,b=b)
;ARGS:
;hsp {hsp}: struct   sp1 header (from desc.hsp).
;tp[n]    : float    totPwr. each should come from hsp header.
;KEYWORDS:
; b : {}    struct   data struct read via pdevget. Will compute the
;                    power for polA,B in this struct (returning array of 2)
; RETURNS: 
; istat : int     0 ok, -1 error (time domain spectra).
; pdevlev[n]:{} : structure holding the levels at various steps.
;
;DESCRIPTION:
;   Given the total power value of a spectrum, and the sp1 header 
;(desc.hsp) compute the levels at each step in the pdev computational chain 
;(see http://www.naic.edu/~phil/hardware/pdev/pdevgain/settingPdevLvls.html). 
; The use can optionally pass in a single struct holding a spectral record
; read via pdevget().
;
;The steps in the computation are:
;
; 0. We use the average spectral value so divide by fftlen
; 1. spcAvg= totalPwr/spcLen
; 2. acc=spcAvg * ashiftScl
;        40 bit accum was upshifted by ashift and then the upper pack
;        bits were output.
; 3. acc1D=acc/ndumps : get value for 1 accum. uses FCNT 
; 4. acc1=acc1*dshiftScl. correct for DSHIFT. downshifts by  2^(DSHIFT_S0)
; 5. fftOutpOut= sqrt(acc1/2.)/sqrt(2) : Converts to rms voltage. 
;            Divide pwr by 2 since jeff computes V*V*2. 
;            divide by sqrt(2) since pwr=(vI^2 + vR^2).  
;            or sqrt(pwr)=sqrt(vI^2+VR^2)
;            if vI same magnitude as vR then we get sqrt 2.
; 6. fftInp: fftOut/pshiftScl
;            pshiftscl is log2(sqrt(fftlen)-numshiftPshift)
;            For unity scaling of noise in fft, need to divde by sqrt(fftlen)
; 7  pfbInp: fftInp/pfbScl
;            The fir portion of the pfb decreases noise rms by .75           
; 8. If not hires mode, then the 12 bits of the A/D get put in the
;    upper 12 bits of the 18 bit pfb reg. So there is a mult by 2^6=64
;  
;    to get Hi res to work:
;       - There is no scaling when going dlpfOut to pfbInp ->
;         upper most 16bits of dlpf -> lower 16 bits of pfbInp
;       - The lpdf has a dc gain of .627 (i measured .61)
;       -hr_shift (upshift) in the 26 bit accum should be set for unit
;         gain for noise. With dec=0 this would be upshift of 10.
;         if dec not zero then: hr_shift=10-alog2(sqrt(dec)) since the 
;         noise grows as the sqrt of the number of adds.
;       - the 12 bits of the a/d are put in the upper 12 bits of the
;         dlpf 16 bit register (scale up by 2^4=16).
;
; 9. A/D sigma: answer is sqrt(2) too low..probably in the 
;    conversion from power to voltage. 
;
; PdevLev structure:
;IDL> help,lev1,/st
;* Structure <9ff2c34>, 28 tags, length=116, data length=106, refs=3:
;   TP              FLOAT 4.99311e+09 total power input
;   _FFTLEN         UINT  8192        fftlen
;   SPCAVG          FLOAT 609510.     avg spectral value
;   _PACK_B         INT   32          bits from accumulator returned
;   _ASHIFT         UINT  0           upshift used in 40bit accum
;   ACC             FLOAT 1.56035e+08 40 bit accum value 
;   _FCNT           LONG  20752       number of spectra added
;   ACC1D           FLOAT 7519.02     avgSpc value 1 spectra
;   _DSHIFT         UINT   0          down shift each spc before sum
;   ACC1            FLOAT  7519.02    acvSpc value before downshift
;   FFTOUT          FLOAT  43.3561    output fft. rms
;   _VSHFIT         UINT      0       upshift
;   _PSHIFT         STRING '0x1ff5'   pshift. butter fly downshifts
;   _SCLPSHIFT      FLOAT  0.0441942  scaling of fft
;   _SCLPSHIFTMAX   FLOAT  0.707107   max scaling fft thru butterflys 
;   _SCLPSHIFTMIN   FLOAT  0.0441942  min scaling fft thru butterflys
;   FFTINP          FLOAT  981.03     rms input to fft.12bits in upper 18
;   _PFBGAIN        FLOAT  0.750000   pfb noise gain
;   PFBINP          FLOAT  1308.05    pfb inp
;   DLPFOUT         FLOAT  20.4383    / by 64. 12 bits to upper 18.
;   _DEC            INT    0          decimation dlpf
;   _LPDFGAIN       FLOAT  0.627000   dlpf gain
;   _HRSHIFT        UINT   9          hr_shift in dlpf
;   _HRSHIFTEXP     FLOAT  0.0        expected shift
;   _LPDFSCALE      FLOAT  1.00000    dlpf total scaling
;   _DLPFINP       FLOAT  20.4383     dlpf input
;   ATODSIGMA       FLOAT 20.4383     a/d sigma
;   ATODSIGMACOR    FLOAT 28.9041     a/d sigma correct for sqrt(2)
;
;-
function    pdevlevels,hsp,tp,pdevLev,b=b
;
; 
;   some hardcoded numbers
;
    if n_elements(b) ne 0 then begin
       if hsp.fmttype eq 0 then  begin
        tpL=total(b.d[*,0],1)
        ntp=1
       endif else begin
        tpL=total(b.d[*,0:1],1)
        ntp=2
       endelse
    endif else begin
       tpL=tp
       ntp=n_elements(tp)
    endelse
    cmpErr=sqrt(2);         i'm sqrt 2 too low don't know why.
    pfbGain=.75
    scl12to18= 2L^6    ; place 12 bits in upper 12 of 18 bit number.
    scl12to16= 2L^4    ; place 12 bits in upper 12 of 18 bit number.
    scl16to18= 2L^2    ; place 16 bits in upper 16 of 18 bit number.
    lpdfGain=.627           ; dc gain of hanning filter.
    packBits=(hsp.fmtwidth eq 0)?8  : $
             (hsp.fmtwidth eq 1)?16 : 32
;
    ndumps=hsp.fftaccum*1L
    hiRes =hsp.hrmode ne 0
    dec   =(hsp.hrdec > 1)
    fftlen=hsp.fftlen
    tmDomain=hiRes and (hsp.hrlpf ne 0)
    if tmDomain then begin
        print,"header is for a time domain data..."
        return,-1
    endif
;
; ashift (upshift in 40 bits reg) depends on the packing
;
    Ashiftscl= 2.^(40. - packBits - hsp.ashift_s0);upshift from 40 to packbitsb
;
;   number of shifts extra/less we did in the butterfly stages
;   for noise want sqrt(fftlen) scaling..
    pshift=hsp.fftshiftmask
    pshiftCnt=0
    tmp=pshift
    for i=0,13-1 do begin &$
        if (tmp and 1) then pshiftCnt++ &$
        tmp=ishft(tmp,-1) &$
    endfor
    pshiftScl= 2.^((alog10(sqrt(fftlen))/alog10(2) ) - pshiftCnt)
;
;
; for pshift see the max,min value that we modify the values by
; depends how they group the shifts:
;
    nbits=long(alog10(fftlen)/alog10(2) + .5)
    mask= ishft(1,nbits-1)
    nse=1.
    maxV=-1.
    minV=2e9
    for i=0,nbits-1 do begin &$
        nse=nse*sqrt(2.) &$
        nse=((mask and pshift) ne 0)?nse/2:nse &$
        mask/=2 &$
        maxV=(maxV>nse) &$
        minV=(minV<nse) &$
    endfor
;
;   loop over the tp input
;
    for i=0,ntp-1 do begin
    spc=tpL[i]/fftlen
    acc= spc * ashiftScl     ; use polA
    acc1d= acc/ndumps;
    acc1 =acc1d * 2.^hsp.dshift_s0
    sclIonly=(hsp.fmttype eq 0)?2:1 ; i only.. added A+B
    fftOut   = sqrt(acc1/(2*2.*sclIonly))      ; goto voltage
    tmp      = fftOut/(2.^hsp.upshift)    ; upshift output of pfb
    fftInp   = fftOut/pshiftscl
;  /sqrt(fftlen) only needed if you do inverse fft. here.
;;    tmp      /=sqrt(fftlen*1.) ; need divide by fftlen in volts. did sqrtinPwr
    pfbInp    =fftInp/pfbGain
    if hiRes and (dec gt 1) then begin
;
;   in dlpf rms increases as sqrt(dec)
;   we have to upshift by 10 to stay the same
;   16 bit output upshifted in 26 bit register
;   expected shift (10 - alog2(sqrt(dec)))
;   difference req - did is the scale factor
;    to make it work i see:
;    dlpf upper 16 -> lower 16 of pfb18 (no scale here)
;    a/d 12 -> upper 12 of dlpf 16 .. scale by 16.
;
        dlpfOut=pfbInp
        hrshiftExp=10. - alog(sqrt(dec))/alog(2.)
        shiftScl  = 1./(2.^( hrshiftExp - hsp.hrshift))
        dlpfScale=lpdfGain*shiftScl
        dlpfInp  = dlpfOut/dlpfScale
        AtoDsigma =dlpfInp/(scl12to16)
;       print,pfbInp,dlpfOut,shiftScl,dlpfScale,atodSigma
    endif else begin
        dlpfOut   = pfbInp/scl12to18    ; 12 bits to upper 12 of 18 bit number
        dlpfInp  = dlpfOut
        AtoDsigma =dlpfOut
        dlpfScale= 1.
        hrshiftExp=0.
    endelse
;
    pdevL1  ={$    
                 tp     : tpL[i]        , $; 
                 _fftlen:fftlen  , $;
                 spcAvg : spc       , $; noise 1 channel  
                 _PACK_B:  packBits ,$
                 _ASHIFT:  hsp.ashift_s0,$
                 acc    : acc       , $; multiply by ashift scl
                 _FCNT  : ndumps  , $ 
                 acc1d:acc1d      , $; 1 dump. after dshift
                 _DSHIFT:  hsp.dshift_s0,$
                 acc1:acc1      , $; output power compute
                 fftOut:fftOut,   $;/2, sqrt v,// upshift
                 _VSHFIT:  hsp.upshift,$
                 _PSHIFT: string(format='("0x",z4.4)',hsp.fftshiftmask),$
                 _SCLPSHIFT: pshiftScl,$
                 _SCLPSHIFTMax: maxV,$
                 _SCLPSHIFTMin: minV,$
                 fftInp:fftInp   ,$
                 _PFBGAIN: pfbGain,$
                 pfbInp:pfbInp,   $;/2, sqrt v,// upshift
                 dlpfOut:dlpfOut, $;/64 for 12 to 18 bits
                 _dec     : (not hires)?0:dec,$
                 _LPDFGAIN: lpdfGain,$
                 _HRSHIFT : hsp.hrshift,$
                 _HRSHIFTExp : hrshiftExp,$
                 _LPDFScale: dlpfScale  ,$
                 _DLPFInp : dlpfInp  ,$
                 AtoDsigma:AtoDsigma    ,$;
                 AtoDsigmaCor:AtoDsigma*cmpErr   $;
              }
        if i eq 0 then begin
           pdevLev=replicate(pdevL1,ntp)
        endif
        pdevLev[i]=pdevL1
    endfor  
    return, 0
end
