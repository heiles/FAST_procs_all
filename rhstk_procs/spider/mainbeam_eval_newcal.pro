pro mainbeam_eval_newcal, azarray, zaarray, b2dfit, mainbeam, $
	noalphaway=noalphaway

;+ 
;PURPOSE: evaluate the main beam at any set of az, za (fully vectorized).
;Response at beam center is UNITY TIMES THE SOURCE ANTENNA TEMPERATURE.

;CALLING SEQUENCE:
;
;	MAINBEAM_EVAL_NEWCAL, azarray, zaarray, b2dfit, mainbeam, $
;	noalphaway=noalphaway
;
;INPUTS:
;
;	AZARRAY, ZAARRAY, the array of az and za offset from center at
;which to evaluatte the beam in units of arcmin. 
;
;	B2DFIT, the array of 2d fit coefficients described and derived in
;BEAM2D_DESCRIBE. 
;
;KEYWORDS:
;	NOALPHAWAY: does NOT use the 'alpha' formulation; instead 
;it uses the fourier rep of HPBW. WE DO **NOT** SET NOALPHAWAY, which
;means that we do it the OLD way below.
;
;OUTPUT: 
;
;	MAINBEAM, the response of the main beam at the azarray, zaarray
;points. 
;
;RESTRICTIONS:
;
;IMPORTANT NOTE: In the last statement of this pgm, notice
;	that we limit the coma correction to 0.75. We do this to 
;	keep the beam shape well-behaved. This is important only for
;	ridiculously large values of alpha (this works up to alpha=0.5)
;
;HISTORY:
;	extracted from G2DCURV_ALLCAL.pro
;	17 OCT 2000: changed definition of alpha_coma...
;-

;--------FIRST CALCULATE THE MAIN BEAM CONTRIBUTIONS FOR ALL STRIPS-------

;GET PARAMETERS OF THE AZ, ZA ARRAYS...
;AZ, ZA ARE THE DISTANCES OF THE OBSERVED POINTS FROM THE **TRUE** BEAM CENTER.
az = azarray
za = zaarray
distance_squared = az^2 + za^2
distance = sqrt(distance_squared)
;PHI_SCAN ARE THE PAs OF THE OBSERVED POINTS WRT TO **TRUE** BEAM CENTER.
phi_scan = atan( za, az)

;EXTRACT THE BEAM PARAMETERS FROM B2DFIT...
tsrc= b2dfit[ 2,0]
if (keyword_set( kelvins)) then tsrc = 1.
bmwid_0= b2dfit[ 5,0]* 0.6005612
bmwid_2= b2dfit[ 6,0]* 0.6005612
phi_bm= b2dfit[ 7,0]* !dtor

;-----------------OLD WAY, USING alpha----------------------------
if (keyword_set( noalphaway) ne 1) then begin

;print, 'DOING IT THE OLD WAY'

;EXTRACT THE COMA PARAMETERS FROM B2DFIT...
;OLD WAY...
;alpha_coma= b2dfit[ 8,0]* (0.6005612/bmwid_0) 

alpha_coma= b2dfit[ 8,0]
phi_coma= b2dfit[ 9,0]* !dtor

;BMWID ARE THE BEAMWIDTHS AT THE PAs OF THE OBSERVED POINTS.
bmwid= bmwid_0 + bmwid_2*cos(2* (phi_scan- phi_bm))

;COMADIST ARE THE DISTANCES ALONG THE COMA DIRECTION
comadist = distance* cos( phi_scan- phi_coma)

;mainbeam = tsrc* exp( - distance_squared*(1. - alpha_coma*comadist/bmwid) / $
;        bmwid^2)

;mainbeam = tsrc* exp( - distance_squared*(1. - alpha_coma*comadist/bmwid_0) / $
;        bmwid^2)

;KEEP COMA CORRECTION FROM DIVERGING...
mainbeam = tsrc* exp( - distance_squared*(1. - $
	(alpha_coma*comadist/bmwid_0 < 0.75) ) / $
        bmwid^2)

endif else begin

;print, 'DOING IT THE new WAY'

;-----------------TRIAL WAY, USING HPBW--------------------------
bmwid_1= b2dfit[ 8,0]* 0.6005612
phi_coma= b2dfit[ 9,0]* !dtor

;BMWID ARE THE BEAMWIDTHS AT THE PAs OF THE OBSERVED POINTS.
bmwid= bmwid_0 + bmwid_1*cos( phi_scan- phi_coma) + $
	bmwid_2*cos(2* (phi_scan- phi_bm))

mainbeam= tsrc* exp( - distance_squared/ bmwid^2)
endelse

return
end

