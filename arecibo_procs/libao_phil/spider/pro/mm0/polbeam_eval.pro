pro polbeam_eval, arcmin, azarray, zaarray, b2dfit, nstk, $
    squintbeam, squashbeam

;+ 
;NAME:
;polbeam_eval
;PURPOSE: evaluate the POLARIZED STOKES PARAMETER MAIN BEAM at any set
;of az, za (fully vectorized). 
;
;INPUTS:
;
;   ARCMIN, the hpbw specified in the original pattern observation,
;arcmin. 
;   AZARRAY, ZAARRAY, the array of az and za in units of ARCMIN.
;   B2DFIT, the array of 2d fit coefficients described and derived in
;BEAM2D_DESCRIBE. 
;
;   NSTK, the Stokes parameter number: 1,2,3 for Q,U,V.  Don't set
;NSTK=0
;
;OUTPUTS: 
;   SQUINTBEAM, the squint portion of the polarized beam evaluated
;at (azarray, zaarray)
;   SQUASHBEAM, the squint portion of the polarized beam evaluated
;at (azarray, zaarray)
;
;RESTRICTIONS: Some IMPORTANT NOTES: see documentation for
;MAINBEAM_EVAL.
;
;-

;--------FIRST CALCULATE THE MAIN BEAM CONTRIBUTIONS FOR ALL STRIPS-------

;GET PARAMETERS OF THE AZ, ZA ARRAYS...
;AZ, ZA ARE THE DISTANCES OF THE OBSERVED POINTS FROM THE **TRUE** BEAM CENTER.
az = azarray
za = zaarray
;EXTRACT THE BEAM PARAMETERS FROM B2DFIT...
tsrc= b2dfit[ 2,0]
if (keyword_set( kelvins)) then tsrc = 1.
bmwid_0= b2dfit[ 5,0]* 0.6005612
bmwid_2= b2dfit[ 6,0]* 0.6005612
phi_bm= b2dfit[ 7,0]* !dtor
alpha_coma= b2dfit[ 8,0]
phi_coma= b2dfit[ 9,0]* !dtor

;-------FIRST EVALUATE THE SQUINT DERIVATIVE TIMES THE SQUINT------
squint_ampl= b2dfit[ 10+ 10*nstk+ 3, 0]
squint_angl= !dtor* b2dfit[ 10+ 10*nstk+ 4, 0]

azuse= az+ 0.5*squint_ampl* cos( squint_angl)
zause= za+ 0.5*squint_ampl* sin( squint_angl)

distance_squared = azuse^2 + zause^2
distance = sqrt(distance_squared)
;PHI_SCAN ARE THE PAs OF THE OBSERVED POINTS WRT TO **TRUE** BEAM CENTER.
phi_scan = atan( zause, azuse)

;BMWID ARE THE BEAMWIDTHS AT THE PAs OF THE OBSERVED POINTS.
bmwid= bmwid_0 + bmwid_2*cos(2* (phi_scan- phi_bm))

;COMADIST ARE THE DISTANCES ALONG THE COMA DIRECTION
comadist = distance* cos( phi_scan- phi_coma)

;KEEP COMA CORRECTION FROM DIVERGING...
mainbeam_squintplus = tsrc* exp( - distance_squared*(1. - $
    (alpha_coma*comadist/bmwid_0 < 0.75) ) / $
        bmwid^2)

azuse= az- 0.5*squint_ampl* cos( squint_angl)
zause= za- 0.5*squint_ampl* sin( squint_angl)

distance_squared = azuse^2 + zause^2
distance = sqrt(distance_squared)
;PHI_SCAN ARE THE PAs OF THE OBSERVED POINTS WRT TO **TRUE** BEAM CENTER.
phi_scan = atan( zause, azuse)

;BMWID ARE THE BEAMWIDTHS AT THE PAs OF THE OBSERVED POINTS.
bmwid= bmwid_0 + bmwid_2*cos(2* (phi_scan- phi_bm))

;COMADIST ARE THE DISTANCES ALONG THE COMA DIRECTION
comadist = distance* cos( phi_scan- phi_coma)

;KEEP COMA CORRECTION FROM DIVERGING...
mainbeam_squintminus = tsrc* exp( - distance_squared*(1. - $
    (alpha_coma*comadist/bmwid_0 < 0.75) ) / $
        bmwid^2)

squintbeam= -( mainbeam_squintplus-mainbeam_squintminus)

;-------NEXT EVALUATE THE SQUASH DERIVATIVE TIMES THE SQUASH------

squash_ampl= b2dfit[ 10+ 10*nstk+ 5, 0]
squash_angl= !dtor* b2dfit[ 10+ 10*nstk+ 6, 0]

bmwid_0= b2dfit[ 5,0]* 0.6005612
bmwid_2= b2dfit[ 6,0]* 0.6005612


distance_squared = az^2 + za^2
distance = sqrt(distance_squared)
;PHI_SCAN ARE THE PAs OF THE OBSERVED POINTS WRT TO **TRUE** BEAM CENTER.
phi_scan = atan( za, az)

;COMADIST ARE THE DISTANCES ALONG THE COMA DIRECTION
comadist = distance* cos( phi_scan- phi_coma)

;BMWID ARE THE BEAMWIDTHS AT THE PAs OF THE OBSERVED POINTS.
bmwid= bmwid_0 + bmwid_2*cos(2* (phi_scan- phi_bm)) + $
    0.5* squash_ampl*cos(2* ( phi_scan- squash_angl))

;KEEP COMA CORRECTION FROM DIVERGING...
mainbeam_squashplus = tsrc* exp( - distance_squared*(1. - $
    (alpha_coma*comadist/bmwid_0 < 0.75) ) / $
        bmwid^2)

;BMWID ARE THE BEAMWIDTHS AT THE PAs OF THE OBSERVED POINTS.
bmwid= bmwid_0 + bmwid_2*cos(2* (phi_scan- phi_bm)) - $
    0.5* squash_ampl*cos(2* ( phi_scan- squash_angl))

;KEEP COMA CORRECTION FROM DIVERGING...
mainbeam_squashminus = tsrc* exp( - distance_squared*(1. - $
    (alpha_coma*comadist/bmwid_0 < 0.75) ) / $
        bmwid^2)

squashbeam= mainbeam_squashplus-mainbeam_squashminus

;stop

return
end

