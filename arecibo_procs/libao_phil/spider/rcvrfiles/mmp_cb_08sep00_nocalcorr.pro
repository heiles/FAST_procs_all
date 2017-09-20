pro mmp_cb_08sep00_nocalcorr, cfr, m_tot, m_astron, $
	deltag, epsilon, alpha, phi, chi, psi, angle_astron

;+

;PURPOSE: return M_TOT for cb, given cfr.  
;
;	The parameters come primarily from B0017+154 and B2209+080, and
;secondarily from B1615+212, observed 16sep00, 17sep00, and15sep00,
;respectively. The source 0333+321, observed 20sep00, had crappy fits and
;gave conflicting results and was totally ignored. 
;
;	The behavior of psi with frequency implies a cable length
;difference for the correlated cal of 58 cm if one restricts attention to
;the three upper frequencies (4860, 5000, 5400 MHz). The lowest
;frequency, 4500 MHz, did not lie on this straight line at all. The
;reason for such a large path difference, and also for the inconsistent
;result at 4500 MHz, is a total mystery.

;CALLING SEQUENCE: MMP_LBN_08DEC00-NOCALCORR, cfr, m_tot, $
;	deltag, epsilon, alpha, phi, chi, psi

;
;INPUT: 
;
;	CFR. 
;
;OUTPUT:
;
;	M_TOT, the feeds mueller matrix.
;
;	M_ASTRON

;	DELTAG, EPSILON, ALPHA, PHI, CHI, PSI, the parameters.  The
;units of angles are radians.  
; 
;KEYWORD: 
; 
;	INCOMPLETE does not include the final rotation required to make 
;pa's correct for astronomical sources. 
;
;-

cfr50= cfr- 5000.

alpha= -1.23
alpha= !dtor* alpha

epsilon= 0.005

phi= 132.
phi= !dtor* phi

if (cfr gt 4800.) then begin
psi= -125.+ 0.102*cfr50
endif else psi=78.
psi= !dtor*psi

chi= 90.*!dtor
deltag= 0.020

m_tot, deltag, epsilon, alpha, phi, chi, psi, m_tot

;NEXT GET THE CORRECTION REQUIRED TO MAKE THE PA'S CORRECT FOR 
;ASTRONOMY...

if keyword_set( incomplete) then return      
angle_astron= -78.
angle= angle_astron* !dtor   
m_astron= fltarr( 4,4)
m_astron[ 0,0]= 1.
m_astron[ 3,3]= 1.
m_astron[ 1,1]= 2.* cos( angle)
m_astron[ 2,1]= 2.* sin( angle) 
m_astron[ 2,2]= m_astron[ 1,1] 
m_astron[ 1,2]= -m_astron[ 2,1]

return
end

