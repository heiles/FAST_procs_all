pro gfitczfix, look, xdata, tdata, zro0, hgt0, cen0, wid0, tfit, sigma, $
    zro1, hgt1, cen1, wid1, sigzro1, sighgt1, sigcen1, sigwid1, cov
;+
;NAME:
;   GFITCZFIX
;
;PURPOSE:
;    Fit multiple (N) Gaussians to a one-d array of data points; 
;    THIS VERSION KEEPS THE CENTER FIXED AND ALSO THE ZERO OFFSET FIXED.
;
;CALLING SEQUENCE:
;    GFITCZFIX, look, xdata, tdata, zro0, hgt0, cen0, wid0, tfit, sigma,
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
;     zro0: the  zero offset of the data points.
;     hgt0: the array of N estimated heights of the Gaussians.
;     cen0: the array of N estimated centers of the Gaussians.
;     wid0: the array of N estimated halfwidths of the Gaussians.
;
;OUTPUTS:
;     tfit: the fitted values of the data at the points in xdata.
;     sigma: the rms of the residuals.
;     zro1: equal to zro0, the inputted zero offset.
;     hgt1: the array of N fitted heights. 
;     cen1: the array of N fitted centers.
;     wid1: the array of N fitted half-power widths.
;     sigzro1: meaningless. Set equal to zero.
;     sighgt1: the array of errors of the N fitted heights.
;     sigcen1: the array of errors of the N fitted centers.
;     sigwid1: the array of errors of the N fitted widths.
;     cov: the normalized covariance matrix of the fitted coefficients.
;
;RESTRICTIONS:
;    The data and x values should be in asympototic x order, 
;    either increasing or decreasing.
;    Gaussians are not an orthogonal set of functions! 
;    This doesn't matter for many cases; convergence is unique UNLESS...
;    Convergence is NOT unique when Gaussians are close together or when
;    multiple Gaussians lie within a single peak. In these cases, you
;    can get different outputs from different inputs.
;    And sometimes in these cases the fits will not converge!
;
;    This procedure uses the classical nonlinear least squares technique,
;    which utilizes analytically-calculated derivatives, to iteratively
;    solve for the least squares coefficients. Some criteria on the
;    parameters used to update the iterated coefficients are used to
;    make the fit more stable (and more time-consuming). The number
;    of iterations is limited to 50; if you need more, enter the routing
;    again, using the output parameters as input for the next attampt.
;
;EXAMPLE:
;    You have two Gaussians that are well-separated. This counts as an
;    easy case; for the estimated parameters, you need not be accurate
;    at all. The heights are hgt0=[1.5, 2.5], the centers cen0=[12., 20.],
;    and the widths are [5., 6.]. There are 100 data points (tdata) at 
;     100 values of x (xdata). You don't wish to see plots of the iterations,
;     you don't care about the uncertainties, but you want the fitted
;     points and also the rms of the residuals.
;
;	gfit, look, xdata, tdata, zro0, hgt0, cen0, wid0, tfit, sigma
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

;AX1 IS THE PERCENTAGE OF CHANGE THAT WE ALLOW; 1% IS THE DEFAULT...
ax1 = 0.01
;DFSTOP IS THE MAXIMUM WIDTH WE ALLOW, = 80% of the total window...
dfstop = 0.8*abs(xdata[datasize-1]-xdata[0])

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

nloop = 0

;DEFINE THE ARRAYS THAT WILL BE PLOTTED...
hgtplot = fltarr( ngaussians, 50)
cenplot = fltarr( ngaussians, 50)
widplot = fltarr( ngaussians, 50)
hgtplot[ *, nloop] = hgt1
cenplot[ *, nloop] = cen1
widplot[ *, nloop] = wid1/0.6005612

;DEFINE THE EQUATION-OF-CONDITION ARRAY, S...
s = fltarr(2*ngaussians, datasize)

;THIS IS THE BEGINNING OF THE ITERATION LOOP...
iterate:
nloop = nloop + 1

tsum = fltarr( datasize) + zro0

for ng = 0, ngaussians-1 do begin
    del = (xdata - cen1[ng])/wid1[ng]
    edel = exp(-del^2)
    sum1 = edel
    sum2 = edel*del
    sum3 = sum2*del
    sum6 = 2.*hgt1[ng]/wid1[ng]
    s[(2*ng), *] = sum1          ;HGT
    s[(2*ng+1), *] = sum3*sum6     ;WIDTH
    tsum = tsum + hgt1(ng)*sum1    ;DATA
endfor

;stop
;CREATE AND SOLVE THE NORMAL EQUATION MATRICES...
t = tdata-tsum
ss = transpose(s) ## s
st = transpose(s) ## t
ssi = invert(ss)
a = ssi ## st

;CHECK THE DERIVED PARAMETERS...

;THE AMPLITUDES...
delt = a[2*indgen(ngaussians)]
adelt = abs(delt)
adelt = 0.2*abs(hgt1) < adelt
delthgt = adelt*(1.- 2.*(delt lt 0.))

;THE WIDTHS...
delt = a[2*indgen(ngaussians)+1]
adelt = abs(delt)
adelt = 0.2*abs(wid1) < adelt
deltwid = adelt*(1.- 2.*(delt lt 0.))

;CHECK FOR CONVERGENCE AND REASONABLENESS...
hgtf = abs( delthgt/hgt1)
widf = abs( deltwid/wid1)
redoit = 0
if (max( hgtf) gt ax1) then redoit=1
if (max( widf) gt ax1) then redoit=1

;INCREMENT THE PARAMETERS...
halfassed = 0.5
if (redoit eq 0) then halfassed = 1.0
hgt1 = hgt1 + halfassed*delthgt
wid1 = wid1 + halfassed*deltwid

;print, 'a[0] = ', a[0]
;print, 'delthgt = ', delthgt, hgt1
;print, 'deltcen = ', deltcen, cen1
;print, 'deltwid = ', deltwid/0.6005612, wid1/0.6005612
;stop
;print, nloop, zro1, a[0]
hgtplot[ *, nloop] = hgt1
widplot[ *, nloop] = wid1/0.6005612

;stop

;CHECK TO SEE IF WIDTH IS TOO BIG..
if (max(wid1) gt dfstop) or (min(wid1) lt 0.) then begin
    problem = -1
    print, 'a width is out of range...'
    goto, finished
endif

if (nloop ge 49) then begin
    print, '50 loops; returning'
    goto, finished
endif

if (redoit eq 1) then goto, iterate    

;IF WE GET THIS FAR, THE FIT IS FINISHED AND SUCCESSFUL...

finished:

;CONVERT THE 1/E WIDTHS TO HALFWIDTHS...
wid1 = wid1/0.6005612
;print, 'final widths: ', wid1

;DERIVE THE FITTED POINTS, RESIDUALS, THE ERRORS IN DERIVED COEFFICIENTS...
gcurv, xdata, zro1, hgt1, cen1, wid1, tfit
resid = tdata - tfit
sigsq = total( resid^2)/(datasize - 2.*ngaussians)
sigma = sqrt( sigsq)
sigarray = sigsq * ssi[indgen(2*ngaussians)*(2*ngaussians+1)]
sigarray = sqrt( sigarray)
sigzro1 = 0.0
sighgt1 = sigarray[ 2*indgen(ngaussians)]
sigcen1 = 0.0
sigwid1 = sigarray[ 2*indgen(ngaussians) + 1]/0.6005612

;DERIVE THE NORMALIZED COVARIANCE ARRAY...
doug = ssi[indgen(2*ngaussians+1)*(2*ngaussians+2)]
doug = doug#doug
cov = ssi/sqrt(doug)

;PLOT GAUSSIANS IF LOOK ne 0...
if (look ge 0) then begin
ng = look
xpix=250
ypix = 200
wbegin = !d.window

;SET UP THE TWO WINDOWS...
window, xsize=xpix, ysize=ypix, title = 'HEIGHT', /free, $
	xpos = 10, ypos=10
whgt = !d.window
window, xsize=xpix, ysize=ypix, title = 'WIDTH', /free, $
	xpos = 10, ypos=10+2*(ypix+25)
wwid = !d.window
;stop
plotagn:
if (ng ge ngaussians) then begin
print, 'THERE ARENT THAT MANY GAUSSIANS! Reset to the number ', ngaussians
print, string(7b)
ng = ngaussians-1
endif

print, 'these plots are for Gaussian number, ', ng
wset, whgt
hgtmin = min(hgtplot[ng, 0:nloop])
hgtmax = max(hgtplot[ng, 0:nloop])
plot, findgen(nloop+1), hgtplot[ng, 0:nloop], $
    xrange=[0, nloop], yrange=[hgtmin, hgtmax], xstyle=1, ystyle=1

wset, wwid
widmin = min(widplot[ng, 0:nloop])
widmax = max(widplot[ng, 0:nloop])
plot, findgen(nloop+1), widplot[ng, 0:nloop], $
    xrange=[0, nloop], yrange=[widmin, widmax], xstyle=1, ystyle=1

read, ng, prompt='enter another Gaussian number (begin from zero, not one) to plot, or < 0 to stop: '
if (ng ge 0) then goto, plotagn

wset, wbegin
wdelete, whgt
wdelete, wwid

endif

return
end

