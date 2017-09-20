pro mm_chisqfit, pacoeffs, coeffs_in, coeffs_out, sigcoeffs_out, $
	fixdeltag=fixdeltag, fixpsi=fixpsi, $
        fixalpha=fixalpha, fixepsilon=fixepsilon,fixphi=fixphi, $
        fixqsrc=fixqsrc, fixusrc=fixusrc, fixvsrc=fixvsrc, $
	nloop=nloop, cov=cov, noprint=noprint

;+
; **** the chi-swquared aspect has not yet been included!!!****
;
;PURPOSE: Given data over a range of parallactic angles, fit for any
;combination of deltag, psi, alpha, epsilon, phi, qsrc, usrc, vsrc. This
;version (31jul2016) allows for nonzero vsrc.
;
;	*** THE UNIT FOR ALL PHASE ANGLES IS ****RADIANS******
;
;CALLING SEQUENCE:
;mmfit_linfeed, pacoeffs, coeffs_in, coeffs_out, sigcoeffs_out, $
;	fixdeltag=fixdeltag, fixpsi=fixpsi, $
;       fixalpha=fixalpha, fixepsilon=fixepsilon,fixphi=fixphi, $
;       fixqsrc=fixqsrc, fixusrc=fixusrc, fixvsrc=fixvsrc, $
;	nloop=nloop, cov=cov, noprint=noprint
;
;INPUTS:
;	PACOEFFS[3,2,4]: The input data from STRIPFIT_TO_PACOEFFS: 
;           PACOEFFS[3,*,*] are ABC in: intensity = A + Bcos(2pa) + Csin(20a)
;           PACOEFFS[*,2,*] are the value and its uncertainty
;           PACOEFFS[*,*,4] are APB', AMB', AB'. BA' in eqn 27 of the
;               Heiles et al PASP paper on Mueller matrix calibration
;
;  COEFFS_IN={.deltag, .psi, .alpha, .epsilon, .phi, .chi, .qsrc, .usrc, .vsrc}
;       A structure containing the iniial guesses for the parameters
;       to be solved for. The easiest way to set up COEFFS_IN is to use the
;       procedure COEFFS_IN_SETUP; see its documentation for more info.
;
;OUTPUTS:
;       COEFFS_OUT, the fitted values of the parameters in coeffs_in. 
;       SIGCOEFFS_OUT, the uncertainties in coeffs_out. quantities not solved
;       for are assigned zero uncertainty.
;
;KEYWORDS:
;	FIXpsi: Accepts PSI0 as correct and doesn't fit for it. 
;       FIXdeltag: accepts deltag0 as correct and doesn't fit for it.
;       fixalpha: Accepts alpha0 as correct and doesn't fit for it. 
;       fixepsilon; Accepts epsilon0 as correct and doesn't fit for it. 
;       fixphi=fixphi; Accepts phi0 as correct and doesn't fit for it. 
;	FIXqsrc, takes qsrc0 as correct and doesn't fit for it
;	FIXusrc, takes usrc0 as correct and doesn't fit for it
;	FIXvsrc, takes vsrc0 as correct and doesn't fit for it
;	PROBLEM, if nonzero, indicates a problems in the nonlinear fit.
;	NLOOP, the number of loops in the nonlinear ls fit.
;	COV, the normalized covariance matrix
;
;HISTORY: 
;	original 31jul2016 by carl. based on mmlsfit.pro
;-

forward_function sign

;DETERMINE THE SIZE OF THE ORIGINAL DATA ARRAYS...
;DETERMINE THE SIZE OF THE DATA ARRAY...
datasize = 9

;DEFINE THE INTERNAL data array used for fitting...
tdata= fltarr( datasize)
tdata[ 0:2]= pacoeffs[ 0, 0, 1:3]
tdata[ 3:5]= pacoeffs[ 1, 0, 1:3]
tdata[ 6:8]= pacoeffs[ 2, 0, 1:3]

;AX1 IS THE PERCENTAGE OF CHANGE THAT WE ALLOW; 1% IS THE DEFAULT...
;IT IS FRACTIONAL FOR QUANTITIES AND NONFRACTIONAL, .01 RADIANS, FOR ANGLES
ax1 = 0.001
;ax1 = 0.0001

;DEFINE FRACTION TO CHANGE FOR EVALUATING DERIVATIVES...
frc = 0.01d0
frc = 0.001d0

;A NONZERO PROBLEM INDICATES A PROBLEM...
problem=0

;DEFINE THE OUTPUT PARAMETERS.
;THESE ARE THE SAME AS THE PARAMETERS THAT ARE ITERATED.
;cfndx is 1 if the parameter is solved for.
nparams = 8
cfndx= 1 + intarr( nparams)

ntag=0
if keyword_set( fixdeltag) then begin
        nparams=nparams-1
        cfndx[ntag]=0
endif

ntag= ntag+1 
if keyword_set( fixpsi) then begin
        nparams=nparams-1
        cfndx[ntag]=0
endif

ntag= ntag+1 
if keyword_set( fixalpha) then begin
        nparams=nparams-1
        cfndx[ntag]=0
endif

ntag= ntag+1 
if keyword_set( fixepsilon) then begin
        nparams=nparams-1
        cfndx[ntag]=0
endif

ntag= ntag+1 
if keyword_set( fixphi) then begin
        nparams=nparams-1
        cfndx[ntag]=0
endif

;-----------------
ntag= ntag+1 
if keyword_set( fixqsrc) then begin
        nparams=nparams-1
        cfndx[ntag]=0
endif

ntag= ntag+1 
if keyword_set( fixusrc) then begin
        nparams=nparams-1
        cfndx[ntag]=0
endif

ntag= ntag+1 
if keyword_set( fixvsrc) then begin
        nparams=nparams-1
        cfndx[ntag]=0
endif

deltag= double( coeffs_in.deltag)
psi= double( coeffs_in.deltag)
alpha= double( coeffs_in.alpha)
epsilon= double( coeffs_in.epsilon)
phi= double( coeffs_in.phi)
qsrc= double( coeffs_in.qsrc)
usrc= double( coeffs_in.usrc)
vsrc= double( coeffs_in.vsrc)
chi= double(coeffs_in.chi)

;DEFINE NLOOP, THE NR OF ITERATIONS IN THE NONLINEAR FIT...
nloop = 0

;HALFASSED IS THE MULTIPLIER FOR THE CORRECTIONS IN NONLINEAR REGIME.
halfassed = 0.5

;DEFINE THE EQUATION-OF-CONDITION ARRAY, S...
s = dblarr(nparams, datasize)
vals= fltarr( nparams)

print, 'npa9ams, datasize= ', nparams, datasize

;------------- BEGIN THE NONLINEAR ITERATION LOOP----------------
ITERATE_NONLINEAR:
nloop= nloop+1

;EVALUATE THE DERIVATIVES...
nr= -1
;DM_DDELTAG
IF (keyword_set( fixdeltag) ne 1) THEN BEGIN
del = frc
deltag = deltag + del
guess_tot, deltag, epsilon, alpha, phi, chi, psi, qsrc, usrc, vsrc=vsrc, guessplus
deltag = deltag - 2.d0*del
guess_tot, deltag, epsilon, alpha, phi, chi, psi, qsrc, usrc, vsrc=vsrc, guessminus
deltag = deltag + del
nr=nr+1 & s[ nr,*] = (guessplus- guessminus)/ (2.d0*del)
vals[nr]= deltag
ENDIF

;DM_Dpsi
IF (keyword_set( fixpsi) ne 1) THEN BEGIN
del = frc
psi = psi + del
guess_tot, deltag, epsilon, alpha, phi, chi, psi, qsrc, usrc, vsrc=vsrc, guessplus
psi = psi - 2.d0*del
guess_tot, deltag, epsilon, alpha, phi, chi, psi, qsrc, usrc, vsrc=vsrc, guessminus
psi = psi + del
nr=nr+1 & s[ nr,*] = (guessplus- guessminus)/ (2.d0*del)
vals[ nr]= psi
ENDIF

;DM_Dalpha
IF (keyword_set( fixalpha) ne 1) THEN BEGIN
del = frc
alpha = alpha + del
guess_tot, deltag, epsilon, alpha, phi, chi, psi, qsrc, usrc, vsrc=vsrc, guessplus
alpha = alpha - 2.d0*del
guess_tot, deltag, epsilon, alpha, phi, chi, psi, qsrc, usrc, vsrc=vsrc, guessminus
alpha = alpha + del
nr=nr+1 & s[ nr,*] = (guessplus- guessminus)/ (2.d0*del)
vals[ nr]= alpha
ENDIF

;DM_Depsilon
IF (keyword_set( fixepsilon) ne 1) THEN BEGIN
del = frc
epsilon = epsilon + del
guess_tot, deltag, epsilon, alpha, phi, chi, psi, qsrc, usrc, vsrc=vsrc, guessplus
epsilon = epsilon - 2.d0*del
guess_tot, deltag, epsilon, alpha, phi, chi, psi, qsrc, usrc, vsrc=vsrc, guessminus
epsilon = epsilon + del
nr=nr+1 & s[ nr,*] = (guessplus- guessminus)/ (2.d0*del)
vals[ nr]= epsilon
ENDIF

;DM_Dphi
IF (keyword_set( fixphi) ne 1) THEN BEGIN
del = frc
phi = phi + del
guess_tot, deltag, epsilon, alpha, phi, chi, phi, qsrc, usrc, vsrc=vsrc, guessplus
phi = phi - 2.d0*del
guess_tot, deltag, epsilon, alpha, phi, chi, phi, qsrc, usrc, vsrc=vsrc, guessminus
phi = phi + del
nr=nr+1 & s[ nr,*] = (guessplus- guessminus)/ (2.d0*del)
vals[ nr]= phi
ENDIF

;--------------------
IF (keyword_set( fixqsrc) ne 1) THEN BEGIN
;DM_Dqsrc
del = frc
qsrc = qsrc + del
guess_tot, deltag, epsilon, alpha, phi, chi, psi, qsrc, usrc, vsrc=vsrc, guessplus
qsrc = qsrc - 2.d0*del
guess_tot, deltag, epsilon, alpha, phi, chi, psi, qsrc, usrc, vsrc=vsrc, guessminus
qsrc = qsrc + del
nr=nr+1 & s[ nr,*] = (guessplus- guessminus)/ (2.d0*del)
vals[ nr]= qsrc
ENDIF

IF (keyword_set( fixusrc) ne 1) THEN BEGIN
;DM_Dusrc
del = frc
usrc = usrc + del
guess_tot, deltag, epsilon, alpha, phi, chi, psi, qsrc, usrc, vsrc=vsrc, guessplus
usrc = usrc - 2.d0*del
guess_tot, deltag, epsilon, alpha, phi, chi, psi, qsrc, usrc, vsrc=vsrc, guessminus
usrc = usrc + del
nr=nr+1 & s[ nr,*] = (guessplus- guessminus)/ (2.d0*del)
vals[ nr]= usrc
ENDIF

IF (keyword_set( fixvsrc) ne 1) THEN BEGIN
;DM_Dvsrc
del = frc
vsrc = vsrc + del
guess_tot, deltag, epsilon, alpha, phi, chi, psi, qsrc, usrc, vsrc=vsrc, guessplus
vsrc = vsrc - 2.d0*del
guess_tot, deltag, epsilon, alpha, phi, chi, psi, qsrc, usrc, vsrc=vsrc, guessminus
vsrc = vsrc + del
nr=nr+1 & s[ nr,*] = (guessplus- guessminus)/ (2.d0*del)
vals[ nr]= vsrc
ENDIF

;EVALUATE THE GUESSED MATRIX...
guess_tot, deltag, epsilon, alpha, phi, chi, psi, qsrc, usrc, vsrc=vsrc, $
              guess_tot, m_tot

;CREATE AND SOLVE THE NORMAL EQUATION MATRICES...
t = tdata- guess_tot
ss = transpose(s) ## s
st = transpose(s) ## t
ssi = invert(ss)
delt = ssi ## st

;CHECK FOR SMALLNESS OF THE CORRECTIONS...
redoit= 0
indx= where(abs( delt) gt ax1, count)
;for this set of params we don't need to check any fractional chnges.
goto, skipfractcheck
IF (COUNT EQ 0) THEN BEGIN
fracts= abs( delt[ chkindx]/ vals[ chkindx])
indx= where( fracts gt ax1, count)
ENDIF
skipfractcheck:

IF (count ne 0) then BEGIN
redoit=1
jndx = where( abs( delt) gt 1.2, count)
if (count ne 0) then delt[ jndx] = 1.2* sign( delt[jndx])
ENDIF

if (redoit eq 0) then halfassed= 1.0

;==========================================================
;==========================================================
;==========================================================
nr=-1
if keyword_set( fixdeltag) eq 0 then begin
   nr=nr+1 & deltag= deltag+ halfassed*delt[nr ]
endif

if keyword_set( fixpsi) eq 0 then begin
   nr=nr+1 & psi= psi+ halfassed*delt[nr ]
endif

if keyword_set( fixalpha) eq 0 then begin
   nr=nr+1 & alpha= alpha+ halfassed*delt[nr ]
endif

if keyword_set( fixepsilon) eq 0 then begin
   nr=nr+1 & epsilon= epsilon+ halfassed*delt[nr ]
endif

if keyword_set( fixphi) eq 0 then begin
   nr=nr+1 & phi= phi+ halfassed*delt[nr ]
endif

;--------------------------------------
IF (keyword_set( fixqsrc) ne 1) THEN BEGIN
   nr=nr+1 & qsrc= qsrc+  halfassed*delt[nr ]
ENDIF

IF (keyword_set( fixusrc) ne 1) THEN BEGIN
   nr=nr+1 & usrc= usrc+  halfassed*delt[nr ]
ENDIF

IF (keyword_set( fixvsrc) ne 1) THEN BEGIN
   nr=nr+1 & vsrc= vsrc+  halfassed*delt[nr ]
ENDIF

if (nloop ge 1000) then begin
                problem = -2
                goto, PROBLEM
endif   

if keyword_set( noprint) eq 0 then print, nloop,transpose( delt)
;stop
if (redoit eq 1) then GOTO, ITERATE_NONLINEAR

;EVALUATE THE GUESSED MATRIX...
guess_tot, deltag, epsilon, alpha, phi, chi, psi, qsrc, usrc, vsrc=vsrc, tfit

resid= tdata- tfit
sigsq = total( resid^2)/(datasize - nparams)
sigma = sqrt( sigsq)
sigarray = sigsq * ssi[indgen(nparams)*(nparams+1)]
indxsqrt = where( sigarray lt 0., countsqrt)
sigarray = sqrt( abs(sigarray))

;DERIVE THE NORMALIZED COVARIANCE ARRAY...
doug = ssi[indgen(nparams)*(nparams+1)]
doug = doug#doug
cov = ssi/sqrt(doug)

;create the coeffs output structure:
coeffs_out= coeffs_in
sigcoeffs_out= coeffs_in
for nt=0, n_tags( coeffs_in)-1 do sigcoeffs_out.(nt)= 0.

nr=-1
ntag=0
if keyword_set( fixdeltag) eq 0 then begin
   nr=nr+1 & coeffs_out.(ntag)= deltag & sigcoeffs_out.(ntag)=sigarray( nr)
endif

ntag=ntag+1
if keyword_set( fixpsi) eq 0 then begin
   psi= modangle( psi, 2.*!pi, /NEGPOS)
   nr=nr+1 & coeffs_out.(ntag)= psi & sigcoeffs_out.(ntag)=sigarray( nr)
endif

ntag=ntag+1
if keyword_set( fixalpha) eq 0 then begin
   nr=nr+1 & coeffs_out.(ntag)= alpha & sigcoeffs_out.(ntag)=sigarray( nr)
endif

ntag=ntag+1
if keyword_set( fixepsilon) eq 0 then begin
   nr=nr+1 & coeffs_out.(ntag)= epsilon & sigcoeffs_out.(ntag)=sigarray( nr)
endif

ntag=ntag+1
if keyword_set( fixphi) eq 0 then begin
   nr=nr+1 & coeffs_out.(ntag)= phi & sigcoeffs_out.(ntag)=sigarray( nr)
endif

;========================================
ntag=ntag+1
IF (keyword_set( fixqsrc) ne 1) THEN BEGIN
   nr=nr+1 & coeffs_out.(ntag)= qsrc & sigcoeffs_out.(ntag)=sigarray( nr)
ENDIF

ntag=ntag+1
IF (keyword_set( fixusrc) ne 1) THEN BEGIN
   nr=nr+1 & coeffs_out.(ntag)= usrc & sigcoeffs_out.(ntag)=sigarray( nr)
ENDIF

ntag=ntag+1
IF (keyword_set( fixvsrc) ne 1) THEN BEGIN
   nr=nr+1 & coeffs_out.(ntag)= vsrc & sigcoeffs_out.(ntag)=sigarray( nr)
ENDIF

;stop

; TR ADDED POLSRC AND PASRC TO THE MUELLER PARAMS JUN 19, 2007...
coeffs_out.polsrc = sqrt( coeffs_out.qsrc^2 + coeffs_out.usrc^2)
pasrc = !radeg * 0.5*atan(coeffs_out.usrc, coeffs_out.qsrc)
coeffs_out.pasrc = modangle( pasrc,180.0,/NEGPOS)

; TR ADDED THE UNCERTAINTIES JUN 29 2007...
; CHECKED AGAINST THE HEILES/FISHER MEMO AND THEY AGREE!!
sigpolsrc = sqrt( coeffs_out.qsrc^2*sigcoeffs_out.qsrc^2 + $
        coeffs_out.usrc^2*sigcoeffs_out.usrc^2) / coeffs_out.polsrc
sigcoeffs_out.polsrc = sigpolsrc
sigcoeffs_out.pasrc = !radeg * 0.5 * sigpolsrc / coeffs_out.polsrc

;STOP, 'no problem'
return

PROBLEM:
print, 'PROBLEM!! NUMBER ', problem, string(7b)
muellerparams1.problem= problem

;STOP, 'problem'
return
end
