pro tbgfitflex_exp, look, xdataa, tdataa, xindxrange, $
	zrocnm, taucnm, cencnm, widcnm, tspincnm, ordercnm, $
	zrocnmyn, taucnmyn, cencnmyn, widcnmyn, tspincnmyn, $
	continuum, hgtwnm, cenwnm, widwnm, fwnm, $
	continuumyn, hgtwnmyn, cenwnmyn, widwnmyn, fwnmyn, $
	tfita, sigma, $
	zrocnm1, taucnm1, cencnm1, widcnm1, tspincnm1, $
	sigzrocnm1, sigtaucnm1, sigcencnm1, sigwidcnm1, sigtspincnm1, $
	continuum1, hgtwnm1, cenwnm1, widwnm1, fwnm1, $
	sigcontinuum1, sighgtwnm1, sigcenwnm1, sigwidwnm1, sigfwnm1, $
	cov, problem, nloop, $
        tb_cont=tb_cont, tb_wnm_tot=tb_wnm_tot, tb_cnm_tot=tb_cnm_tot, $
        exp_tau_sum=exp_tau_sum, nloopmax=nloopmax, halfasseduse=halfasseduse


;+
;NAME:
;   TBGFITFLEX_EXP
;
;PURPOSE:
;    Fit multiple emission/absorption gaussians to an UNSWITCHED 21-cm
;    line spectrum.
;	keeping any arbitrary set of parameters fixed and not included
;	in the fit.
;
;THIS IS EXACTLY LIKE GFITFLEX_EXP.PRO, EXCEPT THAT DERIVATIVES ARE
;TAKEN NUMERICALLY.

;CALLING SEQUENCE:
;tbgfitflex_exp, look, xdataa, tdataa, xindxrange, $
;	zrocnm, taucnm, cencnm, widcnm, tspincnm, ordercnm, $
;	zrocnmyn, taucnmyn, cencnmyn, widcnmyn, tspincnmyn, $
;	continuum, hgtwnm, cenwnm, widwnm, fwnm, $
;	continuumyn, hgtwnmyn, cenwnmyn, widwnmyn, fwnmyn, $
;	tfita, sigma, $
;	zrocnm1, taucnm1, cencnm1, widcnm1, tspincnm1, $
;	sigzrocnm1, sigtaucnm1, sigcencnm1, sigwidcnm1, sigtspincnm1, $
;	continuum1, hgtwnm1, cenwnm1, widwnm1, fwnm1, $
;	sigcontinuum1, sighgtwnm1, sigcenwnm1, sigwidwnm1, sigfwnm1, $
;	cov, problem, nloop, $
;        tb_cont=tb_cont, tb_wnm_tot=tb_wnm_tot, tb_cnm_tot=tb_cnm_tot, $
;        exp_tau_sum=exp_tau_sum, nloopmax=nloopmax, halfasseduse=halfasseduse
;
;INPUTS:
;     LOOK: if >=0, plots the iteratited values for the Gaussian
;     whose number is equal to look. Then it prompts you to plot 
;     a different Gaussian number.
;
;     XDATAA: the x-values at which the data points exist.
;     TDATAA: the data points.
;     XINDXRANGE: this specifies the channel ranges to fit
;       each range is specified by 2 nrx, the beginning and ending chnls. 
;       Example: There are 100 data points (tdata) at 
;	100 values of x (xdata) and you want to fit indices 25-75 and
;	77-80 only, soyou set xindxrange=[25,75,77,80]. 
;
;     zrocnm: the estimated constant zero offset of the CNM opacity.
;     taucnm: the array of N estimated central opacity of the CNM Gaussians.
;     cencnm: the array of N estimated centers of the CNM Gaussians.
;     widcnm: the array of N estimated halfwidths of the CNM Gaussians.
;     tspincnm: the array of N estimated spin temps of the CNM Gaussians.
;     ordercnm: the array of N estimated spin temps of the CNM Gaussians.
;
;     zrocnmyn: if 0, does not fit zero level; if 1, it does.
;     taucnmyn: array of N 0 or 1; 0 does not fit the hgt, 1 does.
;     cencnmyn: array of N 0 or 1; 0 does not fit the cen, 1 does.
;     widcnmyn: array of N 0 or 1; 0 does not fit the wid, 1 does.
;     tspincnmyn: array of N 0 or 1; 0 does not fit the tspin, 1 does.
;
;     continuum: the estimated continuum temp from beind all the
;       CNM. Normally you can't fit for this, so normally set 
;       continuumyn=0, ***SEE NOTE BELOW REGARDING CONTINUUM!!***
;     hgtwnm: the array of N estimated central intensity of the WNM Gaussians.
;     cenwnm: the array of N estimated centers of the WNM Gaussians.
;     widwnm: the array of N estimated halfwidths of the WNM Gaussians.
;     fwnm: the array of N estimated f-factors of the WNM Gaussians.
;
;     contiinuumyn: if 0, does not fit for the background continuum;
;       THIS IS THE USUAL CASE! if 1, it does.
;     hgtwnmyn: array of N 0 or 1; 0 does not fit the hgt, 1 does.
;     cenwnmyn: array of N 0 or 1; 0 does not fit the cen, 1 does.
;     widwnmyn: array of N 0 or 1; 0 does not fit the wid, 1 does.
;     fwnmyn: array of N 0 or 1; 0 does not fit the fwnm, 1 does.
;
;OUTPUTS:
;     tfita: the fitted values of the data at the points in xdata.
;     sigma: the rms of the residuals.
;
;     zrocnm1: fitted zero offset for CNM opacity (held constant if zrocnmyn=0).
;     taucnm1: the array of N fitted CNM central opacities;
;     cencnm1: the array of N fitted CNM centers.
;     widcnm1: the array of N fitted CNM half-power widths.
;     tspincnm1: the array of N fitted CNM tspins.
;     sigzrocnm1: the error of the fitted CNM zero offset; zero if zrocnmyn=0.
;     sigtaucnm1: the array of errors of the CNM heights; zero if taucnmyn=0).
;     sigcencnm1: the array of errors of the CNM centers; zero if cencnmyn=0).
;     sigwidcnm1: the array of errors of the CNM widths; zero if widcnmyn=0).
;     sigtspincnm1: the array of errors of   CNM tspins; zero if tspincnmyn=0).
;     continuum1: fitted zero offset for WNM opacity (held constant if continuumyn=0).
;     hgtwnm1: the array of N fitted WNM central opacities;
;     cenwnm1: the array of N fitted WNM centers.
;     widwnm1: the array of N fitted WNM half-power widths.
;     fwnm1: the array of N fitted WNM f-factors.
;     sigcontinuum1: the error of the fitted WNM zero offset; zero if continuumyn=0.
;     sighgtwnm1: the array of errors of the WNM heights; zero if hgtwnmyn=0).
;     sigcenwnm1: the array of errors of the WNM centers; zero if cenwnmyn=0).
;     sigfwnm1: the array of errors of the WNM f-factors; zero if fwnmyn=0).
;
;     problem: 0, OK; -1, excessive width; -2, >50 loops; -3, negative sigmas,
;	; 4, bad derived values.
;     cov: the normalized covariance matrix of the fitted coefficients.
;
;OPTIONAL OUTPUTS:
;      tb_cont, the observed background continuum (absorbed by cnm)
;      tb_wnm_tot, the observed contribution from the WNM 
;      tb_cnm_tot, the observed contribution from the CNM
;      exp_tau_sum, the total optical depth spectrum from all CNM components
;      nloopmax=nloopmasx, max nr of iterations; defaut is 50
;      halfasseduse=halfasseduse, mult fctr for corrections; defauult is 0.5
;
;NOTE REGARDING CONTINUUM:
;       This program is written for a 'total power' spectrum that is NOT
;frequency switched. Thus, it fits
;       T_A = T_s [ 1 - exp(-tau)] + [T_W + T_C] exp(-tau)
;where
;       T_A is observed antenna temp
;       T_x is spin temp for a particular Gaussian component
;       tau is the Gaussian-shaped optical depth profile for a
;particular Gaussian component representing the CNM
;       T_W is the background 21-cm emission absorbed by the CNM
;component
;       T_C is the background continuum absorbed by the CNM component,
;which includes the CBR, Galactic synchrotron background, and 'point
;source' continuum.
;------->>>> see the accompanying latex file tbgfitflex_exp.pdf <<<<-------

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
;    of iterations is limited to a default NLOOPMAX=50; if you need
;    more, change the keyword NLOOPMAX. Also, if convergence is a
;    problem, reduce halfasseduse from its default value of 0.5 to, say,
;    0.1 (and you will then need to increase NLOOPMAX).
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
;	you set xindxrange=[25,75,77,80]. 
;    You don't wish to see plots of the iterations,
;	you don't care about the uncertainties, but you want the fitted
;	 points and also the rms of the residuals.
;
;    If you have two Gaussians that are mixed, you must be careful in
;    your estimates!
;
;RELATED PROCEDURES:
;	TB_EXP
;HISTORY:
;	12 MAR 2000
;       08may2012: clarified 'continuum' usage.
;       25may2012: changed some numerical derivative 'del' values from
;       fractional to constant. see embedded comments.
;       15dec2012: see 'notes' file. problem with one case, with the
;       solutions converging but to the wrong solution. tried changing
;       increment for numerical derivatives ('delc', below); no effect.
;-

;common plotcolors

;delc=0.0000025d0
delc=0.001
;print, 'tbgf...***** delc= ', delc

dp600 = 0.5d0/(sqrt(-alog(0.5d0)))
dp600= 1.0

;DETERMINE THE SIZE OF THE DATA ARRAY...
nr_of_ns = n_elements(xindxrange)/2
datasize = 0l
for nnr = 0, nr_of_ns-1 do datasize = datasize + xindxrange[2*nnr+1]-xindxrange[2*nnr]+1l
xdata = dblarr(datasize,/nozero)
tdata = dblarr(datasize,/nozero)

;stop

;PICK OUT THE DATA VALUES TO TREAT...
dtsiz=0l
for nnr = 0, nr_of_ns-1 do begin
dtsiz1 = dtsiz + xindxrange[2*nnr+1]-xindxrange[2*nnr] +1l
xdata[dtsiz:dtsiz1-1] = double(xdataa[ xindxrange[2*nnr]:xindxrange[2*nnr+1] ])
tdata[dtsiz:dtsiz1-1] = double(tdataa[ xindxrange[2*nnr]:xindxrange[2*nnr+1] ])
dtsiz = dtsiz1
endfor

;AX1 IS THE PERCENTAGE OF CHANGE THAT WE ALLOW; 1% IS THE DEFAULT...
ax1 = 0.01d0
ax1 = 0.003d0
;ax1 = 0.0003d0

;HALFASSED IS THE MULTIPLIER FOR THE CORRECTIONS IN NONLINEAR REGIME.
if n_elements( halfasseduse) eq 0 then halfassed = 0.5d0 else halfassed=halfasseduse

if n_elements( nloopmax) eq 0 then nloopmax=50

;A NONZERO PROBLEM INDICATES A PROBLEM...
problem=0

;DFSTOP IS THE MAXIMUM WIDTH WE ALLOW, = 80% of the total window...
dfstop = double( 0.8*abs(xdata[datasize-1]-xdata[0]) )

;DEFINE THE OUTPUT GAUSSIAN PARAMETERS; SCALE WID FROM FWHM TO 1/E...
;THESE ARE THE SAME AS THE PARAMETERS THAT ARE ITERATED.
zrocnm1 = double( zrocnm)
taucnm1 = double( taucnm)
cencnm1 = double( cencnm)
widcnm1 = double( dp600*widcnm)
tspincnm1 = double( tspincnm)

continuum1 = double( continuum)
hgtwnm1 = double( hgtwnm)
cenwnm1 = double( cenwnm)
widwnm1 = double( dp600*widwnm)
fwnm1 = double( fwnm)

nloop = 0
nloopn = 0

;DETERMINE NR OF CNM AND WNM GAUSSIANS TO FIT...
ngaussians_cnm = n_elements(taucnm)
ngaussians_wnm = n_elements(hgtwnm)

;DETERMINE THE NR OF PARAMETERS TO FIT...
nparams = total(zrocnmyn) + total(taucnmyn) + total(cencnmyn) + $
	total(widcnmyn) + total(tspincnmyn) + $ 
	total(continuumyn) + total(hgtwnmyn) + total(cenwnmyn) + $
	total(widwnmyn) + total(fwnmyn) 

;DETERNUBE THT TOTAL NR OF PARAMGERS THAT WOULD BE FIT IF ALL YN'S = 1...
nparams_max = 2 + 4*(ngaussians_cnm + ngaussians_wnm)

;;DEFINE THE ARRAYS THAT WILL BE PLOTTED...
;hgtplot = fltarr( ngaussians, 5000)
;cenplot = fltarr( ngaussians, 5000)
;widplot = fltarr( ngaussians, 5000)
;hgtplot[ *, nloopn] = hgt1
;cenplot[ *, nloopn] = cen1
;widplot[ *, nloopn] = wid1/dp600

;DEFINE THE EQUATION-OF-CONDITION ARRAY, S AND ITS COUNTERPART SFULL...
s = dblarr(nparams, datasize)
sfull = dblarr(nparams_max, datasize)
afull = dblarr(nparams_max)
sfull_to_s = fltarr(nparams)
sigarraya = dblarr(nparams_max)

;DEFINE THE RELATIONSHIP BETWEEN COLS IN S AND SFULL...
;BEGIN WITH THE CNM PARAMETERS...
scol = 0
sfullcol = 0

if (zrocnmyn ne 0) then begin 
	sfull_to_s[scol]=sfullcol
	scol=scol+1 
endif
sfullcol = sfullcol + 1

for ng=0, ngaussians_cnm-1 do begin 
if (taucnmyn[ng] ne 0) then begin 
	sfull_to_s[scol]=sfullcol
	scol=scol+1 
endif
sfullcol = sfullcol + 1

if (cencnmyn[ng] ne 0) then begin 
	sfull_to_s[scol]=sfullcol
	scol=scol+1 
endif
sfullcol = sfullcol + 1

if (widcnmyn[ng] ne 0) then begin 
	sfull_to_s[scol]=sfullcol
	scol=scol+1 
endif
sfullcol = sfullcol + 1

if (tspincnmyn[ng] ne 0) then begin 
	sfull_to_s[scol]=sfullcol
	scol=scol+1 
endif
sfullcol = sfullcol + 1

endfor

;THEN DO THE WNM PARAMETERS...

if (continuumyn ne 0) then begin 
	sfull_to_s[scol]=sfullcol
	scol=scol+1 
endif
sfullcol = sfullcol + 1

for ng=0, ngaussians_wnm-1 do begin 
if (hgtwnmyn[ng] ne 0) then begin 
	sfull_to_s[scol]=sfullcol
	scol=scol+1 
endif
sfullcol = sfullcol + 1

if (cenwnmyn[ng] ne 0) then begin 
	sfull_to_s[scol]=sfullcol
	scol=scol+1 
endif
sfullcol = sfullcol + 1

if (widwnmyn[ng] ne 0) then begin 
	sfull_to_s[scol]=sfullcol
	scol=scol+1 
endif
sfullcol = sfullcol + 1

if (fwnmyn[ng] ne 0) then begin 
	sfull_to_s[scol]=sfullcol
	scol=scol+1 
endif
sfullcol = sfullcol + 1

endfor

;THIS IS THE BEGINNING OF THE ITERATION LOOP...
iterate:
nloop = nloop + 1
nloopn = nloopn + 1

sfullcol = 0

;EVALUATE CONSTANT DERIVATIVE FOR CNM:
;del = 0.0000025d0
del = delc
zrocnm1 = zrocnm1 + del
tb_exp, xdata, $
	zrocnm1, taucnm1, cencnm1, widcnm1/dp600, tspincnm1, ordercnm, $
        continuum1, hgtwnm1, cenwnm1, widwnm1/dp600, fwnm1, $
        tb_cont, tb_wnm_tot, tb_cnm_tot, tb_totplus, exp_tau_sum
zrocnm1 = zrocnm1 - 2.*del
tb_exp, xdata, $
	zrocnm1, taucnm1, cencnm1, widcnm1/dp600, tspincnm1, ordercnm, $
        continuum1, hgtwnm1, cenwnm1, widwnm1/dp600, fwnm1, $
        tb_cont, tb_wnm_tot, tb_cnm_tot, tb_totminus, exp_tau_sum
zrocnm1 = zrocnm1 + del
zrocnmder = (tb_totplus - tb_totminus)/(2.*del)

;STOP

sfull[sfullcol, *] = zrocnmder				;THE CONSTANT
sfullcol = sfullcol + 1

;WORK THROUGH CNM GAUSSIANS...
for ng = 0, ngaussians_cnm - 1 do begin

;EVALUATE HGT DERIVATIVE:
;del = 0.0000025D0
del = delc* taucnm1[ng]
taucnm1[ng] = taucnm1[ng] + del
tb_exp, xdata, $
	zrocnm1, taucnm1, cencnm1, widcnm1/dp600, tspincnm1, ordercnm, $
        continuum1, hgtwnm1, cenwnm1, widwnm1/dp600, fwnm1, $
        tb_cont, tb_wnm_tot, tb_cnm_tot, tb_totplus, exp_tau_sum
taucnm1[ng] = taucnm1[ng] -2.* del
tb_exp, xdata, $
	zrocnm1, taucnm1, cencnm1, widcnm1/dp600, tspincnm1, ordercnm, $
        continuum1, hgtwnm1, cenwnm1, widwnm1/dp600, fwnm1, $
        tb_cont, tb_wnm_tot, tb_cnm_tot, tb_totminus, exp_tau_sum
taucnm1[ng] = taucnm1[ng] + del
tauder = (tb_totplus - tb_totminus)/(2.*del)

;EVALUATE CEN DERIVATIVE:
;del = 0.0000025*widcnm1[ng]
del = delc* widcnm1[ng]
cencnm1[ng] = cencnm1[ng] + del
tb_exp, xdata, $
	zrocnm1, taucnm1, cencnm1, widcnm1/dp600, tspincnm1, ordercnm, $
        continuum1, hgtwnm1, cenwnm1, widwnm1/dp600, fwnm1, $
        tb_cont, tb_wnm_tot, tb_cnm_tot, tb_totplus, exp_tau_sum
cencnm1[ng] = cencnm1[ng] - 2.*del
tb_exp, xdata, $
	zrocnm1, taucnm1, cencnm1, widcnm1/dp600, tspincnm1, ordercnm, $
        continuum1, hgtwnm1, cenwnm1, widwnm1/dp600, fwnm1, $
        tb_cont, tb_wnm_tot, tb_cnm_tot, tb_totminus, exp_tau_sum
cencnm1[ng] = cencnm1[ng] + del
cender = (tb_totplus - tb_totminus)/(2.*del)

;EVALUATE WID DERIVATIVE:
;del = 0.0000025*widcnm1[ng]
del = delc* widcnm1[ng]
widcnm1[ng] = widcnm1[ng] + del
tb_exp, xdata, $
	zrocnm1, taucnm1, cencnm1, widcnm1/dp600, tspincnm1, ordercnm, $
        continuum1, hgtwnm1, cenwnm1, widwnm1/dp600, fwnm1, $
        tb_cont, tb_wnm_tot, tb_cnm_tot, tb_totplus, exp_tau_sum
widcnm1[ng] = widcnm1[ng] - 2.*del
tb_exp, xdata, $
	zrocnm1, taucnm1, cencnm1, widcnm1/dp600, tspincnm1, ordercnm, $
        continuum1, hgtwnm1, cenwnm1, widwnm1/dp600, fwnm1, $
        tb_cont, tb_wnm_tot, tb_cnm_tot, tb_totminus, exp_tau_sum
widcnm1[ng] = widcnm1[ng] + del
widder = (tb_totplus - tb_totminus)/(2.*del)

;EVALUATE TSPIN DERIVATIVE:
;del = 0.0000025*tspincnm1[ng] change 25may2012
;del = 0.0000025* 100.d0
del= delc
tspincnm1[ng] = tspincnm1[ng] + del
tb_exp, xdata, $
	zrocnm1, taucnm1, cencnm1, widcnm1/dp600, tspincnm1, ordercnm, $
        continuum1, hgtwnm1, cenwnm1, widwnm1/dp600, fwnm1, $
        tb_cont, tb_wnm_tot, tb_cnm_tot, tb_totplus, exp_tau_sum
tspincnm1[ng] = tspincnm1[ng] -2.*del
tb_exp, xdata, $
	zrocnm1, taucnm1, cencnm1, widcnm1/dp600, tspincnm1, ordercnm, $
        continuum1, hgtwnm1, cenwnm1, widwnm1/dp600, fwnm1, $
        tb_cont, tb_wnm_tot, tb_cnm_tot, tb_totminus, exp_tau_sum
tspincnm1[ng] = tspincnm1[ng] + del
tspinder = (tb_totplus - tb_totminus)/(2.*del)

    sfull[ sfullcol, *] = tauder     ;HGT
sfullcol = sfullcol + 1
    sfull[ sfullcol, *] = cender     ;CNTR
sfullcol = sfullcol + 1
    sfull[ sfullcol, *] = widder     ;WIDTH
sfullcol = sfullcol + 1
    sfull[ sfullcol, *] = tspinder   ;TSPIN
sfullcol = sfullcol + 1

endfor

;STOP

;EVALUATE CONSTANT DERIVATIVE FOR WNM:
;del = 0.0000025d0* 10.d0
del= delc
continuum1 = continuum1 + del
tb_exp, xdata, $
	zrocnm1, taucnm1, cencnm1, widcnm1/dp600, tspincnm1, ordercnm, $
        continuum1, hgtwnm1, cenwnm1, widwnm1/dp600, fwnm1, $
        tb_cont, tb_wnm_tot, tb_cnm_tot, tb_totplus, exp_tau_sum
continuum1 = continuum1 - 2.*del
tb_exp, xdata, $
	zrocnm1, taucnm1, cencnm1, widcnm1/dp600, tspincnm1, ordercnm, $
        continuum1, hgtwnm1, cenwnm1, widwnm1/dp600, fwnm1, $
        tb_cont, tb_wnm_tot, tb_cnm_tot, tb_totminus, exp_tau_sum
continuum1 = continuum1 + del
continuumder = (tb_totplus - tb_totminus)/(2.*del)

sfull[sfullcol, *] = continuumder				;THE CONSTANT
sfullcol = sfullcol + 1

;WORK THROUGH wnm GAUSSIANS...
for ng = 0, ngaussians_wnm - 1 do begin

;EVALUATE HGT DERIVATIVE:
;del = 0.0000025d0* 10.d0
del= delc* hgtwnm1[ ng]
hgtwnm1[ng] = hgtwnm1[ng] + del
tb_exp, xdata, $
	zrocnm1, taucnm1, cencnm1, widcnm1/dp600, tspincnm1, ordercnm, $
        continuum1, hgtwnm1, cenwnm1, widwnm1/dp600, fwnm1, $
        tb_cont, tb_wnm_tot, tb_cnm_tot, tb_totplus, exp_tau_sum
hgtwnm1[ng] = hgtwnm1[ng] -2.* del
tb_exp, xdata, $
	zrocnm1, taucnm1, cencnm1, widcnm1/dp600, tspincnm1, ordercnm, $
        continuum1, hgtwnm1, cenwnm1, widwnm1/dp600, fwnm1, $
        tb_cont, tb_wnm_tot, tb_cnm_tot, tb_totminus, exp_tau_sum
hgtwnm1[ng] = hgtwnm1[ng] + del
hgtder = (tb_totplus - tb_totminus)/(2.*del)

;EVALUATE CEN DERIVATIVE:
;del = 0.0000025*widwnm1[ng]
del = delc* widwnm1[ng]
cenwnm1[ng] = cenwnm1[ng] + del
tb_exp, xdata, $
	zrocnm1, taucnm1, cencnm1, widcnm1/dp600, tspincnm1, ordercnm, $
        continuum1, hgtwnm1, cenwnm1, widwnm1/dp600, fwnm1, $
        tb_cont, tb_wnm_tot, tb_cnm_tot, tb_totplus, exp_tau_sum
cenwnm1[ng] = cenwnm1[ng] - 2.*del
tb_exp, xdata, $
	zrocnm1, taucnm1, cencnm1, widcnm1/dp600, tspincnm1, ordercnm, $
        continuum1, hgtwnm1, cenwnm1, widwnm1/dp600, fwnm1, $
        tb_cont, tb_wnm_tot, tb_cnm_tot, tb_totminus, exp_tau_sum
cenwnm1[ng] = cenwnm1[ng] + del
cender = (tb_totplus - tb_totminus)/(2.*del)

;EVALUATE WID DERIVATIVE:
;del = 0.0000025*widwnm1[ng]
del = delc*widwnm1[ng]
widwnm1[ng] = widwnm1[ng] + del
tb_exp, xdata, $
	zrocnm1, taucnm1, cencnm1, widcnm1/dp600, tspincnm1, ordercnm, $
        continuum1, hgtwnm1, cenwnm1, widwnm1/dp600, fwnm1, $
        tb_cont, tb_wnm_tot, tb_cnm_tot, tb_totplus, exp_tau_sum
widwnm1[ng] = widwnm1[ng] - 2.*del
tb_exp, xdata, $
	zrocnm1, taucnm1, cencnm1, widcnm1/dp600, tspincnm1, ordercnm, $
        continuum1, hgtwnm1, cenwnm1, widwnm1/dp600, fwnm1, $
        tb_cont, tb_wnm_tot, tb_cnm_tot, tb_totminus, exp_tau_sum
widwnm1[ng] = widwnm1[ng] + del
widder = (tb_totplus - tb_totminus)/(2.*del)

;EVALUATE F DERIVATIVE:
;del = 0.0000025 * fwnm1[ng]; change 25may2012
;del = 0.0000025d0
del = delc
fwnm1[ng] = fwnm1[ng] + del
tb_exp, xdata, $
	zrocnm1, taucnm1, cencnm1, widcnm1/dp600, tspincnm1, ordercnm, $
        continuum1, hgtwnm1, cenwnm1, widwnm1/dp600, fwnm1, $
        tb_cont, tb_wnm_tot, tb_cnm_tot, tb_totplus, exp_tau_sum
fwnm1[ng] = fwnm1[ng] -2.*del
tb_exp, xdata, $
	zrocnm1, taucnm1, cencnm1, widcnm1/dp600, tspincnm1, ordercnm, $
        continuum1, hgtwnm1, cenwnm1, widwnm1/dp600, fwnm1, $
        tb_cont, tb_wnm_tot, tb_cnm_tot, tb_totminus, exp_tau_sum
fwnm1[ng] = fwnm1[ng] + del
fder = (tb_totplus - tb_totminus)/(2.*del)

    sfull[ sfullcol, *] = hgtder     ;HGT
sfullcol = sfullcol + 1
    sfull[ sfullcol, *] = cender     ;CNTR
sfullcol = sfullcol + 1
    sfull[ sfullcol, *] = widder     ;WIDTH
sfullcol = sfullcol + 1
    sfull[ sfullcol, *] = fder   ;f
sfullcol = sfullcol + 1

endfor

;STOP

s = sfull[sfull_to_s,*]

;CALCULATE T_PREDICTED...
tb_exp, xdata, $
	zrocnm1, taucnm1, cencnm1, widcnm1/dp600, tspincnm1, ordercnm, $
        continuum1, hgtwnm1, cenwnm1, widwnm1/dp600, fwnm1, $
        tb_cont, tb_wnm_tot, tb_cnm_tot, t_predicted, exp_tau_sum

;STOP

;CREATE AND SOLVE THE NORMAL EQUATION MATRICES...
t = tdata-t_predicted
;STOP
ss = transpose(s) ## s
st = transpose(s) ## transpose(t)
ssi = invert(ss)
a = ssi ## st
afull[sfull_to_s] = a

;CHECK THE DERIVED CNM PARAMETERS...

;THE CNM AMPLITUDES...
delt = afull[ 4*indgen(ngaussians_cnm) + 1 ]
adelt = abs(delt)
adelt = 0.2*abs(taucnm1) < adelt
delttaucnm = adelt*(1.- 2.*(delt lt 0.))

;THE CNM CENTERS...
delt = afull[ 4*indgen(ngaussians_cnm) + 2 ]
adelt = abs(delt)
adelt = 0.2*abs(widcnm1) < adelt
deltcencnm = adelt*(1.- 2.*(delt lt 0.))

;THE CNM WIDTHS...
delt = afull[ 4*indgen(ngaussians_cnm)+3 ]
adelt = abs(delt)
adelt = 0.2*abs(widcnm1) < adelt
deltwidcnm = adelt*(1.- 2.*(delt lt 0.))

;THE CNM TSPINS...
delt = afull[ 4*indgen(ngaussians_cnm)+4 ]
adelt = abs(delt)
adelt = 0.2*abs(tspincnm1) < adelt
delttspincnm = adelt*(1.- 2.*(delt lt 0.))

;CHECK FOR CONVERGENCE AND REASONABLENESS FOR THE CNM PARAMETERS...
hgtf = abs( delttaucnm/taucnm1)
cenf = abs( deltcencnm/widcnm1)
widf = abs( deltwidcnm/widcnm1)
tspinf = abs( delttspincnm/tspincnm1)
redoit = 0
if (max( hgtf) gt ax1) then redoit=1
if (max( cenf) gt ax1) then redoit=1
if (max( widf) gt ax1) then redoit=1
if (max( tspinf) gt ax1) then redoit=1

;CHECK THE DERIVED WNM PARAMETERS...
;print, nloop, afull[0],delttaucnm[0], deltcencnm[0], deltwidcnm[0]
;THE WNM AMPLITUDES...
delt = afull[ 4*indgen(ngaussians_wnm) + 4*ngaussians_cnm + 2 ]
adelt = abs(delt)
adelt = 0.2*abs(hgtwnm1) < adelt
delthgtwnm = adelt*(1.- 2.*(delt lt 0.))

;THE WNM CENTERS...
delt = afull[ 4*indgen(ngaussians_wnm) + 4*ngaussians_cnm + 3 ]
adelt = abs(delt)
adelt = 0.2*abs(widwnm1) < adelt
deltcenwnm = adelt*(1.- 2.*(delt lt 0.))

;THE WNM WIDTHS...
delt = afull[ 4*indgen(ngaussians_wnm) + 4*ngaussians_cnm + 4 ]
adelt = abs(delt)
adelt = 0.2*abs(widwnm1) < adelt
deltwidwnm = adelt*(1.- 2.*(delt lt 0.))

;THE WNM F'S...
delt = afull[ 4*indgen(ngaussians_wnm) + 4*ngaussians_cnm + 5 ]
adelt = abs(delt)
adelt = 0.2*abs(fwnm1) < adelt
deltfwnm = adelt*(1.- 2.*(delt lt 0.))

;CHECK FOR CONVERGENCE AND REASONABLENESS FOR THE wnm PARAMETERS...
hgtwnmf = abs( delthgtwnm/hgtwnm1)
cenwnmf = abs( deltcenwnm/widwnm1)
widwnmf = abs( deltwidwnm/widwnm1)
fwnmf = abs( deltfwnm/fwnm1)

if (max( hgtwnmf) gt ax1) then redoit=1
if (max( cenwnmf) gt ax1) then redoit=1
if (max( widwnmf) gt ax1) then redoit=1
if (max( fwnmf) gt ax1) then redoit=1

;INCREMENT THE PARAMETERS...
;halfassed = 0.5
;halfassed = 0.4
if (redoit eq 0) then halfassed = 1.0
zrocnm1 = zrocnm1 + halfassed * afull[ 0]
taucnm1 = taucnm1 + halfassed * delttaucnm
cencnm1 = cencnm1 + halfassed * deltcencnm
widcnm1 = widcnm1 + halfassed * deltwidcnm
tspincnm1 = tspincnm1 + halfassed * delttspincnm

continuum1 = continuum1 + halfassed * afull[ 4*ngaussians_cnm + 1]
hgtwnm1 = hgtwnm1 + halfassed * delthgtwnm
cenwnm1 = cenwnm1 + halfassed * deltcenwnm
widwnm1 = widwnm1 + halfassed * deltwidwnm
fwnm1 = fwnm1 + halfassed * deltfwnm

;hgtplot[ *, nloopn] = hgt1
;cenplot[ *, nloopn] = cen1
;widplot[ *, nloopn] = wid1/dp600

;print, a, format='(11f9.4)'
;if (nloop lt 30) then redoit=1

;STOP

;CHECK TO SEE IF WIDTH IS TOO BIG..but ignore if these params are fixed.
;if ( 	(max(widcnm1) gt dfstop) or $
;	(min(widcnm1) lt 0.)     or $
;	(max(widwnm1) gt dfstop) or $
;	(min(widwnm1) lt 0.) ) then begin
if ( 	(max(widcnmyn*widcnm1) gt dfstop) or $
	(min(widcnmyn*widcnm1) lt 0.)     or $
	(max(widwnmyn*widwnm1) gt dfstop) or $
	(min(widwnmyn*widwnm1) lt 0.) ) then begin
    problem = -1
;    print, 'a width is out of range...'
    goto, finished
endif

if (nloop ge nloopmax-1) then begin
;    print, '50 loops; halfassed = ', halfassed
;	if (halfassed lt .1) then goto, finished
;	if (halfassed lt .005) then begin
		problem = -2
		goto, finished
;	endif
;	halfassed=halfassed/2.
;	nloop=-1
endif

;STOP

if (redoit eq 1) then goto, iterate    

;IF WE GET THIS FAR, THE FIT IS FINISHED AND SUCCESSFUL...

finished:

;CONVERT THE 1/E WIDTHS TO HALFWIDTHS...
widcnm1 = widcnm1/dp600
widwnm1 = widwnm1/dp600

;print, 'final CNM widths: ', widcnm1
;print, 'final WNM widths: ', widwnm1

;DERIVE THE FITTED POINTS, RESIDUALS, THE ERRORS IN DERIVED COEFFICIENTS...
;NOTE THAT THE WIDTHS HAVE BEEN CONVERTED TO HALFWIDTHS HERE, SO THE
;0.6 FACTORS ARE NOT REQUIRED...
tb_exp, xdata, $
;	zrocnm1, taucnm1, cencnm1, widcnm1/dp600, tspincnm1, ordercnm, $
;        continuum1, hgtwnm1, cenwnm1, widwnm1/dp600, fwnm1, $
	zrocnm1, taucnm1, cencnm1, widcnm1, tspincnm1, ordercnm, $
        continuum1, hgtwnm1, cenwnm1, widwnm1, fwnm1, $
        tb_cont, tb_wnm_tot, tb_cnm_tot, t_predicted, exp_tau_sum
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
sigzrocnm1 = sigarraya[ 0]
sigtaucnm1 = sigarraya[ 4*indgen(ngaussians_cnm) + 1]
sigcencnm1 = sigarraya[ 4*indgen(ngaussians_cnm) + 2]
sigwidcnm1 = sigarraya[ 4*indgen(ngaussians_cnm) + 3]/dp600
sigtspincnm1 = sigarraya[ 4*indgen(ngaussians_cnm) + 4]

sigcontinuum1 = sigarraya[ 4*ngaussians_cnm + 1]
sighgtwnm1 = sigarraya[ 4*indgen(ngaussians_wnm) + 4*ngaussians_cnm + 2]
sigcenwnm1 = sigarraya[ 4*indgen(ngaussians_wnm) + 4*ngaussians_cnm + 3]
sigwidwnm1 = sigarraya[ 4*indgen(ngaussians_wnm) + 4*ngaussians_cnm + 4]/dp600
sigfwnm1   = sigarraya[ 4*indgen(ngaussians_wnm) + 4*ngaussians_cnm + 5]

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
    xindxrange=[0, nloopn], yrange=[hgtmin, hgtmax], xstyle=1, ystyle=1

wset, wcen
cenmin = min(cenplot[ng, 0:nloopn])
cenmax = max(cenplot[ng, 0:nloopn])
plot, findgen(nloopn+1), cenplot[ng, 0:nloopn], $
    xindxrange=[0, nloopn], yrange=[cenmin, cenmax], xstyle=1, ystyle=1

wset, wwid
widmin = min(widplot[ng, 0:nloopn])
widmax = max(widplot[ng, 0:nloopn])
plot, findgen(nloopn+1), widplot[ng, 0:nloopn], $
    xindxrange=[0, nloopn], yrange=[widmin, widmax], xstyle=1, ystyle=1

read, ng, prompt='enter another Gaussian number (begin from zero, not one) to plot, or < 0 to stop: '
if (ng ge 0) then goto, plotagn

wset, wbegin
wdelete, whgt
wdelete, wcen
wdelete, wwid

endif

;stop

;NOTE THAT THE WIDTHS HAVE BEEN CONVERTED TO HALFWIDTHS HERE, SO THE
;0.6 FACTORS ARE NOT REQUIRED...
tb_exp, xdata, $
;	zrocnm1, taucnm1, cencnm1, widcnm1/dp600, tspincnm1, ordercnm, $
;        continuum1, hgtwnm1, cenwnm1, widwnm1/dp600, fwnm1, $
	zrocnm1, taucnm1, cencnm1, widcnm1, tspincnm1, ordercnm, $
        continuum1, hgtwnm1, cenwnm1, widwnm1, fwnm1, $
        tb_cont, tb_wnm_tot, tb_cnm_tot, tfita, exp_tau_sum

return
end


