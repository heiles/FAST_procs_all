pro mmp_sbh_08apr02_nocalcorr, cfr, m_tot, m_astron, $
	deltag, epsilon, alpha, phi, chi, psi, angle_astron

;+

;PURPOSE: return M_TOT for sbh, given cfr.  
;
;   These are dummy parameters to get us going before any calibration runs
;done..
;
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

cfr50= cfr- 3500.

;alpha= -1.23
alpha= 0.
alpha= !dtor* alpha

;epsilon= 0.005
epsilon= 0.

;phi= 132.
phi= 90.
phi= !dtor* phi

;if (cfr gt 4800.) then begin
;psi= -125.+ 0.102*cfr50
;endif else psi=78.
psi=0.
psi= !dtor*psi

chi= 90.*!dtor
;deltag= 0.020
deltag= 0.0

m_tot, deltag, epsilon, alpha, phi, chi, psi, m_tot

;NEXT GET THE CORRECTION REQUIRED TO MAKE THE PA'S CORRECT FOR 
;ASTRONOMY...

if keyword_set( incomplete) then return      
;angle_astron= -78.
angle_astron= 0.
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
