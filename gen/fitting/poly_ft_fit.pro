pro poly_ft_fit, frqin, ydata, degree, times, $
	coeffs, sigcoeffs, yfit, sigma, nr3bad, ncov, cov, $
	residbad=residbad, goodindx=goodindx, problem=problem, $
        polycoeffs=polycoeffs, fcoeffs=fcoeffs, fpower=fpower, $
	yfit_poly= yfit_poly, yfit_fourier=yfit_fourier, verbose=verbose

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
;########################## IMPORTANT ############################ 
;ALL COEFFS ARE DERIVED FOR THE QUANTITY [FRQIN- MEAN( FRQIN)], NOT FRQIN!!
;########################## IMPORTANT ############################ 
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
;		NOTE: yfit= yfit_poly+ yfit_fourier
;	VERBOSE, set for verbose
;
;EXAMPLE OF USE:
;	you've got a lousy ripple in the spectrum. the ripple is represented
;by yfit_fourier. ydata-yfit_fourier is the ripple-free spectrum.
;
;HISTORY: carl h, 24june2005
;-

problem= 0
fmean= mean(frqin)
x= frqin- fmean
x00=x
t = double(ydata)
ndata= n_elements( t)
goodindxx= lindgen( ndata)
niter= 0l
nr3bad = 0l

ndata = n_elements(x)
nfourier= 2l* n_elements( times)
ncoeffs= degree+ 1l+ nfourier

;stop

ITERATE:
s = dblarr(ncoeffs, ndata, /nozero)

for ndeg = 0, degree do s[ndeg,*] = x^ndeg
for nf= 0, nfourier-1, 2 do $
	s[ nf+degree+1l, *]= cos( 2.d*!dpi* times[ nf/2]* x)
for nf= 0, nfourier-1, 2 do $
	s[ nf+degree+2l, *]= sin( 2.d*!dpi* times[ nf/2]* x)

ss = transpose(s) ## s
st = transpose(s) ## transpose(t)

;stop, 'just before INVERT'

diags= lindgen( ncoeffs) * (ncoeffs+1)
;ssi = invert(ss, status_invert)  ;;;;;;;;;, /double)
;print, 'INVERT status_invert = ', status_invert
;tst= ssi ## ss
;print, minmax( tst[ diags])
;tst[ diags]= 0.
;print, minmax( tst)

;stop

ssi= la_invert( ss, status=status_la_invert, /double)
if keyword_set( verbose) then print, 'INVERT status_la_invert = ', status_la_invert
tst= ssi ## ss
if keyword_set( verbose) then print, minmax( tst[ diags])
tst[ diags]= 0.
if keyword_set( verbose) then print, minmax( tst)

a = ssi ## st
bt = s ## a
resid = t - bt
yfit = reform( bt)
sigsq = total(resid^2)/ (ndata-ncoeffs)
sigarray = sigsq * ssi[indgen(ncoeffs)*(ncoeffs+1)]
sigcoeffs = sqrt( abs(sigarray))
coeffs = reform( a)
sigma = sqrt(sigsq)
if keyword_set( residbad) then $
        badindx = where( abs(resid) gt residbad*sigma, nr3bad)
;stop

if ( (keyword_set( residbad)) and (nr3bad ne 0) ) then begin
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
endif

PROBLEMGOOD: ; go here if there aren't enough good points left.

;stop

;TEST FOR NEG SQRTS...
indxsqrt = where( sigarray lt 0., countbad)
if (countbad ne 0) then begin
        print, countbad, ' negative sqrts in sigarray!'
        sigarray[indxsqrt] = -sigarray[indxsqrt]
        problem=-3
endif

cov=ssi

;DERIVE THE NORMALIZED COVARIANCE ARRAY...
doug = ssi[indgen(ncoeffs)*(ncoeffs+1)]
doug = doug#doug
ncov = ssi/sqrt(doug)

yfit_poly= fltarr( n_elements( x00))
yfit_fourier= fltarr( n_elements( x00))
for ndeg=0, degree do yfit_poly= yfit_poly+ coeffs[ ndeg]*x00^ndeg
for nf= 0, nfourier-1, 2 do yfit_fourier= yfit_fourier+ $
	coeffs[ degree+ nf+ 1]* cos( 2.*!pi* times[ nf/2]* x00) + $
	coeffs[ degree+ nf+ 2]* sin( 2.*!pi* times[ nf/2]* x00)

yfit= yfit_poly+ yfit_fourier
goodindx= goodindxx

polycoeffs= coeffs[ 0:degree]
fcoeffs= coeffs[ degree+1:ncoeffs-1]
fcoeffs= reform(fcoeffs, 2, nfourier/2l)
fpower= reform( fcoeffs[0,*]^2+ fcoeffs[1,*]^2)

;stop

return
end

