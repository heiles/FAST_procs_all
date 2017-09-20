pro g2dcurv_allcal, delt_zaencoder, az_scan, za_scan, totoffset, $
	hgt_lobe, cen_lobe, wid_lobe, tsys, dtsys_dza, $
	tsrc, az_bmcntr, za_bmcntr, bmwid_0, bmwid_1, phi_bm, $
	alpha_coma, phi_coma, tout

;+
;NAME:
;   G2DCURV
;
;PURPOSE:
;    Calculate multiple (N) Gaussians + offset + slope (wrt ZAencoder).
;
;CALLING SEQUENCE:
;    
;
;INPUTS:
;FIRST, THE OBSERVED DATA FROM THE TELESCOPE:
;	DELT_ZAENCODER is the zenith angle from the encoder MINUS an offset
;		which should be the mean of the za_encoder values 
;		(makes the fit meaningful)
;	AZ_SCAN is the set of az offsets from assumed beam center
;	ZA_SCAN is the set of za offset from assumed beam center 

;NEXT, THE PARAMETERS OF THIS FUNCTION:
;FOR THE CENTRAL GAUSSIAN:
;	TSRC is the height of the beam center
;	AZ_BMCNTR is the az offset of assumed beam cntr from true beam cntr
;	ZA_BMCNTR is the za offset of assumed beam cntr from true beam cntr
;	BMWID_0 is the constant term in the beamwidth
;	BMWID_1 is the coefficient of the 2-phi term in the beamwidth
;	PHI_BM is the angle of the major axis wrt az=0 of the ellipse 
;		of the beam. ***RADIANS***
;	ALPHA_COMA is the magnitude of the coma lobe
;	PHI_COMA is the angle of the coma lobe wrt az=0. RADIANS.
;	TSYS is the off-source system temp
;	DTSYS/dza is the derivative of TSYS wrt ZA

;FOR THE SIDELOBES:
;	STRIPFIT contains the amplitudes and other parameters of the
;sidelobes--see comment at 'tout =...' below. 

;OUTPUTS:
;	TOUT, the array of output temps.

;NOTE REGARDING COMA: We assume the coma lobe to be parameterized by a
;DIRECTION, called PHI_COMA, and a MAGNITUDE, called ALPHA. 

;RELATED PROCEDURES:
;	
;HISTORY:
;	Written by Carl Heiles. 23sep00.
;	17 oct: modified sign of alpha and what it is divided by.
;-

;--------FIRST CALCULATE THE MAIN BEAM CONTRIBUTIONS FOR ALL STRIPS-------

;AZ, ZA ARE THE DISTANCES OF THE OBSERVED POINTS FROM THE **TRUE** BEAM CENTER. 
az = az_scan + az_bmcntr
za = za_scan + za_bmcntr
distance_squared = az^2 + za^2
distance = sqrt(distance_squared)     

;PHI_SCAN ARE THE PAs OF THE OBSERVED POINTS WRT TO **TRUE** BEAM CENTER.
phi_scan = atan( za, az)

;BMWID ARE THE BEAMWIDTHS AT THE PAs OF THE OBSERVED POINTS.
bmwid= bmwid_0 + bmwid_1*cos(2* (phi_scan- phi_bm))

;COMADIST ARE THE DISTANCES ALONG THE COMA DIRECTION
comadist = distance* cos( phi_scan- phi_coma)

;tout = tsrc* exp( - distance_squared*(1. - alpha_coma*comadist/bmwid) / $
;	bmwid^2) 

;THIS CHANGE, DIVIDING COMADIST BY BMWID_0 INSTEAD OF BMWID, CONFORMS TO
;	A MORE SENSIBLE DEFINITION OF ALPHA_COMA...
tout = tsrc* exp( - distance_squared*(1. - alpha_coma*comadist/bmwid_0) / $
	bmwid^2) 

;----------NOW ADD IN THE SIDELOBE CONTRIBUTIONS-----------------------

;HERE WE ARE BEING LAZY AND DEFINING THESE VARIABLES--NOTHING MOFE.
tstrip_lft= az_scan
tstrip_rgt= az_scan

for nr=0, 3 do begin
gcurv, totoffset[*, nr], 0., hgt_lobe[ 0,nr], cen_lobe[ 0,nr], $
	wid_lobe[ 0,nr], tstrip
tstrip_lft[ *,nr]= tstrip

gcurv, totoffset[*, nr], 0., hgt_lobe[ 1,nr], cen_lobe[ 1,nr], $
	wid_lobe[ 1,nr], tstrip
tstrip_rgt[ *,nr]= tstrip

ENDFOR

tout= tout + tstrip_lft + tstrip_rgt

tout= tout + tsys + delt_zaencoder*dtsys_dza

return
end

