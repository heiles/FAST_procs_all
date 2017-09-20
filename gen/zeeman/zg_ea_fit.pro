pro zg_ea_fit, xdata, tdata, hgt0, cen0, wid0, $
	hgttau, centau, widtau, $
        bfld, berr, vpredicted, cov
;+
;NAME:
;ZGFIT -- Fit B fields to Stokes V data, assuming emitting Gaussians and one absorbing gaussian
;
;PURPOSE:
;    Fit B fields to Stokes V data, assuming Gaussians are the
;         total intensity spectrum and assuming one absorbing gaussian.
;CALLING SEQUENCE:
;    ZG_EA_FIT, xdata, tdata, hgt0, cen0, wid0, hgttau, centau, widtau, $
;	bfld, berr, cov
;
;INPUTS:
;     tdata: the data points of the Stokes V spectrum.
;     hgt0: the array of N Gaussian heights of the Stokes I/2 spectrum.
;     cen0: the array of N Gaussian centers of the Stokes I/2 spectrum.
;     wid0: the array of N Gaussian widths of the Stokes I/2 spectrum.
;	hgttau: the absorbing gaussian height
;	centau, the absorbing gaussian centr
;	widtau, the absorbing gaussian halfpower width
;
;NOTE:
;	ABSORBTION ASSUMED TO BE OF THE FORM
;	optical depth = hgttau * exp[ (xdata - centau)/(0.6005612*widtau))^2]
;
;OUTPUTS:
;     bfld: the array of N fields of the Gaussians. 
;     berr: the array of N fitted centers.
;     cov: the normalized covariance matrix.
;
;RESTRICTIONS:
;    None...that we know of.
;EXAMPLE:
;    You have fit N Gaussians to a total intensity profile; their
;         parameters are in the N-element arrays hgt, cen, wid. 
;         You also have the Stokes V spectrum, which is the array 
;         tdata, and you want to derive the associated field strengths. 
;         ZGFIT, tdata, hgt0, cen0, wid0, bfld, berr, cov
;-

ngaussians = n_elements( hgt0)
datasize = n_elements( tdata)

;SET UP EQUATIONS OF CONDITION MATRIX...
s = fltarr(ngaussians +1, datasize-2)
td = tdata[1:datasize-2]
xd= xdata[1:datasize-2]

;GET THE EMISSION DERIVATIVES...
for ng = 0, ngaussians-1 do begin
gcurv, xdata, 0.0, hgt0[ng], cen0[ng], wid0[ng], ttotal
diff = 0.5*( shift( ttotal, -1) - shift( ttotal, 1))
s[ng, *] = diff[1:datasize-2]

;GET THE ABSORPTION CONTRIBUTION...
;FIRST THE TOTAL EMISSION...
gcurv, xdata, 0.0, hgt0, cen0, wid0, ttotal
;NEXT ABSORPTION...
gcurv, xdata, 0.0, hgttau, centau, widtau, tautotal
ttotal_predicted= ttotal* exp(- tautotal)
ttotal_predicted= ttotal_predicted[ 1:datasize-2]
taudiff= 0.5*( shift( tautotal, -1) - shift( tautotal, 1))
taudiff= taudiff[ 1:datasize-2]
indx= where( tautotal ne 0., count)
if count ne 0 then $
	s[ ngaussians, indx]= -ttotal_predicted[ indx]*taudiff[ indx]
endfor

wset,1
plot, td
oplot, s[ ngaussians,*],color=!red
;stop

;CREATE AND SOLVE THE NORMAL EQUATION MATRICES...
ss = transpose(s) ## s
st = transpose(s) ## td
ssi = invert(ss)
a = ssi ## st

;GET THE ERRORS...
resid = td - (s ## a)
sigsq = total(resid^2)/(datasize-2-ngaussians)
bfld = reform( a)
berr = sqrt( sigsq*ssi[(ngaussians+2)*indgen(ngaussians+1)])
vpredicted = reform( s ## a)
vpredicted= [0., vpredicted, 0.]

;DERIVE THE NORMALIZED COVARIANCE ARRAY...
doug = ssi[(ngaussians+2)*indgen(ngaussians+1)]
doug = doug#doug
cov = ssi/sqrt(doug)

return
end
