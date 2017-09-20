;+
;NAME:
;mkcarsrrot - make complete carsr radar model (1 rotation)
;SYNTAX: buf=mkcarsrrot(freqtoret=freqtoret,rotFudge=rotFudge,$
;               nogauss=nogauss,ippsused=ippsused,eps=eps)
;ARGS:
;   NONE
;KEYWORDS:
; freqToret: int  1 for f1,f1n, 1 for f2,f2n (see pulse structure below).
;  nogauss: if set then don't include the gaussian beam as it sweeps
;               by the observatory. This leaves the amplitude constant. The
;               default is to increase the amplitude of the radar
;               by 30 db as it sweeps by ao. The width of and sidelobes by gaussians
;               with amplitudes 50db/38db above the noise floor. If nogauss
;               is set, then nosdlb is assumed.
; rotFudge: float change the default rotational width of the beam as it
;               passed in front of the observatory. By default the
;               fwhm of the gaussian is set so that the edge of the 
;               blanking region (.7 secs from bore sight) is 12 db down from
;               the peak. rotFudge multiples the fwhm of the beam.
;               If nogauss then rotFudge is ignored.
;pkamp   : float change the peak amplitude for the gaussian beam when it
;               points at ao. The default is 1000.*50. 
;noisesig: float if supplied then add random noise to the entire data set.
;               the amplitude of the noise is noiseSig. (the default
;               amplitude for the radar when it is not pointed at ao is
;               50 counts
;eps     : dbl  change last ipp by eps usecs
;RETURNS:
;   buf[1200000]: float  buffer holding 1 12 second rotation of the
;                        faa at 1 usec sampling (in the time domain). 
;DESCRIPTION:
;   create a model of the carsr radar (faa and punta borinquen) output for 1 12 second rotation
;at 1 usecond resolution. 
;
;    The carsr radar broadcasts at 4  frequencies: 
; pulseStructure:
;    all 4 freq are included in 1 pulse. let the 4 freq be:
; f1,f1n, f2,f2n  (where n stands for narrow duration) then:
;
; f1:117 usecs, 2usecOff,f2:117usecs,2 off, f2n:19usecs, 2 off, f1n:19usecs
; fx and fxn are separated by about 5 Mhz
; f1 and f2 are separated by about 96 mhz.
;
; The model will return the pulses from f1,f1n  or f2,f2n (using freqtoret=keyword)
;The default parameters are:
;1. pulsewidth: see structure above
;2. ipps used: 15... 5*2755.4 usec, 5*3150.7 usecs, 5*3627.5 usecs
;3. rotation period 12 seconds. this is not a integral multiple of the
;   the 15 ipps.
;4. place a gaussian at the center of the buf of amplitude 1e5 for when
;   the radar points at ao.
;5. set the gaussian fwhm width to be 50 milliseconds.
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
function mkcarsrrot,freqToret=freqToRet,rotFudge=rotFudge,nogauss=nogauss,ippsused=ippsused,$
				  pkamp=pkamp,noisesig=noisesig,eps=eps
;
;    make 12 second faa rotation. at 1 usec resolution
;
;   build a complete cycle
;
	eps=n_elements(eps) eq 0 ? 0d:eps
	blankDeg=3.27
	blankSec=blankDeg/360. * 12.
	blankSample=long(blankSec*1e6)
	if n_elements(freqToRet) eq 0 then freqToRet=1
	numF=3				; take gaussian out to 3fwhm
    rotWidCor=1.        ; fudge on rotational width
    if keyword_set(rotFudge) then rotWidCor=rotFudge
    rotSec=12.
	icen=long(rotSec*1e6/2.)           ; center pixel 

	frqstr={ start:0.,$
		   duration :0.}
	;freq 1 and 2 pulse durations in pulse
	frqP=replicate(frqstr,2)
	if (freqToRet eq 1) then begin
		frqp[0].start=0.0 
		frqp[0].duration=117.
		frqp[1].start=117 + 2. + 117 + 2 + 19 + 2.
		frqp[1].duration=19
	endif else begin
;
		frqp[0].start=117 + 2.
		frqp[0].duration=117.
		frqp[1].start=117 + 2. + 117 + 2 
		frqp[1].duration=19
	endelse
	
;	ipp1=dblarr(5) +2755.4
;	ipp2=dblarr(5) +3150.7
;	ipp3=dblarr(5) +3627.5
;    from apr13
;	ipp1=dblarr(5) +2744.9
;	ipp2=dblarr(5) +3148.0
;	ipp3=dblarr(5) + (3631.3 + eps)
;   from 14jan14.. checked both faa and punta borinquen
	ipp1=dblarr(5) + 3157.2342d
	ipp2=dblarr(5) + 3473.0911d
	ipp3=dblarr(5) + 2744.8654d + eps
    ippArU =[ipp1,ipp2,ipp3]
    ippsUsed=ippArU
    amplReg =50.
    amplPeak=amplReg*100                    ; 10 times bigger
	if keyword_set(pkamp) then amplPeak=pkamp
	;use frq1p,frq2p
;	puls=[1.,1.,1.,1.,.5,1.,1.,1.,1.,.5]
	if n_elements(noisesig) eq 0 then  noiseSig=0.
;
    fwhmRotU=(50000.*rotWidCor)				; 50 millisecs
    numIpp=n_elements(ippArU)                          ; number of ipps
    lenIppCycleU=long(total(ippArU) + .5)     ; number usecs 1 cycle
    oneCycleU=fltarr(lenIppCycleU)
    ippArCumU=total(ippArU,/cum)  - ippArU[0]
    for i=0,numIpp-1 do begin &$ 
		; two pulses each ipp
        i0f=ippArCumU[i] &$
		; first freq  puls 1
        i1f=i0f + frqp[0].start 
        i2f=i1f + frqp[0].duration - 1.
        i1=long(i1f + .5)
        i2=long(i2f + .5)
        oneCycleU[i1:i2]=amplReg &$
;	      first freq pulse 2
        i1f=i0f + frqp[1].start 
        i2f=i1f + frqp[1].duration - 1.
        i1=long(i1f + .5)
        i2=long(i2f + .5)
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
;
;   now blank when it looks at us
;
	i0=icen - blankSample/2L
	i1=icen + blankSample/2L
	retVal[i0:i1]=0.

    return,retval
end
