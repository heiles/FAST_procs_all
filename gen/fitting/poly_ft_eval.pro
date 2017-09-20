pro poly_ft_eval, frqin, degree, coeffs, times, $
	yeval, yeval_poly, yeval_fourier

;+
;POLY_FT_EVAL -- using results from poly_ft_fit, calculate the fitted spectrum 
;
;CALLING SEQUENCE: 
;poly_ft_eval, frqin, degree, times, coeffs, sigcoeffs, $
;	yeval, yeval_poly, yeval_fourier
;
;INPUTS:
;	FRQIN, the array of input freqs at which to evaluate the spectrum
;	DEGREE, the degree of the polynomial to fit
;	COEFFS, the set of coeffs from the original fit
;	TIMES, the times for whichi the fourier components are fitted
;
;OUTPUTS:
;	YEVAL, the evaluated points
;	YEVAL_POLY, the contribution to YEVAL from the polynomial part
;	YEVAL_FOURIER, the contribution to YEVAL from the fourier part
;
;HISTORY: carl h, 02sep2005
;-

yeval_poly= fltarr( n_elements( frqin))
yeval_fourier= fltarr( n_elements( frqin))
nfourier= (n_elements( coeffs)- (degree+1)) 

for ndeg=0, degree do yeval_poly= yeval_poly+ coeffs[ ndeg]*frqin^ndeg
for nf= 0, nfourier-1, 2 do yeval_fourier= yeval_fourier+ $
	coeffs[ degree+ nf+ 1]* cos( 2.d0*!dpi* times[ nf/2]* frqin) + $
	coeffs[ degree+ nf+ 2]* sin( 2.d0*!dpi* times[ nf/2]* frqin)

yeval= yeval_poly+ yeval_fourier
return
end

