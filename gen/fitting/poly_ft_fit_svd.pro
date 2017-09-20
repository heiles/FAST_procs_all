pro poly_ft_fit_svd, frqin, ydata, degree, times, $
	coeffs, sigcoeffs, yfit, sigma, nr3bad, ncov, cov, $
	residbad=residbad, goodindx=goodindx, problem=problem, $
        polycoeffs=polycoeffs, fcoeffs=fcoeffs, sigfcoeffs=sigfcoeffs, $
	fpower=fpower, sigfpower=sigfpower, $
	yfit_poly= yfit_poly, yfit_fourier=yfit_fourier, $
	itmax=itmax, noplot=noplot

;+
;POLY_FT_FIT -- fit polynomial plus fourier terms to a spectrum.
;
;CALLING SEQUENCE: 
;POLY_FT_FIT, frqin, ydata, degree, times, $
;	coeffs, sigcoeffs, yfit, sigma, nr3bad, ncov, cov, $
;	residbad=residbad, goodindx=goodindx, problem=problem, $
;        polycoeffs=polycoeffs, fcoeffs=fcoeffs, fpower=fpower, $
;	yfit_poly= yfit_poly, yfit_fourier=yfit_fourier
;
;INPUTS:
;	FRQIN, the array of input freqs for the spectrum
;	YDATA, the array of spectral points
;	DEGREE, the degree of the polynomial to fit
;	TIMES, the times for whichi the fourier components are fitted
;
;OUTPUTS:
;	COEFFS, the array of fitted coefficients. the first (degree+1)
;coefficients are for the polynomial; the remaining ones are paired,
;the number of pairs is equal to the nr of elements in times. the first
;member of each pair is the cosine term, the second the sine.
;	YFIT, the fitted datapoints
;	SIGMA, the sigma of the fitted points
;	NR3BAD, the nr of bad points on the last iteration. should be zero.
;	NCOV, the normalized covariance matrix
;	COV, the covariance matrix
;
;OPTIONALS:
;	RESIDBAD: toss out points that depart by more that this times sigma.
;e.g., if residbad is 3, it eliminates points haveing resids gt 3 sigma
;	GOODINDX, the indx of good points (the points that it actually 
;included in the fit)
;	PROBLEM, nonzero if there is a problem
;	POLYCOEFFS, the set of coeffs in the polynomial fit
;	FCOEFFS, the set of coeffs that are fourier pairs
;	FPOWER, the power in each fourier component (quad sum of cos and sin)
;	YFIT_POLY, THE fitted polynomial curve
;	YFIT_FOURIER, THE fitted fourier curve
;	ITMAX, the max nr of iterations in svdc.
;	NOTE: yfit= yfit_poly_ yfit_fourier
;
;EXAMPLE OF USE:
;	you've got a lousy ripple in the spectrum. the ripple is represented
;by yfit_fourier. ydata-yfit_fourier is the ripple-free spectrum.
;
;HISTORY: carl h, 24june2005
;-

x= frqin

problem= 0
t = double(ydata)
ndata= n_elements( t)
goodindxx= lindgen( ndata)
niter= 0l
nr3bad = 0l

ndata = n_elements(x)
nfourier= 2l* n_elements( times)
ncoeffs= degree+ 1l+ nfourier

ITERATE:
s = dblarr(ncoeffs, ndata, /nozero)

for ndeg = 0, degree do s[ndeg,*] = x^ndeg
for nf= 0, nfourier-1, 2 do $
	s[ nf+degree+1l, *]= cos( 2.d0*!dpi* times[ nf/2]* x)
for nf= 0, nfourier-1, 2 do $
	s[ nf+degree+2l, *]= sin( 2.d0*!dpi* times[ nf/2]* x)

U=0.d
V=0.d
wgt=0.d

;stop

;lsfit_svd_tst, s, t, U, V, $
;        wgt, a, vara, siga, ncov, sigsq, ybar=yfit, cov=cov, $
;	status=status, divide=divide

;stop

lsfit_svd, s, t, U, V, $
        wgt, a, vara, siga, ncov, sigsq, ybar=yfit, cov=cov

;plot, wgt
;stop, 'STOP IN POLY_FT_FIT_SVD AFTER CALLIN LSFIT_SVD'

indxwgt= where( wgt lt 0.1*median(wgt), countwgt)
IF COUNTWGT NE 0 THEN BEGIN 
wgt_inv= 1./wgt
wgt_inv[ indxwgt]= 0.
lsfit_svd, s, t, U, V, $
        wgt, a, vara, siga, ncov, sigsq, ybar=yfit, cov=cov, $
	status=status, divide=divide, wgt_inv=wgt_inv
ENDIF

coeffs = reform( a)
sigcoeffs= siga
sigma = sqrt(sigsq)

;stop
resid = t - yfit

if keyword_set( residbad) then $
        badindx = where( abs(resid) gt residbad*sigma, nr3bad)

print, 'niter ', niter, ' nr3bad ', nr3bad

IF ( (KEYWORD_SET( RESIDBAD)) AND (NR3BAD NE 0) ) THEN BEGIN
goodindx = where( abs(resid) le residbad*sigma, nr3good)
IF NR3GOOD LE DEGREE+1 THEN BEGIN
        problem=-2
        goto, problemgood
ENDIF 
x= x[goodindx]
t= t[goodindx]
goodindxx= goodindxx[ goodindx]
ndata= nr3good
niter= niter+ 1l
goto, iterate
ENDIF

PROBLEMGOOD: ; go here if there aren't enough good points left.

;DERIVE THE NORMALIZED COVARIANCE ARRAY...
doug = cov[indgen(ncoeffs)* ( ncoeffs+1)]
doug = doug#doug
ncov = cov/sqrt(doug)

goodindx= goodindxx

yfit_poly= fltarr( n_elements( frqin))
yfit_fourier= fltarr( n_elements( frqin))
for ndeg=0, degree do yfit_poly= yfit_poly+ coeffs[ ndeg]*frqin^ndeg
for nf= 0, nfourier-1, 2 do yfit_fourier= yfit_fourier+ $
	coeffs[ degree+ nf+ 1]* cos( 2.d0*!dpi* times[ nf/2]* frqin) + $
	coeffs[ degree+ nf+ 2]* sin( 2.d0*!dpi* times[ nf/2]* frqin)

;NOTE REMOVING BELOW!!
;yfit= yfit_poly+ yfit_fourier
ybar= yfit_poly+ yfit_fourier
goodindx= goodindxx

polycoeffs= coeffs[ 0:degree]
fcoeffs= coeffs[ degree+1:ncoeffs-1]
fcoeffs= reform(fcoeffs, 2, nfourier/2l)
sigfcoeffs= sigcoeffs[ degree+1:ncoeffs-1]
sigfcoeffs= reform(sigfcoeffs, 2, nfourier/2l)

fpower= 0.5* reform( fcoeffs[0,*]^2+ fcoeffs[1,*]^2)
sigfpower= 0.5* 2.* $
	sqrt( reform( fcoeffs[0,*]^2* sigfcoeffs[ 0,*]^2+ $
	        fcoeffs[1,*]^2* sigfcoeffs[ 1,*]^2) )

if keyword_set( noplot) then return

wset,1
plot, frqin, ydata, yra=[-2,4]*1e4
oplot, frqin, ybar, color=!red
oplot, frqin, ydata-ybar, color=!green, thick=2

wset,0
tmp= coeffs[1:*]
help, tmp
tmp= reform( tmp, 2, n_elements(tmp)/2d)
pwr= tmp[0,*]^2 + tmp[1,*]^2
plot, times, pwr, xra=[0.2,2.5], yra=[0,1]*2.e6

;stop, 'STOP AT END OF POLY_FIT_FIT_SVD'

return
end

