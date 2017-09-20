pro poly_cos_fit_svd, frqin, ydata, degree, times, $
	coeffs, sigcoeffs, yfit, sigma, nr3bad, ncov, cov, $
	residbad=residbad, goodindx=goodindx, problem=problem, $
      polycoeffs=polycoeffs, coscoeffs=coscoeffs, sigcoscoeffs=sigcoscoeffs, $
	cospower=cospower, sigcospower=sigcospower, $
	yfit_poly= yfit_poly, yfit_cos=yfit_cos, $
	itmax=itmax

;+
;POLY_FT_FIT -- fit polynomial plus cosine terms to a spectrum.
;
;CALLING SEQUENCE: 
;POLY_FT_FIT, frqin, ydata, degree, times, $
;	coeffs, sigcoeffs, yfit, sigma, nr3bad, ncov, cov, $
;	residbad=residbad, goodindx=goodindx, problem=problem, $
;        polycoeffs=polycoeffs, coscoeffs=coscoeffs, cospower=cospower, $
;	yfit_poly= yfit_poly, yfit_cos=yfit_cos
;
;INPUTS:
;	FRQIN, the array of input freqs for the spectrum
;	YDATA, the array of spectral points
;	DEGREE, the degree of the polynomial to fit
;	TIMES, the times for whichi the fourier components are fitted
;
;OUTPUTS:
;	COEFFS, the array of fitted coefficients. the first (degree+1)
;coefficients are for the polynomial; the remaining ones are for the
;cosines, the numbver of which is equal to the nr of elements in times. 
;	SIGCOEFFS, sigmas of coeffs
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
;	COSCOEFFS, the set of coeffs for the cosines
;	SIGCOSCOEFFS, sigmas of coscoeffs
;	COSPOWER, the power in each cosine component (square of coefficient)
;	SIGCOSPOWER, the power in each cosine component (square of coefficient)
;	YFIT_POLY, THE fitted polynomial curve
;	YFIT_COS, THE fitted cosine curve
;	ITMAX, the max nr of iterations in svdc.
;	NOTE: yfit= yfit_poly+ yfit_cosine
;
;EXAMPLE OF USE:
;	you've got a lousy ripple in the spectrum. the ripple is represented
;by yfit_cos. ydata-yfit_cos is the ripple-free spectrum.
;
;HISTORY: carl h, 11june2005, adapted from poly_ft_fit_svd
;-

x= frqin

problem= 0
t = double(ydata)
ndata= n_elements( t)
goodindxx= lindgen( ndata)
niter= 0l
nr3bad = 0l

ndata = n_elements(x)
ncos= n_elements( times)
ncoeffs= degree+ 1l+ ncos

ITERATE:
s = dblarr(ncoeffs, ndata, /nozero)

for ndeg = 0, degree do s[ndeg,*] = x^ndeg
for nf= 0, ncos-1 do $
	s[ nf+degree+1l, *]= cos( 2.d0*!dpi* times[ nf]* x)

U=0.d
V=0.d
wgt=0.d

;DO SVD SOLUTION...
lsfit_svd, s, t, U, V, $
        wgt, a, vara, siga, ncov, sigsq, ybar=yfit, cov=cov

;CHK THE WEIGHTS...DISCARD ANY SMALL ONES AND REDO THE SVD FIT...
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
yfit_cos= fltarr( n_elements( frqin))
for ndeg=0, degree do yfit_poly= yfit_poly+ coeffs[ ndeg]*frqin^ndeg
for nf= 0, ncos-1 do yfit_cos= yfit_cos+ $
	coeffs[ degree+ nf+ 1]* cos( 2.d0*!dpi* times[ nf]* frqin)

;NOTE REMOVING BELOW!!
;yfit= yfit_poly+ yfit_cos
ybar= yfit_poly+ yfit_cos
goodindx= goodindxx

polycoeffs= coeffs[ 0:degree]
coscoeffs= coeffs[ degree+1:ncoeffs-1]
sigcoscoeffs= sigcoeffs[ degree+1:ncoeffs-1]

cospower= coscoeffs^2
sigcospower= 2.* abs( coscoeffs* sigcoscoeffs)

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

