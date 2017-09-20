pro polyfit_wgt, xdata, ydata, wgts, degree, $
	coeffs, sigcoeffs, yfit, sigma, nr3bad, ncov, cov, $
	residbad=residbad, goodindx=goodindx, problem=problem
;+
;NAME:
;POLYFIT_WGT -- polynomial fits of weighted datapoints
;
;PURPOSE:
;    Polynomial fits, like IDL's POLY_FIT, but allows weighting the input eq's of cond.
;	returns sigmas of
;	the coefficients, the fitted line, and the normalized covariance
;	matrix also.
;
;CALLING SEQUENCE:
;    POLYFIT_WGT, xdata, ydata, wgts, degree, coeffs, sigcoeffs, yfit, sigma, nr3bad, cov
;
;INPUTS:
;     xdata: the x-axis data points. 
;     ydata: the y-axis data points.
;	wgts, the weighting factors applied to eqns of cond. these get squared
;		then the normal equations are calculated. Thus, for
;		Gaussian noise, you should set 
;               wgts = (1/uncertainty of each data point) [NOT squared!]
;     degree: the degree of the polynomial. e.g. linear fit has degree=1.
;KEYWORDS:
;     residbad: if set, excludes points those residuals exceed residbad*sigma
;	goodindx: the array of indices actually used in the fit.
;	problem: nonzero if there was a problem with the fit.
;OUTPUTS:
;     coeffs: array of coefficients.
;     sigcoeffs: me's of the coefficients.
;     yfit: the fitted points evaluated at datax.
;     sigma: the sigma (mean error) of the data points.
;     nr3sig: the nr of datapoints lying more than 3 sigma away from the fit.
;     ncov: the normalized covariance matrix.
;     cov: the covariance matrix.

;IMPORTANT COMMENT: i have not checked whether the returned errors are right, nor whether it 
;behaves properly when eliminating bad points.
;-

problem=0
x = double(xdata)
t = double(ydata)
wgt= double( wgts)
twgt= t* wgt
ndata = n_elements(x)
goodindxx= lindgen( ndata)
niter= 0l
nr3bad = 0l

ITERATE:
s = dblarr(degree+1, ndata, /nozero)

for ndeg = 0, degree do s[ndeg,*] = x^ndeg
for nr=0, ndata-1 do s[ *,nr]= s[ *,nr]* wgt[ nr]

ss = transpose(s) ## s
st = transpose(s) ## transpose(twgt)
ssi = invert(ss)
a = ssi ## st
bt = s ## a
resid = twgt - bt
yfit = reform( bt)
sigsq = total(resid^2)/(ndata-degree-1.)
sigarray = sigsq * ssi[indgen(degree+1)*(degree+2)]
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
doug = ssi[indgen(degree+1)*(degree+2)]
doug = doug#doug
ncov = ssi/sqrt(doug)

yfit= fltarr( n_elements( xdata))
for ndeg=0, degree do yfit= yfit+ coeffs[ ndeg]*xdata^ndeg

goodindx= goodindxx


return
end
