pro m_a, deltag, psi, m_a


;+
; PURPOSE: Calculate the Mueller for the amplifier, M_A, the two relevant parameters
;(see AOTM 2000=xy).
;
; CALLING SEQUENCE:
;
;       M_A, deltag, psi, M_A
;
; INPUTS:
;
;       deltag, the POWER (not voltage) gain error. 
;
;       alpha: the tangent of alpha is the voltage ellipse.
;
;       phi, chi, psi are the various phase angles; units are RADIANS.
;
; OUTPUTS:
;
;       M_A, the amplifier Mueller matrix.
;
; RELATED PROCEDURES/FUNCTIONS:
;
;       M_TOT, M_ILFR, M_F
;
;-
  
m = fltarr(4,4)

m[0,0]=1.

m[1,0] = 0.5*deltag


m[0,1] = 0.5*deltag 

m[1,1] = 1.

m[2,2] = cos(psi)

m[3,2] = -sin(psi)


m[2,3] = sin(psi)

m[3,3] =  cos(psi)

m_a = m

return
end
