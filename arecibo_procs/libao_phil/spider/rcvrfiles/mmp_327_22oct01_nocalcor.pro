pro mmp_327_22oct01_nocalcor, cfr, m_tot, m_astron, $
        deltag, epsilon, alpha, phi, chi, psi, angle_astron

;+
;PURPOSE: return M_TOT for 327, given cfr.  
;
;
;	The parameters are dummies so that initial analysis will run..
;
;
;CALLING SEQUENCE: MMP_327_22oct01_nocalcor, cfr, m_tot, m_astron, $
;        deltag, epsilon, alpha, phi, chi, psi

;
;INPUT: 
;
;	CFR. doesn't matter in this case.
;
;OUTPUT:
;
;	M_TOT, the feeds mueller matrix which is garbage..
;
;	M_ASTRON, etc.
;-

chi=90.* !dtor

deltag= 0.00
epsilon=0.0
alpha= 0.0
phi= 0.
psi= 0.

m_tot, deltag, epsilon, alpha, phi, chi, psi, m_tot


;M_ASTRON IS UNKNOWN, SO WE DEFINE IT AS DIAGONAL...
angle_astron=0.
m_astron= fltarr(4,4)
m_astron[ 5*indgen(4)] = 1.
return
end

