pro rcvr4_6__default, cfr, m_tot, m_astron, $
	deltag, epsilon, alpha, phi, chi, psi, angle_astron, $
	zero_deltag= zero_deltag

;+
; NAME:
;       RCVR4_6__default
;
; PURPOSE: 
;       Return M_TOT and M_ASTRON for C band, given cfr.
;
; CALLING SEQUENCE: 
;       rcvr4_6__default, cfr, m_tot, m_astron,
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

;FIRST GET THE FEED'S MATRIX, M_TOT
;delf = cfr- 1420.
delf = cfr- 1485.8

deltag = ;-0.5
epsilon = ;0.0049
alpha = ;!dtor* (0.0) 
phi = ;!dtor* (150)
psi = ;!dtor* (-18.7232  - 0.0086 * delf)

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

