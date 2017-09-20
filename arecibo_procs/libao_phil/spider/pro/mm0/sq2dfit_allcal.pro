pro sq2dfit_allcal, nstk, sigmalimit, delt_zaencoder, azoffset, zaoffset, $
        totoffset, stokesoffset_cont, hgt_lobe, cen_lobe, wid_lobe, $
    stripfit, $
        tsys, dtsys_dza, tsrc_in, az_bmcntr, za_bmcntr, $
        bmwid_0, bmwid_1, phi_bm, alpha_coma, phi_coma, $
        a, sigarray, tfit_all, sigma, jndx, $
        problem, cov, $
    squoosh= squoosh
        
;+
;NAME:
;sq2dfit_allcal
;   SQFIT_ALLCAL, nrstrip, nstk, xdata, stokesoffset_cont, $
;        tfit, sigma, stripfit, sigstripfit, problem, cov
;
;PURPOSE:
;FIT    (1) INTENSITIES OF CENTRAL BEAM AND THE TWO SIDELOBES,
;       (2) BEAM SQUINT (FIRST DERIVATIVE OF GAUSSIAN) AND
;       (3) SQUASH (DIFF IN BEAMWIDTHS) FOR ALL POL STOKES AND ONE STRIP.
;   note: added squash_avg to ls soln 31jul2003.
;       For deriving polarization leakage, beam squint and
;       beam squash. the parameters
;       of the original gaussian are already known.
;
;CALLING SEQUENCE:
;    SQFIT_ALLCAL, nrstrip, nstk, offset, stokesoffset_cont, $
;        tfit, sigma, stripfit, sigstripfit, problem, cov
;
;INPUTS:
;     xdata: the x-values at which the data points exist.
;     STOKESOFFSET_CONT, the datapoints
;     STRIPFIT[ *, 0, NRSTRIP]: THE XPY POWER FOR THE STRIP (ALREADY DERIVED)
;
;OUTPUTS:
;     tfit: the fitted values of the data at the points in xdata.
;     sigma: the rms of the residuals.
;     STRIPFIT[ *, NSTK, NRSTRIP] coeffs: array of fitted parameters for
;       this stokes param NSTK, this strip NRSTRIP
;     SIGSTRIPFIT: the array of errors of coeffs.
;     problem: 0, OK;  -3, negative sigmas; 4, bad derived values.
;     cov: the normalized covariance matrix of the fitted coefficients.
;
;INTERMEDIATE RESULTS...
;       COEFFS: the array of fitted parameters, which are:
;       [zero offset, main beam polarized intensity, squint, squash,
;               left sidelobe polarized intensity,
;               right sidelobe polarized intensity]
;
;RELATED PROCEDURES:
;       GCURV_ALLCAL
;HISTORY:
;       Derived from sqfit.pro, 13sep00
;   ch eliminated subtracting the polarized tsys offsets. 04jan03
;       2003feb06: factor of two error in squint, squash fixed. earlier
;squint/squash were factor of two too small. In PASP article, see
;equation 20: the factor (I/2) sits iin front of the second term instead
;of the factor (I). this factor of two repair is put in at the end of
;this program.
;   2003jun31: included squoosh in the fit, so the squash 
;is now like a fourier series with 0 and 2pa terms. the output array
;   2003aug10: fixed squash, which has been faulty forever, and squoosh.
;added keyword SQUOOSH
;
;-

;NOTE THE 0.5, ADDED FOR THE FACTOR OF TWO PROBLEM (SEE 'HISTORY'):
tsrc= 0.5* tsrc_in

;DEFINE MULTIPLIER FOR NUMERICAL DERIVATIVES...
dmult = 0.01d0

;DETERMINE THE SIZE OF THE ORIGINAL DATA ARRAYS...
alldatasize = n_elements( azoffset)
jndx = indgen( alldatasize)
;######################################################################
nparams = keyword_set( squoosh)+ 7
s_all= fltarr( nparams, alldatasize)

;DEFINE THE INTERNAL VARIABLES...
tdata= reform( stokesoffset_cont[ nstk,*,*])


;EVALUATE THE SIDELOBES USING STRIPFIT, AND SUBTRACT THEM AWAY...
t_both= 0.* tdata
for nrstrip= 0,3 do begin

;CHANGE 04JAN03:
;gcurv, totoffset[ *, nrstrip], stripfit[ 10, nstk, nrstrip], $
gcurv, totoffset[ *, nrstrip], 0., $
    [ stripfit[ 2,nstk,nrstrip], stripfit[ 3,nstk,nrstrip]], $
    [ stripfit[ 5,nstk,nrstrip], stripfit[ 6,nstk,nrstrip]], $
    [ stripfit[ 8,nstk,nrstrip], stripfit[ 9,nstk,nrstrip]], $
    t_bth
t_both[ *, nrstrip]= t_bth+ stripfit[ 11,nstk,nrstrip]*totoffset[ *,nrstrip]
endfor

tdata= tdata- t_both

radius= sqrt( azoffset^2+ zaoffset^2)
cosphi= azoffset/ radius
sinphi= zaoffset/ radius
sin2phi= 2.* sinphi*cosphi
cos2phi= 2.* cosphi^2 - 1.
sin2phi[ 0:alldatasize/2- 1]= 0.
cos2phi[ alldatasize/2: alldatasize-1]= 0.

;POPULATE THE S MATRIX...
sindx = 0
problem=0

;POLARIZED TSYS (the zero offset)...
s_all[ sindx,*] =  1. + fltarr(alldatasize)
sindx = sindx + 1   
        
;D(POLARIZED TSYS)/ DZAENCODER...
s_all[ sindx,*] = delt_zaencoder
sindx = sindx + 1   

;POLARIZED TSRC...
TSRC_PLUS= tsrc* dmult
g2dcurv_allcal, delt_zaencoder, azoffset, zaoffset, totoffset, $
        hgt_lobe, cen_lobe, wid_lobe, tsys, dtsys_dza, $
        TSRC_PLUS, az_bmcntr, za_bmcntr, bmwid_0, bmwid_1, phi_bm, $
        alpha_coma, phi_coma, TOUTPLUS
TSRC_MINUS= -tsrc* dmult
g2dcurv_allcal, delt_zaencoder, azoffset, zaoffset, totoffset, $
        hgt_lobe, cen_lobe, wid_lobe, tsys, dtsys_dza, $
        TSRC_MINUS, az_bmcntr, za_bmcntr, bmwid_0, bmwid_1, phi_bm, $
        alpha_coma, phi_coma, TOUTMINUS
s_all[ sindx,*] = (TOUTPLUS- TOUTMINUS)/(TSRC_PLUS- TSRC_MINUS)
sindx = sindx + 1   

;MAIN BEAM THETA_SQUINTCOS...
;**** NOTE THE MINUS SIGN IN THE LAST STATEMENT! ***
AZ_BMCNTR_PLUS= dmult* bmwid_0
g2dcurv_allcal, delt_zaencoder, azoffset, zaoffset, totoffset, $
        hgt_lobe, cen_lobe, wid_lobe, tsys, dtsys_dza, $
        tsrc, AZ_BMCNTR_PLUS, za_bmcntr, bmwid_0, bmwid_1, phi_bm, $
        alpha_coma, phi_coma, TOUTPLUS
AZ_BMCNTR_MINUS= -dmult* bmwid_0
g2dcurv_allcal, delt_zaencoder, azoffset, zaoffset, totoffset, $
        hgt_lobe, cen_lobe, wid_lobe, tsys, dtsys_dza, $
        tsrc, AZ_BMCNTR_MINUS, za_bmcntr, bmwid_0, bmwid_1, phi_bm, $
        alpha_coma, phi_coma, TOUTMINUS
s_all[ sindx, *] = -(TOUTPLUS- TOUTMINUS)/(AZ_BMCNTR_PLUS- AZ_BMCNTR_MINUS)
sindx = sindx + 1   
        
;MAIN BEAM THETA_SQUINTSIN...
;**** NOTE THE MINUS SIGN IN THE LAST STATEMENT! ***
ZA_BMCNTR_PLUS= dmult* bmwid_0
g2dcurv_allcal, delt_zaencoder, azoffset, zaoffset, totoffset, $
        hgt_lobe, cen_lobe, wid_lobe, tsys, dtsys_dza, $
        tsrc, az_bmcntr, ZA_BMCNTR_PLUS, bmwid_0, bmwid_1, phi_bm, $
        alpha_coma, phi_coma, TOUTPLUS
ZA_BMCNTR_MINUS=  -dmult* bmwid_0
g2dcurv_allcal, delt_zaencoder, azoffset, zaoffset, totoffset, $
        hgt_lobe, cen_lobe, wid_lobe, tsys, dtsys_dza, $
        tsrc, az_bmcntr, ZA_BMCNTR_MINUS, bmwid_0, bmwid_1, phi_bm, $
        alpha_coma, phi_coma, TOUTMINUS
s_all[ sindx, *] = -(TOUTPLUS- TOUTMINUS)/(ZA_BMCNTR_PLUS- ZA_BMCNTR_MINUS)
sindx = sindx + 1   

;MAIN BEAM THETA_SQUASHCOS...
THETA_PLUS_COS= bmwid_0* (1.+ dmult* cos2phi)
g2dcurv_allcal, delt_zaencoder, azoffset, zaoffset, totoffset, $
        hgt_lobe, cen_lobe, wid_lobe, tsys, dtsys_dza, $
        tsrc, az_bmcntr, za_bmcntr, THETA_PLUS_COS, bmwid_1, phi_bm, $
        alpha_coma, phi_coma, TOUTPLUS
THETA_MINUS_COS= bmwid_0* (1.- dmult* cos2phi)
g2dcurv_allcal, delt_zaencoder, azoffset, zaoffset, totoffset, $
        hgt_lobe, cen_lobe, wid_lobe, tsys, dtsys_dza, $
        tsrc, az_bmcntr, za_bmcntr, THETA_MINUS_COS, bmwid_1, phi_bm, $
        alpha_coma, phi_coma, TOUTMINUS
;indx= where( (THETA_PLUS_COS- THETA_MINUS_COS) ne 0., count)
;if (count ne 0.) then s_all[ sindx, indx] = $
;   (TOUTPLUS- TOUTMINUS)[indx]/(THETA_PLUS_COS- THETA_MINUS_COS)[indx]
s_all[ sindx, *] = (TOUTPLUS- TOUTMINUS)/(2.* bmwid_0* dmult)
sindx = sindx + 1   

;MAIN BEAM THETA_SQUASHSIN...
THETA_PLUS= bmwid_0* (1. + dmult* sin2phi)
g2dcurv_allcal, delt_zaencoder, azoffset, zaoffset, totoffset, $
        hgt_lobe, cen_lobe, wid_lobe, tsys, dtsys_dza, $
        tsrc, az_bmcntr, za_bmcntr, THETA_PLUS, bmwid_1, phi_bm, $
        alpha_coma, phi_coma, TOUTPLUS
THETA_MINUS= bmwid_0* (1. - dmult* sin2phi)
g2dcurv_allcal, delt_zaencoder, azoffset, zaoffset, totoffset, $
        hgt_lobe, cen_lobe, wid_lobe, tsys, dtsys_dza, $
        tsrc, az_bmcntr, za_bmcntr, THETA_MINUS, bmwid_1, phi_bm, $
        alpha_coma, phi_coma, TOUTMINUS
;indx= where( (THETA_PLUS- THETA_MINUS) ne 0., count)
;if (count ne 0.) then s_all[ sindx, indx] = $
;   (TOUTPLUS- TOUTMINUS)[indx]/(THETA_PLUS- THETA_MINUS)[indx]
s_all[ sindx, *] = (TOUTPLUS- TOUTMINUS)/(2.* bmwid_0* dmult)
sindx = sindx + 1   

;STOP, 'SQ2DFIT', 0

;-------------------- ADD SQUOOSH IF DESIRED -------------------------
IF (KEYWORD_SET( SQUOOSH) ) THEN BEGIN

;MAIN BEAM THETA_SQUOOSH...
;THETA_PLUS= bmwid_0* (1. + dmult*(1.+ fltarr( 80,4)))
THETA_PLUS= bmwid_0* (1. + dmult)
TSRC_PLUS= tsrc* (bmwid_0/theta_plus)^2
g2dcurv_allcal, delt_zaencoder, azoffset, zaoffset, totoffset, $
        hgt_lobe, cen_lobe, wid_lobe, tsys, dtsys_dza, $
        TSRC_PLUS, az_bmcntr, za_bmcntr, THETA_PLUS, bmwid_1, phi_bm, $
        alpha_coma, phi_coma, TOUTPLUS
;THETA_MINUS= bmwid_0* (1. - dmult*(1.+ fltarr( 80,4)))
THETA_MINUS= bmwid_0* (1. - dmult)
TSRC_MINUS= tsrc* (bmwid_0/theta_minus)^2
g2dcurv_allcal, delt_zaencoder, azoffset, zaoffset, totoffset, $
        hgt_lobe, cen_lobe, wid_lobe, tsys, dtsys_dza, $
        TSRC_MINUS, az_bmcntr, za_bmcntr, THETA_MINUS, bmwid_1, phi_bm, $
        alpha_coma, phi_coma, TOUTMINUS
;indx= where( (THETA_PLUS- THETA_MINUS) ne 0., count)
;if (count ne 0.) then s_all[ sindx, indx] = $
;   (TOUTPLUS- TOUTMINUS)[indx]/(THETA_PLUS- THETA_MINUS)[indx]
s_all[ sindx, *] = (TOUTPLUS- TOUTMINUS)/(2.* bmwid_0* dmult)

ENDIF

;print, 'theta_squashavg stats: ', count, n_elements( theta_plus)
sindx = sindx + 1   

;DEFINE NLOOP_BAD, THE NR OF ITERATIONS FOR BAD POINTS...
nloop_bad = 0

;---------- BEGINNING OF ITERATION LOOP FOR BAD POINTS---------  
ITERATE_BAD:

;DETERMINE THE SIZE OF THE DATA ARRAY...
dtsize = n_elements(jndx)

s= s_all[ *, jndx]
t = tdata[ jndx]

;STOP, 'SQ2DFIT', 1

ss = transpose(s) ## s
st = transpose(s) ## t
ssi = invert(ss)
a = ssi ## st

tfit_all= s_all ## a
resid_all= tdata- tfit_all
resid= resid_all[ jndx]

sigsq = total( resid^2)/(dtsize - nparams)
sigma = sqrt( sigsq)
;CHECK TO SEE IF RESIDUALS EXCEED sigmalimit * SIGMA...
jjndx = where( abs(resid_all) lt sigmalimit*sigma, count_jjndx)
    
;stop

;IF THERE ARE TOO FEW GOOD POINTS, RETURN...
if (count_jjndx le nparams) then begin
        problem = -5
        GOTO, PROBLEM
endif

;IF THEY EXCEED sigmalimit * SIGMA, DISCARD AND ITERATE...
if ( count_jjndx lt dtsize) then begin
        jndx= jjndx
        nloop_bad= nloop_bad+1
;       stop, 'iterating, ', nloop_bad, count
        goto, ITERATE_BAD
end

;IF YOU GET THIS FAR, YOU'VE SUCCEEDED!!!
sigarray = sigsq * ssi[indgen(nparams)*(nparams+1)]
indxsqrt = where( sigarray lt 0., countsqrt)
sigarray = sqrt( abs(sigarray))

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

;stop , 'COV'

FINISH:

tsys1= a[0 ]
dtsys_dza1= a[ 1]
tsrc1= a[ 2]
theta_squint1_cos= a[ 3]
theta_squint1_sin= a[ 4]
theta_squash1_cos= a[ 5]
theta_squash1_sin= a[ 6]

sigtsys1= sigarray[0 ]
sigdtsys_dza1= sigarray[ 1]
sigtsrc1= sigarray[ 2]
sigtheta_squint1_cos= sigarray[ 3]
sigtheta_squint1_sin= sigarray[ 4]
sigtheta_squash1_cos= sigarray[ 5]
sigtheta_squash1_sin= sigarray[ 6]

if ( keyword_set( squoosh)) then begin
theta_squoosh= a[ 7]
sigtheta_squooash= sigarray[ 7]
endif

;STOP, 'STOP: END OF SQ2DFIT_ALLCAL'

return
;stop

PROBLEM:
a= fltarr(nparams)
sigarray= fltarr(nparams)
goto, FINISH

END


;covariance matrix:
;
;    1.00000   0.00658166    -0.403084  -0.00775136   0.00636504   0.00530467   0.00583559    -0.290257
;   0.00658172      1.00000   -0.0247168   0.00310793    0.0409546    -0.285087     0.224274  -0.00675345
;    -0.403084   -0.0247167      1.00000    0.0123805    -0.112716   -0.0833069   -0.0395505     0.908753
;  -0.00775136   0.00310802    0.0123805      1.00000   -0.0334437    0.0108355    -0.263287   0.00892493
;   0.00636502    0.0409547    -0.112716   -0.0334437      1.00000    -0.185214   0.00696501    -0.150676
;   0.00530464    -0.285088   -0.0833068    0.0108355    -0.185214      1.00000   -0.0638775   -0.0614150
;   0.00583559     0.224274   -0.0395505    -0.263287   0.00696498   -0.0638774      1.00000   -0.0675187
;    -0.290257  -0.00675329     0.908753   0.00892492    -0.150676   -0.0614150   -0.0675187      1.00000

