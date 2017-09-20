pro g2dfit_allcal, sigmalimit, $
    delt_zaencoder, az_scan, za_scan, totoffset, stokesoffset_cont, $
    hgt_lobe, cen_lobe, wid_lobe, $
    tsys0, dtsys_dza0, tsrc0, az_bmcntr0, za_bmcntr0, $
    bmwid_00, bmwid_10, phi_bm0, alpha_coma0, phi_coma0, $
    tfit, sigma, tsys, dtsys_dza, tsrc, az_bmcntr, za_bmcntr, $
    bmwid_0, bmwid_1, phi_bm, alpha_coma, phi_coma, $
    sigtsys, sigdtsys_dza, sigtsrc, sigaz_bmcntr, sigza_bmcntr, $
    sigbmwid_0, sigbmwid_1, sigphi_bm, sigalpha_coma, sigphi_coma, $
    problem, nloop, cov

;+
;NAME:
;   G2DFIT

;PURPOSE:

;   A 2d nonlinear least squares fit to central beam including coma
;and elliptical beam with arbitrary position angle. Called from
;BEAM2D_DESCRIBE.

;   ***IN CONTRAST TO MOST OF OUR GFITTING ROUTINES, HERE THE
;INPUTS AND OUTPUTS ARE 1/E WIDTHS!!!***

;INPUTS:

;---------FIRST, THE OBSERVED DATA FROM THE TELESCOPE--------

;   SIGMALIMIT: for residuals about SIGMALIMIT*sigma, the points are
;discarded and the fit is tried again. Usually, SIGMALILMIT = 3,
;hardwired in beam2d_describe.

;       DELT_ZAENCODER is the set of 240 zenith angles from the encoder
;MINUS an offset ;which should be the mean of the za_encoder values
;makes the fit meaningful)

;       AZ_SCAN is the set of 240 az offsets from assumed beam center
;       ZA_SCAN is the set of 240 za offset from assumed beam center
;   TOTOFFSET is the set of 240 offsets from center. It's the same for
;each strip. 

;   STOKESOFFSET_CONT is the set of system temps for each point
;(includes both the rcvr temp and source deflection)

;--------NEXT, THE GUESSED PARAMETERS OF THIS FUNCTION--------
;FOR THE CENTRAL GAUSSIAN:
;       TSYS0 is the off-source system temp
;       DTSYS/DZA0 is the derivative of TSYS wrt ZA
;       TSRC0 is the height of the beam center
;       AZ_BMCNTR0 is the az offset of assumed beam cntr from true beam cntr
;       ZA_BMCNTR0 is the za offset of assumed beam cntr from true beam cntr
;       BMWID_00 is the constant term in the beamwidth (***1/e***)
;       BMWID_10 is the coefficient of the 2-phi term in the beamwidth (1/e)
;       PHI_BM0 is the angle of the major axis wrt az=0 of the ellipse
;               of the beam. ***RADIANS***
;       ALPHA_COMA0 is the magnitude of the coma lobe
;       PHI_COMA0 is the angle of the coma lobe wrt az=0. RADIANS.

;FOR THE SIDELOBE GAUSSIANS:
;   HGT_LOBE, CEN_LOBE, WID_LOBE are arrays of the hgt, cen, and wid
;of the sidelobe Gaussians from the 1d fit and are used as the guessed
;parameters. These arrays are of size [2, npatterns]

;OUTPUTS:

;   THE DERIVED PARAMETERS FROM THE LS FIT. They are identical to
;the guessed parameters, except that the suffix '0' is '1'. For example,
;TSYS1, DTSYS/DZA1, etc.

;   PROBLEM: a nonzero value indicates a problem with the ls fit.
;Look at the code to figure out what they mean.

;   NLOOP: the number of loops required for convergence of the
;nonlinear ls fit for the final fit after all bad points are discarded.

;   COV: the normalized covariance matrix of the fitted coefficients.

;RELATED PROCEDURES:
;   G2DCURV

;HISTORY:
;   MODIFIED 28 OCT 00 TO CHANGE CRITERIA FOR ACCEPTING CHANGES
;IN THE ANGLES PHI_BM0 AND PHI_COMA0
;-

;DETERMINE THE SIZE OF THE ORIGINAL DATA ARRAYS...
alldatasize = n_elements( az_scan)
jndx = indgen( alldatasize)

;DEFINE THE INTERNAL VARIABLES...
tdata= reform( stokesoffset_cont[ 0,*,*])

;DFSTOP IS THE MAXIMUM WIDTH WE ALLOW, = 4 1/e half beamwidths...
dfstop = 4.
;AX1 IS THE PERCENTAGE OF CHANGE THAT WE ALLOW; 1% IS THE DEFAULT...
ax1 = 0.01
;A NONZERO PROBLEM INDICATES A PROBLEM...
problem=0

;DEFINE THE OUTPUT PARAMETERS.
;THESE ARE THE SAME AS THE PARAMETERS THAT ARE ITERATED.
nparams = 10
tsrc = double( tsrc0)
az_bmcntr = double( az_bmcntr0)
za_bmcntr = double( za_bmcntr0)
bmwid_0 = double( bmwid_00)
bmwid_1 = double( bmwid_10)
phi_bm = double( phi_bm0)
alpha_coma = double( alpha_coma0) 
phi_coma = double( phi_coma0)
tsys = double( tsys0)
dtsys_dza = double( dtsys_dza0)

;DEFINE FRACTION TO CHANGE FOR EVALUATING DERIVATIVES...
frc = 0.01d0

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

nrs=0
;TSRC:
del = 1.
tsrc= tsrc + del
g2dcurv_allcal, delt_zaencoder, az_scan, za_scan, totoffset, $
        hgt_lobe, cen_lobe, wid_lobe, tsys, dtsys_dza, $
        tsrc, az_bmcntr, za_bmcntr, bmwid_0, bmwid_1, phi_bm, $
        alpha_coma, phi_coma, toutplus
tsrc = tsrc - 2.* del
g2dcurv_allcal, delt_zaencoder, az_scan, za_scan, totoffset, $
        hgt_lobe, cen_lobe, wid_lobe, tsys, dtsys_dza, $
        tsrc, az_bmcntr, za_bmcntr, bmwid_0, bmwid_1, phi_bm, $
        alpha_coma, phi_coma, toutminus
tsrc = tsrc + del
s[ nrs, *] = ((toutplus- toutminus)/(2.*del))[ jndx]
nrs=nrs+1

;AZ_BMCNTR:
del = frc* bmwid_0
az_bmcntr = az_bmcntr + del
g2dcurv_allcal, delt_zaencoder, az_scan, za_scan, totoffset, $
        hgt_lobe, cen_lobe, wid_lobe, tsys, dtsys_dza, $
        tsrc, az_bmcntr, za_bmcntr, bmwid_0, bmwid_1, phi_bm, $
        alpha_coma, phi_coma, toutplus
az_bmcntr = az_bmcntr - 2.* del
g2dcurv_allcal, delt_zaencoder, az_scan, za_scan, totoffset, $
        hgt_lobe, cen_lobe, wid_lobe, tsys, dtsys_dza, $
        tsrc, az_bmcntr, za_bmcntr, bmwid_0, bmwid_1, phi_bm, $
        alpha_coma, phi_coma, toutminus
az_bmcntr = az_bmcntr + del
s[ nrs, *] = ((toutplus- toutminus)/(2.*del))[ jndx]
nrs=nrs+1

;ZA_BMCNTR:
del = frc* bmwid_0
za_bmcntr = za_bmcntr + del
g2dcurv_allcal, delt_zaencoder, az_scan, za_scan, totoffset, $
        hgt_lobe, cen_lobe, wid_lobe, tsys, dtsys_dza, $
        tsrc, az_bmcntr, za_bmcntr, bmwid_0, bmwid_1, phi_bm, $
        alpha_coma, phi_coma, toutplus
za_bmcntr = za_bmcntr - 2.* del
g2dcurv_allcal, delt_zaencoder, az_scan, za_scan, totoffset, $
        hgt_lobe, cen_lobe, wid_lobe, tsys, dtsys_dza, $
        tsrc, az_bmcntr, za_bmcntr, bmwid_0, bmwid_1, phi_bm, $
        alpha_coma, phi_coma, toutminus
za_bmcntr = za_bmcntr + del
s[ nrs, *] = ((toutplus- toutminus)/(2.*del))[ jndx]
nrs=nrs+1

;BMWID_0:
del = frc* bmwid_0
bmwid_0 = bmwid_0 + del
g2dcurv_allcal, delt_zaencoder, az_scan, za_scan, totoffset, $
        hgt_lobe, cen_lobe, wid_lobe, tsys, dtsys_dza, $
        tsrc, az_bmcntr, za_bmcntr, bmwid_0, bmwid_1, phi_bm, $
        alpha_coma, phi_coma, toutplus
bmwid_0 = bmwid_0 - 2.* del
g2dcurv_allcal, delt_zaencoder, az_scan, za_scan, totoffset, $
        hgt_lobe, cen_lobe, wid_lobe, tsys, dtsys_dza, $
        tsrc, az_bmcntr, za_bmcntr, bmwid_0, bmwid_1, phi_bm, $
        alpha_coma, phi_coma, toutminus
bmwid_0 = bmwid_0 + del
s[ nrs, *] = ((toutplus- toutminus)/(2.*del))[ jndx]
nrs=nrs+1

;BMWID_1:
del = 0.1* frc* bmwid_0
bmwid_1 = bmwid_1 + del
g2dcurv_allcal, delt_zaencoder, az_scan, za_scan, totoffset, $
        hgt_lobe, cen_lobe, wid_lobe, tsys, dtsys_dza, $
        tsrc, az_bmcntr, za_bmcntr, bmwid_0, bmwid_1, phi_bm, $
        alpha_coma, phi_coma, toutplus
bmwid_1 = bmwid_1 - 2.* del
g2dcurv_allcal, delt_zaencoder, az_scan, za_scan, totoffset, $
        hgt_lobe, cen_lobe, wid_lobe, tsys, dtsys_dza, $
        tsrc, az_bmcntr, za_bmcntr, bmwid_0, bmwid_1, phi_bm, $
        alpha_coma, phi_coma, toutminus
bmwid_1 = bmwid_1 + del
s[ nrs, *] = ((toutplus- toutminus)/(2.*del))[ jndx]
nrs=nrs+1

;PHI_BM:
del = 3.*frc
phi_bm = phi_bm + del
g2dcurv_allcal, delt_zaencoder, az_scan, za_scan, totoffset, $
        hgt_lobe, cen_lobe, wid_lobe, tsys, dtsys_dza, $
        tsrc, az_bmcntr, za_bmcntr, bmwid_0, bmwid_1, phi_bm, $
        alpha_coma, phi_coma, toutplus
phi_bm = phi_bm - 2.* del
g2dcurv_allcal, delt_zaencoder, az_scan, za_scan, totoffset, $
        hgt_lobe, cen_lobe, wid_lobe, tsys, dtsys_dza, $
        tsrc, az_bmcntr, za_bmcntr, bmwid_0, bmwid_1, phi_bm, $
        alpha_coma, phi_coma, toutminus
phi_bm = phi_bm + del
s[ nrs, *] = ((toutplus- toutminus)/(2.*del))[ jndx]
nrs=nrs+1

;ALPHA_COMA (6):
del = 0.1* frc* bmwid_0
alpha_coma = alpha_coma + del
g2dcurv_allcal, delt_zaencoder, az_scan, za_scan, totoffset, $
        hgt_lobe, cen_lobe, wid_lobe, tsys, dtsys_dza, $
        tsrc, az_bmcntr, za_bmcntr, bmwid_0, bmwid_1, phi_bm, $
        alpha_coma, phi_coma, toutplus
alpha_coma = alpha_coma - 2.* del
g2dcurv_allcal, delt_zaencoder, az_scan, za_scan, totoffset, $
        hgt_lobe, cen_lobe, wid_lobe, tsys, dtsys_dza, $
        tsrc, az_bmcntr, za_bmcntr, bmwid_0, bmwid_1, phi_bm, $
        alpha_coma, phi_coma, toutminus
alpha_coma = alpha_coma + del
s[ nrs, *] = ((toutplus- toutminus)/(2.*del))[ jndx]
nrs=nrs+1

;PHI_COMA:
del = 3.*frc
phi_coma = phi_coma + del
g2dcurv_allcal, delt_zaencoder, az_scan, za_scan, totoffset, $
        hgt_lobe, cen_lobe, wid_lobe, tsys, dtsys_dza, $
        tsrc, az_bmcntr, za_bmcntr, bmwid_0, bmwid_1, phi_bm, $
        alpha_coma, phi_coma, toutplus
phi_coma = phi_coma - 2.* del
g2dcurv_allcal, delt_zaencoder, az_scan, za_scan, totoffset, $
        hgt_lobe, cen_lobe, wid_lobe, tsys, dtsys_dza, $
        tsrc, az_bmcntr, za_bmcntr, bmwid_0, bmwid_1, phi_bm, $
        alpha_coma, phi_coma, toutminus
phi_coma = phi_coma + del
s[ nrs, *] = ((toutplus- toutminus)/(2.*del))[ jndx]
nrs=nrs+1

;TSYS
s[ nrs, *] = 1.
nrs=nrs+1

;DTSYS_DZA
s[ nrs, *] = delt_zaencoder[ jndx]

g2dcurv_allcal, delt_zaencoder, az_scan, za_scan, totoffset, $
        hgt_lobe, cen_lobe, wid_lobe, tsys, dtsys_dza, $
        tsrc, az_bmcntr, za_bmcntr, bmwid_0, bmwid_1, phi_bm, $
        alpha_coma, phi_coma, tout

;STOP, 'just before solving...'

;CREATE AND SOLVE THE NORMAL EQUATION MATRICES...
t_all = reform( tdata-tout, alldatasize)
t = t_all[ jndx]
ss = transpose(s) ## s
st = transpose(s) ## t
ssi = invert(ss)
a = ssi ## st

;stop

;CHECK THE DERIVED PARAMETERS...

;TSRC...
delt = a[ 0]
adelt = abs(delt)
adelt = 0.2*abs(tsrc) < adelt
deltsrc = adelt*(1.- 2.*(delt lt 0.))

;AZ_BMCNTR, THE AZ POINTING OFFSET...
delt = a[ 1]
adelt = abs(delt)
adelt = 0.2*bmwid_0 < adelt
delaz_bmcntr = adelt*(1.- 2.*(delt lt 0.))

;ZA_BMCNTR, THE ZA POINTING OFFSET...
delt = a[ 2]
adelt = abs(delt)
adelt = 0.2*bmwid_0 < adelt
delza_bmcntr = adelt*(1.- 2.*(delt lt 0.))

;BMWID_0, THE MEAN BEAMWIDTH...
delt = a[ 3]
adelt = abs(delt)
adelt = 0.2*bmwid_0 < adelt
delbmwid_0 = adelt*(1.- 2.*(delt lt 0.))

;BMWID_1, THE ELLIPTICITY BEAMWIDTH...
delt = a[ 4]
adelt = abs(delt)
adelt = 0.02*bmwid_0 < adelt
delbmwid_1 = adelt*(1.- 2.*(delt lt 0.))

;PHI_BM, THE THE ELLIPTICITY POSN ANGLE...
delt = a[ 5]
adelt = abs(delt)
adelt = 0.2 < adelt
;adelt = 0.02*bmwid_0 < adelt
delphi_bm = adelt*(1.- 2.*(delt lt 0.))

;ALPHA_COMA, THE COMA MAGNITUDE...
delt = a[ 6]
adelt = abs(delt)
adelt = 0.02*bmwid_0 < adelt
delalpha_coma = adelt*(1.- 2.*(delt lt 0.))

;PHI_COMA, THE THE COMA POSN ANGLE...
delt = a[ 7]
adelt = abs(delt)
adelt = 0.2 < adelt
;adelt = 0.02*bmwid_0 < adelt
delphi_coma = adelt*(1.- 2.*(delt lt 0.))

;TSYS...
delt = a[ 8]
adelt = abs(delt)
adelt = 0.2*tsys < adelt
deltsys = adelt*(1.- 2.*(delt lt 0.))

;DTSYS_DZA...
delt = a[ 9]
adelt = abs(delt)
;adelt = 0.1 < adelt
adelt = 1.0 < adelt
deldtsys_dza = adelt*(1.- 2.*(delt lt 0.))

;CHECK FOR CONVERGENCE AND REASONABLENESS...
deltsrcf = abs( deltsrc) 
delaz_bmcntrf = abs( delaz_bmcntr) 
delza_bmcntrf = abs( delza_bmcntr) 
delbmwid_0f = abs( delbmwid_0) 
delbmwid_1f = abs( delbmwid_1) 
delphi_bmf = abs( delphi_bm) 
delalpha_comaf = abs( delalpha_coma) 
delphi_comaf = abs( delphi_coma) 
deltsysf = abs( deltsys) 
deldtsys_dzaf = abs( deldtsys_dza) 

redoit = 0

if( deltsrcf gt ax1) then redoit=1
if( delaz_bmcntrf gt ax1) then redoit=1
if( delza_bmcntrf gt ax1) then redoit=1
if( delbmwid_0f gt ax1) then redoit=1
if( delbmwid_1f gt ax1) then redoit=1
;if( delphi_bmf  gt ax1) then redoit=1
if( delphi_bmf* bmwid_1  gt ax1) then redoit=1
if( delalpha_comaf  gt ax1) then redoit=1
;if( delphi_comaf  gt ax1) then redoit=1
if( delphi_comaf* alpha_coma  gt ax1) then redoit=1
if( deltsysf  gt ax1) then redoit=1
if( deldtsys_dzaf  gt ax1) then redoit=1

;INCREMENT THE PARAMETERS...
if (redoit eq 0) then halfassed = 1.0

tsrc= tsrc + halfassed*deltsrc  
az_bmcntr= az_bmcntr+  halfassed*delaz_bmcntr  
za_bmcntr= za_bmcntr+ halfassed*delza_bmcntr  
bmwid_0= bmwid_0+ halfassed*delbmwid_0  
bmwid_1= bmwid_1+ halfassed*delbmwid_1  
phi_bm= phi_bm+ halfassed*delphi_bm  
alpha_coma= alpha_coma+ halfassed*delalpha_coma  
phi_coma= phi_coma+ halfassed*delphi_coma  
tsys= tsys+ halfassed*deltsys  
dtsys_dza= dtsys_dza+ halfassed*deldtsys_dza  

;print, nloop, a, format='(i3,10f7.3)'
;STOP

;CHECK TO SEE IF WIDTH IS TOO BIG..
if ( bmwid_0 gt dfstop) or ( bmwid_0 le 0.) then begin
    problem = -1
    ;print, 'width is out of range...'
    goto, PROBLEM
endif

if (nloop ge 100) then begin
        problem = -2
        goto, PROBLEM
endif

if (redoit eq 1) then GOTO, ITERATE_NONLINEAR    

;IF WE GET THIS FAR, THE NONLINEAR PART OF THE FIT IS FINISHED AND SUCCESSFUL...

finished:

;DERIVE THE FITTED POINTS, RESIDUALS, THE ERRORS IN DERIVED COEFFICIENTS...
g2dcurv_allcal, delt_zaencoder, az_scan, za_scan, totoffset, $
        hgt_lobe, cen_lobe, wid_lobe, tsys, dtsys_dza, $
        tsrc, az_bmcntr, za_bmcntr, bmwid_0, bmwid_1, phi_bm, $
        alpha_coma, phi_coma, tfit
resid_all = tdata - tfit

resid= resid_all[ jndx]
sigsq = total( resid^2)/(datasize - nparams)
sigma = sqrt( sigsq)
sigarray = sigsq * ssi[indgen(nparams)*(nparams+1)]
indxsqrt = where( sigarray lt 0., countsqrt)
sigarray = sqrt( abs(sigarray))

;CHECK TO SEE IF RESIDUALS EXCEED sigmalimit * SIGMA...
jjndx = where( abs(resid_all) lt sigmalimit*sigma, count)

;IF THERE ARE NO GOOD POINTS, RETURN...
if (count eq 0) then begin
        problem = -5
        GOTO, PROBLEM
endif

;IF THEY EXCEED sigmalimit * SIGMA, ITERATE...
if ( (count-datasize) lt 0l) then begin
    jndx= jjndx
    nloop_bad= nloop_bad+1
;   stop, 'iterating, ', nloop_bad, count
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

;DERIVE THE NORMALIZED COVARIANCE ARRAY...
doug = ssi[indgen(nparams)*(nparams+1)]
doug = doug#doug
cov = ssi/sqrt(doug)

sigtsrc = sigarray[ 0]
sigaz_bmcntr = sigarray[ 1]
sigza_bmcntr = sigarray[ 2]
sigbmwid_0  = sigarray[ 3]
sigbmwid_1  = sigarray[4]
sigphi_bm  = sigarray[ 5]
sigalpha_coma = sigarray[ 6]
sigphi_coma  = sigarray[ 7]
sigtsys  = sigarray[ 8]
sigdtsys_dza = sigarray[ 9]

;stop
return

PROBLEM:

tfit= 0.* stokesoffset_cont
sigma= 0.

tsys= 0.* tsys0
dtsys_dza= 0.* dtsys_dza
tsrc= 0.* tsrc
az_bmcntr= 0.* az_bmcntr
za_bmcntr= 0.* za_bmcntr
bmwid_0= 0.* bmwid_0
bmwid_1= 0.* bmwid_1
phi_bm= 0.* phi_bm
alpha_coma= 0.* alpha_coma
phi_coma= 0.* phi_coma
sigtsys= 0.
sigdtsys_dza= 0.
sigtsrc= 0.
sigaz_bmcntr= 0.
sigza_bmcntr= 0.
sigbmwid_0= 0.
sigbmwid_1= 0.
sigphi_bm= 0.
sigalpha_coma= 0.
sigphi_coma= 0.

end

