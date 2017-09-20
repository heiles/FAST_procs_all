pro sidelobe_eval, nterms, fhgt, fcen, fhpbw, az, za, sidelobe

;+

;PURPOSE: evaluate the sidelobes at an arbitrary set of az, za given the
;Fourier coefficients describing hgt, cen, and wid.

;CALLING SEQUENCE:
;SIDELOBE_EVAL, nterms, fhgt, fcen, fhpbw, az, za, sidelobe

;INPUTS:

;	NTERMS, the number of terms to use in evaluating the inverse
;FFT. For our application with 4 strips, we use NTERMS=6).

;	FHGT, FCEN, FWID, the set of complex Fourier coefficients for
;the height, center, and width of the Gaussians that describe the
;sidelobes.

;	AZ,ZA: the position at which to evaluate the sidelobes. Units
;are ARCMIN. 

;OUTPUT:	

;	SIDELOBE, the amplitude of the sidelobe.

;NOTE ON UNITS FOR THE WIDTH: The input width is in in units of HPBW. In
;the evaluation, we use 1/e widths, which is why we multiply by 0.6...

;-

radius= sqrt( az^2 + za^2)
angle = atan( za, az)

;INPUT
hgt= ffteval( nterms, fhgt, angle)
cen= ffteval( nterms, fcen, angle)
wid= 0.6005612* ffteval( nterms, fhpbw, angle)

sidelobe= hgt* exp( -((radius-cen)/wid)^2)

ptsperstrip= sqrt( n_elements( sidelobe))
sidelobe= reform( sidelobe, ptsperstrip, ptsperstrip)

return
end
