pro mmfit_2016_multiplesources, pacoeffs_in, $
        coeffs_in, coeffs_out, sigcoeffs_out, $
        sources_in, sources_out, sigsources_out, $
	fixdeltag=fixdeltag, fixpsi=fixpsi, $
        fixalpha=fixalpha, fixepsilon=fixepsilon,fixphi=fixphi, $
        fixqsrc=fixqsrc, fixusrc=fixusrc, fixvsrc=fixvsrc, $
	nloop=nloop, ncov=ncov, noprint=noprint, tdata=tdata, tfit=tfit, $
        m_tot=m_tot, pacoeffs_out=pacoeffs_out, problem=problem

;+
;
;PURPOSE: Given data for multiple sources whose polarizations are not
;necessarily known, over a range of parallactic angles, fit for any
;combination of deltag, psi, alpha, epsilon, phi, qsrc, usrc, vsrc. This
;version handles multiple sources: NRS sources, all with different
;intrinsic stokes parameters and all with the same mueller matrix
;coefficients.
;
;	*** THE UNIT FOR ALL PHASE ANGLES IS ****RADIANS******
;
;CALLING SEQUENCE:
;mmfit_2016_multiplesources, pacoeffs_in, $
;        coeffs_in, coeffs_out, sigcoeffs_out, $
;        sources_in, sources_out, sigsources_out, $
;	fixdeltag=fixdeltag, fixpsi=fixpsi, $
;        fixalpha=fixalpha, fixepsilon=fixepsilon,fixphi=fixphi, $
;        fixqsrc=fixqsrc, fixusrc=fixusrc, fixvsrc=fixvsrc, $
;	nloop=nloop, ncov=ncov, noprint=noprint, tdata=tdata, tfit=tfit, $
;        m_tot=m_tot, pacoeffs_out=pacoeffs_out, problem=problem
;
;INPUTS:
;   PACOEFFS_IN[3,2,4, NRS]: PACOEFFS, the output from STRIPFIT_TO_PACOEFFS: 
;           PACOEFFS_IN[3,*,*,*] are ABC in: intensity = A + Bcos(2pa) + Csin(20a)
;           PACOEFFS_IN[*,2,*,*] are the value and its uncertainty
;           PACOEFFS_IN[*,*,4,*] are APB', AMB', AB'. BA' in eqn 27 of the
;               Heiles et al PASP paper on Mueller matrix calibration
;           PACOEFFS_IN[*,*,4,NRS] are for the NRS different
;       sources. Using STRIPFIT_TO_PACOEFFS, evaluate PACOEFFS for each
;       source (a 3-d array) and combine them to make the 4d array PACOEFFS_IN.
;
;  COEFFS_IN= {.deltag, .psi, .alpha, .epsilon, .phi, .chi, .m_tot, $
;          .theta_feed, .theta_astron, .vfctr}
;       A single structure containing the iniial guesses for the Mueller
;       matrix parameters to be solved for. Use MM_COEFFS_IN_SETUP to
;       generate this. This structure was originally meant for a single
;       source; for the present proc, which accomodates multiple
;       sources, the 3 final tags for the source polarizations are
;       ignored and instead obtained from SOURCES_IN
;
;  SOURCES_IN={.src, .isrc, .qsrc, .usrc, .vsrc, .polsrc, .pasrc}, an
;       NRS-long array of structures with initial guesses for the source
;       stokes parameters.  Easiest is to set all these guesses equal to
;       zero.
;
;OUTPUTS:
;       COEFFS_OUT, the fitted values of the Mueller matrixparameters in COEFFS_IN. 
;       SIGCOEFFS_OUT, the uncertainties in COEFFS_OUT. quantities not solved
;               for are assigned zero uncertainty.
;       SOURCES_OUT, the fitted values for the parameters in SOURCES_IN.
;       SIGSOURCES_OUT, the uncertainties In SOURCES_IN.
;
;KEYWORDS:
;	FIXpsi: Accepts PSI0 as correct and doesn't fit for it. 
;       FIXdeltag: accepts deltag0 as correct and doesn't fit for it.
;       fixalpha: Accepts alpha0 as correct and doesn't fit for it. 
;       fixepsilon; Accepts epsilon0 as correct and doesn't fit for it. 
;       fixphi=fixphi; Accepts phi0 as correct and doesn't fit for it. 
;	FIXqsrc, takes all qsrc0 as correct and doesn't fit for them
;	FIXusrc, takes all usrc0 as correct and doesn't fit for them
;	FIXvsrc, takes all vsrc0 as correct and doesn't fit for them
;	PROBLEM, if nonzero, indicates a problems in the nonlinear fit.
;	NLOOP, the number of loops in the nonlinear ls fit.
;	NCOV, the normalized covariance matrix
;       NOPRINT, don't print new estimates for each iterative loop
;       TDATA[3,nrs], the normalized array of Q,U,V WHICH ARE THE DATA
;               BEING FIT TO
;       TFIT[3,nrs], the final fitted values for TDATA.       
;HISTORY: 
;	original 31jul2016 by carl. based on mmlsfit.pro. more
;refinement 05jun2017.
;-

forward_function sign

;DETERMINE THE SIZE OF THE DATA ARRAY...
nrs= n_elements( sources_in)
datasize = 9*nrs

;DEFINE THE INTERNAL data array used for fitting...
tdata= fltarr( datasize)
nt=0
for ns=0, nrs-1 do begin
tdata[ nt+0:nt+2]= reform(pacoeffs_in[ 0:2, 0, 1, ns])
tdata[ nt+3:nt+5]= reform(pacoeffs_in[ 0:2, 0, 2, ns])
tdata[ nt+6:nt+8]= reform(pacoeffs_in[ 0:2, 0, 3, ns])
nt= nt+9
endfor
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
if keyword_set( fixqsrc) eq 0 then nparams= nparams+ nrs
if keyword_set( fixusrc) eq 0 then nparams= nparams+ nrs
if keyword_set( fixvsrc) eq 0 then nparams= nparams+ nrs

if keyword_set( fixdeltag) then nparams=nparams-1
if keyword_set( fixpsi) then nparams=nparams-1
if keyword_set( fixalpha) then nparams=nparams-1
if keyword_set( fixepsilon) then nparams=nparams-1
if keyword_set( fixphi) then nparams=nparams-1

coeffs_out=coeffs_in
sources_out=sources_in
sigsources_out=sources_in
sigsources_out.isrc=0.
sigsources_out.qsrc=0.
sigsources_out.usrc=0.
sigsources_out.vsrc=0.
;#####################################################3

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
guess_tot_st_multiplesources, coeffs_out, sources_out, guessplus
coeffs_out.deltag = coeffs_out.deltag - 2.d0*del
guess_tot_st_multiplesources, coeffs_out, sources_out, guessminus
coeffs_out.deltag = coeffs_out.deltag + del
nr=nr+1 & s[ nr,*] = (guessplus- guessminus)/ (2.d0*del)
ENDIF

;DM_Dpsi
IF (keyword_set( fixpsi) ne 1) THEN BEGIN
del = frc
coeffs_out.psi = coeffs_out.psi + del
guess_tot_st_multiplesources, coeffs_out, sources_out, guessplus
coeffs_out.psi = coeffs_out.psi - 2.d0*del
guess_tot_st_multiplesources, coeffs_out, sources_out, guessminus
coeffs_out.psi = coeffs_out.psi + del
nr=nr+1 & s[ nr,*] = (guessplus- guessminus)/ (2.d0*del)
ENDIF

;DM_Dalpha
IF (keyword_set( fixalpha) ne 1) THEN BEGIN
del = frc
coeffs_out.alpha = coeffs_out.alpha + del
guess_tot_st_multiplesources, coeffs_out, sources_out, guessplus
coeffs_out.alpha = coeffs_out.alpha - 2.d0*del
guess_tot_st_multiplesources, coeffs_out, sources_out, guessminus
coeffs_out.alpha = coeffs_out.alpha + del
nr=nr+1 & s[ nr,*] = (guessplus- guessminus)/ (2.d0*del)
ENDIF

;DM_Depsilon
IF (keyword_set( fixepsilon) ne 1) THEN BEGIN
del = frc
coeffs_out.epsilon = coeffs_out.epsilon + del
guess_tot_st_multiplesources, coeffs_out, sources_out, guessplus
coeffs_out.epsilon = coeffs_out.epsilon - 2.d0*del
guess_tot_st_multiplesources, coeffs_out, sources_out, guessminus
coeffs_out.epsilon = coeffs_out.epsilon + del
nr=nr+1 & s[ nr,*] = (guessplus- guessminus)/ (2.d0*del)
ENDIF

;DM_Dphi
IF (keyword_set( fixphi) ne 1) THEN BEGIN
del = frc
coeffs_out.phi = coeffs_out.phi + del
guess_tot_st_multiplesources, coeffs_out, sources_out, guessplus
coeffs_out.phi = coeffs_out.phi - 2.d0*del
guess_tot_st_multiplesources, coeffs_out, sources_out, guessminus
coeffs_out.phi = coeffs_out.phi + del
nr=nr+1 & s[ nr,*] = (guessplus- guessminus)/ (2.d0*del)
ENDIF

;--------------------
;############################################################
for ns=0, nrs-1 do begin
   IF (keyword_set( fixqsrc) ne 1) THEN BEGIN
;DM_Dqsrc
      del = frc
      sources_out[ns].qsrc = sources_out[ns].qsrc + del
      guess_tot_st_multiplesources, coeffs_out, sources_out, guessplus
      sources_out[ns].qsrc = sources_out[ns].qsrc - 2.d0*del
      guess_tot_st_multiplesources, coeffs_out, sources_out, guessminus
sources_out[ns].qsrc = sources_out[ns].qsrc + del
;nr=nr+1 & s[ nr,ns*9:ns*9+8] = (guessplus- guessminus)/ (2.d0*del)
nr=nr+1 & s[ nr,*] = (guessplus- guessminus)/ (2.d0*del)
;stop
ENDIF

IF (keyword_set( fixusrc) ne 1) THEN BEGIN
;DM_Dusrc
del = frc
sources_out[ns].usrc = sources_out[ns].usrc + del
;guess_tot_st_multiplesources, coeffs_out, sources_out[ns], guessplus
guess_tot_st_multiplesources, coeffs_out, sources_out, guessplus
sources_out[ns].usrc = sources_out[ns].usrc - 2.d0*del
;guess_tot_st_multiplesources, coeffs_out, sources_out[ns], guessminus
guess_tot_st_multiplesources, coeffs_out, sources_out, guessminus
sources_out[ns].usrc = sources_out[ns].usrc + del
;nr=nr+1 & s[ nr,ns*9:ns*9+8] = (guessplus- guessminus)/ (2.d0*del)
nr=nr+1 & s[ nr,*] = (guessplus- guessminus)/ (2.d0*del)
ENDIF

IF (keyword_set( fixvsrc) ne 1) THEN BEGIN
;DM_Dvsrc
del = frc
sources_out[ns].vsrc = sources_out[ns].vsrc + del
guess_tot_st_multiplesources, coeffs_out,sources_out, guessplus
sources_out[ns].vsrc = sources_out[ns].vsrc - 2.d0*del
guess_tot_st_multiplesources, coeffs_out,sources_out, guessminus
sources_out[ns].vsrc = sources_out[ns].vsrc + del
;nr=nr+1 & s[ nr,ns*9:ns*9+8] = (guessplus- guessminus)/ (2.d0*del)
nr=nr+1 & s[ nr,*] = (guessplus- guessminus)/ (2.d0*del)
ENDIF
ENDFOR

;EVALUATE THE GUESSED MATRIX...
guess_tot_st_multiplesources, coeffs_out, sources_out, guess_tdata, m_tot
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

;#######################################################################
FOR ns=0, nrs-1 DO BEGIN
   IF (keyword_set( fixqsrc) ne 1) THEN BEGIN
   nr=nr+1 & sources_out[ns].qsrc= sources_out[ns].qsrc+  halfassed*delt[nr ]
ENDIF

IF (keyword_set( fixusrc) ne 1) THEN BEGIN
   nr=nr+1 & sources_out[ns].usrc= sources_out[ns].usrc+  halfassed*delt[nr ]
ENDIF

IF (keyword_set( fixvsrc) ne 1) THEN BEGIN
   nr=nr+1 & sources_out[ns].vsrc= sources_out[ns].vsrc+  halfassed*delt[nr ]
ENDIF
ENDFOR

if (nloop ge 1000) then begin
                problem = -2
                goto, PROBLEM
endif   

if keyword_set( noprint) eq 0 then begin
   print, nloop,transpose( delt)
;   print, nloop,transpose( tfit)
print, coeffs_out.deltag, coeffs_out.psi
print, sources_out.qsrc, sources_out.usrc, sources_out.vsrc
endif

;stop
if (redoit eq 1) then GOTO, ITERATE_NONLINEAR
;if nloop lt 50 then goto, iterate_nonlinear

;stop
;EVALUATE THE GUESSED MATRIX...
guess_tot_st_multiplesources, coeffs_out, sources_out, tfit, m_tot, $
   pacoeffs_out=pacoeffs_out

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
FOR ns=0, nrs-1 DO BEGIN
IF (keyword_set( fixqsrc) ne 1) THEN BEGIN
   nr=nr+1 & sigsources_out[ns].qsrc=sigarray( nr)
ENDIF

IF (keyword_set( fixusrc) ne 1) THEN BEGIN
   nr=nr+1 & sigsources_out[ns].usrc=sigarray( nr)
ENDIF

IF (keyword_set( fixvsrc) ne 1) THEN BEGIN
   nr=nr+1 & sigsources_out[ns].vsrc=sigarray( nr)
ENDIF
ENDFOR


;stop

; TR ADDED POLSRC AND PASRC TO THE MUELLER PARAMS JUN 19, 2007...
sources_out.polsrc = sqrt( sources_out.qsrc^2 + sources_out.usrc^2)
pasrc = !radeg * 0.5*atan(sources_out.usrc, sources_out.qsrc)
sources_out.pasrc = modangle( pasrc,180.0,/NEGPOS)

; TR ADDED THE UNCERTAINTIES JUN 29 2007...
; CHECKED AGAINST THE HEILES/FISHER MEMO AND THEY AGREE!!
sigpolsrc = sqrt( sources_out.qsrc^2*sigsources_out.qsrc^2 + $
        sources_out.usrc^2*sigsources_out.usrc^2) / sources_out.polsrc
sigsources_out.polsrc = sigpolsrc
sigsources_out.pasrc = !radeg * 0.5 * sigpolsrc / sources_out.polsrc

;STOP, 'no problem'
return

PROBLEM:
print, 'PROBLEM!! NUMBER ', problem, string(7b)
;muellerparams1.problem= problem

;STOP, 'problem'
return
end
