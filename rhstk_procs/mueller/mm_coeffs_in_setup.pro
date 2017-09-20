pro mm_coeffs_in_setup, coeffs_in, nativecircular=nativecircular, $
	src=src, deltag=deltag, psi=psi, $
        alpha=alpha, epsilon=epsilon,phi=phi, $
        qsrc=qsrc, usrc=usrc, vsrc=vsrc

;+
;PURPOSE: make a standard set of guesses to run MM_CHISQFIT with and
;insert them in the input-guess structure COEFFS_IN
;
;CALLING SEQUENCE:
;mm_coeffs_in_setup, coeffs_in, nativecircular=nativecircular, $
;	src=src, deltag=deltag, psi=psi, $
;        alpha=alpha, epsilon=epsilon,phi=phi, $
;        qsrc=qsrc, usrc=usrc, vsrc=vsrc
;
;OUTPUT:
;  COEFFS_IN={.src, .deltag, .psi, .alpha, .epsilon, .phi, .chi, m_tot, $
;       .qsrc, .usrc, .vsrc, polsrc, pasrc } 
;-

coeffs_in= {src:'', deltag:0.0, psi:0.0, alpha:0.0, epsilon:0.0, phi:0.0, $
   chi:!pi/2., m_tot:fltarr(4,4), $
   qsrc:0.01, usrc:0.01, vsrc:0.01, polsrc:0.0, pasrc:0.0}

if keyword_set( nativecircular) then coeffs_in.alpha=!pi/4.

if n_elements( src) ne 0 then coeffs_in.src= src
if n_elements( deltag) ne 0 then coeffs_in.deltag= deltag
if n_elements( psi) ne 0 then coeffs_in.psi= psi
if n_elements( alpha) ne 0 then coeffs_in.alpha= alpha
if n_elements( epsilon) ne 0 then coeffs_in.epsilon= epsilon
if n_elements( phi) ne 0 then coeffs_in.phi= phi
     m_tot, coeffs_in.deltag, coeffs_in.epsilon, coeffs_in.alpha, $
            coeffs_in.phi, coeffs_in.chi, coeffs_in.psi, m_tot 
     coeffs_in.m_tot= m_tot
if n_elements( qsrc) ne 0 then coeffs_in.qsrc= qsrc
if n_elements( usrc) ne 0 then coeffs_in.usrc= usrc
if n_elements( vsrc) ne 0 then coeffs_in.vsrc= vsrc

; TR ADDED POLSRC AND PASRC TO THE MUELLER PARAMS JUN 19, 2007...
;               
coeffs_in.polsrc = sqrt( coeffs_in.qsrc^2 + coeffs_in.usrc^2)
pasrc = !radeg * 0.5*atan(coeffs_in.usrc, coeffs_in.qsrc)
coeffs_in.pasrc = modangle( pasrc,180.0,/NEGPOS)

return
end

