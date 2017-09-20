pro mmp_610_08sep00, cfr, m_tot, m_astron, $
        deltag, epsilon, alpha, phi, chi, psi, angle_astron

;+
;PURPOSE: return M_TOT for 610, given cfr.  
;
;
;	The parameters come from B2251+158 and B2223+210, board 1,
;observed 19sep00 and 22sep00, respectively.  These two sources gave
;results that could only be inperpreted if the if cables had been
;reversed between the two dates, thus interchanging the two cals.  This
;routine assumes that the relative cal values are correct, i.e. it
;assumes that whatever values are used, they provide deltaG=0.
;
;	This system does not have a correlated cal. Thus psi is
;indeterminant. We averatged the values of psi given by the fits for
;these two sources, which were observed on different days and were 92 and
;99 degrees. Amazing that they are so close!
;
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
;
;	M_ASTRON, etc.
;-

chi=90.* !dtor

deltag= 0.003
epsilon=0.021
alpha= 1.3* !dtor
phi= -100.* !dtor
psi= 95.* !dtor

m_tot, deltag, epsilon, alpha, phi, chi, psi, m_tot


;M_ASTRON IS UNKNOWN, SO WE DEFINE IT AS DIAGONAL...
angle_astron=0.
m_astron= fltarr(4,4)
m_astron[ 5*indgen(4)] = 1.



return
end

