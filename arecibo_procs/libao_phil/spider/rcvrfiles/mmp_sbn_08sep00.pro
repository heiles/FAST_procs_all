pro mmp_sbn_08sep00, cfr, m_tot, m_astron, $
        deltag, epsilon, alpha, phi, chi, psi, angle_astron
 
;+
;PURPOSE: return M_TOT for sbn, given cfr.  on
;08dec00, there is no dependence on cfr, so this parameter doesn't
;matter. 
;
;	The parameters come from B1749+096, observed 20sep00.  The
;parameters herein are obtained WITHOUT the relative cals having been
;corrected. deltaG is small enough that this correction is unnecessary. 
;
;\/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/
;>                                                                     <
;>	We HAVE NOT DETERMINED THE ROTATION REQUIRED TO MAKE PA'S     <
;>     CORRECT FOR ASTRONOMICAL SOURCES                                <
;>                                                                     <
;/\ /\ /\ /\ /\ /\ /\ /\ /\ /\ /\ /\ /\ /\ /\ /\ /\ /\ /\ /\ /\ /\ /\ /\ 
;
;
;CALLING SEQUENCE: MMP_SBN_08DEC00, cfr, m_tot, m_astron, $
;        deltag, epsilon, alpha, phi, chi, psi
 
;
;INPUT: 
;
;	CFR. doesn't matter in this case.
;
;OUTPUT:
;
;	M_TOT, the feeds mueller matrix.

;	M_ASTRON, ETC.
;
;KEYWORD:
;
;-

chi=90.* !dtor

deltag= 0.008
epsilon=0.005
alpha= -39.9* !dtor
phi= 88.* !dtor
psi= -38.* !dtor

m_tot, deltag, epsilon, alpha, phi, chi, psi, m_tot

;NEXT GET THE CORRECTION REQUIRED TO MAKE THE PA'S CORRECT FOR
;ASTRONOMY...

angle_astron=-15.
angle= angle_astron* !dtor
m_astron= fltarr( 4,4)
m_astron[ 0,0]= 1.
m_astron[ 3,3]= 1.
m_astron[ 1,1]= cos( 2.* angle)
m_astron[ 2,1]= sin( 2.* angle)
m_astron[ 2,2]= m_astron[ 1,1]
m_astron[ 1,2]= -m_astron[ 2,1]

return
end

