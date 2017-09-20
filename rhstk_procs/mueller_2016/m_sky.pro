pro m_sky, parang, m_sky

;+
; PURPOSE: Calculate the Mueller for the parallactic rotation on the sky

; CALLING SEQUENCE:
;
;       M_SKY, parang, m_sky
;
; INPUTS:
;       PARANG, the angle in DEGREES
;
; OUTPUTS:
;       M_sky
;-
  
m_sky = fltarr(4,4)

m_sky[0,0]=1.

m_sky[1,1] = 1.

m_sky[1,1] = cos(!dtor* 2.* parang)
m_sky[2,2] = m_sky[1,1]
m_sky[2,1] = sin(!dtor* 2.* parang)
m_sky[1,2] = -m_sky[ 2,1]
m_sky[3,3] =  1.0

return
end
