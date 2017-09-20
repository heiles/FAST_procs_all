;THIS VERSION HAS THE MODIFIED PROBLEM/HALFASSED DEALINGS...
pro gfit2d, look, xdata, ydata, tdata, zro0, hgt0, cenx0, ceny0, wid0, tfit, $
    sigma, $
    zro1, hgt1, cenx1, ceny1, wid1, sigzro1, sighgt1, sigcenx1, sigceny1, $
    sigwid1, problem, cov, quiet=quiet
;+
;NAME:
;   GFIT2D
;
;PURPOSE:
;    Fit multiple (N) Gaussians to a 2-d array of data points
;
;CALLING SEQUENCE:
;    GFIT2D, look, xdata, ydata, tdata, zro0, hgt0, cenx0, ceny0, wid0, 
;         tfit, sigma,
;         zro1, hgt1, cenx1, ceny1, wid1, 
;         sigzro1, sighgt1, sigcenx1,sigceny1, sigwid1, 
;	  problem, cov
;
;INPUTS:
;     look: if >=0, plots the iteratited values for the Gaussian
;     whose number is equal to look. Then it prompts you to plot 
;     a different Gaussian number.
;
;     xdata: the x-values at which the data points exist.
;     ydata: the y-values at which the data points exist.
;     tdata: the data points.
;
;     zro0: the estimated constant zero offset of the data points.
;     hgt0: the array of N estimated heights of the Gaussians.
;     cenx0: the array of N estimated x-centers of the Gaussians.
;     ceny0: the array of N estimated y-centers of the Gaussians.
;     wid0: the array of N estimated halfwidths of the Gaussians.
;                                          
;KEYWORD:
;       quiet. suppresses error msgs and suggestions
;
;OUTPUTS:
;     tfit: the fitted values of the data at the points in xdata.
;     sigma: the rms of the residuals.
;     zro1: the fitted zero offset.
;     hgt1: the array of N fitted heights. 
;     cenx1: the array of N fitted x-centers.
;     ceny1: the array of N fitted y-centers.
;     wid1: the array of N fitted half-power widths.
;     sigzro1: the 'error of the mean' of the fitted zero offset.
;     sighgt1: the array of errors of the N fitted heights.
;     sigcenx1: the array of errors of the N fitted x-centers.
;     sigceny1: the array of errors of the N fitted y-centers.
;     sigwid1: the array of errors of the N fitted widths.
;     problem: 0, OK; -1, excessive width; -2, >50 loops; -3, negative sigmas,
	; 4, bad derived values.
;     cov: the normalized covariance matrix of the fitted coefficients.
;
;RESTRICTIONS:
;    The data and x values NO LONGER NEED be in asympototic x order, 
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
;
;    If you have two Gaussians that are mixed, you must be careful in
;    your estimates!
;
;RELATED PROCEDURES:
;	GCURV2D
;HISTORY:
;	GFIT Written by Carl Heiles. 21 Mar 1998.
;	Modified 16 jul 98, with 'problems' enhancement.
;	Modified 7 apr 2002, restriction on asymptotic x removed.
;       Upgraded to 2D by Paul Demorest 6 jan 2003.
;-

;DETERMINE THE SIZE OF THE DATA ARRAY...
dtsize = size(tdata)
dtsize = reverse(dtsize)
datasize = dtsize[0]

;AX1 IS THE PERCENTAGE OF CHANGE THAT WE ALLOW; 1% IS THE DEFAULT...
ax1 = 0.01
;HALFASSED IS THE MULTIPLIER FOR THE CORRECTIONS IN NONLINEAR REGIME.
halfassed = 0.5
;A NONZERO PROBLEM INDICATES A PROBLEM...
problem=0

;DFSTOP IS THE MAXIMUM WIDTH WE ALLOW, = 80% of the total window...
;dfstop = 0.8*abs(xdata[datasize-1]-xdata[0])
dfstopx = 0.8*( max( xdata)- min( xdata))
dfstopy = 0.8*( max( ydata)- min( ydata))
dfstop = min([dfstopx, dfstopy])

;DETERMINE NR OF GAUSSIANS TO FIT...
hgt0size = size(hgt0)
hgt0size = reverse(hgt0size)
ngaussians = hgt0size[0]
if (ngaussians eq 0) then ngaussians=1

;DEFINE THE OUTPUT GAUSSIAN PARAMETERS; SCALE WID FROM FWHM TO 1/E...
;THESE ARE THE SAME AS THE PARAMETERS THAT ARE ITERATED.
zro1 = zro0
hgt1 = hgt0
cenx1 = cenx0
ceny1 = ceny0
wid1 = 0.6005612*wid0

nloop = 0
nloopn = 0

;DEFINE THE ARRAYS THAT WILL BE PLOTTED...
hgtplot = fltarr( ngaussians, 5000)
cenxplot = fltarr( ngaussians, 5000)
cenyplot = fltarr( ngaussians, 5000)
widplot = fltarr( ngaussians, 5000)
hgtplot[ *, nloopn] = hgt1
cenxplot[ *, nloopn] = cenx1
cenyplot[ *, nloopn] = ceny1
widplot[ *, nloopn] = wid1/0.6005612

;DEFINE THE EQUATION-OF-CONDITION ARRAY, S...
s = fltarr(4*ngaussians+1, datasize)

;THIS IS THE BEGINNING OF THE ITERATION LOOP...
iterate:
nloop = nloop + 1
nloopn = nloopn + 1

tsum = fltarr( datasize) + zro1
s[0, *] = 1. + fltarr(datasize) ;THE CONSTANT

for ng = 0, ngaussians-1 do begin
    delx = (xdata - cenx1[ng])/wid1[ng]
    dely = (ydata - ceny1[ng])/wid1[ng]
    edel = exp(-delx^2 - dely^2)
    sum1 = edel
    sum2x = edel*delx
    sum2y = edel*dely
    sum3 = sum2x*delx + sum2y*dely
    sum6 = 2.*hgt1[ng]/wid1[ng]
    s[(4*ng+1), *] = sum1          ;HGT
    s[(4*ng+2), *] = sum2x*sum6     ;X-CNTR
    s[(4*ng+3), *] = sum2y*sum6     ;Y-CNTR
    s[(4*ng+4), *] = sum3*sum6     ;WIDTH
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
delt = a[4*indgen(ngaussians)+1]
adelt = abs(delt)
adelt = 0.2*abs(hgt1) < adelt
delthgt = adelt*(1.- 2.*(delt lt 0.))

;THE X-CENTERS...
delt = a[4*indgen(ngaussians)+2]
adelt = abs(delt)
adelt = 0.2*abs(wid1) < adelt
deltcenx = adelt*(1.- 2.*(delt lt 0.))

;THE Y-CENTERS...
delt = a[4*indgen(ngaussians)+3]
adelt = abs(delt)
adelt = 0.2*abs(wid1) < adelt
deltceny = adelt*(1.- 2.*(delt lt 0.))

;THE WIDTHS...
delt = a[4*indgen(ngaussians)+4]
adelt = abs(delt)
adelt = 0.2*abs(wid1) < adelt
deltwid = adelt*(1.- 2.*(delt lt 0.))

;CHECK FOR CONVERGENCE AND REASONABLENESS...
hgtf = abs( delthgt/hgt1)
cenxf = abs( deltcenx/wid1)
cenyf = abs( deltceny/wid1)
widf = abs( deltwid/wid1)
redoit = 0
if (max( hgtf) gt ax1) then redoit=1
if (max( cenxf) gt ax1) then redoit=1
if (max( cenyf) gt ax1) then redoit=1
if (max( widf) gt ax1) then redoit=1
;if (halfassed*max( hgtf) gt ax1) then redoit=1
;if (halfassed*max( cenf) gt ax1) then redoit=1
;if (halfassed*max( widf) gt ax1) then redoit=1

;INCREMENT THE PARAMETERS...
;halfassed = 0.5
;halfassed = 0.4
if (redoit eq 0) then halfassed = 1.0
;zro1 = zro1 + a[0]
zro1 = zro1 + halfassed*a[0]
hgt1 = hgt1 + halfassed*delthgt
cenx1 = cenx1 + halfassed*deltcenx
ceny1 = ceny1 + halfassed*deltceny
wid1 = wid1 + halfassed*deltwid


;if ( (nloopn eq 130) or (nloopn eq 131) ) then begin
;print, nloop,'a[0] = ', a[0], zro1
;print, 'delthgt = ', delthgt, hgt1
;print, 'deltcen = ', deltcen, cen1
;print, 'deltwid = ', deltwid/0.6005612, wid1/0.6005612
;stop
;endif
;stop
;print, nloop, zro1, a[0]
hgtplot[ *, nloopn] = hgt1
cenxplot[ *, nloopn] = cenx1
cenyplot[ *, nloopn] = ceny1
widplot[ *, nloopn] = wid1/0.6005612

;stop

;CHECK TO SEE IF WIDTH IS TOO BIG..
if (max(wid1) gt dfstop) or (min(wid1) lt 0.) then begin
    problem = -1
    ;print, 'a width is out of range...'
    goto, finished
endif

if (nloop ge 49) then begin
;    print, '50 loops; halfassed = ', halfassed
;	if (halfassed lt .1) then goto, finished
;	if (halfassed lt .005) then begin
		problem = -2
		goto, finished
;	endif
;	halfassed=halfassed/2.
;	nloop=-1
endif

if (redoit eq 1) then goto, iterate    

;IF WE GET THIS FAR, THE FIT IS FINISHED AND SUCCESSFUL...

finished:

;CONVERT THE 1/E WIDTHS TO HALFWIDTHS...
wid1 = wid1/0.6005612
;print, 'final widths: ', wid1

;DERIVE THE FITTED POINTS, RESIDUALS, THE ERRORS IN DERIVED COEFFICIENTS...
gcurv2d, xdata, ydata, zro1, hgt1, cenx1, ceny1, wid1, tfit
resid = tdata - tfit
sigsq = total( resid^2)/(datasize - 4.*ngaussians - 1.0)
sigma = sqrt( sigsq)
sigarray = sigsq * ssi[indgen(4*ngaussians+1)*(4*ngaussians+2)]
indxsqrt = where( sigarray lt 0., countsqrt)
sigarray = sqrt( abs(sigarray))

;TEST FOR NEG SQRTS...
if (countsqrt ne 0) then begin
	;print, countsqrt, ' negative sqrts in sigarray!'
	sigarray[indxsqrt] = -sigarray[indxsqrt]
	problem=-3
endif
;TEST FOR INFINITIES, ETC...
indxbad = where( finite( a) eq 0b, countbad)
if (countbad ne 0) then problem=-4

sigzro1 = sigarray[ 0]
sighgt1 = sigarray[ 4*indgen(ngaussians) + 1]
sigcenx1 = sigarray[ 4*indgen(ngaussians) + 2]
sigceny1 = sigarray[ 4*indgen(ngaussians) + 3]
sigwid1 = sigarray[ 4*indgen(ngaussians) + 4]/0.6005612

;DERIVE THE NORMALIZED COVARIANCE ARRAY...
doug = ssi[indgen(4*ngaussians+1)*(4*ngaussians+2)]
doug = doug#doug
cov = ssi/sqrt(doug)

;PLOT GAUSSIANS IF LOOK ne 0...
if (look ge 0) then begin
ng = look
xpix=250
ypix = 200
wbegin = !d.window

;SET UP THE FOUR WINDOWS...
window, xsize=xpix, ysize=ypix, title = 'HEIGHT', /free, $
	xpos = 10, ypos=10
whgt = !d.window
window, xsize=xpix, ysize=ypix, title = 'X-CENTER', /free, $
	xpos = 10, ypos=10+(ypix+25)
wcenx = !d.window
window, xsize=xpix, ysize=ypix, title = 'Y-CENTER', /free, $
	xpos = 10, ypos=10+2*(ypix+25)
wceny = !d.window
window, xsize=xpix, ysize=ypix, title = 'WIDTH', /free, $
	xpos = 10, ypos=10+3*(ypix+25)
wwid = !d.window
;stop
plotagn:
if (ng ge ngaussians) then begin
if keyword_set( quiet) eq 0 then print, 'THERE ARENT THAT MANY GAUSSIANS! Reset to the number ', ngaussians
if keyword_set( quiet) eq 0 then print, string(7b)
ng = ngaussians-1
endif

if keyword_set( quiet) eq 0 then print, 'these plots are for Gaussian number, ', ng
wset, whgt
hgtmin = min(hgtplot[ng, 0:nloopn])
hgtmax = max(hgtplot[ng, 0:nloopn])
plot, findgen(nloopn+1), hgtplot[ng, 0:nloopn], $
    xrange=[0, nloopn], yrange=[hgtmin, hgtmax], xstyle=1, ystyle=1

wset, wcenx
cenxmin = min(cenxplot[ng, 0:nloopn])
cenxmax = max(cenxplot[ng, 0:nloopn])
plot, findgen(nloopn+1), cenxplot[ng, 0:nloopn], $
    xrange=[0, nloopn], yrange=[cenxmin, cenxmax], xstyle=1, ystyle=1

wset, wceny
cenymin = min(cenyplot[ng, 0:nloopn])
cenymax = max(cenyplot[ng, 0:nloopn])
plot, findgen(nloopn+1), cenyplot[ng, 0:nloopn], $
    xrange=[0, nloopn], yrange=[cenymin, cenymax], xstyle=1, ystyle=1

wset, wwid
widmin = min(widplot[ng, 0:nloopn])
widmax = max(widplot[ng, 0:nloopn])
plot, findgen(nloopn+1), widplot[ng, 0:nloopn], $
    xrange=[0, nloopn], yrange=[widmin, widmax], xstyle=1, ystyle=1

read, ng, prompt='enter another Gaussian number (begin from zero, not one) to plot, or < 0 to stop: '
if (ng ge 0) then goto, plotagn

wset, wbegin
wdelete, whgt
wdelete, wcenx
wdelete, wceny
wdelete, wwid

endif

;stop
return
end

