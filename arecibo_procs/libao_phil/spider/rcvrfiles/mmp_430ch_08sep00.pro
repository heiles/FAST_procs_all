pro mmp_430ch_08sep00, cfr, m_tot, m_astron, $
        deltag, epsilon, alpha, phi, chi, psi, angle_astron

;+
;PURPOSE: return M_TOT for 430ch, given cfr. 
;
;	The parameters come from B0106+130 and B1634+269, board 1,
;observed 17sep00 and 16sep00, respectively.  
;

;	This routine assumes that the cal values are the adjusted values
;by duncan, namely tcalxx=27.4, tcalyy=39.6.

;	We think that This system does not have a correlated cal. 
;Whether or not it does, the feed is circular so without knowing the
;source pa psi is indeterminant.  We set psi=0/

;
;\/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/
;>                                                                     <
;>	We HAVE NOT DETERMINED THE ROTATION REQUIRED TO MAKE PA'S     <
;>     CORRECT FOR ASTRONOMICAL SOURCES                                <
;>                                                                     <
;/\ /\ /\ /\ /\ /\ /\ /\ /\ /\ /\ /\ /\ /\ /\ /\ /\ /\ /\ /\ /\ /\ /\ /\ 
;
;
;CALLING SEQUENCE: MMP_430CH_08DEC00, cfr, m_totm_astron, $
;        deltag, epsilon, alpha, phi, chi, psi
;
;INPUT: 
;
;	CFR. doesn't matter in this case.
;
;OUTPUT:
;
;	M_TOT, the feeds mueller matrix.
;
;       
;       M_ASTRON, the matrix required to rotate the derived qsrc,usrc
;to astronomical pa.
;
;
;-

chi=90.* !dtor

deltag= 0.010
epsilon=0.036
alpha= -47.6* !dtor
phi= -49.3* !dtor
psi= 0.* !dtor

m_tot, deltag, epsilon, alpha, phi, chi, psi, m_tot
angle_astron= 0.
;M_ASTRON IS UNKNOWN, SO WE DEFINE IT AS DIAGONAL...m_astron= fltarr(4,4)
m_astron= fltarr(4,4)
m_astron[ 5*indgen(4)] = 1.

return
end

