function poly_ft_calc, polycoeffs, times, fcoeffs, frqs, $
	res_poly, res_f, fpower

;+
;PURPOSE: calculate the fits generated ty poly_ft_fit_svd for any set of frequencies.
;INPUTS:
;	POLYCOEFFS, the array of polynomial coefficients
;	TIMES, the times at which the fourier coeffs FCOEFFS are evaluated
;	FCOEFFS, the array of fourier coefficients
;	FRQS, the freq arraay for which  you want result;
;
;RETURNS: the calculated fitted spectrum.
;
;OUTPUTS:
;	res_poly, the polynomial portion of the fit
;	res_f, the fourier portion of the fit
;	fpower, the fourier power versus time
;-

print, 'stop! use poly_ft_eval instead!!'
stop

degree= n_elements( polycoeffs)-1l
nfr= n_elements( fcoeffs)/2l

res_poly= fltarr( n_elements( frqs))
res_f=  fltarr( n_elements( frqs))
res=  fltarr( n_elements( frqs))

;GET THE POLYNOMIAL RESULT...
for ndeg=0, degree do res_poly= res_poly+ polycoeffs[ ndeg]*frqs^ndeg 

;GET THE FOURIER RESULT...
for nf= 0, nfr-1 do res_f= res_f+ $
        fcoeffs[ 0, nf]* cos( 2.d0*!dpi* times[ nf]* frqs) + $
        fcoeffs[ 1, nf]* sin( 2.d0*!dpi* times[ nf]* frqs)

res= res_poly+ res_f

;stop

fpower= reform( fcoeffs[0,*]^2+ fcoeffs[1,*]^2)

return, res

end
