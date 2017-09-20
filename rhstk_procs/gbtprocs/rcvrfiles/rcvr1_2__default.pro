pro rcvr1_2__default, cfr, m_tot, m_astron, $
	deltag, epsilon, alpha, phi, chi, psi, angle_astron, $
	zero_deltag= zero_deltag

;+
; NAME:
;       RCVR1_2__default
;
; PURPOSE: 
;       Return M_TOT and M_ASTRON for L band, given cfr.
;
; CALLING SEQUENCE: 
;       Rcvr1_2__default, cfr, m_tot, m_astron,
; 	                  deltag, epsilon, alpha, phi, chi, psi, 
;                         angle_astron [, /ZERO_DELTAG]
;
; INPUT: 
;	CFR - frequency of observation.
;
; KEYWORD:
;       /ZERO_DELTAG: forces deltag in the mmatrix to zero, which should be
;                     set when you are using cal values adjusted make
;                     deltag zero.

; OUTPUT:
;       M_TOT: the feeds mueller matrix.
;
;       DELTAG, EPSILON, ALPHA, PHI, CHI, PSI: the parameters.  The units
;                                              of angles are radians.
; 
;       M_ASTRON: the matrix required to rotate the derived qsrc,usrc to
;                 astronomical pa.
;
; MODIFICATION HISTORY:
;       TR Jun 13 2008: Parameters determined from SP and ACS spider scans
;                       on 3C286.
;-

;================== FIRST GET THE FEED'S MATRIX, M_TOT ===============

;************* PAREMETERS THAT WE NEED TO INSERT BY HAND *************
;
;We read the values for the parameters visually off of the postscript plots.
;We do crude fits to the frequency dependences, using 1485.8 MHz as a
;       convenient center frequency about which to fit:
;
;       For native linear, the most important parameter is PSI; this
;       is a phase difference which arises from a difference in cable
;       lengths, so psi is expected to be a linear function of frequency.
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


;delf = cfr- 1420.
delf = cfr- 1485.8 ; why 85.5???

deltag = -0.5
epsilon = 0.0049
alpha = !dtor* (0.0) 
phi = !dtor* (150)
psi = !dtor* (-18.7232  - 0.0086 * delf)

chi = 90.* !dtor

if keyword_set( zero_deltag) then deltag=0.

m_tot, deltag, epsilon, alpha, phi, chi, psi, m_tot

;NEXT GET THE CORRECTION REQUIRED TO MAKE THE PA'S CORRECT FOR
;ASTRONOMY... 

angle_astron = 90.
angle = angle_astron* !dtor
m_astron = fltarr( 4,4)
m_astron[ 0,0] = 1.

m_astron[ 3,3] = 1.  ; this gives proper IAU Stokes V definition
;m_astron[ 3,3] = -1.

m_astron[ 1,1] = cos( 2.* angle)
m_astron[ 2,1] = sin( 2.* angle)
m_astron[ 2,2] = m_astron[ 1,1]
m_astron[ 1,2] = -m_astron[ 2,1]

end

