pro mm_genfit, pacoeffs, coeffs_in, coeffs_out, sigcoeffs_out, $
	fixdeltag=fixdeltag, fixpsi=fixpsi, $
        fixalpha=fixalpha, fixepsilon=fixepsilon,fixphi=fixphi, $
        fixqsrc=fixqsrc, fixusrc=fixusrc, fixvsrc=fixvsrc, $
	nloop=nloop, ncov=ncov, noprint=noprint, tdata=tdata, tfit=tfit, $
        m_tot=m_tot, pacoeffs_out=pacoeffs_out

;+
;
;PURPOSE: Given data over a range of parallactic angles, fit for any
;combination of deltag, psi, alpha, epsilon, phi, qsrc, usrc, vsrc. This
;version (31jul2016) allows for nonzero vsrc.
;
;	*** THE UNIT FOR ALL PHASE ANGLES IS ****RADIANS******
;
;CALLING SEQUENCE:
;mm_genfit, pacoeffs, coeffs_in, coeffs_out, sigcoeffs_out, $
;	fixdeltag=fixdeltag, fixpsi=fixpsi, $
;        fixalpha=fixalpha, fixepsilon=fixepsilon,fixphi=fixphi, $
;        fixqsrc=fixqsrc, fixusrc=fixusrc, fixvsrc=fixvsrc, $
;	nloop=nloop, ncov=ncov, noprint=noprint, tdata=tdata, tfit=tfit, $
;        m_tot=m_tot, pacoeffs_out=pacoeffs_out
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
;       to be solved for. Use MM_COEFFS_IN_SETUP to generate this.
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
;	NCOV, the normalized covariance matrix
;
;HISTORY: 
;	original 31jul2016 by carl. based on mmlsfit.pro
;-

forward_function sign

;DETERMINE THE SIZE OF THE DATA ARRAY...
datasize = 9

;DEFINE THE INTERNAL data array used for fitting...
tdata= fltarr( datasize)
tdata[ 0:2]= reform(pacoeffs[ 0:2, 0, 1])
tdata[ 3:5]= reform(pacoeffs[ 0:2, 0, 2])
tdata[ 6:8]= reform(pacoeffs[ 0:2, 0, 3])

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
if keyword_set( fixdeltag) then nparams=nparams-1
if keyword_set( fixpsi) then nparams=nparams-1
if keyword_set( fixalpha) then nparams=nparams-1
if keyword_set( fixepsilon) then nparams=nparams-1
if keyword_set( fixphi) then nparams=nparams-1
if keyword_set( fixqsrc) then nparams=nparams-1
if keyword_set( fixusrc) then nparams=nparams-1
if keyword_set( fixvsrc) then nparams=nparams-1

coeffs_out=coeffs_in

;DEFINE NLOOP, THE NR OF ITERATIONS IN THE NONLINEAR FIT...
nloop = 0

;HALFASSED IS THE MULTIPLIER FOR THE CORRECTIONS IN NONLINEAR REGIME.
halfassed = 0.5

;DEFINE THE EQUATION-OF-CONDITION ARRAY, S...
s = dblarr(nparams, datasize)

print, 'nparams, datasize= ', nparams, datasize

;------------- BEGIN THE NONLINEAR ITERATION LOOP----------------
ITERATE_NONLINEAR:
nloop= nloop+1

;stop

;EVALUATE THE DERIVATIVES...
nr= -1
;DM_DDELTAG
IF (keyword_set( fixdeltag) ne 1) THEN BEGIN
del = frc
coeffs_out.deltag = coeffs_out.deltag + del
guess_tot_st, coeffs_out, guessplus
coeffs_out.deltag = coeffs_out.deltag - 2.d0*del
guess_tot_st, coeffs_out, guessminus
coeffs_out.deltag = coeffs_out.deltag + del
nr=nr+1 & s[ nr,*] = (guessplus- guessminus)/ (2.d0*del)
ENDIF

;DM_Dpsi
IF (keyword_set( fixpsi) ne 1) THEN BEGIN
del = frc
coeffs_out.psi = coeffs_out.psi + del
guess_tot_st, coeffs_out, guessplus
coeffs_out.psi = coeffs_out.psi - 2.d0*del
guess_tot_st, coeffs_out, guessminus
coeffs_out.psi = coeffs_out.psi + del
nr=nr+1 & s[ nr,*] = (guessplus- guessminus)/ (2.d0*del)
ENDIF

;DM_Dalpha
IF (keyword_set( fixalpha) ne 1) THEN BEGIN
del = frc
coeffs_out.alpha = coeffs_out.alpha + del
guess_tot_st, coeffs_out, guessplus
coeffs_out.alpha = coeffs_out.alpha - 2.d0*del
guess_tot_st, coeffs_out, guessminus
coeffs_out.alpha = coeffs_out.alpha + del
nr=nr+1 & s[ nr,*] = (guessplus- guessminus)/ (2.d0*del)
ENDIF

;DM_Depsilon
IF (keyword_set( fixepsilon) ne 1) THEN BEGIN
del = frc
coeffs_out.epsilon = coeffs_out.epsilon + del
guess_tot_st, coeffs_out, guessplus
coeffs_out.epsilon = coeffs_out.epsilon - 2.d0*del
guess_tot_st, coeffs_out, guessminus
coeffs_out.epsilon = coeffs_out.epsilon + del
nr=nr+1 & s[ nr,*] = (guessplus- guessminus)/ (2.d0*del)
ENDIF

;DM_Dphi
IF (keyword_set( fixphi) ne 1) THEN BEGIN
del = frc
coeffs_out.phi = coeffs_out.phi + del
guess_tot_st, coeffs_out, guessplus
coeffs_out.phi = coeffs_out.phi - 2.d0*del
guess_tot_st, coeffs_out, guessminus
coeffs_out.phi = coeffs_out.phi + del
nr=nr+1 & s[ nr,*] = (guessplus- guessminus)/ (2.d0*del)
ENDIF

;--------------------
IF (keyword_set( fixqsrc) ne 1) THEN BEGIN
;DM_Dqsrc
del = frc
coeffs_out.qsrc = coeffs_out.qsrc + del
guess_tot_st, coeffs_out, guessplus
coeffs_out.qsrc = coeffs_out.qsrc - 2.d0*del
guess_tot_st, coeffs_out, guessminus
coeffs_out.qsrc = coeffs_out.qsrc + del
nr=nr+1 & s[ nr,*] = (guessplus- guessminus)/ (2.d0*del)
ENDIF

IF (keyword_set( fixusrc) ne 1) THEN BEGIN
;DM_Dusrc
del = frc
coeffs_out.usrc = coeffs_out.usrc + del
guess_tot_st, coeffs_out, guessplus
coeffs_out.usrc = coeffs_out.usrc - 2.d0*del
guess_tot_st, coeffs_out, guessminus
coeffs_out.usrc = coeffs_out.usrc + del
nr=nr+1 & s[ nr,*] = (guessplus- guessminus)/ (2.d0*del)
ENDIF

IF (keyword_set( fixvsrc) ne 1) THEN BEGIN
;DM_Dvsrc
del = frc
coeffs_out.vsrc = coeffs_out.vsrc + del
guess_tot_st, coeffs_out, guessplus
coeffs_out.vsrc = coeffs_out.vsrc - 2.d0*del
guess_tot_st, coeffs_out, guessminus
coeffs_out.vsrc = coeffs_out.vsrc + del
nr=nr+1 & s[ nr,*] = (guessplus- guessminus)/ (2.d0*del)
ENDIF

;EVALUATE THE GUESSED MATRIX...
guess_tot_st, coeffs_out, guess_tdata, m_tot
;stop
;CREATE AND SOLVE THE NORMAL EQUATION MATRICES...
t = tdata- guess_tdata
ss = transpose(s) ## s
st = transpose(s) ## t
ssi = invert(ss)
delt = ssi ## st

;CHECK FOR SMALLNESS OF THE CORRECTIONS...
redoit= 0
indx= where(abs( delt) gt ax1, count)

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
   nr=nr+1 & coeffs_out.deltag= coeffs_out.deltag+ halfassed*delt[nr ]
endif

if keyword_set( fixpsi) eq 0 then begin
   nr=nr+1 & coeffs_out.psi= coeffs_out.psi+ halfassed*delt[nr ]
endif

if keyword_set( fixalpha) eq 0 then begin
   nr=nr+1 & coeffs_out.alpha= coeffs_out.alpha+ halfassed*delt[nr ]
endif

if keyword_set( fixepsilon) eq 0 then begin
   nr=nr+1 & coeffs_out.epsilon= coeffs_out.epsilon+ halfassed*delt[nr ]
endif

if keyword_set( fixphi) eq 0 then begin
   nr=nr+1 & coeffs_out.phi= coeffs_out.phi+ halfassed*delt[nr ]
endif

IF (keyword_set( fixqsrc) ne 1) THEN BEGIN
   nr=nr+1 & coeffs_out.qsrc= coeffs_out.qsrc+  halfassed*delt[nr ]
ENDIF

IF (keyword_set( fixusrc) ne 1) THEN BEGIN
   nr=nr+1 & coeffs_out.usrc= coeffs_out.usrc+  halfassed*delt[nr ]
ENDIF

IF (keyword_set( fixvsrc) ne 1) THEN BEGIN
   nr=nr+1 & coeffs_out.vsrc= coeffs_out.vsrc+  halfassed*delt[nr ]
ENDIF

if (nloop ge 1000) then begin
                problem = -2
                goto, PROBLEM
endif   

if keyword_set( noprint) eq 0 then print, nloop,transpose( delt)
;stop
if (redoit eq 1) then GOTO, ITERATE_NONLINEAR

;EVALUATE THE GUESSED MATRIX...
guess_tot_st, coeffs_out, tfit, m_tot, pacoeffs=pacoeffs_out

;stop
resid= tdata- tfit
sigsq = total( resid^2)/(datasize - nparams)
sigma = sqrt( sigsq)
sigarray = sigsq * ssi[indgen(nparams)*(nparams+1)]
indxsqrt = where( sigarray lt 0., countsqrt)
sigarray = sqrt( abs(sigarray))

;DERIVE THE NORMALIZED COVARIANCE ARRAY...
doug = ssi[indgen(nparams)*(nparams+1)]
doug = doug#doug
ncov = ssi/sqrt(doug)

;create the sigcoeffs output structure:
sigcoeffs_out= coeffs_out
coeffs_out.m_tot= m_tot
for nt=0, n_tags( sigcoeffs_out)-1 do begin
   sz= size( sigcoeffs_out.(nt))
   if sz[1] eq 4 then sigcoeffs_out.(nt)= 0.
endfor

nr=-1
if keyword_set( fixdeltag) eq 0 then begin
   nr=nr+1 & sigcoeffs_out.deltag=sigarray( nr)
endif

if keyword_set( fixpsi) eq 0 then begin
   coeffs_out.psi= modangle( coeffs_out.psi, 2.*!pi, /NEGPOS)
   nr=nr+1 & sigcoeffs_out.psi=sigarray( nr)
endif

if keyword_set( fixalpha) eq 0 then begin
   nr=nr+1 & sigcoeffs_out.alpha=sigarray( nr)
endif

if keyword_set( fixepsilon) eq 0 then begin
   nr=nr+1 & sigcoeffs_out.epsilon=sigarray( nr)
endif

if keyword_set( fixphi) eq 0 then begin
   nr=nr+1 & sigcoeffs_out.phi=sigarray( nr)
endif

;========================================
IF (keyword_set( fixqsrc) ne 1) THEN BEGIN
   nr=nr+1 & sigcoeffs_out.qsrc=sigarray( nr)
ENDIF

IF (keyword_set( fixusrc) ne 1) THEN BEGIN
   nr=nr+1 & sigcoeffs_out.usrc=sigarray( nr)
ENDIF

IF (keyword_set( fixvsrc) ne 1) THEN BEGIN
   nr=nr+1 & sigcoeffs_out.vsrc=sigarray( nr)
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
