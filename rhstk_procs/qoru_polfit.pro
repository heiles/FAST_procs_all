pro qoru_polfit, pa, stk, qsky, usky, sigqsky, sigusky, $
                 pol, polang, sigpol, sigpolang, $
                 bt, q=q, u=u, $
                 payes=payes, stkyes=stkyes, indxorig_yes=indxorig_yes, $
                 cut=cut, mars=mars

;+
;PURPOSE: Fit cos2pa and sin2pa to the OBSERVED (non parallactic-angle
;corrected) stokes q or u to to derive the true SOURCE qsky and
;usky. Provides opportunity to automatically reject high residuals.
;
;CALLING SEQUENCE
;QORU_POLFIT, pa, stk, qsky, usky, sigqsky, sigusky, $
;                 pol, polang, sigpol, sigpolang, $
;                 bt, q=q, u=u, $
;                 payes=payes, stkyes=stkyes, indxorig_yes=indxorig_yes, $
;                 cut=cut, mars=mars
;
;INPUTS:
;       PA is input parallactic angle in DEGREES
;       STK is observed non-pa corrected stokes parm, either q or u.
;
;KEYWORDS:
;       set Q or U, depending on whether the input STK is q or u
;       set CUT to nr of sigma to zap data. e.g., cut=3 cuts all resids
;over 3 sigma. If cut is zero or not defined, it doesn't zap any data.
;       MARS: if set, does a Minimum Absolute Residual Sum fit, which is
;like using the median. Good for cases of severe interference. If set,
;it simply revers to the procedure qoru_polfit_mars.
;       NITER_MAX: if MARS is set, this pecifies themaximum mumber of
;iterations in the MARS fit. Default is 200.
;
;OUTPUTS:
;       QSKY, USKY, the resultls of the fit for the source q and u
;       SIGQSKY, SIGUSKY, the errors of QSKY, USKY
;       POL, the polarized intensity [i.e., sqrt(qsky^2 + usky^2) ]
;       POLANG, the position angle of the source in DEGREES
;       SIGPOL, SIGPOLANG, the errors in pol, polang
;       BT, the fitted values of STK, only for the points included in
;the fit.
;
;KEYWORD OUTPUTS:
;       STKYES=STKYES, the stk data included in the fit.
;       PAYES=PAYES, the parallactic angles included in the fit.
;       INDXORIG_YES=INDXORIG_YES, the indices of the original data that
;were used i.e., not rejected) in the fit
;
;HISTORY
;       CUT keyword added 19 may 2011.
;       Documented and updated by CH, 18 feb 2012
;
;FUNDAMENTAL EQNS:
;qobs= qsky cos(2pa)  +  usky sin(2pa)
;uobs= -qsky sin(2pa)  +  usky cos(2pa)
;-

if keyword_set( mars) then begin
   qoru_polfit_mars, pa, stk, qsky, usky, sigqsky, sigusky, $
                      pol, polang, sigpol, sigpolang, $
                      bt, q=q, u=u, $
                      niter_max=niter_max
   return
endif

ndata= n_elements( pa)
parad= !dtor* pa
stkyes= stk
indxorig_yes= lindgen( ndata)

iterate:
s= fltarr( 2, ndata)

if keyword_set( q) + keyword_set( u) ne 1 then stop, 'bad Q, U keywords!! stopping.'

if keyword_set( q) then begin
s[ 0,*]= cos( 2.* parad)
s[ 1,*]= sin( 2.* parad)
endif

if keyword_set( u) then begin
s[ 1,*]= cos( 2.* parad)
s[ 0,*]= -sin( 2.* parad)
endif

t= stkyes

ss = transpose(s) ## s
st = transpose(s) ## transpose(t)
ssi = invert(ss)

a = ssi ## st
bt = s ## a
resid = t - bt
yfit = reform( bt)
sigsq = total(resid^2)/(ndata-2.)
sigarray = sigsq * ssi[indgen(2)* 3]
sigcoeffs = sqrt( abs(sigarray))
coeffs = reform( a)
sigma = sqrt(sigsq)

;remove 3 sigma points if cut is set...
if keyword_set( cut) then begin
indxno= where( abs( resid) gt cut* sigma, countno)
;stop

if countno eq 0 then goto, finished
if keyword_set( cut) then begin
    indxyes= where( abs( resid) lt cut* sigma, countyes)
endif else indxyes= lindgen( ndata)
parad= parad[ indxyes]
stkyes= stkyes[ indxyes]
ndata= countyes
indxorig_yes= indxorig_yes[ indxyes]
goto, iterate
endif

finished:

payes= parad/ !dtor

qsky= coeffs[ 0]
usky= coeffs[ 1]
sigqsky= sigcoeffs[ 0]
sigusky= sigcoeffs[ 1]

pol= sqrt( qsky^2 + usky^2)
polang= !radeg* 0.5* atan( usky, qsky)

sigpol= sqrt( (qsky^2*sigqsky^2 + usky^2*sigusky^2)/pol^2)
sigpolang= sqrt( (qsky^2*sigusky^2 + usky^2*sigqsky^2)/pol^4)
return
end
