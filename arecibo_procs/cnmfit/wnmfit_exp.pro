pro wnmfit_exp, xdata, zrocnm, hgtcnm, cencnm, widcnm, tspincnm, ordercnm, $
	zrownm, hgtwnm, cenwnm, widwnm, fwnm, $
	tdata, chnl1a, chnl2a, $
	tspin, tspinerr, tpredicted, cov
;+
;NAME:
;   WNMFIT_EXP
;
;PURPOSE:
;    Fit TSPIN or limit to wnm gaussians, using residuals from tau fit.
;	Patterned on zgfit_exp.pro
;
;CALLING SEQUENCE:
;    ZGFIT_exp, tdata, zro0, hgt0, cen0, wid0, chnl1a, chnl2a, deltaf, $
;          bfld, berr, vpredicted, cov
;
;
;INPUTS:
;     xdata ---> fwnm: the same as inputs for tb_exp.pro
;     tdata: the data points, which are the residuals of the tau fit.
;     hgt0: the array of N Gaussian heights of the WNM gaussians
;     cen0: the array of N Gaussian centers of the WNM gaussians
;     wid0: the array of N Gaussian widths of the WNM gaussians
;     chnl1a: the first channel nr to include in the fit.
;     chnl2a: the last channel nr to include in the fit.
;
;OUTPUTS:
;     tspin: the array of N tspins fields of the WNM Gaussians. 
;     tspinerr: the array of errors for tspin
;     tpredicted: the predicted profile of brightness temp from the gaussians
;     cov: the normalized covariance matrix.
;
;RESTRICTIONS:
;    None...that we know of.
;+

common plotcolors

ngaussians = n_elements( hgtwnm)
datasize = n_elements( tdata)
xdata = findgen(datasize)

fitsize = chnl2a - chnl1a + 1

;SET UP EQUATIONS OF CONDITION MATRIX...
s = fltarr(ngaussians, fitsize)
sfull = fltarr(ngaussians, datasize)
td = tdata[ chnl1a:chnl2a]

;EVALUATE CENTER DERIVATIVES NUMERICALLY...
for ng = 0, ngaussians-1 do begin
tb_exp, xdata, zrocnm, hgtcnm, cencnm, widcnm, tspincnm, ordercnm, $
	zrownm, hgtwnm[ng], cenwnm[ng], widwnm[ng], fwnm[ng], $
	tb_wnm_tot, tb_cnm_tot, tb_tot, exp_tausum
s[ng, *] = tb_wnm_tot[ chnl1a:chnl2a]
sfull[ ng,*] = tb_wnm_tot
endfor

;CREATE AND SOLVE THE NORMAL EQUATION MATRICES...
ss = transpose(s) ## s
st = transpose(s) ## transpose(td)
ssi = invert(ss)
a = ssi ## st

;GET THE ERRORS...
resid = td - (s ## a)
sigsq = total(resid^2)/(fitsize-ngaussians)

tspin = a 
tspinerr = sqrt( sigsq*ssi[(ngaussians+1)*indgen(ngaussians)])
tpredicted = reform( sfull ## a)

;DERIVE THE NORMALIZED COVARIANCE ARRAY...
doug = ssi[(ngaussians+1)*indgen(ngaussians)]
doug = doug#doug
cov = ssi/sqrt(doug)

;stop

return
end
