pro Rcvr8_10__06jan03, cfr, m_tot, m_astron, $
	deltag, epsilon, alpha, phi, chi, psi, angle_astron, $
	zero_deltag= zero_deltag

;+

;PURPOSE: return M_TOT and related parameteres for Xband, given cfr.
;
;CALLING SEQUENCE:
;
;Rcvr8_10__06jan03, cfr, m_tot, m_astron, $
;       deltag, epsilon, alpha, phi, chi, psi, angle_astron, $
;       zero_deltag= zero_deltag
;
;INPUT:
;
;       CFR.
;
;KEYWORD:
;       ZERO_DELTAG forces deltag in the mmatrix to zero, which should
;be set only if you know what you are doing and why
;
;OUTPUT:
;
;       M_TOT, the feeds mueller matrix.
;
;       DELTAG, EPSILON, ALPHA, PHI, CHI, PSI, the parameters.  The
;units of angles are radians.
;
;       M_ASTRON, the matrix required to rotate the derived qsrc,usrc
;to astronomical pa.
;
;       ANGLE_ASTRON, the angle required to rotate from telescope-based
;angle to astronomically defined angle of polarization.
;
;HISTORY:
;
;       determined from 3C48, 3C138early jan 2003
;	aug03: better cals used. old version written to '*badcals.pro'
;	sep03: added special stuff for over 11 GHz.
;-


;============ FIRST GET THE FEED'S MATRIX, M_TOT ================

;************* PAREMETERS THAT WE NEED TO INSERT BY HAND *************
;
;We read the values for the parameters visually off of the postscript plots.
;We do crude fits to the frequency dependences, using 9000 MHz as a 
;       convenient center frequency about which to fit: 
;
;       For native circular, the most important parameter is ALPHA; this
;       tells the ellipticity of the polarization, with 45 deg being pure 
;       circular. In the feed, the circular is generated from the 
;        signal picked up by the linear probes by a tranducer, and 
;       this might well have frequency dependence. The details of
;       this dependence depend on the design of the transducer. For
;       these data, it seemed appropriate to polyfit with a degree of 2.
;
;       For DELTA G, these fits probably represent the frequency dependence
;       of the cal value. There is no particular expectation here, so 
;       we use a polynomial fit with a visually apprpriate degree of 2.
;
;       Similarly, for the other parameeters we do 'what seems reasonable'.
;       The other parameters refer to imperfections in the feed, whicih
;       are usually small. note that each imperfection parameter
;       (like epsilon) is associated with ana angle (like phi). 

;********************************************************************

delf= cfr- 9000.

deltag= -0.046949898+ 1.3866454e-05* delf -7.4361979e-08* delf^2

epsilon= 0.0046 - 3.03e-6*delf
alpha= !dtor* ( -48.34 - 0.002*delf + 2.49e-6* delf^2)
phi= !dtor* (12.+ 0.178* delf)
chi= 90.* !dtor
psi= 0.

;add cfr>11 GHz from 3C48 calib mm4_2d_bd0_3C48.Rcvr8_10.0.03Sep10.05:52:56.sav.sav

IF (CFR GT 11000.) THEN BEGIN
deltag= 0.
psi= 0.
alpha=  !dtor* (-48.6)
epsilon= 0.003
phi= !dtor* 55.7
ENDIF


if keyword_set( zero_deltag) then deltag=0.

m_tot, deltag, epsilon, alpha, phi, chi, psi, m_tot

;NEXT GET THE CORRECTION REQUIRED TO MAKE THE PA'S CORRECT FOR
;ASTRONOMY... 

angle_astron = -1.*(-45.5 - 0.011*delf)
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

