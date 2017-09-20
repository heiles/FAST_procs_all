pro mmp_430_08sep00_nocalcorr, cfr, m_tot, m_astron, $
	deltag, epsilon, alpha, phi, chi, psi, angle_astron

;+
;PURPOSE: return M_TOT for 430, given cfr.  
;
;	The parameters come from B0106+130, observed 18sep00.  
;
;\/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/
;>                                                                     <
;>	We HAVE NOT DETERMINED THE ROTATION REQUIRED TO MAKE PA'S     <
;>     CORRECT FOR ASTRONOMICAL SOURCES                                <
;>                                                                     <
;/\ /\ /\ /\ /\ /\ /\ /\ /\ /\ /\ /\ /\ /\ /\ /\ /\ /\ /\ /\ /\ /\ /\ /\ 
;
;
;CALLING SEQUENCE: MMP_430_08DEC00-NOCALCORR, cfr, m_tot, m_astron, $
;	deltag, epsilon, alpha, phi, chi, psi
;
;INPUT: 
;
;	CFR. doesn't matter in this case.
;
;OUTPUT:
;
;	M_TOT, the feeds mueller matrix.
;
;	DELTAG, EPSILON, ALPHA, PHI, CHI, PSI, the parameters.  The
;units of angles are radians.  
; 
;	M_ASTRON, the matrix required to rotate the derived qsrc,usrc
;to astronomical pa.

;-

deltag= -0.023
epsilon= 0.006
alpha= 0.5* !dtor
phi= 78.6* !dtor
chi=90.* !dtor
psi= 150.* !dtor

m_tot, deltag, epsilon, alpha, phi, chi, psi, m_tot

;M_ASTRON IS UNKNOWN, SO WE DEFINE IT AS DIAGONAL...
angle_astron=0.
m_astron= fltarr(4,4)
m_astron[ 5*indgen(4)] = 1.

return
end

