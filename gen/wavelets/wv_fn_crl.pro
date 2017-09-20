pro wv_fn_crl, mother, nrpts, tsmpl, order, scale, $
	time, fhz, tw, fw, wf

;+
;NAME:
;wv_fn_crl -- return mother wavelet at specified times; also its ft, other stuff too
;
;PURPOSE: return mother wavelet at specified times; also its ft; also
;the times and frequencies.
;
;CALLING SEQUENCE: wv_fn_crl, mother, nrpts, tsmpl, order, scale, $
;	time, fhz, tw, fw, wf
;
;INPUTS:
;	MOTHER, the mother wavelet name. morlet, psul, gaussian.
;
;	NRPTS, the nr of time points. the generated time points are returned.
;make this EVEN, a power of two.
;	TSMPL, the time interval between points. 
;
;	ORDER: the order of the wavelet. acceptable ranges are:
;		gaussian: 1 to 10 inclusive
;		paul: 1 to 20 inclusive
;		morlet: 3 to 24 inclusive.
;
;	SCALE: the scale parameter, 'a' in eros writeup.
;
;OUTPUTS:
;	TIME, the time array. returned as FFT convention, 0 first elemetn
;	fhz, the corresponding frequency array. these are Hz, not radians/sec.
;returned as FFT convention, zero first element
;	TW, the wavelet points versus time. 
;	FW, the waveleet points veresus fsrequency
;	WF, idl's wavelet structure--basically meaningless...
;
;-


nrpts1= nrpts+ 1
timew= tsmpl* (findgen( nrpts1)- (nrpts1-1)/2.)

;NOTE: PLOTSCALE IS SAME AS FSMPL--THE RECIPROCDAL OF THE TIME INTERVAL
fsmpl= 1./tsmpl
fhz= fsmpl* (findgen( nrpts)- (nrpts/2))/ nrpts
fhz= shift( fhz, nrpts/2)

calcscale= fsmpl* scale

;FIRST GET TW...MUST USE ODD NR OF POINTS...
if ( mother eq 'morlet') then $
	wf=wv_fn_morlet(order, calcscale, nrpts1, /spatial, wavelet=tw)
if ( mother eq 'gaussian') then $
	wf=wv_fn_gaussian(order, calcscale, nrpts1, /spatial, wavelet=tw)
if ( mother eq 'paul') then $
	wf=wv_fn_paul(order, calcscale, nrpts1, /spatial, wavelet=tw)

;FIX AMPLITUDE SCALING SCREEWED UP BY CALCSCALE KLUGE...
tw= tw/ sqrt(tsmpl)

;NOW THROW AWAY THE LAST AND MAKE FFT CONVENTION...
tw= tw[0:nrpts-1]
time= timew[0:nrpts-1]
tw= shift( tw, nrpts/2)
time= shift( time, nrpts/2)

;GET THE INVERSE FFT OF THE COMPLEX CONJUGATE...
;fw= fft( conj(tw), /inverse)
fw= fft( conj(tw))
;fw= fft( tw)

;print, mother
;print, 'calcscale= ', calcscale
;print, tw[0:8]

;stop

return
end
