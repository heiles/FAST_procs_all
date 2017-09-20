pro polyfit_wgts, xdata, ydata, wgts, degree, $
	coeffs, sigcoeffs_mod, yfit, sigma_ordinary, ncov, $
	sigsq, sigsq_wgt
;+
;NAME:
;   POLYFIT_WGTS
;
;PURPOSE:
;    Polynomial fits with weighting, like our POLYFIT, but includes
;the possibility of including arbitrary weights.
;
;CALLING SEQUENCE:
;POLYFIT_WGTS, xdata, ydata, wgts, degree, $
;	coeffs, sigcoeffs, yfit, sigma_ordinary, ssi, cov
;
;INPUTS:
;     xdata: the x-axis data points. 
;     ydata: the y-axis data points.
;     WGTS: the weights of teh datapoints, which should be (1/sigma_data),
;	where sigmaa_data is the intrinsic dispersion of each datapoint.
;     degree: the degree of the polynomial. e.g. linear fit has degree=1.
;
;OUTPUTS:
;     coeffs: array of coefficients.
;     sigcoeffs: me's of the coefficients, calculated according to
;	the prescrtiption in my ls memo..
;     yfit: the fitted points evaluated at datax.
;     sigma: the sigma (mean error) of the data points, computed 
;	according to the weights..
;     ncov: the normalized covariance matrix.
;+

x = double(xdata)
t = double(ydata)

ndata = n_elements(x)
s = dblarr(degree+1, ndata, /nozero)

for ndeg = 0, degree do s[ndeg,*] = x^ndeg

;DO THE WEIGHTING...
t = t* wgts
for nd= 0,ndata-1 do s[*,nd]= s[*,nd]* wgts[ nd]

ss = transpose(s) ## s
st = transpose(s) ## transpose(t)
ssi = invert(ss)
a = ssi ## st
bt = s ## a
resid = t - bt
yfit = reform( bt)

;sigsq = total( resid^2)/(ndata-degree-1.)
;sigarray = sigsq * ssi[indgen(degree+1)*(degree+2)]

sigsq_ordinary = total( resid^2)/total(wgts^2)
sigarray_ordinary = sigsq_ordinary * (ssi[indgen(degree+1)*(degree+2)])

sigsq_mod = total( (wgts*resid)^2)/(total(wgts^2))
sigarray_mod = sigsq_mod * (ssi[indgen(degree+1)*(degree+2)])
sigcoeffs_mod = sqrt( abs(sigarray_mod))
coeffs = reform( a)
sigma_ordinary = sqrt(sigsq_ordinary)

;badindx = where( abs(resid) gt 3.*sigma, nr3sig)
;stop

;DERIVE THE NORMALIZED COVARIANCE ARRAY...
doug = ssi[indgen(degree+1)*(degree+2)]
doug = doug#doug
ncov = ssi/sqrt(doug)

;stop

return
end
