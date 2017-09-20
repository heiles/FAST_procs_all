pro qoru_polfit_mars, pa, stk, qsky, usky, sigqsky, sigusky, $
                      pol, polang, sigpol, sigpolang, $
                      bt, q=q, u=u, $
                      niter_max=niter_max
  
;+                                                                                                     
;PURPOSE: Fit cos2pa and sin2pa to the OBSERVED (non parallactic-angle                                 
;corrected) stokes q or u to to derive the true SOURCE qsky and                                        
;usky. Does MARS fit.
; 
;CALLING SEQUENCE 
;QORU_POLFIT_MARS, pa, stk, qsky, usky, sigqsky, sigusky, $
;                      pol, polang, sigpol, sigpolang, $
;                      bt, q=q, u=u, $
;                      niter_max=niter_max
;  
;INPUTS:
;       PA is input parallactic angle in DEGREES
;       STK is observed non-pa corrected stokes parm, either q or u. 
;
;KEYWORDS: 
;       set Q or U, depending on whether the input STK is q or u 
;       niter_max: max nr of iterations for mars fit. default = 200                                                              ;                                        
;OUTPUTS:                                                                                              
;       QSKY, USKY, the resultls of the fit for the source q and u                                     
;       POL, the polarized intensity [i.e., sqrt(qsky^2 + usky^2) ]
;       POLANG, the position angle of the source in DEGREES 
;       SIGPOL, SIGPOLANG, the errors in pol, polang
;       BT, the fitted values of STK, only for the points included in
;the fit.
;
;HISTORY 
;       Documented and updated by CH, 18 feb 2012 
; 
;FUNDAMENTAL EQNS:
;qobs= qsky cos(2pa)  +  usky sin(2pa) 
;uobs= -qsky sin(2pa)  +  usky cos(2pa) 
;-

if keyword_set( NITER_MAX) eq 0 then niter_max=200

ndata= n_elements( pa)
wgt= 1.d0+ dblarr( 2l* ndata)
parad= double( !dtor* pa)
ncoeffs=2
niterate=0

;THE PREFIX W MEANS QUANTITIES ARE WEIGHTED BEFORE BEING USED.
s= dblarr( ncoeffs, ndata)
ws= dblarr( ncoeffs, ndata)
wmin=1.d0
wtot= total( wgt)

if keyword_set( q) then begin
s[ 0,*]= cos( 2.* parad)
s[ 1,*]= sin( 2.* parad)
endif

if keyword_set( u) then begin
s[ 1,*]= cos( 2.* parad)
s[ 0,*]= -sin( 2.* parad)
endif

tt= double( stk)

ITERATE:
wmin_before= wmin
wtot_before= wtot
;APPLY THE WEIGHTS...
;for nd=0l, 2l*ndata-1l do ws[ *,nd]= s[ *,nd]* wgt[ nd]
for nco= 0, ncoeffs-1 do ws[ nco,*]= s[ nco,*]*wgt
wt= tt* wgt

wss = transpose( ws) ## ws
wst = transpose( ws) ## wt
wssi = invert( wss)

a = wssi ## wst
wbt = ws ## a
bt= wbt/ wgt

wresid = wt - wbt
resid= wresid/ wgt
wyfit = reform( wbt)
yfit = wyfit/ wgt

w= abs( resid) 
wtot= total( w)
w=w/ median(w)
w= w > 1.e-9
wgt= 1./ sqrt( w)

niterate= niterate+1
wmin= min( w)

indx= where( resid gt 0, count)
indxhalf = 0
if ( abs( count - ndata) gt 1) then indxhalf=1

;BY-HAND TEST...
wratio=  (wtot-wtot_before)/wtot
;print, niterate, count, ndata, wtot, wtot-wtot_before, wratio, a[0], a[1]
;print, wmin-wmin_before, wtot-wtot_before, '   HIT ANY KEY TO CONTINUE, q TO FINISH'
;result= get_kbrd(1)
;if (result eq 's') then begin
;        stop, 'stopped'
;        goto, iterate
;endif
;if (result ne 'q') then goto, iterate

;IF ( (NITERATE LT NITER_MAX) AND $
;        ((ABS( WMIN) GT 1E-6) or (indxhalf eq 1)) AND $
;        ( abs( wmin - wmin_before) gt 1e-6) ) THEN GOTO, ITERATE

if niterate eq 1 then goto, iterate
IF ( (NITERATE le NITER_MAX) AND $
     ((wtot-wtot_before)/wtot lt -4.e-5) ) then goto, iterate

;DERIVE THE NORMALIZED COVARIANCE ARRAY...
diags= indgen( ncoeffs)*( ncoeffs+ 1)
doug = wssi[ diags]
doug = doug#doug
ncov = wssi/sqrt(doug)

;CALCULATE ERRORS ASSUMING GAUSSIAN PDF, USING STANDARD LS FIT
;TECHNIQUE...
variance= total( resid^2)/ (ndata*2l- ncoeffs)
sigsqarray1 = variance * wssi[ diags ]

sigma= sqrt( variance)
sigcoeffs = sqrt( abs(sigsqarray1))
coeffs = reform( a)

;----------------------------
;sigsq = total(resid^2)/(2l*ndata-ncoeffs)
;sigarray = sigsq * ssi[indgen(ncoeffs)* (ncoeffs+1)]
;sigcoeffs = sqrt( abs(sigarray))
;coeffs = reform( a)
;sigma = sqrt(sigsq)
;
;;generate new weights, which are sqrt of reciprocal of abs resid...
;wgt= sqrt( abs( resid)) 
;wgt= wgt > (mean( wgt)/1.e6)
;wgt= 1./wgt
;goto, iterate

;EXTRACT SOURCE PARAMETERS...
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
