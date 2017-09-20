pro legendrefit_mars, xdata, ydata, degree, $
	coeffs, sigcoeffs, yfit, sigma, ncov, cov, $
	problem=problem, niter=niter, nitmax=nitmax
;+
;NAME: LEGENDREFIT_MARS -- legendre min-abs-resid-sum (MARS) fit using
;standard least squares
;
;IMPORTANT NOTES: 
;	(0) XDATA MUST LIE BTN -1 AND 1. CONVERT ORIGINAL X VALS TO THIS RANGE
;		USING the function GET_XLEGENDRE
;	(1) GODDARD'S FLEGENDRE/POLYLEG ARE MUCH FASTER THAN IDL'S LEGENDRE!
;	(2) THUS, GIVEN LEGENDRE COEFFS, EVALUATE: 
;               YFIT= POLYLEG( XDATA, LEGCOEFFS)
;       (3) THE XDATA MUST LIE BETWEEN -1 AND 1. WHAT'S MORE...
;       (4) PAY ATTENTION TO DOUBLE PRECISION FOR HARD PROBLEMS!!!
;
;PURPOSE:
;    like a polynomial fit but uses legendre functions, which are 
;orthogonal over the interval (-1,1). the input data must be 
;within this range.
;
;CALLING SEQUENCE:
;LEGENDREFIT_MARS, xdata, ydata, degree, $
;	coeffs, sigcoeffs, yfit, sigma, ncov, cov, $
;	problem=problem, niter=niter, nitmax=nitmax
;INPUTS:
;     xdata: the x-axis data points. 
;     ydata: the y-axis data points.
;     degree: the degree of the legendre fit. e.g. linear fit has degree=1.
;KEYWORDS:
;	problem: nonzero if there was a problem with the fit.
;       niter: nr of iterations used
;       nitmax_ max nr of iterations to try; default=200
;OUTPUTS:
;     coeffs: array of coefficients.
;     sigcoeffs: me's of the coefficients. SEE NOTE BELOW.
;     yfit: the fitted points evaluated at datax.
;     sigma: the sigma (mean error) of the data points.
;     ncov: the normalized covariance matrix.
;     cov: the covariance matrix.
;
;HISTORY - carl used legendrefit and polyfit_median as eg's to
;          write this on united flight 19, 13 aug 2010.
;-

if n_elements( nitmax) eq 0 then nitmax= 200
problem=0
x = double(xdata)
t = double(ydata)
ndata = n_elements(x)
ncoeffs= long( degree+ 1.5)
niter= 0l

;FIRST TIME AROUND, DO A CONVENTIONAL LS FIT...
wgt= 1.0d0 + dblarr( ndata)
w = wgt
ws = dblarr(degree+1, ndata, /nozero)
wmin= 1.
delmwars_ratio=0.
mwars=0.

ITERATE:
wmin_before= wmin
delmwars_ratio_before= delmwars_ratio
mwars_before= mwars

s= transpose( flegendre( x, degree+1))
for nc= 0, ncoeffs-1 do ws[ nc, *]= wgt* s[ nc, *] 
wt= wgt* t

wss = transpose(ws) ## ws
wst = transpose(ws) ## transpose(wt)
wssi = invert(wss)
a = wssi ## wst

;BELOW, THE PREFIX 'W' MEANS WEIGHTED. FOR EXAMPLE,
;WBT IS PREDICTED YDATA WITH WEIGHT; BT IS WITHOUT WEIGHT...
wbt = ws ## a
bt= wbt/wgt

wresid = wt - wbt
resid = wresid/wgt
mwars= total( abs( resid))
delmwars_ratio= (mwars_before-mwars)/mwars_before
if niter eq 0l then mwars_before= 2.*mwars
if niter eq 0l then delmwars_ratio_before= 2.*delmwars_ratio

wyfit = reform( wbt)
yfit = wyfit/wgt

w= abs( resid) > 1e-10
wgt = 1./ sqrt( w)

niter= niter+1
wmin= min( w)

;indxhalf was in the original criteria. i don't think it should
;be. i was mistakenly assuming that the mars fit has half the points
;neg, half pos, but that is not true. hence, we now eliminate that from
;the test.
;indx= where( resid gt 0, count) ; original
;indxhalf = 0
;if ( abs( count - ndata/2) gt 1) then indxhalf=1

IF ( (NITER LT nitmax) AND $
;        ((ABS( WMIN) GT 1E-6) or (indxhalf eq 1)) AND $
        (ABS( WMIN) GT 1E-6)  AND $
        ( abs( wmin - wmin_before) gt 1e-6) ) THEN GOTO, ITERATE

if (niter ge nitmax) then problem=1

;DERIVE THE NORMALIZED COVARIANCE ARRAY...
doug = wssi[indgen(degree+1)*(degree+2)]
doug = doug#doug
ncov = wssi/sqrt(doug)
cov= wssi

;CALCULATE ERRORS ASSUMING GAUSSIAN PDF, USING STANDARD LS FIT
;TECHNIQUE...     
variance= total( resid^2)/ (ndata-degree-1.)
sigsqarray1 = variance * wssi[indgen(degree+1)*(degree+2)]

sigma= sqrt( variance)
sigcoeffs = sqrt( abs(sigsqarray1))
coeffs = reform( a)
yfit= polyleg( x, coeffs)

return

end
