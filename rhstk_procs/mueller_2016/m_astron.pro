pro m_astron, theta, vfctr, m_astro

;+
; PURPOSE: Calculate the Mueller for the 'astronomical
; conventions'. This matrix consists of a rotation angle, theta, for
; the possition angle; and a factor vctr=+-1 to make the sign of Stokes
; V comply with standard definition.

; CALLING SEQUENCE:
;
;       M_ASTRON, theta, vfctr, m_astro
;
; INPUTS:
;       theta, the angle in DEGREES
;       vfctr
;
; OUTPUTS:
;       M_ASTRO
;-
  
m_astro = fltarr(4,4)

m_astro[0,0]=1.

m_astro[1,1] = cos(!dtor* 2.* theta)
m_astro[2,2] = m_astro[1,1]
m_astro[2,1] = sin(!dtor* 2.* theta)
m_astro[1,2] = -m_astro[ 2,1]
m_astro[3,3] =  vfctr

return
end
