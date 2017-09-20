pro mm_coeffs_in_setup, coeffs_in, nativecircular=nativecircular, $
	deltag=deltag, psi=psi, $
        alpha=alpha, epsilon=epsilon,phi=phi, $
        theta_feed=theta_feed, theta_astron=theta_astron, vfctr=vfctr, $
        src=src, isrc=isrc, qsrc=qsrc, usrc=usrc, vsrc=vsrc, nosrc=nosrc
        inv=inv
;+
;PURPOSE: make a standard set of guesses to run MM_CHISQFIT with and
;insert them in the input-guess structure COEFFS_IN
;
;CALLING SEQUENCE:
;mm_coeffs_in_setup, coeffs_in, nativecircular=nativecircular, $
;	deltag=deltag, psi=psi, $
;        alpha=alpha, epsilon=epsilon,phi=phi, $
;        theta_feed:theta_feed, theta_astron:theta_astron, vfctr:vfctr, $
;        src=src, isrc=isrc, qsrc=qsrc, usrc=usrc, vsrc=vsrc, nosrc=nosrc
;       inv=inv
;
;INPUTS
;all inputs are keywords. since the purpose of this proc is to generate
;a standard mm_coeffs structure used in fitting, there is usually no
;reason to set any of these keywords
;
;OUTPUT:
;  COEFFS_IN={.deltag, .psi, .alpha, .epsilon, .phi, .chi, m_tot, $
;       .src, .isrc, .qsrc, .usrc, .vsrc, polsrc, pasrc } 
;
;KEYWORDS:
; NOSRC: if set, the coeffs_in structue does not contain the src
;               stokes parameters.
; all of the mueller coefficients, which are entered in COEFFS_IN
; INV: the nonzero initial guesses for the mueller coeffs. default=0.001
;-

if n_elements( inv) eq 0 then inv=0.0001
  
  coeffs_in= {deltag:inv, psi:inv, alpha:inv, epsilon:inv, phi:inv, $
   chi:!pi/2., m_tot:fltarr(4,4), $
   theta_feed:0.0, theta_astron:0.0, vfctr:1.0, $
   src:'', isrc:1.0, qsrc:0.0, usrc:0.0, vsrc:0.0, polsrc:0.0, pasrc:0.0}

if keyword_set( nosrc) then $
   coeffs_in= {deltag:inv, psi:inv, alpha:inv, epsilon:inv, phi:inv, $
   chi:!pi/2., m_tot:fltarr(4,4), $
   theta_feed:0.0, theta_astron:0.0, vfctr:1.0}

if keyword_set( nativecircular) then coeffs_in.alpha=!pi/4.

if n_elements( deltag) ne 0 then coeffs_in.deltag= deltag
if n_elements( psi) ne 0 then coeffs_in.psi= psi
if n_elements( alpha) ne 0 then coeffs_in.alpha= alpha
if n_elements( epsilon) ne 0 then coeffs_in.epsilon= epsilon
if n_elements( phi) ne 0 then coeffs_in.phi= phi

if n_elements( theta_feed) ne 0 then coeffs_theta_feed=theta_feed
if n_elements( theta_astron) ne 0 then coeffs_theta_astron=theta_astron
if n_elements( vfctr) ne 0 then coeffs_in.vfctr= vfctr

m_tot, coeffs_in.deltag, coeffs_in.epsilon, coeffs_in.alpha, $
     coeffs_in.phi, coeffs_in.chi, coeffs_in.psi, m_tot 
     coeffs_in.m_tot= m_tot

if keyword_set( nosrc) eq 0 then begin
        if n_elements( src) ne 0 then coeffs_in.src= src
        if n_elements( isrc) ne 0 then coeffs_in.isrc= isrc
        if n_elements( qsrc) ne 0 then coeffs_in.qsrc= qsrc
        if n_elements( usrc) ne 0 then coeffs_in.usrc= usrc
        if n_elements( vsrc) ne 0 then coeffs_in.vsrc= vsrc

; TR ADDED POLSRC AND PASRC TO THE MUELLER PARAMS JUN 19, 2007...
;               
coeffs_in.polsrc = sqrt( coeffs_in.qsrc^2 + coeffs_in.usrc^2)
pasrc = !radeg * 0.5*atan(coeffs_in.usrc, coeffs_in.qsrc)
coeffs_in.pasrc = modangle( pasrc,180.0,/NEGPOS)
endif

return
end

