;THIS VERSION HAS THE MODIFIED PROBLEM/HALFASSED DEALINGS...
pro gfit_allcal, sigmalimit, xdata, tdata, $
    tsys0, slope0, alpha0, hgt0, cen0, wid0, $
    tfit, sigma, $
    tsys1, slope1, alpha1, hgt1, cen1, wid1, $
    sigtsys1, sigslope1, sigalpha1, sighgt1, sigcen1, sigwid1, $
    problem, cov
;+
;NAME:
;   GFIT_ALLCAL
;
;PURPOSE:

;    FITS 1, 2, OR 3 GAUSSIANS. THE FIRST GAUSSIAN IS MEAND TO REPRESENT
;THE MAIN BEAM AND HAS A SKEWNESS PARAMETER, ALPHA. THE OTHER ARE
;STANDARD GAUSSIANS WITH HGT, CEN, WID. ALSO, THE ZERO LEVEL AND SLOPE
;ARE FIT. 
;
;INPUTS:
;     sigmalimit: excludes points with residuals gt sigmalimit*sigma
;
;     xdata: the x-values at which the data points exist.
;     tdata: the data points.
;
;     zro0: the estimated constant zero offset of the data points.
;     slope0: the estimated slope. 
;     alpha0: the estimated coma of the first Gaussian.
;     hgt0: the array of N estimated heights of the Gaussians.
;     cen0: the array of N estimated centers of the Gaussians.
;     wid0: the array of N estimated HPBWs of the Gaussians.
;
;OUTPUTS:
;     tfit: the fitted values of the data at the points in xdata.
;     sigma: the rms of the residuals.
;     zro1: the fitted zero offset.
;     slope1: the fitted value of the slope.
;     alpha1: the fitted coma of the first Gaussian. 
;     hgt1: the array of N fitted heights. 
;     cen1: the array of N fitted centers.
;     wid1: the array of N fitted HALF-POWER WIDTHS.
;     sigzro1: the 'error of the mean' of the fitted zero offset.
;     sigalpha1: the array of errors of the sigma (coma).
;     sighgt1: the array of errors of the N fitted heights.
;     sigcen1: the array of errors of the N fitted centers.
;     sigwid1: the array of errors of the N fitted widths.
;     problem: 0, OK; -1, excessive width; -2, >50 loops; -3, negative sigmas,
;    4, bad derived values.
;     cov: the normalized covariance matrix of the fitted coefficients.
;
;
;RELATED PROCEDURES:
;   GCURV_ALLCAL (COMPUTES THE CURVE GIVEN THE PARAMETERS)
;HISTORY:
;-

;DETERMINE THE SIZE OF THE ORIGINAL DATA ARRAYS...
alldatasize = n_elements( xdata)
jndx = indgen( alldatasize)

;DFSTOP IS THE MAXIMUM WIDTH WE ALLOW, = 80% of the total window
;   or 4 * 1/e half beamwidths...
dfstop = 4.
;AX1 IS THE PERCENTAGE OF CHANGE THAT WE ALLOW; 1% IS THE DEFAULT...
ax1 = 0.01
;A NONZERO PROBLEM INDICATES A PROBLEM...
problem=0

;DETERMINE NR OF GAUSSIANS TO FIT...
hgt0size = size(hgt0)
hgt0size = reverse(hgt0size)
ngaussians = hgt0size[0]
if (ngaussians eq 0) then ngaussians=1
nparams= 3*ngaussians+ 3

;DEFINE THE OUTPUT GAUSSIAN PARAMETERS; SCALE WID FROM FWHM TO 1/E...
;THESE ARE THE SAME AS THE PARAMETERS THAT ARE ITERATED.
tsys1 = tsys0
slope1 = slope0
alpha1 = alpha0
hgt1 = hgt0
cen1 = cen0
wid1 = 0.6005612*wid0

;DEFINE NLOOP_BAD, THE NR OF ITERATIONS FOR BAD POINTS...
nloop_bad = 0
        
;---------- BEGINNING OF ITERATION LOOP FOR BAD POINTS---------
ITERATE_BAD:

;HALFASSED IS THE MULTIPLIER FOR THE CORRECTIONS IN NONLINEAR REGIME.
halfassed = 0.5

;DEFINE NLOOP, THE NR OF ITERATIONS IN THE NONLINEAR FIT...   
nloop = 0

;DETERMINE THE SIZE OF THE DATA ARRAY...
datasize = n_elements( jndx)

;DEFINE THE EQUATION-OF-CONDITION ARRAY, S...
s = fltarr(nparams, datasize)

;------------ BEGINNING OF THE NONLINEAR PART OF THE ITERATION LOOP-----

ITERATE_NONLINEAR:
nloop = nloop + 1

ng = 0
gcurv_allcal, xdata, 0., 0., alpha1, $
    hgt1[ ng], cen1[ ng], wid1[ ng]/0.6005612, ff
x = xdata - cen1[ ng]
dff_dcen = ff*( 2*x + 3.*alpha1*x^2)/(wid1[ ng]^2)
dff_dwid = ff*( x^2 + alpha1*x^3)/(wid1[ ng]^3)
dff_dalpha = -ff*x^3/wid1[ ng]^2
    s[(3*ng+0), *] = dff_dalpha[ jndx]      ;APLHA
    s[(3*ng+1), *] = (ff/hgt1[ ng])[ jndx]  ;HGT
    s[(3*ng+2), *] = dff_dcen[ jndx]        ;CNTR
    s[(3*ng+3), *] = dff_dwid[jndx]     ;WIDTH

IF( ngaussians gt 1) then begin
FOR ng = 1, ngaussians-1 do begin
gcurv_allcal, xdata, 0., 0., 0., $
    hgt1[ ng], cen1[ ng], wid1[ ng]/0.6005612, ff
x = xdata - cen1[ ng]
dff_dcen = ff*( 2*x + 3.*alpha1*x^2)/(wid1[ ng]^2)
dff_dwid = ff*( x^2 + alpha1*x^3)/(wid1[ ng]^3)
    s[(3*ng+1), *] = (ff/hgt1[ ng])[ jndx]  ;HGT
    s[(3*ng+2), *] = dff_dcen[ jndx]        ;CNTR
    s[(3*ng+3), *] = dff_dwid[ jndx]        ;WIDTH
ENDFOR
ENDIF

s[ nparams-2, *]= 1. + fltarr( datasize)
s[ nparams-1, *]= xdata[ jndx]

gcurv_allcal, xdata, tsys1, slope1, alpha1, $
    hgt1, cen1, wid1/0.6005612, tsum_all

;CREATE AND SOLVE THE NORMAL EQUATION MATRICES...
t_all = reform( tdata-tsum_all)
t = t_all[ jndx]
ss = transpose(s) ## s
st = transpose(s) ## t
ssi = invert(ss)
a = ssi ## st

;doug = ssi[indgen(nparams)*(nparams+1)]
;doug = doug#doug
;cov = ssi/sqrt(doug)

;if (nloop_bad eq 8) then stop, 'two', nloop, nloop_bad

;CHECK THE DERIVED PARAMETERS...

;ALPHA, THE COMA PARAMETER...
delt = a[ 0]
adelt = abs(delt)
adelt = 0.02 < adelt
deltalpha = adelt*(1.- 2.*(delt lt 0.))

;THE AMPLITUDES...
delt = a[3*indgen(ngaussians)+1]
adelt = abs(delt)
adelt = 0.2*abs(hgt1) < adelt
delthgt = adelt*(1.- 2.*(delt lt 0.))

;THE CENTERS...
delt = a[3*indgen(ngaussians)+2]
adelt = abs(delt)
adelt = 0.2*abs(wid1) < adelt
deltcen = adelt*(1.- 2.*(delt lt 0.))

;THE WIDTHS...
delt = a[3*indgen(ngaussians)+3]
adelt = abs(delt)
adelt = 0.2*abs(wid1) < adelt
deltwid = adelt*(1.- 2.*(delt lt 0.))

;THE SYSTEM TEMP...
delt = a[ nparams-2]
adelt = abs(delt)
adelt = 0.2*tsys1 < adelt
delttsys = adelt*(1.- 2.*(delt lt 0.))

;THE SLOPE...
delt = a[ nparams-1]
adelt = abs(delt)
adelt = 0.01*tsys1 < adelt
deltslope = adelt*(1.- 2.*(delt lt 0.))

;CHECK FOR CONVERGENCE AND REASONABLENESS...
alphaf = abs( deltalpha)
hgtf = abs( delthgt/hgt1)
cenf = abs( deltcen/wid1)
widf = abs( deltwid/wid1)
tsysf= abs( delttsys/tsys1)
slopef= abs( deltslope/tsys1)

redoit = 0
if (max( alphaf) gt ax1) then redoit=1
if (max( hgtf) gt ax1) then redoit=1
if (max( cenf) gt ax1) then redoit=1
if (max( widf) gt ax1) then redoit=1
if (max( tsysf) gt ax1) then redoit=1
if (max( slopef) gt ax1) then redoit=1

;INCREMENT THE PARAMETERS...
if (redoit eq 0) then halfassed = 1.0
alpha1 = alpha1 + halfassed*deltalpha
hgt1 = hgt1 + halfassed*delthgt
cen1 = cen1 + halfassed*deltcen
wid1 = wid1 + halfassed*deltwid
tsys1 = tsys1 + halfassed*delttsys
slope1= slope1 + halfassed*deltslope

;print, 'GFIT_ALLCAL1 ', alpha1, deltalpha, tsys1, delttsys, slope1, deltslope 
;print, hgt1, delthgt
;print, cen1, deltcen
;print, wid1, deltwid

;print, 'GFIT_ALLCAL2 ', deltalpha, delthgt, deltcen, deltwid, delttsys, deltslope
;stop

;CHECK TO SEE IF WIDTH IS TOO BIG..
if (max(wid1) gt dfstop) or (min(wid1) lt 0.) then begin
    problem = -1
    ;print, 'a width is out of range...'
    GOTO, PROBLEM
endif

if (nloop ge 99) then begin
;    print, '50 loops; halfassed = ', halfassed
;   if (halfassed lt .1) then goto, finished
;   if (halfassed lt .005) then begin
        problem = -2
        GOTO, PROBLEM
;   endif
;   halfassed=halfassed/2.
;   nloop=-1
endif

;if (nloop_bad eq 8) then stop, 'two', nloop, nloop_bad

if (redoit eq 1) then GOTO, ITERATE_NONLINEAR    

;IF WE GET THIS FAR, THE FIT IS FINISHED AND SUCCESSFUL...

finished:

;DERIVE THE FITTED POINTS, RESIDUALS, THE ERRORS IN DERIVED COEFFICIENTS...

gcurv_allcal, xdata, tsys1, slope1, alpha1, $
    hgt1, cen1, wid1/0.6005612, tfit

resid_all= tdata - tfit
    
resid = resid_all[ jndx]
sigsq = total( resid^2)/(datasize - nparams)
sigma = sqrt( sigsq)
sigarray = sigsq * ssi[indgen(nparams)*(nparams+1)]
indxsqrt = where( sigarray lt 0., countsqrt)
sigarray = sqrt( abs(sigarray))

;CHECK TO SEE IF RESIDUALS EXCEED sigmalimit * SIGMA...
jjndx = where( abs(resid_all) lt sigmalimit*sigma, count)
;jjndx = indgen( alldatasize)

;IF THERE ARE NO GOOD POINTS, RETURN...
if (count eq 0) then begin
    problem = -5
    GOTO, PROBLEM
endif

;IF THEY EXCEED sigmalimit * SIGMA, ITERATE...
if ( (count-datasize) lt 0l) then begin
        jndx= jjndx
        nloop_bad= nloop_bad+1
;       stop, 'iterating, ', nloop_bad, count, sigma, nloop
        goto, ITERATE_BAD   
end

;TEST FOR NEG SQRTS...
if (countsqrt ne 0) then begin
    ;print, countsqrt, ' negative sqrts in sigarray!'
    sigarray[indxsqrt] = -sigarray[indxsqrt]
    problem=-3
    GOTO, PROBLEM
endif
;TEST FOR INFINITIES, ETC...
indxbad = where( finite( a) eq 0b, countbad)
if (countbad ne 0) then begin
    problem=-4
    GOTO, PROBLEM
endif

sigalpha1 = sigarray[ 0]
sighgt1 = sigarray[ 3*indgen(ngaussians) + 1]
sigcen1 = sigarray[ 3*indgen(ngaussians) + 2]
sigwid1 = sigarray[ 3*indgen(ngaussians) + 3]/0.6005612
sigtsys1 = sigarray[ nparams- 2]
sigslope1 = sigarray[ nparams- 1]

;DERIVE THE NORMALIZED COVARIANCE ARRAY...
doug = ssi[indgen(nparams)*(nparams+1)]
doug = doug#doug
cov = ssi/sqrt(doug)

;CONVERT THE 1/E WIDTHS TO HALFWIDTHS...
wid1 = wid1/0.6005612
;print, 'final widths: ', wid1

;PRINT, 'NLOOP, PROBLEM = ', nloop, problem
;stop
return

;IN CASE OF PROBLEM, SET FINAL ANSWERS EQUAL TO INITIAL GUESS.
;SET SIGS EQUAL TO ZERO, AND RETURN.
PROBLEM:

;stop, 'gfit_allcal, problem:'

tsys1 = tsys0
slope1 = slope0
alpha1 = alpha0
hgt1 = hgt0
cen1 = cen0
wid1 = wid0

sigtsys1 = 0.*tsys0
sigslope1 = 0.*slope0
sigalpha1 = 0.*alpha0
sighgt1 = 0.*hgt0
sigcen1 = 0.*cen0
sigwid1 = 0.*wid0

tfit = 0.*tdata
sigma= 0.

;PRINT, 'NLOOP, PROBLEM = ', nloop, problem
return


end

