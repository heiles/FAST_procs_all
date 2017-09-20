pro polyfit_median, xdata, ydata, degree, $
	coeffs, sigcoeffs, yfit, sigma, ncov, datawgt=datawgt

;+
;NAME:
;   POLYFIT_MEDIAN -- perform a least-abs-dev (median) polynomial fit
;
;PURPOSE:
;    Polynomial MEDIAN fits.
;
;CALLING SEQUENCE:
;    POLYFIT_MEDIAN, xdata, ydata, degree, $
;	coeffs, sigcoeffs, yfit, sigma, ncov, datawgt=datawgt
;
;INPUTS:
;     XDATA: the x-axis data points. 
;     YDATA: the y-axis data points.
;     DEGREE: the degree of the polynomial. e.g. linear fit has degree=1.
;
;OUTPUTS:
;     COEFFS: array of coefficients.
;     SIGCOEFFS: me's of the coefficients. SEE NOTE BELOW
;     YFIT: the fitted points evaluated at datax.
;     SIGMA: the sigma (mean error) of the data points. SEE NOTE BELOW
;     NCOV: the normalized covariance matrix.
;
;KEYWORDS:
;       DATAWGT, an arb weight of each datapoint. normally is proportional
;       to 1./error (i.e., 1/sqrt(N), where N is the nr of points that
;       contributted to the datapoint)--> NOT 1./error^2 or 1/N <---

;NOTE ON SIGMA AND SIGCOEFFS:
;	SIGMA and SIGCOEFFS are calculated as if we were doing a least
;squares fit.  this is appropriate for Gaussian statistics, but not for
;others, so this is relatively meaningless. For example, a single large
;discrepant point will contribute a lot to sigma, and to sigcoeffs, but
;because this is a median fit it is ignored.
;
;HISTORY: ch: 04apr2007, quasi-fix to convergence based on note below. could
;probably do better...
;       09apr2007: the convergence criterion just above worked much
;       worse than the old one, so i return to it...cleary, we need more
;       experimentation!
;       23dec2010: datawgt option added.
;**************IMPORTANT NOTE*******************
;
;THE CONVERSION CRITEROON IS WRONG. THERE IS ABSOLUTELY NO REQIREMENT 
;FOR NR OF POINTS ABOVE TO BE EQUAL TO THE NR BELOW, BECAUSE IT'S A 
;'WEIGHTED MEDIAN'. INSTEAD, YOU SHOULD LOOK AT THE CHANGE IN THE MARS 
;FROM EACH ITERATION AND COMPARE TO THE ACTUAL MARS VALUE.
;WITH DOUBLE PRECISION AND COMPLICATED PROBLEMS (E.G. 50 COEFFICIENTS), 
;A RATIO OF 1E-5 FOR CONVERGENCE IS REASONABLE (AS SHOWN BY LINPOL STUFF 10AUG2006)
;
;-

x = double(xdata)
tt = double(ydata)
ndata = n_elements(x)
ncoeffs= long( degree+ 1.5)
niter= 0l
if n_elements( datawgt) eq 0 then datawgt= 1.+ fltarr( ndata)

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

for ndeg = 0, degree do ws[ndeg,*] = datawgt* wgt* (x^ndeg)
wt= datawgt* wgt* tt

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

indx= where( resid gt 0, count)
indxhalf = 0
if ( abs( count - ndata/2) gt 1) then indxhalf=1

;DIAGNOSTICS...

;print, niter, count, wmin, mwars, mwars_before, mwars_before-mwars, delmwars_ratio
;print, niter, mwars, mwars_before, mwars_before-mwars, delmwars_ratio, $
;  delmwars_ratio_before-delmwars_ratio
;result= get_kbrd(1)
;if (result ne 'q') then goto, iterate

;'NEWER' CONVERGENCE CRITERIA...WHICH DON'T WORK VERY WELL...
;if niter lt 10l then goto, iterate
;IF ( (NITER LT 200l) AND (delmwars_ratio gt 1.d-6)) then goto, iterate


;OLDER CONVERGENCE CRITERIA, WHICH WORK MUCH BETTER...
;print, niter, count, wmin, indxhalf, wmin-wmin_before
;print, wmin-wmin_before

;indxhalf was in the original criteria. i don't think it should
;be. i was mistakenly assuming that the mars fit has half the points
;neg, half pos, but that is not true. hence, we now eliminate that from
;the test.    
IF ( (NITER LT 200) AND $
;	((ABS( WMIN) GT 1E-6) or (indxhalf eq 1)) AND $
	(ABS( WMIN) GT 1E-6) AND $
	( abs( wmin - wmin_before) gt 1e-6) ) THEN GOTO, ITERATE


;print, niter, count, wmin, count, indxhalf
;print, niter, count, wmin
;print, wss ## wssi

;DERIVE THE NORMALIZED COVARIANCE ARRAY...
doug = wssi[indgen(degree+1)*(degree+2)]
doug = doug#doug
ncov = wssi/sqrt(doug)

;CALCULATE ERRORS ASSUMING GAUSSIAN PDF, USING STANDARD LS FIT TECHNIQUE...
variance= total( resid^2)/ (ndata-degree-1.)
sigsqarray1 = variance * wssi[indgen(degree+1)*(degree+2)]

sigma= sqrt( variance)
sigcoeffs = sqrt( abs(sigsqarray1))
coeffs = reform( a)

return
end
