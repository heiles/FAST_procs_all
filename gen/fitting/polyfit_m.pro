pro polyfit_m, xdata, ydata, degree, $
	coeffs, sigcoeffs, yfit, sigma, nr3sig, cov, $
	xmean= xmean
;+
;NAME:
;   POLYFIT_M
;
;PURPOSE:
;    Polynomial fits, but coefficients are for xdata - xmean.
;	like IDL's POLY_FIT, but returns sigmas of
;	the coefficients, the fitted line, and the normalized covariance
;	matrix also.
;
;CALLING SEQUENCE:
;    POLYFIT_M, xdata, ydata, degree, coeffs, sigcoeffs, yfit, cov
;
;INPUTS:
;     xdata: the x-axis data points. 
;     ydata: the y-axis data points.
;     degree: the degree of the polynomial. e.g. linear fit has degree=1.
;OUTPUTS:
;     coeffs: array of coefficients.
;     sigcoeffs: me's of the coefficients.
;     yfit: the fitted points evaluated at datax.
;     sigma: the sigma (mean error) of the data points.
;     nr3sig: the nr of datapoints lying more than 3 sigma away from the fit.
;     cov: the normalized covariance matrix.
;KEYWORDS:
;	XMEAN, the mean value of x around which the fit is done.
;+


xmean= mean( double(xdata))
x = double( xdata) - xmean
t = double(ydata)

ndata = n_elements(x)
s = dblarr(degree+1, ndata, /nozero)

for ndeg = 0, degree do s[ndeg,*] = x^ndeg

ss = transpose(s) ## s
st = transpose(s) ## transpose(t)
ssi = invert(ss)
a = ssi ## st
bt = s ## a
resid = t - bt
yfit = reform( bt)
sigsq = total(resid^2)/(ndata-degree-1.)
sigarray = sigsq * ssi[indgen(degree+1)*(degree+2)]
sigcoeffs = sqrt( abs(sigarray))
coeffs = reform( a)
sigma = sqrt(sigsq)
badindx = where( abs(resid) gt 3.*sigma, nr3sig)
;stop

;TEST FOR NEG SQRTS...
indxsqrt = where( sigarray lt 0., countbad)
if (countbad ne 0) then begin
	print, countsqrt, ' negative sqrts in sigarray!'
	sigarray[indxsqrt] = -sigarray[indxsqrt]
	problem=-3
endif

;DERIVE THE NORMALIZED COVARIANCE ARRAY...
doug = ssi[indgen(degree+1)*(degree+2)]
doug = doug#doug
cov = ssi/sqrt(doug)
return
end
