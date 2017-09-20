;+
;NAME:
;mkfaarot - make complete faa model (1 rotation)
;SYNTAX: buf=mkfaarot(rotFudge=rotFudge,$
;                     nogauss=nogauss,ippsused=ippsused)
;ARGS:
;   NONE
;KEYWORDS:
;  nogauss: if set then don't include the gaussian beam as it sweeps
;               by the observatory. This leaves the amplitude constant. The
;               default is to have main beam and sidelobes by gaussians
;               with amplitudes 50db/38db above the noise floor. If nogauss
;               is set, then nosdlb is assumed.
; rotFudge: float change the default rotational width of the beam as it
;               passed in front of the observatory. By default the
;               fwhm of the gaussian is set so that the edge of the 
;               blanking region (.7 secs from bore sight) is 12 db down from
;               the peak. rotFudge multiples the fwhm of the beam.
;               If nogauss then rotFudge is ignored.
;RETURNS:
;   buf[1200000]: float  buffer holding 1 12 second rotation of the
;                        faa at 1 usec sampling (in the time domain). 
;DESCRIPTION:
;   create a model of the faa radar output for 1 12 second rotation
;at 1 usecond resolution. The default parameters are:
;1. pulsewidth 5 usecs
;2. 5 ipps: [2633.,2821.,2746.,2595.,3310.]
;3. rotation period 12 seconds.
;4. Start with gaussian noise with a 1 sigma level of 5 counts
;5. For each radar pulse increase the level by 10 counts.
;6. place a gaussian at the center of the buf of amplitude 1e5 for when
;   the radar points at ao.
;7. set the gaussian fwhm width to be 50 milliseconds.
;
;   On return there will 12000000 samples with a 1 sigme level of 5 counts.
;added to this is the faa values that increase the noise by 10 counts
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
function mkfaarot,rotFudge=rotFudge,nogauss=nogauss,ippsused=ippsused,$
				  pkamp=pkamp,noisesig=noisesig
;
;    make 12 second faa rotation. at 1 usec resolution
;    5 usec pulse/ipp (should 2*5 since two pulses)
;    5 ipps per cycle
;
;   build a complete cycle
;
	numF=3				; take gaussian out to 3fwhm
    rotWidCor=1.        ; fudge on rotational width
    if keyword_set(rotFudge) then rotWidCor=rotFudge
    rotSec=12.
	icen=long(rotSec*1e6/2.)           ; center pixel 

    pulswU =10.						; 2*5 usecs
    pulswU =5.						; 2*5 usecs
    pulswU =2.						; 2*5 usecs
    ippArU =[2633.,2821.,2746.,2595.,3310.]
    ippsUsed=ippArU
    amplPeak=1e3                    ; 10 times bigger
	if keyword_set(pkamp) then amplPeak=pkamp
    amplReg =50.
	puls=[1.,1.,1.,1.,.5,1.,1.,1.,1.,.5]
	if n_elements(noisesig) eq 0 then  noiseSig=0.
;
    fwhmRotU=(50000.*rotWidCor)				; 50 millisecs
    numIpp=n_elements(ippArU)                          ; number of ipps
    lenIppCycleU=total(ippArU)                         ; number usecs 1 cycle
    oneCycleU=fltarr(lenIppCycleU)
    ippArCumU=long(total(ippArU,/cum)) - long(ippArU[0])
    for i=0,numIpp-1 do begin &$ 
        i1=ippArCumU[i] &$
        i2=i1+pulswU-1L &$
;        oneCycleU[i1:i2]=puls &$
        oneCycleU[i1:i2]=amplreg &$
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
;   now the gaussian beam
;
    if not keyword_set(nogauss) then begin
        len=fwhmRotU*numF
        f=gs(len,amplPeak,fwhmRotU,len/2)
        len=n_elements(f)

        i1=long(iCen- len/2L)
        i2=i1+ len -1
        retval[i1:i2]=retval[i1:i2]*(f/amplReg)
    endif
;
;   and the noise abs since power. don't want negs..
;
	if noisesig ne 0. then begin
	    seed=1.
   	 	 y=abs(randomn(seed,lenretVal,/normal))*noiseSig
    	retval=retval+y
	endif
    return,retval
end
