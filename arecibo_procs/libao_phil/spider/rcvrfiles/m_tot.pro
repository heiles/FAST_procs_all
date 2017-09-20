pro m_tot, deltag, epsilon, alpha, phi, chi, psi, m_tot

;+
; PURPOSE: Calculate the Mueller matrix given the six relevant parameters
;(see AOTM 2000=xy).
;
; CALLING SEQUENCE:
;
;	M_TOT, deltag, epsilon, alpha, phi, chi, psi, m_tot
;
; INPUTS:
;
;	deltag, the amplifier POWER (not voltage) gain error
;
;	epsilon, the nonorthogonal voltage coupling.  Units are
;fractions of the input voltage, which is unity. 
;
;	alpha: the tangent of alpha is the voltage ellipse.
;
;	phi, chi, psi are the various phase angles; units are RADIANS. 
;
; OUTPUTS:
;
;	M_TOT, the total Mueller matrix. 
;
; METHOD:
;
;	Calculates the individual matrices M_Fr, M_IFr, and M_A
;individually and the multiplies them.
;
; RELATED PROCEDURES/FUNCTIONS:
;
;	M_ILFR, M_F, M_A
;
;-




;FOR THE ANALYTICAL VERSION: M_TOT_ANALYTICAL.PRO

m_ilfr, epsilon, phi, m_ilfr
m_f, alpha, chi, m_f
m_a, deltag, psi, m_a
;m_tot = m_a ## m_f ## m_ilfr
m_tot = m_a ## m_ilfr ## m_f

return
end

