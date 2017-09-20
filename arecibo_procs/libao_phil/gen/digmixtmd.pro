;+
;NAME:
;digmixtmd - digitally mix a complex timedomain waveform
;SYNTAX: bufOut=digmixtmd(mixI,bufInp)
;ARGS:
;  mixI    :  {}    mixing info. Returned by digmixtmdinit()
; bufInp[n]: complex  complex data input (before mixing).
;RETURNS:
; bufOut[n]: complex  data after mixing
;
;DESCRIPTION:
;   digmixtmd() will mix complex time domain baseband data. The user first calls
; digmixtmdinit() to define the sampling frequency and the new center frequency 
;after mixing.
;	You then call digmixtmd() as many times as needed with contiguous time domain
;buffers. The lophase is stored in mixI and is updated on each call to digmixtmd().
;
;Example:
;   Assume:
;   1. complex time domain data sampled at 100 Mhz
;   2. you want to mix 30 Mhz to the center of the band
;   3. Do thie for an entire files worth of data.
;   - open file
;   - mixI=digmixtmdinit(100e6,30e6)
;     bout=complexarr(maxsamples)
;     icur=0
;   - while ((nsamples=readbuf(bufInp)) != eof)
;       dout[icur:icur+nsamples-1]=digmixtmd(bufInp,mixI)
;       icur+=nsamples
;     endwhile
;
;SEE ALSO:digmixtmdinit()
;-
;
; generate complex signals, then mix them
;
function digmixtmd,mixI,dataIn
	len=n_elements(dataIn)
	nLocycle=len*mixI.loFrq/mixI.smpFrq
	phaseR=mixI.LoPhase + .25 	; .25 since using sine
	phaseI=mixI.LoPhase       	; 
	loD=complex(mksin(len,nLocycle,phase=phaseR),mksin(len,nLocycle,phase=phaseI))
;   compute start lo phase for next call
	mixI.LoPhase+= (len * mixI.smpFrq/mixI.loFrq)  mod 1D
	return,dataIn*loD
end
