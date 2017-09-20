;+
;NAME:
;fftinterp - fft interpolation of real data
;SYNTAX:  fftinterp,n,yin,yout,
;ARGS:
; n         : interpolation factor
; yin[m]    : float input data
; yout[m*n] : flout interpolated data
;DESCRIPTION:
;	interpolate the yin function by a factor of n using the fft.
;This probably needs a better filter. You get lots of 
;ringing between interpolated points.
;-
pro fftinterp,n,yin,yout

	
	nin=n_elements(yin) 
	nout=nin*n
	spcyin=fft(yin,1)
	spcout=complexarr(nout)
	l=nin/2
	spcout[0:l-1]=spcyin[0:l-1]
	spcout[nout-l:nout-1]=spcyin[l:*]
	yout=float(fft(spcout,-1))*n
	return
end
