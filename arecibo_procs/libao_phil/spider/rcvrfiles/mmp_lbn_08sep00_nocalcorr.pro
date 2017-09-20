pro mmp_lbn_08sep00_nocalcorr, cfr, m_tot, m_astron, $
	deltag, epsilon, alpha, phi, chi, psi, angle_astron

;+

;PURPOSE: return M_TOT for lbn, given cfr.  psi is
;indeterminant; we take the value as what the fit happened to give at
;1415 MHz. 
;
;	The parameters come from B0017+154 and B2209+080, both observed
;20sep00. 

;
;\/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/
;>                                                                     <
;>	We HAVE NOT DETERMINED THE ROTATION REQUIRED TO MAKE PA'S     <
;>     CORRECT FOR ASTRONOMICAL SOURCES                                <
;>                                                                     <
;/\ /\ /\ /\ /\ /\ /\ /\ /\ /\ /\ /\ /\ /\ /\ /\ /\ /\ /\ /\ /\ /\ /\ /\ 
;
;
;CALLING SEQUENCE: MMP_LBN_08DEC00-NOCALCORR, cfr, m_tot, m_astron, $
;	deltag, epsilon, alpha, phi, chi, psi
;
;INPUT: 
;
;	CFR. really matters in this case!
;
;OUTPUT:
;
;	M_TOT, the feeds mueller matrix.
;
;	M_ASTRON, the matrix required to rotate to astron defn
;
;	DELTAG, EPSILON, ALPHA, PHI, CHI, PSI, the parameters.  The
;units of angles are radians.  
; 
;KEYWORD: 
; 
;	INCOMPLETE does not include the final rotation required to make 
;pa's correct for astronomical sources.  We haven't determined this 
;rotation, so this keyword is always implicitly set!
;
;-

cfr15= cfr- 1415.
cfr00= cfr- 1400.

alpha= 47.74- .363*cfr15
alpha= !dtor* alpha


epsilon= 0.00278+ 1.383e-5* cfr15 + 1.3089e-6* cfr15^2

phi= 44.8+ 1.0225* cfr00
phi= 6.+ 1.0225* cfr00
phi= !dtor* phi

chi= !dtor*90.

psi=!dtor* 43.6

deltag= 0.034- 1.78e-4* cfr15+ 3.267e-6* cfr15^2

m_tot, deltag, epsilon, alpha, phi, chi, psi, m_tot


;M_ASTRON IS UNKNOWN, SO WE DEFINE IT AS DIAGONAL...
angle_astron=0.
m_astron= fltarr(4,4)
m_astron[ 5*indgen(4)] = 1.

;stop

return
end

