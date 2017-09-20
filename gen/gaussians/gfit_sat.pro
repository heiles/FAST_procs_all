;THIS VERSION HAS THE MODIFIED PROBLEM/HALFASSED DEALINGS...
pro gfit_sat, xdata, tdata, zro0, tx0, tau0, cen0, wid0, tfit, sigma, $
              zro1, tx1, tau1, cen1, wid1, $
              sigzro1, sigtx1, sigtau1, sigcen1, sigwid1, problem, cov, $
              nloopmax=nloopmax, halfassed=halfassed, ax1=ax1, quiet=quiet
;+
;NAME:
;GFIT_SAT -- Fit multiple (N) saturated Gaussians + an offset to a one-d array
;        of data points
;
;PURPOSE:
;    Fit multiple (N) saturated Gaussians to a one-d array of data points
;    The equation fitted is:
;       tdata= zro1 + tx1 * (1 - exp( -tau_xdata))
;    where
;       tau_xdata = tau1 * exp(- (xdata-cen)^2/deltax^2)
;    and deltx is the width; the pgr returns the FWHM.
;
;CALLING SEQUENCE:
;gfit_sat, xdata, tdata, zro0, tx0, tau0, cen0, wid0, tfit, sigma, $
;       zro1, tx1, tau1, cen1, wid1, $
;       sigzro1, sigtx1, sigtau1, sigcen1, sigwid1, problem, cov, $
;       nloopmax=nloopmax, halfassed=halfassed, ax1=ax1
;
;INPUTS:
;     xdata: the x-values at which the data points exist.
;     tdata: the data points.
;     zro0: the estimated constant zero offset of the data points.
;     tx0: the array of N estimated excitation temps.
;     tau0: the array of N estimated central opt-depths the Gaussians.
;     cen0: the array of N estimated centers of the Gaussians.
;     wid0: the array of N estimated halfwidths of the Gaussians.
;
;OPTIONAL INPUT:
;       nloopmax, max nr of loops, default is 50
;       halfassed, adiabatic multiplier; default 0.5
;       ax1, the fractional change in derived params where iterations stop
;       quiet: if set, inhibit print warnings for problem
;
;OUTPUTS:
;     tfit: the fitted values of the data at the points in xdata.
;     sigma: the rms of the residuals.
;     zro1: the fitted zero offset.
;     tx1, the array of N fitted excitation temps
;     tau1: the array of N fitted heights. 
;     cen1: the array of N fitted centers.
;     wid1: the array of N fitted half-power widths.
;     sigzro1: the 'error of the mean' of the fitted zero offset.
;     sigtx1: the array of errors of the N fitted Tx.
;     sigtau1: the array of errors of the N fitted tau.
;     sigcen1: the array of errors of the N fitted centers.
;     sigwid1: the array of errors of the N fitted widths.
;     problem: 0, OK; -1, excessive width; -2, >50 loops; -3, negative sigmas,
;	; 4, bad derived values.
;     cov: the normalized covariance matrix of the fitted coefficients.
;
;RESTRICTIONS:
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
;
;RELATED PROCEDURES:
;	GCURV_sat
;HISTORY:
;	Adapted from gfit by CH 22 jun 2009.
;-

if keyword_set( nloopmax) eq 0 then nloopmax= 50

;DETERMINE THE SIZE OF THE DATA ARRAY...
dtsize = size(tdata)
dtsize = reverse(dtsize)
datasize = dtsize[0]

;AX1 IS THE PERCENTAGE OF CHANGE THAT WE ALLOW; 1% IS THE DEFAULT...
if keyword_set( ax1) eq 0 then ax1 = 0.01

;HALFASSED IS THE MULTIPLIER FOR THE CORRECTIONS IN NONLINEAR REGIME.
if keyword_set( halfassed) eq 0 then halfassed = 0.5

;A NONZERO PROBLEM INDICATES A PROBLEM...
problem=0

;DFSTOP IS THE MAXIMUM WIDTH WE ALLOW, = 80% of the total window...
dfstop = 0.8*abs(xdata[datasize-1]-xdata[0])
dfstop = 0.8*( max( xdata)- min( xdata))

;DETERMINE NR OF GAUSSIANS TO FIT...
tau0size = size(tau0)
tau0size = reverse(tau0size)
ngaussians = tau0size[0]
if (ngaussians eq 0) then ngaussians=1
nparams= 4*ngaussians+ 1

;DEFINE THE OUTPUT GAUSSIAN PARAMETERS; SCALE WID FROM FWHM TO 1/E...
;THESE ARE THE SAME AS THE PARAMETERS THAT ARE ITERATED.
zro1 = zro0
tx1= tx0
tau1 = tau0
cen1 = cen0
wid1 = 0.6005612*wid0

nloop = 0
nloopn = 0

;DEFINE THE EQUATION-OF-CONDITION ARRAY, S...
s = fltarr(nparams, datasize)

;THIS IS THE BEGINNING OF THE ITERATION LOOP...
iterate:
nloop = nloop + 1
nloopn = nloopn + 1

tsum = fltarr( datasize) + zro1
s[0, *] = 1. + fltarr(datasize) ;THE CONSTANT

for ng = 0, ngaussians-1 do begin
    del = (xdata - cen1[ng])/wid1[ng]
    edel = exp(-del^2)
    sum1 = edel
    sum2 = edel*del
    sum3 = sum2*del
    sum6 = 2.*tau1[ng]/wid1[ng]
    s[(4*ng+1), *] = 1.- exp(-tau1(ng)*edel) 
    s[(4*ng+2), *] = tx1[ng]* edel*exp(-tau1(ng)*edel)
    s[(4*ng+3), *] = tx1[ng]* tau1[ng]* sum2*sum6*exp(-tau1(ng)*edel)
    s[(4*ng+4), *] = tx1[ng]* tau1[ng]* sum3*sum6*exp(-tau1(ng)*edel)
    tsum = tsum + tx1[ ng]*(1.- exp(-tau1(ng)*edel))
endfor

;stop
;CREATE AND SOLVE THE NORMAL EQUATION MATRICES...
t = tdata-tsum
ss = transpose(s) ## s
st = transpose(s) ## t
ssi = invert(ss)
a = ssi ## st

;CHECK THE DERIVED PARAMETERS...

;THE TXs...
delt = a[4*indgen(ngaussians)+1]
adelt = abs(delt)
adelt = 0.2*abs(tx1) < adelt
delttx = adelt*(1.- 2.*(delt lt 0.))
;print, 'tx  ', delt, delttx

;THE TAUs...
delt = a[4*indgen(ngaussians)+2]
adelt = abs(delt)
adelt = 0.2*abs(tau1) < adelt
delttau = adelt*(1.- 2.*(delt lt 0.))
;print, 'tau  ', delt, delttau

;THE CENTERS...
delt = a[4*indgen(ngaussians)+3]
adelt = abs(delt)
adelt = 0.2*abs(wid1) < adelt
deltcen = adelt*(1.- 2.*(delt lt 0.))
;print, 'cen  ', delt, deltcen

;THE WIDTHS...
delt = a[4*indgen(ngaussians)+4]
adelt = abs(delt)
adelt = 0.2*abs(wid1) < adelt
deltwid = adelt*(1.- 2.*(delt lt 0.))
;print, 'wid  ', delt, deltwid

;CHECK FOR CONVERGENCE AND REASONABLENESS...
txf = abs( delttx/tx1)
tauf = abs( delttau/tau1)
cenf = abs( deltcen/wid1)
widf = abs( deltwid/wid1)
redoit = 0
if (max( txf) gt ax1) then redoit=1
if (max( tauf) gt ax1) then redoit=1
if (max( cenf) gt ax1) then redoit=1
if (max( widf) gt ax1) then redoit=1

;INCREMENT THE PARAMETERS...
if (redoit eq 0) then halfassed = 1.0
;zro1 = zro1 + a[0]
zro1 = zro1 + halfassed*a[0]
tx1 = tx1 + halfassed*delttx
tau1 = tau1 + halfassed*delttau
cen1 = cen1 + halfassed*deltcen
wid1 = wid1 + halfassed*deltwid

;CHECK TO SEE IF WIDTH IS TOO BIG..
if (max(wid1) gt dfstop) or (min(wid1) lt 0.) then begin
    problem = -1
    ;print, 'a width is out of range...'
    goto, finished
endif

if (nloop ge nloopmax-1) then begin
    if keyword_set( quiet) eq 0 then begin
       print, nloopmax, ' loops in gfit_sat; halfassed = ', halfassed
       print, 'TRY A SMALLER VALUE OF HALFASSED...MAYBE 0.2'
    endif
		problem = -2
		goto, finished
endif

if (redoit eq 1) then goto, iterate    

;IF WE GET THIS FAR, THE FIT IS FINISHED AND SUCCESSFUL...

finished:

;CONVERT THE 1/E WIDTHS TO HALFWIDTHS...
wid1 = wid1/0.6005612
;print, 'final widths: ', wid1

;DERIVE THE FITTED POINTS, RESIDUALS, THE ERRORS IN DERIVED COEFFICIENTS...
gcurv_sat, xdata, zro1, tx1, tau1, cen1, wid1, tfit
resid = tdata - tfit
sigsq = total( resid^2)/(datasize - nparams)
sigma = sqrt( sigsq)
sigarray = sigsq * ssi[indgen(nparams)*(nparams+1)]
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
sigtx1 = sigarray[ 4*indgen(ngaussians) + 1]
sigtau1 = sigarray[ 4*indgen(ngaussians) + 2]
sigcen1 = sigarray[ 4*indgen(ngaussians) + 3]
sigwid1 = sigarray[ 4*indgen(ngaussians) + 4]/0.6005612

;DERIVE THE NORMALIZED COVARIANCE ARRAY...
doug = ssi[indgen(nparams)*(nparams+1)]
doug = doug#doug
cov = ssi/sqrt(doug)

;stop
return
end

