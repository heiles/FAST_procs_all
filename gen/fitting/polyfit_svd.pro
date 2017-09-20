pro polyfit_svd, xdata, ydata, degree, $
	coeffs, sigcoeffs, yfit, sigma, nr3bad, ncov, cov, $
	residbad=residbad, goodindx=goodindx, problem=problem, $
	wgts=wgts, u=u, wgt_inv=wgt_inv, v=v, auto=auto
;+
;NAME:
;   POLYFIT_SVD -- polynomial fit  using SVD.
;
;PURPOSE:
;    Polynomial fits USING SVD. like IDL's POLY_FIT and my POLYFIT, 
;	but uses SVD. POLYFIT is less accurrate thaN POLY_FIT, which
;	in turn is less accurate than POLYFIT_SVD. Returns sigmas of
;	the coefficients, the fitted line, and the normalized covariance
;	matrix also.
;
;TIME: SVD VERSION IS ABOUT 3 TIMES SLOWER THAN ORDINARY VERSION.
;
;   Has an option to exclude points whose residuals exceed RESIDBAD.
;
;CALLING SEQUENCE:
;    POLYFIT_SVD, xdata, ydata, degree, $
;	coeffs, sigcoeffs, yfit, sigma, nr3bad, ncov, cov, 
;	[residbad], [goodindx], [problem], $
;	wgts=wgts, u=u, wgt_inv=wgt_inv, v=v, auto=auto
;INPUTS:
;     XDATA: the x-axis data points. 
;     YDATA: the y-axis data points.
;     DEGREE: the degree of the polynomial. e.g. linear fit has degree=1.
;KEYWORDS:
;     RESIDBAD: if set, excludes points those residuals exceed residbad*sigma
;	GOODINDX, the indices of the points included in the fit
;       PROBLEM: nonzero if a problem. -2 means too many points discarded
;	WGTS, the svd weights.
;	WGT_INV: you can modify these to eliminate degeneracies; see
;documentation for LSFIT_SVD 
;	U, the returned U matrix from LSIT_SVD
;	V, the returned V matrix from LSIT_SVD
;	AUTO: if nonzero, does the WGT_INV business automatically, zeroing the
;inverse weights when the ratio is smaller than AUTO. if AUTO is set equal
;to >= one, it defaults to 1e-12
;
;OUTPUTS:
;     COEFFS: array of coefficients.
;     SIGCOEFFS: me's of the coefficients.
;     YFIT: the fitted points evaluated at datax.
;     SIGMA: the sigma (mean error) of the data points.
;     NR3SIG: the nr of datapoints lying more than 3 sigma away from the fit.
;     NCOV: the normalized covariance matrix.
;     COV: the covariance matrix.
;
;HOW TO USE YOUR OWN WGT_INV: (it's easier to use AUTO keyword!)
;
;	first invoke this procedure. it returns the native WGTS and
;WGT_INV, and also the U and V as optional outputs. 
;	then modify WGT_INV and call this proc again using the 
;modified WGT_INV, U and V as optional inputs
;
;suppose WGTS spans a huge range, say 10^20. do something like...
;	indx= where( wgts/max( wgts) lt 1e-12)
;	wgt_inv= 1./wgts
;	wgt_inv[ indx]= 0.
;and then call this proc again, specifying U, V, and WGT_INV as optional inputs.
;
;-

problem= 0
x = double(xdata)
t = double(ydata)
ndata = n_elements(x)
goodindxx= lindgen( ndata)
niter= 0l
nr3bad = 0l

ITERATE:

;CREATE S POWER ARRAY BEING A BIT MORE CLEVER THAN USING EXPONENTS...
s= dblarr( degree+1, ndata)
s[ 0, *]= 1.d0
for ndeg= 1, degree do s[ ndeg, *]= s[ ndeg-1, *] * x

if (keyword_set( wgt_inv) eq 0) then begin
	U=0.
	V=0.
	wgts=0.
endif

;stop

lsfit_svd, s, t, U, V, $
        wgts, a, vara, siga, ncov, sigsq, ybar=yfit, cov=cov, $
	wgt_inv=wgt_inv

;DEAL WITH HUGE WGTS USING THE AUTO KEYWORD...
IF KEYWORD_SET(AUTO) THEN BEGIN
if ( auto eq 1.) then auto= 1.e-12
indxw= where( wgts/max( wgts) lt 1e-12, count)
wgt_inv= 1./wgts
if count ne 0 then wgt_inv[ indxw]= 0.
lsfit_svd, s, t, U, V, $
        wgts, a, vara, siga, ncov, sigsq, ybar=yfit, cov=cov, wgt_inv=wgt_inv
ENDIF

coeffs = reform( a)
sigcoeffs= siga
sigma = sqrt(sigsq)

resid = t - yfit
;print, 'niter= ', niter
;print, 'residbad = ', residbad
if keyword_set( residbad) then $
	badindx = where( abs(resid) gt residbad*sigma, nr3bad)

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

U=0.
V=0.
wgts=0.
wgt_inv=0.
goto, iterate
ENDIF

PROBLEMGOOD: ; go here if there aren't enough good points left.

;TEST FOR NEG SQRTS...
indxsqrt = where( vara lt 0., countbad)
IF (COUNTBAD NE 0) THEN BEGIN
	print, countbad, ' negative sqrts in vara!'
	vara[indxsqrt] = -vara[indxsqrt]
	problem=-3
ENDIF

;DERIVE THE NORMALIZED COVARIANCE ARRAY...
doug = cov[indgen(degree+1)*(degree+2)]
doug = doug#doug
ncov = cov/sqrt(doug)

goodindx= goodindxx

return
end
