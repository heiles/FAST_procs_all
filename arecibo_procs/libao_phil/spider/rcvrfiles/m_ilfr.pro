pro m_ilfr, epsilon, phi, m_ilfr

;+

; PURPOSE: Calculate the Mueller matrix for the feed imperfections given
;the two relevant parameters (see AOTM 2000=xy). 
;
; CALLING SEQUENCE:
;
;       M_ILFR, epsilon, phi, m_ilfr
;
; INPUTS:
;
;       epsilon, the nonorthogonal voltage coupling.  Units are
;fractions of the input voltage, which is unity.
;
;       phi, phase angles of the coupling; units are RADIANS.
;
; OUTPUTS:
;
;       M_ILFR, the total Mueller matrix.
;
; RELATED PROCEDURES/FUNCTIONS:
;
;       M_TOT, M_F, M_A
; 
;-
  
m = fltarr(4,4)

m[0,0]=1.

m[2,0] = 2*epsilon*cos(phi) 

m[3,0] = 2*epsilon*sin(phi) 

m[1,1] = 1.

m[0,2] = 2.*epsilon* cos(phi)

m[2,2] = 1.

m[0,3] = 2.*epsilon* sin(phi) 

m[3,3] = 1.

m_ilfr = m

return
end
