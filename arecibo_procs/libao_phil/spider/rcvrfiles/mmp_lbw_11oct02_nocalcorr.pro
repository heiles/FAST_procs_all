pro mmp_lbw_11oct02_nocalcorr, cfr, m_tot, m_astron, $
	deltag, epsilon, alpha, phi, chi, psi, angle_astron, $
	zero_deltag= zero_deltag

;+

;PURPOSE: return M_TOT for lbw, given cfr.  setting INCOMPLETE excludes
;the rotation required to make pa's correct for astronomical sources. 
;
;	The parameters come primarily from B0017+154, observed 16sep00. 
;
;CALLING SEQUENCE: mmp_lbw_08sep00_nocalcorr, cfr, m_tot, m_astron, $
;	deltag, epsilon, alpha, phi, chi, psi
;
;INPUT: 
;
;	CFR. 
;
;KEYWORD:
;	ZERO_DELTAG forces deltag in the mmatrix to zero, which should
;be set when you are using cal values adjusted make deltag zero.

;OUTPUT:
;
;	M_TOT, the feeds mueller matrix.
;
;	DELTAG, EPSILON, ALPHA, PHI, CHI, PSI, the parameters.  The
;units of angles are radians.  
; 
;       M_ASTRON, the matrix required to rotate the derived qsrc,usrc
;to astronomical pa.
;
;HISTORY:
;	15 oct 2002: in m_astron, the m_vv matrix elements was changed to
;-1 from its previous value of +1 to reflect the correct sign of OH masers
;in W49 and, also, helix tests done in spring of 1999.
;	16 oct 2002: phil found the duplicate conversion of alpha from
;deg to radians. removed; see below commentary
;
;-

;FIRST GET THE FEED'S MATRIX, M_TOT
cfr20= cfr- 1420.

alpha= !dtor*0.20
epsilon= 0.003
phi= !dtor* 34.8
psi=!dtor* (172.1)
deltag= -0.058

chi= 90.* !dtor

if keyword_set( zero_deltag) then deltag=0.

m_tot, deltag, epsilon, alpha, phi, chi, psi, m_tot

;NEXT GET THE CORRECTION REQUIRED TO MAKE THE PA'S CORRECT FOR
;ASTRONOMY... 

angle_astron=-45.
angle= angle_astron* !dtor
m_astron= fltarr( 4,4)
m_astron[ 0,0]= 1.

;m_astron[ 3,3]= 1.
m_astron[ 3,3]= -1.

m_astron[ 1,1]= cos( 2.* angle)
m_astron[ 2,1]= sin( 2.* angle)
m_astron[ 2,2]= m_astron[ 1,1]
m_astron[ 1,2]= -m_astron[ 2,1]

return
end

