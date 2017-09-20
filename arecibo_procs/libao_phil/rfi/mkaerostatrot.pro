;+
;NAME:
;mkaerostatrot - make complete aerostat model (1 rotation)
;SYNTAX: buf=mkaerostatrot(nosdlb=nosdlb,noblank=noblank,rotFudge=rotFudge,$
;                          nogauss=nogauss,ippsused=ippsused)
;ARGS:
;   NONE
;KEYWORDS:
;  noblank: if set then don't include the 42 degrees of blanking about
;              the observatory azimuth position.
;  nogauss: if set then don't include the gaussian beam as it sweeps
;               by the observatory. This leaves the amplitude constant. The
;               default is to have main beam and sidelobes by gaussians
;               with amplitudes 50db/38db above the noise floor. If nogauss
;               is set, then nosdlb is assumed.
;   nosdlb: if set then do not include the two sidelobes at +/- 110 degrees.
;               nogauss implies nosdlb.
; rotFudge: float change the default rotational width of the beam as it
;               passed in front of the observatory. By default the
;               fwhm of the gaussian is set so that the edge of the 
;               blanking region (.7 secs from bore sight) is 12 db down from
;               the peak. rotFudge multiples the fwhm of the beam.
;               If nogauss then rotFudge is ignored.
;RETURNS:
;   buf[1200000]: float  buffer holding 1 12 second rotation of the
;                        aerostat at 1 usec sampling (in the time domain). 
;DESCRIPTION:
;   create a model of the aerostat radar output for 1 12 second rotation
;at 1 usecond resolution. The default parameters are:
;1. pulsewidth 320 usecs
;2. 7 ipps: [3771.,3504.,3076,2809.,2903.5,3289.,3676] inusecs
;3. rotation period 12 seconds.
;4. Start with gaussian noise with a 1 sigma level of 5 counts
;5. For each radar pulse increase the level by 10 counts.
;6. place a gaussian at the center of the buf of amplitude 1e6 for when
;   the radar points at ao.
;7. Add two sidelobe gaussian of the same width at -108 degrees and 115
;   degrees from ao boresight. This should be 12db down from the boresight
;   amplitude.
;8. blank the boresight signal for +/- 21 degrees from ao boresight.
;9. arrange the width of the gaussian so that the edge of the blanking
;   is 12 db down from the peak (so it is equal to the sidelobes).
;   This turns out to be 12db down at the edge of the blanking region.
;
;   On return there will 12000000 samples with a 1 sigme level of 5 counts.
;added to this is the aerostat values that increase the noise by 10 counts
;on each pulse. The blanking region will be included. On gaussian (with 
;fwhm of .7 secs and amplitude 1e6) is centered at the middle of the buffer
;(boresight to ao) and two sidelobes (12db down) are positioned at 
;azimuths -108 and +115 degrees from boresight.
;   The keywords allow you to remove some of these options.
;Note:
;   when matching the results to pulsar data it lookes like rotFudge
;needs to be set to about 1.8.  This implies that the rotation width
;needs to be wider. This may be because the amplitude of the main peak
;is selected incorrectly (since it is never measured).
;-
function mkaerostatrot,nosdlb=nosdlb,noblank=noblank,rotFudge=rotFudge,$
                       nogauss=nogauss,ippsused=ippsused
;
;    make 12 second aerostat rotation. at 1 usec resolution
;    320 usec pulse/ipp (actually 2*160 sequential at 2 freq)
;    7 ipps per cycle
;
;   build a complete cycle
;
    rotWidCor=1.        ; fudge on rotational width
    if keyword_set(rotFudge) then rotWidCor=rotFudge
    rotSec=12.
    pulswU =320 
    ippArU =[3771.,3504.,3076,2809.,2903.5,3289.,3676] ; in usecs
    ippsUsed=ippArU
    amplPeak=1e6                    ; 10 times bigger
    amplReg =10.
    noiseSig=5.
    sdlbDb  =-12.                   ; 12 db down
    sdlbR   = 10.^(sdlbDb*.1)
    blankDurU=42./360.*rotSec*1e6
    iblankCen=long(rotSec*1e6/2.)           ; center pixel for blanking
    numF=3.                         ; number fwhm for rotating beam to keep.
;
;   make the rotatonal width so that the amplitude of the blanking signal
;   is equal to the sidelobe level.
;   Asd= amp sidelobe
;   a0 = max amp
;   sdlb = 
;
;   A1/A0=10^-(sdlb*.1)=e(-x1^2/2.sig^2)
    R=sdlbR
    x1=blankDurU/2.
    sig= x1/sqrt(-2*alog(R))
    fwhmRotU=2.*sqrt(-2.*sig*sig*alog(.5))
    fwhmRotU=fwhmRotU*rotWidCor
;
; blank +/- 21 degrees each side of main pulse
;
;
; sidelobes: 108 degrees before , 115 degrees after
;
    isdlobes=long([-108/360.,115./360.]*12e6 + iblankCen);indices sidelobes

    numIpp=n_elements(ippArU)                          ; number of ipps
    lenIppCycleU=total(ippArU)                         ; number usecs 1 cycle
    oneCycleU=fltarr(lenIppCycleU)
    ippArCumU=long(total(ippArU,/cum)) - long(ippArU[0])
    for i=0,numIpp-1 do begin &$ 
        i1=ippArCumU[i] &$
        i2=i1+pulswU-1L &$
        oneCycleU[i1:i2]=amplReg &$
    endfor
;
;   if debug then begin
;       ver,-.1,1.1
;       plot,oneCycleU
;       flag,ippArCumU+160.,color=2
;       ver
;   endif
;
;   now extend it out to the number of seconds they want..
;   make it a multiple of ippcycle len to start with
;   
    ncycle=long(rotSec*1e6/(lenippCycleU*1D)+.999)
    retVal=fltarr(lenIppCycleU,ncycle)
    for i=0,ncycle-1 do retVal[*,i]=oneCycleU
    lenRetVal=12000000L
    retval=retval[0:lenRetVal-1]                ; limit to 12 secs
;
;   now the 3 gaussians3 
;
    if not keyword_set(nogauss) then begin
        len=fwhmRotU*numF
        f=gs(len,amplPeak,fwhmRotU,len/2)
        len=n_elements(f)

        i1=long(iblankCen- len/2L)
        i2=i1+ len -1
        retval[i1:i2]=retval[i1:i2]*(f/amplReg)
;
;   the side lobes
;
        if not keyword_set(nosdlb) then begin
            for  i=0,1 do begin &$
                i1=long(isdlobes[i]- len/2L) &$
                i2=i1 + len -1 &$
                retval[i1:i2]=retval[i1:i2]*(f*sdlbR/amplReg) &$
            endfor
        endif
    endif
;
;    now put in the blanking..
;
    if not keyword_set(noblank) then begin
        len=long(blankDurU)
        i1=iblankCen-len/2L
        i2=i1 + len - 2L
        retval[i1:i2]=0
    endif
;
;   and the noise abs since power. don't want negs..
;
    seed=1.
    y=abs(randomn(seed,lenretVal,/normal))*noiseSig
    retval=retval+y
    return,retval
end
