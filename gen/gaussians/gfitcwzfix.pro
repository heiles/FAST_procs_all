pro gfitcwzfix, look, xdata, tdata, zro0, hgt0, cen0, wid0, tfit, sigma, $
    zro1, hgt1, cen1, wid1, sigzro1, sighgt1, sigcen1, sigwid1, cov
;+
;NAME:
;   GFITCWZFIX
;
;PURPOSE:
;    Fit multiple (N) Gaussians to a one-d array of data points; 
;    THIS VERSION KEEPS THE CENTER, WIDTH, and ZERO POINT FIXED.
;
;CALLING SEQUENCE:
;    GFITCWZFIX, look, xdata, tdata, zro0, hgt0, cen0, wid0, tfit, sigma,
;         zro1, hgt1, cen1, wid1, sigzro1, sighgt1, sigcen1, sigwid1, cov
;
;INPUTS:
;     look: if >=0, plots the iteratited values for the Gaussian
;     whose number is equal to look. Then it prompts you to plot 
;     a different Gaussian number.
;
;     xdata: the x-values at which the data points exist.
;     tdata: the data points.
;
;     zro0: the zero offset of the data points.
;     hgt0: the array of N estimated heights of the Gaussians.
;     cen0: the array of N estimated centers of the Gaussians.
;     wid0: the array of N estimated halfwidths of the Gaussians.
;     BECAUSE THIS IS NOT A NONLINEAR FIT, THE NUMERICAL VALUES OF THE
;	ABOVE DON'T MATTER AT ALL...
;
;OUTPUTS:
;     tfit: the fitted values of the data at the points in xdata.
;     sigma: the rms of the residuals.
;     zro1: the zero offset, equal to zro0.
;     hgt1: the array of N fitted heights. 
;     cen1: the array of centers--equal to cen0.
;     wid1: the array of widths--equal to wid0.
;     sigzro1: meaningless--equal to 0.
;     sighgt1: the array of errors of the N fitted heights.
;     sigcen1: meaningless--equal to 0.
;     sigwid1: meaningless--equal to 0.
;     cov: the normalized covariance matrix of the fitted coefficients.
;
;RESTRICTIONS:
;    none--this is not a nonlinear fit, so no iterations are required.
;
;EXAMPLE:
;    You have two Gaussians whose centers, widths are known.
;	you think that The heights are hgt0=[1.5, 2.5], 
;	the centers cen0=[12., 20.],
;    and the widths are [5., 6.]. There are 100 data points (tdata) at 
;     100 values of x (xdata). 
;
;	gfitcwfix, look, xdata, tdata, zro0, hgt0, cen0, wid0, tfit, sigma
;    If you have two Gaussians that are mixed, you must be careful in
;    your estimates!
;
;RELATED PROCEDURES:
;	GCURV
;HISTORY:
;	Written by Carl Heiles. 21 Mar 1998.
;-

;DETERMINE THE SIZE OF THE DATA ARRAY...
dtsize = size(tdata)
dtsize = reverse(dtsize)
datasize = dtsize[0]

;DETERMINE NR OF GAUSSIANS TO FIT...
hgt0size = size(hgt0)
hgt0size = reverse(hgt0size)
ngaussians = hgt0size[0]
if (ngaussians eq 0) then ngaussians=1

;DEFINE THE OUTPUT GAUSSIAN PARAMETERS; SCALE WID FROM FWHM TO 1/E...
;THESE ARE THE SAME AS THE PARAMETERS THAT ARE ITERATED.
zro1 = zro0
hgt1 = hgt0
cen1 = cen0
wid1 = 0.6005612*wid0

;DEFINE THE EQUATION-OF-CONDITION ARRAY, S...
s = fltarr(ngaussians, datasize)

tsum = fltarr( datasize) + zro1

for ng = 0, ngaussians-1 do begin
    del = (xdata - cen1[ng])/wid1[ng]
    edel = exp(-del^2)
    sum1 = edel
    s[(ng), *] = sum1          ;HGT
    tsum = tsum + hgt1(ng)*sum1    ;DATA
endfor

;stop
;CREATE AND SOLVE THE NORMAL EQUATION MATRICES...
t = tdata-tsum
transs = transpose(s)
stranss = size(transs)
if (stranss[0] eq 1) then transs=reform(transs,datasize,1)
;ss = transpose(s) ## s
;st = transpose(s) ## t
ss = transs ## s
st = transs ## t
ssi = invert(ss)
a = ssi ## st

;stop
;INCREMENT THE PARAMETERS...
hgt1 = hgt1 + a[indgen(ngaussians)]

;print, 'a[0] = ', a[0]
;print, 'delthgt = ', delthgt, hgt1
;print, 'deltcen = ', deltcen, cen1
;print, 'deltwid = ', deltwid/0.6005612, wid1/0.6005612
;stop
;print, nloop, zro1, a[0]

finished:

;CONVERT THE 1/E WIDTHS TO HALFWIDTHS...
wid1 = wid1/0.6005612
;print, 'final widths: ', wid1

;DERIVE THE FITTED POINTS, RESIDUALS, THE ERRORS IN DERIVED COEFFICIENTS...
gcurv, xdata, zro1, hgt1, cen1, wid1, tfit
resid = tdata - tfit
sigsq = total( resid^2)/(datasize - ngaussians)
sigma = sqrt( sigsq)
sigarray = sigsq * ssi[indgen(ngaussians)*(ngaussians+1)]
sigarray = sqrt( sigarray)

sigzro1 = 0.0
sighgt1 = sigarray[indgen(ngaussians)]
sigcen1 = 0.0
sigwid1 = 0.0

;DERIVE THE NORMALIZED COVARIANCE ARRAY...
doug = ssi[indgen(ngaussians)*(ngaussians+1)]
doug = doug#doug
cov = ssi/sqrt(doug)

return
end

