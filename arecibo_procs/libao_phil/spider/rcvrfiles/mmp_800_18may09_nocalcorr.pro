pro mmp_800_18may09_nocalcorr, cfr, m_tot, m_astron, $
        deltag, epsilon, alpha, phi, chi, psi, angle_astron

;+
;PURPOSE: return M_TOT for 610-750.  
;
;
;	The parameters are fake.. need this for initial x102's 
;just use values from 610
;
;the results are stored in 
;  /share/heiles/alyssa/allcal/610_701/bd0_3C433-CH1_m4_6JUN-2001.ps
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
;CALLING SEQUENCE: MMP_800_18may09_nocalcorr, cfr, m_tot, m_astron, $
;        deltag, epsilon, alpha, phi, chi, psi
;
;
;INPUT: 
;
;	CFR. doesn't matter in this case.
;
;OUTPUT:
;
;	M_TOT, the feed's mueller matrix.
;
;	M_ASTRON, etc.
;-

chi=90.* !dtor

deltag= -0.00
psi= -156.* !dtor
alpha= 0.4* !dtor
epsilon=0.007
phi= 138.* !dtor

m_tot, deltag, epsilon, alpha, phi, chi, psi, m_tot


;M_ASTRON IS UNKNOWN, SO WE DEFINE IT AS DIAGONAL...
angle_astron=0.
m_astron= fltarr(4,4)
m_astron[ 5*indgen(4)] = 1.



return
end

