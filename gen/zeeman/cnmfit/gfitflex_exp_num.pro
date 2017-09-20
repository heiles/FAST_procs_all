pro gfitflex_exp_num, look, xdataa, tdataa, xrange, zro0, hgt0, cen0, wid0, $
	zro0yn, hgt0yn, cen0yn, wid0yn, $
	tfita, sigma, zro1, hgt1, cen1, wid1, $
	sigzro1, sighgt1, sigcen1, sigwid1, cov, problem
;+
;NAME:
;   GFITFLEX_EXP_NUM
;
;PURPOSE:
;    Fit multiple (N) exp(-sum of Gaussians) to a one-d array of data points, 
;	keeping any arbitrary set of parameters fixed and not included
;	in the fit.
;
;THIS IS EXACTLY LIKE GFITFLEX_EXP.PRO, EXCEPT THAT DERIVATIVES ARE
;TAKE NUMERICALLY.

;CALLING SEQUENCE:
;    GFITFLEX_EXP, look, xdata, tdata, zro0, hgt0, cen0, wid0, $
;	zro0yn, hgt0yn, cen0yn, wid0yn, $
;	tfit, sigma, zro1, hgt1, cen1, wid1, $
;	sigzro1, sighgt1, sigcen1, sigwid1, cov
;
;INPUTS:
;     look: if >=0, plots the iteratited values for the Gaussian
;     whose number is equal to look. Then it prompts you to plot 
;     a different Gaussian number.
;
;     xdata: the x-values at which the data points exist.
;     tdata: the data points.
;     xrange: 2n-element vector: 2 values for each of n index ranges
;	specifying which indices of tdata to include in the fit.
;
;     zro0: the estimated constant zero offset of the data points.
;     hgt0: the array of N estimated heights of the Gaussians.
;     cen0: the array of N estimated centers of the Gaussians.
;     wid0: the array of N estimated halfwidths of the Gaussians.
;
;     zr0yn: if 0, does not fit zero level; if 1, it does.
;     hgt0yn: array of N 0 or 1; 0 does not fit the hgt, 1 does.
;     cen0yn: array of N 0 or 1; 0 does not fit the hgt, 1 does.
;     wid0yn: array of N 0 or 1; 0 does not fit the hgt, 1 does.
;
;OUTPUTS:
;     tfita: the fitted values of the data at the points in xdata.
;     sigma: the rms of the residuals.
;     zro1: the fitted zero offset (held constant if zro0yn=0).
;     hgt1: the array of N fitted heights. 
;     cen1: the array of N fitted centers.
;     wid1: the array of N fitted half-power widths.
;     sigzro1: the error of the fitted zero offset; zero if zr0yn=0.
;     sighgt1: the array of errors of the N fitted heights; zero if hgt0yn=0).
;     sigcen1: the array of errors of the N fitted centers; zero if cen0yn=0).
;     sigwid1: the array of errors of the N fitted widths; zero if wid0yn=0).
;     problem: 0, OK; -1, excessive width; -2, >50 loops; -3, negative sigmas,
;	; 4, bad derived values.
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
;	easy case; for the estimated parameters, you need not be accurate
;	at all. The heights are hgt0=[1.5, 2.5], the centers cen0=[12., 20.],
;	and the widths are [5., 6.]. You wish to hold the width of the second
;    Gaussian fixed in the fit, so you set wid0yn=[1,0]. 
;    There are 100 data points (tdata) at 
;	100 values of x (xdata) and you want to fit indices 25-75 and
;	77-80 only, so
;	you set xrange=[50,75,77,80]. 
;    You don't wish to see plots of the iterations,
;	you don't care about the uncertainties, but you want the fitted
;	 points and also the rms of the residuals.
;
;    If you have two Gaussians that are mixed, you must be careful in
;    your estimates!
;
;RELATED PROCEDURES:
;	GCURV
;HISTORY:
;	Original GFIT Written by Carl Heiles. 21 Mar 1998.
;	FLEX options added 4 feb 00.
;-

;DETERMINE THE SIZE OF THE DATA ARRAY...
nr_of_ns = n_elements(xrange)/2
datasize = 0l
for nnr = 0, nr_of_ns-1 do datasize = datasize + xrange[2*nnr+1]-xrange[2*nnr]+1l
xdata = fltarr(datasize,/nozero)
tdata = fltarr(datasize,/nozero)

;PICK OUT THE DATA VALUES TO TREAT...
dtsiz=0l
for nnr = 0, nr_of_ns-1 do begin
dtsiz1 = dtsiz + xrange[2*nnr+1]-xrange[2*nnr] +1l
xdata[dtsiz:dtsiz1-1] = xdataa[ xrange[2*nnr]:xrange[2*nnr+1] ]
tdata[dtsiz:dtsiz1-1] = tdataa[ xrange[2*nnr]:xrange[2*nnr+1] ]
dtsiz = dtsiz1
endfor

;AX1 IS THE PERCENTAGE OF CHANGE THAT WE ALLOW; 1% IS THE DEFAULT...
ax1 = 0.01
;HALFASSED IS THE MULTIPLIER FOR THE CORRECTIONS IN NONLINEAR REGIME.
halfassed = 0.5
;A NONZERO PROBLEM INDICATES A PROBLEM...
problem=0

;DFSTOP IS THE MAXIMUM WIDTH WE ALLOW, = 80% of the total window...
dfstop = 0.8*abs(xdata[datasize-1]-xdata[0])

;DEFINE THE OUTPUT GAUSSIAN PARAMETERS; SCALE WID FROM FWHM TO 1/E...
;THESE ARE THE SAME AS THE PARAMETERS THAT ARE ITERATED.
zro1 = zro0
hgt1 = hgt0
cen1 = cen0
wid1 = 0.6005612*wid0

nloop = 0
nloopn = 0

;DETERMINE NR OF GAUSSIANS TO FIT...
ngaussians = n_elements(hgt0)

;DETERMINE THE NR OF PARAMETERS TO FIT...
nparams = total(zro0yn) + total(hgt0yn) + total(cen0yn) + total(wid0yn) 

;DEFINE THE ARRAYS THAT WILL BE PLOTTED...
hgtplot = fltarr( ngaussians, 5000)
cenplot = fltarr( ngaussians, 5000)
widplot = fltarr( ngaussians, 5000)
hgtplot[ *, nloopn] = hgt1
cenplot[ *, nloopn] = cen1
widplot[ *, nloopn] = wid1/0.6005612

;DEFINE THE EQUATION-OF-CONDITION ARRAY, S AND ITS COUNTERPART SFULL...
s = fltarr(nparams, datasize)
sfull = fltarr(3*ngaussians+1, datasize)
afull = fltarr(3*ngaussians+1)
sfull_to_s = fltarr(nparams)
s_to_sfull = fltarr(3*ngaussians+1)
;s_to_sfull = fltarr(nparams)
sigarraya = fltarr(3*ngaussians+1)

;DEFINE THE RELATIONSHIP BETWEEN COLS IN S AND SFULL...
scol = 0
sfullcol = 0
if (zro0yn ne 0) then begin 
	s_to_sfull[0] = scol
	sfull_to_s[scol]=0
	scol=scol+1 
endif

for ng=0, ngaussians-1 do begin 
if (hgt0yn[ng] ne 0) then begin 
	s_to_sfull[3*ng+1] = scol
	sfull_to_s[scol]=3*ng+1
	scol=scol+1 
endif
if (cen0yn[ng] ne 0) then begin 
	s_to_sfull[3*ng+2] = scol
	sfull_to_s[scol]=3*ng+2
	scol=scol+1 
endif
if (wid0yn[ng] ne 0) then begin 
	s_to_sfull[3*ng+3] = scol
	sfull_to_s[scol]=3*ng+3
	scol=scol+1 
endif
endfor

;THIS IS THE BEGINNING OF THE ITERATION LOOP...
iterate:
nloop = nloop + 1
nloopn = nloopn + 1

;FIRST DEFINE SFULL...
gcurv, xdata, zro1, hgt1, cen1, wid1/0.6005612, sum_of_gaussians
t_predicted = exp(-sum_of_gaussians)
expfactor = -t_predicted

;sfull[0, *] = expfactor 			;THE CONSTANT

;EVALUATE CONSTANT DERIVATIVE:
del = 0.025
zro1 = zro1 + del
gcurv, xdata, zro1, hgt1, cen1, wid1/0.6005612, tauplus
zro1 = zro1 - 2.*del
gcurv, xdata, zro1, hgt1, cen1, wid1/0.6005612, tauminus
zro1 = zro1 + del
zroder = (exp(-tauplus) - exp(-tauminus))/(2.*del)

sfull[0, *] = zroder				;THE CONSTANT

for ng = 0, ngaussians-1 do begin
    del = (xdata - cen1[ng])/wid1[ng]
    edel = exp(-del^2)
    sum1 = edel
    sum2 = edel*del
    sum3 = sum2*del
    sum6 = 2.*hgt1[ng]/wid1[ng]
;    sfull[(3*ng+1), *] = expfactor*sum1          ;HGT
;    sfull[(3*ng+2), *] = expfactor*sum2*sum6     ;CNTR
;    sfull[(3*ng+3), *] = expfactor*sum3*sum6     ;WIDTH
;EVALUATE HGT DERIVATIVE:
del = 0.025
hgt1[ng] = hgt1[ng] + del
gcurv, xdata, zro1, hgt1, cen1, wid1/0.6005612, tauplus
hgt1[ng] = hgt1[ng] - 2.*del
gcurv, xdata, zro1, hgt1, cen1, wid1/0.6005612, tauminus
hgt1[ng] = hgt1[ng] + del
hgtder = (exp(-tauplus) - exp(-tauminus))/(2.*del)

;EVALUATE CEN DERIVATIVE:
del = 0.025*wid1[ng]
cen1[ng] = cen1[ng] + del
gcurv, xdata, zro1, hgt1, cen1, wid1/0.6005612, tauplus
cen1[ng] = cen1[ng] - 2.*del
gcurv, xdata, zro1, hgt1, cen1, wid1/0.6005612, tauminus
cen1[ng] = cen1[ng] + del
cender = (exp(-tauplus) - exp(-tauminus))/(2.*del)

;EVALUATE WID DERIVATIVE:
del = 0.025*wid1[ng]
wid1[ng] = wid1[ng] + del
gcurv, xdata, zro1, hgt1, cen1, wid1/0.6005612, tauplus
wid1[ng] = wid1[ng] - 2.*del
gcurv, xdata, zro1, hgt1, cen1, wid1/0.6005612, tauminus
wid1[ng] = wid1[ng] + del
widder = (exp(-tauplus) - exp(-tauminus))/(2.*del)
    sfull[(3*ng+1), *] = hgtder          ;HGT
    sfull[(3*ng+2), *] = cender     ;CNTR
    sfull[(3*ng+3), *] = widder     ;WIDTH
endfor
s = sfull[sfull_to_s,*]

;STOP

;CREATE AND SOLVE THE NORMAL EQUATION MATRICES...
t = tdata-t_predicted
ss = transpose(s) ## s
st = transpose(s) ## transpose(t)
ssi = invert(ss)
a = ssi ## st
;afull[s_to_sfull] = a
afull[sfull_to_s] = a

;CHECK THE DERIVED PARAMETERS...

;THE AMPLITUDES...
delt = afull[3*indgen(ngaussians)+1]
adelt = abs(delt)
adelt = 0.2*abs(hgt1) < adelt
delthgt = adelt*(1.- 2.*(delt lt 0.))

;THE CENTERS...
delt = afull[3*indgen(ngaussians)+2]
adelt = abs(delt)
adelt = 0.2*abs(wid1) < adelt
deltcen = adelt*(1.- 2.*(delt lt 0.))

;THE WIDTHS...
delt = afull[3*indgen(ngaussians)+3]
adelt = abs(delt)
adelt = 0.2*abs(wid1) < adelt
deltwid = adelt*(1.- 2.*(delt lt 0.))

;CHECK FOR CONVERGENCE AND REASONABLENESS...
hgtf = abs( delthgt/hgt1)
cenf = abs( deltcen/wid1)
widf = abs( deltwid/wid1)
redoit = 0
if (max( hgtf) gt ax1) then redoit=1
if (max( cenf) gt ax1) then redoit=1
if (max( widf) gt ax1) then redoit=1

;INCREMENT THE PARAMETERS...
;halfassed = 0.5
;halfassed = 0.4
if (redoit eq 0) then halfassed = 1.0
;zro1 = zro1 + afull[0]
zro1 = zro1 + halfassed*afull[0]
hgt1 = hgt1 + halfassed*delthgt
cen1 = cen1 + halfassed*deltcen
wid1 = wid1 + halfassed*deltwid

hgtplot[ *, nloopn] = hgt1
cenplot[ *, nloopn] = cen1
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
gcurv, xdata, zro1,hgt1,cen1,wid1,sum_of_gaussians
t_predicted = exp(-sum_of_gaussians)
resid = tdata - t_predicted
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

sigarraya[sfull_to_s] = sigarray
sigzro1 = sigarraya[ 0]
sighgt1 = sigarraya[ 3*indgen(ngaussians) + 1]
sigcen1 = sigarraya[ 3*indgen(ngaussians) + 2]
sigwid1 = sigarraya[ 3*indgen(ngaussians) + 3]/0.6005612

;STOP

;DERIVE THE NORMALIZED COVARIANCE ARRAY...
doug = ssi[indgen(nparams)*(nparams+1)]
doug = doug#doug
cov = ssi/sqrt(doug)

;PLOT GAUSSIANS IF LOOK ne 0...
if (look ge 0) then begin
ng = look
xpix=250
ypix = 200
wbegin = !d.window

;SET UP THE THREE WINDOWS...
window, xsize=xpix, ysize=ypix, title = 'HEIGHT', /free, $
	xpos = 10, ypos=10
whgt = !d.window
window, xsize=xpix, ysize=ypix, title = 'CENTER', /free, $
	xpos = 10, ypos=10+(ypix+25)
wcen = !d.window
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
hgtmin = min(hgtplot[ng, 0:nloopn])
hgtmax = max(hgtplot[ng, 0:nloopn])
plot, findgen(nloopn+1), hgtplot[ng, 0:nloopn], $
    xrange=[0, nloopn], yrange=[hgtmin, hgtmax], xstyle=1, ystyle=1

wset, wcen
cenmin = min(cenplot[ng, 0:nloopn])
cenmax = max(cenplot[ng, 0:nloopn])
plot, findgen(nloopn+1), cenplot[ng, 0:nloopn], $
    xrange=[0, nloopn], yrange=[cenmin, cenmax], xstyle=1, ystyle=1

wset, wwid
widmin = min(widplot[ng, 0:nloopn])
widmax = max(widplot[ng, 0:nloopn])
plot, findgen(nloopn+1), widplot[ng, 0:nloopn], $
    xrange=[0, nloopn], yrange=[widmin, widmax], xstyle=1, ystyle=1

read, ng, prompt='enter another Gaussian number (begin from zero, not one) to plot, or < 0 to stop: '
if (ng ge 0) then goto, plotagn

wset, wbegin
wdelete, whgt
wdelete, wcen
wdelete, wwid

endif

;stop

gcurv, xdataa, zro1,hgt1,cen1,wid1,sum_of_gaussians
tfita = exp(-sum_of_gaussians)

return
end


