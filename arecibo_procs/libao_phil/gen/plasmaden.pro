;+ ;NAME:
;plasmaden - compute cold plasma density given plasma frequency
;SYNTAX: Ne=plasmaden(freqMhz)
;ARGS:
;  freqMhz[]:float plasma freq in Mhz
;RETURNS:
; Ne[ ]: float   in density/cc
;DESCRIPTION:
;   Given the plasma freq in Mhz return the electron density.
;Just solves Wp^2=4*pi^2*n0/me
; 
;-
function plasmaden,f
    
;
; cold plasma:
;
; Fpe=8980*sqrt(Ne) (hz)
; in cc
;
; si
; e=1.6022e-19 C
; K=1.380e-23 JK-1
; Me=9.109e-31 kg
; eps0=8.854e-12 Fm-1
; 
;	We=f*1D6*2D*!pi
; 	Me=9.109d-31
; 	eps0=8.854d-12
; 	e=1.6022d-19
; 	ee=e*e
;	
;	NeSi=( We*We*Me*eps0 )/ee
;	NeCGS=NeSi/1d6  
;
	return, ((f*1d6)/8980D)^2.
end
