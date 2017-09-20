pro mparamsfit, parang, stkobs, stksrc, mmcoeffs_in, $
        coeffs_out, sigcoeffs_out, $
	fixdeltag=fixdeltag, fixpsi=fixpsi, $
        fixalpha=fixalpha, fixepsilon=fixepsilon,fixphi=fixphi, $
        nloop=nloop, ncov=ncov, noprint=noprint, tdata=tdata, tfit=tfit, $
        m_tot=m_tot
;+
;
;PURPOSE: given NRS full-stokes measurements of sources with known
;polarization (standard polarization calibrators), observed at known
;parallactic angles, fit for athe mmcoeffs parameterss--any combination
;of of deltag, psi, alpha, epsilon, phi
;
;	*** THE UNIT FOR ALL PHASE ANGLES IS ****RADIANS******
;
;CALLING SEQUENCE:
;MPARAMSFIT, parang, stkobs, stksrc, mmcoeffs_in, $
;        coeffs_out, sigcoeffs_out, $
;	fixdeltag=fixdeltag, fixpsi=fixpsi, $
;        fixalpha=fixalpha, fixepsilon=fixepsilon,fixphi=fixphi, $
;        nloop=nloop, ncov=ncov, noprint=noprint, tdata=tdata, tfit=tfit, $
;        m_tot=m_tot
;
;INPUTS:
;  PARANG[nrs], the set of nrs parallactic angles, in DEGREES.
;  STKOBS[4,nrs], the set of 4 measured stokes parameters at those
;    parangs.
;  STKSRC[4,nrs], the known stokes parameters of the NRS sources
;MMCOEFFS_IN: {.deltag, .psi, .alpha, .epsilon, .phi,, .chi, .m_tot, $
;            .theta_feed, .theta_astron, .vfctr}
;  a structure with the initial 'guessed' values.
;  ALL ANGLES (psi, alpha, phi, chi) IN RADIANS
;  chi is always fixed at 90 deg. You can use
;  MMCOEFFS_IN_SETUP to generate this.
;
;KEYWORD INPUTS:
;	FIXpsi: Accepts PSI0 as correct and doesn't fit for it. 
;       FIXdeltag: accepts deltag0 as correct and doesn't fit for it.
;       fixalpha: Accepts alpha0 as correct and doesn't fit for it. 
;       fixepsilon; Accepts epsilon0 as correct and doesn't fit for it. 
;       fixphi=fixphi; Accepts phi0 as correct and doesn't fit for it. 
;
;OUTPUTS:
;       COEFFS_OUT, like MMCOEFFS_IN, contains the fitted values of mmcoeffs
;       SIGCOEFFS_OUT, the uncertainties in coeffs_out. quantities not solved
;       for are assigned zero uncertainty.
;
;KEYWORD OUTPUTS:
;       PROBLEM, if nonzero, indicates a problems in the nonlinear fit.
;	NLOOP, the number of loops in the nonlinear ls fit.
;	NCOV, the normalized covariance matrix
;       TDATA[3,nrs], the normalized array of Q,U,V WHICH ARE THE DATA
;          BEING FIT TO
;       TFIT[3,nrs], the final fitted values for TDATA.
;
;HISTORY: 
;	adapted from mmfit_2016.pro on 2 jun 2017 by CH
;-

forward_function sign

;DETERMINE THE SIZE OF THE DATA ARRAY...
nrd = n_elements( parang)

;DEFINE THE tdata data array used for fitting...
tdata= fltarr( 3,nrd)
for nd= 0, nrd-1 do tdata[ *,nd]= stkobs[1:3,nd]/stkobs[0,nd]
tdata= reform( tdata, 3*nrd)

;stop
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
nparams = 5
if keyword_set( fixdeltag) then nparams=nparams-1
if keyword_set( fixpsi) then nparams=nparams-1
if keyword_set( fixalpha) then nparams=nparams-1
if keyword_set( fixepsilon) then nparams=nparams-1
if keyword_set( fixphi) then nparams=nparams-1

coeffs_out=mmcoeffs_in

;DEFINE NLOOP, THE NR OF ITERATIONS IN THE NONLINEAR FIT...
nloop = 0

;HALFASSED IS THE MULTIPLIER FOR THE CORRECTIONS IN NONLINEAR REGIME.
halfassed = 0.5

;DEFINE THE EQUATION-OF-CONDITION ARRAY, S...
s = dblarr(nparams, 3*nrd)

;print, 'nparams, nrd= ', nparams, nrd

;------------- BEGIN THE NONLINEAR ITERATION LOOP----------------
ITERATE_NONLINEAR:
nloop= nloop+1

;EVALUATE THE DERIVATIVES...
nr= -1

;DM_DDELTAG
IF (keyword_set( fixdeltag) ne 1) THEN BEGIN
del = frc
coeffs_out.deltag = coeffs_out.deltag + del
mparams_apply, parang, stksrc, coeffs_out, guessp, $
 theta_astron=theta_astron, vfctr_astron=vfctr_astron, $
     tdata=tdataplus
coeffs_out.deltag = coeffs_out.deltag - 2.d0*del
mparams_apply, parang, stksrc, coeffs_out, guessm, $
 theta_astron=theta_astron, vfctr_astron=vfctr_astron, $
     tdata=tdataminus
coeffs_out.deltag = coeffs_out.deltag + del
nr=nr+1 & s[ nr,*] = (tdataplus- tdataminus)/ (2.d0*del)
ENDIF
;stop

;DM_Dpsi
IF (keyword_set( fixpsi) ne 1) THEN BEGIN
del = frc
coeffs_out.psi = coeffs_out.psi + del
mparams_apply, parang, stksrc, coeffs_out, guessp, $
     theta_astron=theta_astron, vfctr_astron=vfctr_astron, $
     tdata=tdataplus
coeffs_out.psi = coeffs_out.psi - 2.d0*del
mparams_apply, parang, stksrc, coeffs_out, guessm, $
     theta_astron=theta_astron, vfctr_astron=vfctr_astron, $
     tdata=tdataminus
coeffs_out.psi = coeffs_out.psi + del
nr=nr+1 & s[ nr,*] = (tdataplus- tdataminus)/ (2.d0*del)
ENDIF

;DM_Dalpha
IF (keyword_set( fixalpha) ne 1) THEN BEGIN
del = frc
coeffs_out.alpha = coeffs_out.alpha + del
mparams_apply, parang, stksrc, coeffs_out, guessp, $
 theta_astron=theta_astron, vfctr_astron=vfctr_astron, $
     tdata=tdataplus
coeffs_out.alpha = coeffs_out.alpha - 2.d0*del
mparams_apply, parang, stksrc, coeffs_out, guessm, $
 theta_astron=theta_astron, vfctr_astron=vfctr_astron, $
     tdata=tdataminus
coeffs_out.alpha = coeffs_out.alpha + del
nr=nr+1 & s[ nr,*] = (tdataplus- tdataminus)/ (2.d0*del)
ENDIF

;DM_Depsilon
IF (keyword_set( fixepsilon) ne 1) THEN BEGIN
del = frc
coeffs_out.epsilon = coeffs_out.epsilon + del
mparams_apply, parang, stksrc, coeffs_out, guessp, $
 theta_astron=theta_astron, vfctr_astron=vfctr_astron, $
     tdata=tdataplus
coeffs_out.epsilon = coeffs_out.epsilon - 2.d0*del
mparams_apply, parang, stksrc, coeffs_out, guessm, $
 theta_astron=theta_astron, vfctr_astron=vfctr_astron, $
     tdata=tdataminus
coeffs_out.epsilon = coeffs_out.epsilon + del
nr=nr+1 & s[ nr,*] = (tdataplus- tdataminus)/ (2.d0*del)
ENDIF

;DM_Dphi
IF (keyword_set( fixphi) ne 1) THEN BEGIN
del = frc
coeffs_out.phi = coeffs_out.phi + del
mparams_apply, parang, stksrc, coeffs_out, guessp, $
 theta_astron=theta_astron, vfctr_astron=vfctr_astron, $
     tdata=tdataplus
coeffs_out.phi = coeffs_out.phi - 2.d0*del
mparams_apply, parang, stksrc, coeffs_out, guessm, $
 theta_astron=theta_astron, vfctr_astron=vfctr_astron, $
     tdata=tdataminus
coeffs_out.phi = coeffs_out.phi + del
nr=nr+1 & s[ nr,*] = (tdataplus- tdataminus)/ (2.d0*del)
ENDIF

;EVALUATE THE GUESSED MATRIX...
mparams_apply, parang, stksrc, coeffs_out, guess_tdata, $
 theta_astron=theta_astron, vfctr_astron=vfctr_astron, $
     tdata=tdata_guess, m_tot=m_tot

;stop, nloop
;CREATE AND SOLVE THE NORMAL EQUATION MATRICES...
t = tdata- tdata_guess
ss = transpose(s) ## s
st = transpose(s) ## t
ssi = invert(ss)
delt = ssi ## st

;CHECK FOR SMALLNESS OF THE CORRECTIONS...
redoit= 0
indx= where(abs( delt) gt ax1, count)

;stop, nloop, transpose( delt)

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

if (nloop ge 1000) then begin
                problem = -2
                goto, PROBLEM
endif   

if keyword_set( noprint) eq 0 then print, nloop,transpose( delt)
;stop
if (redoit eq 1) then GOTO, ITERATE_NONLINEAR

;EVALUATE THE GUESSED MATRIX...
mparams_apply, parang, stksrc, coeffs_out, stkobs_tfit, $
 theta_astron=theta_astron, vfctr_astron=vfctr_astron, $
     tdata=tfit, m_tot=m_tot

;stop
resid= tdata- tfit
sigsq = total( resid^2)/(nrd - nparams)
sigma = sqrt( sigsq)
sigarray = sigsq * ssi[indgen(nparams)*(nparams+1)]
indxsqrt = where( sigarray lt 0., countsqrt)
sigarray = sqrt( abs(sigarray))

;stop

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

;STOP, 'no problem'
return

PROBLEM:
print, 'PROBLEM!! NUMBER ', problem, string(7b)
;muellerparams1.problem= problem

;STOP, 'problem'
return
end
