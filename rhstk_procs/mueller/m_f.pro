pro m_f, alpha, chi, m_f

;+
; PURPOSE: Calculate the feed Mueller matrix given the two relevant parameters
;(see AOTM 2000=xy).
;
; CALLING SEQUENCE:
;
;       M_F, alpha, chi, m_f
;
; INPUTS:
;
;       alpha: the tangent of alpha is the voltage ellipse.
;
;       chi is the phase angles; units are RADIANS. We use !pi/2 only; see the AOTM.
;
; OUTPUTS:
;
;       M_F, the total Mueller matrix.
;
; RELATED PROCEDURES/FUNCTIONS:
;
;       M_ILFR, M_TOT, M_A
; 
;-
  
m = fltarr(4,4)

m[0,0]=1.


m[1,1] = cos(alpha)^2 - sin(alpha)^2

m[2,1] = 2.*cos(alpha)*sin(alpha)*cos(chi)

m[3,1] = 2.*cos(alpha)*sin(alpha)*sin(chi)


m[1,2] = -2.*cos(alpha)*sin(alpha)*cos(chi)

m[2,2] = cos(alpha)^2 - sin(alpha)^2 * cos(2*chi)

m[3,2] = -sin(alpha)^2 * sin(2*chi)



m[1,3] = -2.*cos(alpha)*sin(alpha)*sin(chi)

m[2,3] = -sin(alpha)^2 * sin(2*chi)

m[3,3] = cos(alpha)^2 + sin(alpha)^2 * cos(2*chi)

m_f = m

return
end
