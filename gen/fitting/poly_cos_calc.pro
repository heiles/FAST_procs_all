function poly_cos_calc, polycoeffs, times, coscoeffs, frqs, $
	res_poly, res_cos, cospower

;+
;PURPOSE: calculate the fits generated ty poly_cos_fit_svd for any set of frequencies.
;INPUTS:
;	POLYCOEFFS, the array of polynomial coefficients
;	TIMES, the times at which the fourier coeffs coscoeffs are evaluated
;	coscoeffs, the array of fourier coefficients
;	FRQS, the freq arraay for which  you want result;
;
;RETURNS: the calculated fitted spectrum.
;
;OUTPUTS:
;	res_poly, the polynomial portion of the fit
;	res_cos, the fourier portion of the fit
;	cospower, the fourier power versus time
;-

degree= n_elements( polycoeffs)-1l
nfr= n_elements( coscoeffs)

res_poly= fltarr( n_elements( frqs))
res_cos=  fltarr( n_elements( frqs))
res=  fltarr( n_elements( frqs))

;GET THE POLYNOMIAL RESULT...
for ndeg=0, degree do res_poly= res_poly+ polycoeffs[ ndeg]*frqs^ndeg 

;GET THE FOURIER RESULT...
for nf= 0, nfr-1 do res_cos= res_cos+ $
        coscoeffs[ nf]* cos( 2.d0*!dpi* times[ nf]* frqs)

res= res_poly+ res_cos

;stop

cospower= coscoeffs^2

return, res

end
