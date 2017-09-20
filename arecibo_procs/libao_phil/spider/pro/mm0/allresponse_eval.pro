pro allresponse_eval, arcmin, stripfit, b2dfit, $
    mainampl, mainangl, sideampl, sideangl, $
    squintampl, squintangl, squashampl, squashangl, $
    totalampl, totalangl

;+
;NAME:
; PURPOSE: Evaluate the response of all beams to a brightness temperature
;temperature gradient and second derivative. Evaluate the angle to which
;the beams are most sensitive. 
;
; CALLING SEQUENCE:
;ALLRESPONSE_EVAL, arcmin, stripfit, b2dfit, $
;   mainampl, mainangl, sideampl, sideangl, $
;   squintampl, squintangl, squashampl, squashangl, $
;   totalampl, totalangl
;   
;INPUTS:
;   ARCMIN, the nominal HPBW in arcmin used during observing. From
;HDR1INFO[28, *].
;
;       STRIPFIT, the STRIPFIT array for this particular pattern. See
;BEAM_DESCRIBE
;
;       B2DFIT, the main beam description array for this particular
;pattern. See BEAM2D_DESCRIBE.
;
;OUTPUTS:
;   MAINAMPL[ 2] Amplitude of main beam response to the
;two derivatives.
;
;   MAINANGL[ 2] The position angle of two derivatives at which the
;main beam has max response
;
;   SIDEAMPL[ 4,2] and SIDEANGL[ 4,2] Amplitude and position angle
;for the sidelobes, all four Stokes parameters,
;
;   SQUINTAMPL, SQUINTANGL, SQUASHAMPL, SQUASHANGL[ 4,2], amplitude
;and position angle of the squint and squash beams, the latter 3 Stokes
;parameters only.
;
;   TOTALAMPL, TOTALANGL: the totalbeam (=sidelobe+ squint+ squash)
;responses to the polarization.
;
;-


;DEFINE THE AMPL AND PHASES OF RESPONSE TO THE FIRST AND SECOND DERIVATIVES.
;4 STOKES PARAMETERS (REALLY ONLY THE LAST THREE ARE USED); 2 TEMP DISTRIBS.
mainampl= fltarr( 2)
mainangl= fltarr( 2)
sideampl= fltarr( 4, 2)
sideangl= fltarr( 4, 2)
squintampl= fltarr( 4, 2)
squintangl= fltarr( 4, 2)
squashampl= fltarr( 4, 2)
squashangl= fltarr( 4, 2)
totalampl= fltarr( 4, 2)
totalangl= fltarr( 4, 2)

;DEFINE THE AZ, ZA ARRAYS FOR THE BEAM MAPS (UNITS ARE ARCMIN)...
ptsperstrip= b2dfit[ 18,1]
make_azza_newcal, ptsperstrip, b2dfit, pixelsize, azarray, zaarray

nterms=6

allbeams_eval, nterms, arcmin, pixelsize, azarray, zaarray, $
    stripfit, b2dfit, $
        mainbeam, sidelobe, $
    squintbeam, squashbeam, totalbeam, $
        mainbeam_integral, sidelobe_integral, $
    squintbeam_integral, squashbeam_integral, totalbeam_integral

;CALC THE INTEGRAL UNDER THE MAIN BEAM STOKES I..EVERYTHING HAS TO BE
;NORMALIZED BY THIS AMOUNT... 
mb_tot= pixelsize^2* total( mainbeam[*,*,0])

;AND HERE WE ARE DEALING WITH ORDINARY BRIGHTNESS TEMPERATURES

;EVALUATE THE RESPONSE TO THE FIRST DERIVATIVE...
distance_squared = azarray^2 + zaarray^2
distance = sqrt(distance_squared)/max(azarray)
;PHI_SCAN ARE THE PAs OF THE OBSERVED POINTS WRT TO **TRUE** BEAM CENTER.
phi_scan = atan( zaarray, azarray)

mainbeam_response= fltarr( 8)
sidelobe_response= fltarr( 8)
squintbeam_response= fltarr( 8)
squashbeam_response= fltarr( 8)
totalbeam_response= fltarr( 8)
pngl= fltarr( 8)

;WE USE DISTANCE GOING FROM -1 TO 1 TO MAKE THE FUNCTIONS ORTHOGONAL.
;TO MAKE THE TEMPERATURE GRADIANT ONE K PER ARCMIN, MAKE
tedge_d1= max(azarray) 
;BECAUSE AZARRAY IS IN ARCMIN.

;TO MAKE THE SECOND DERIVATIVE ONE K PER ARCMIN^2: FOR 2ND DER,
;   WE HAVE T = 0.5*(SECOND DER)*DIST^2. THUS 
tedge_d2= 0.5* max(azarray)^2

;LOOP THRU DERIVATIVES: FIRST, THEN SECOND DERIVATIVE.
FOR NDER=0,1 DO BEGIN
nphi_d1=0
FOR PHI_D1= 0., 359., 45. DO BEGIN
if ( nder eq 0) then temp= tedge_d1* distance* cos( phi_scan- !dtor*phi_d1)
if ( nder eq 1) then $
;   temp= tedge_d2* 0.5*(3.*(distance* cos( phi_scan- !dtor*phi_d1))^2 - 1.)
    temp= tedge_d2* ((distance* cos( phi_scan- !dtor*phi_d1))^2 - 1./3.)
nstk=0
mainbeam_response[ nphi_d1]= pixelsize^2* total( temp* mainbeam)/mb_tot
pa1fit, (nder+1)*pngl, 1, mainbeam_response, coeffs, coeffsp, /nodiscard
mainampl[ nstk]= coeffsp[ 0,0]
mainangl[ nstk]= coeffsp[ 1,0]/(nder+1)
nphi_d1= nphi_d1+ 1
ENDFOR

FOR NSTK=1,3 DO BEGIN
nphi_d1=0
FOR PHI_D1= 0., 359., 45. DO BEGIN
if ( nder eq 0) then temp= tedge_d1* distance* cos( phi_scan- !dtor*phi_d1)
if ( nder eq 1) then $
    temp= tedge_d2* ((distance* cos( phi_scan- !dtor*phi_d1))^2 - 1./3.)
;   temp= tedge_d2* 0.5*(3.*(distance* cos( phi_scan- !dtor*phi_d1))^2 - 1.)
pngl[ nphi_d1]= phi_d1
sidelobe_response[ nphi_d1]= $
    pixelsize^2* total( temp* sidelobe[ *,*,nstk])/mb_tot
squintbeam_response[ nphi_d1]= $
    pixelsize^2* total( temp* squintbeam[ *,*,nstk])/mb_tot
squashbeam_response[ nphi_d1]= $
    pixelsize^2* total( temp* squashbeam[ *,*,nstk])/mb_tot
totalbeam_response[ nphi_d1]= $
    pixelsize^2* total( temp* totalbeam[ *,*,nstk])/mb_tot
nphi_d1= nphi_d1+ 1
ENDFOR 

pa1fit, (nder+1)*pngl, 1, sidelobe_response, coeffs, coeffsp, /nodiscard
sideampl[ nstk, nder]= coeffsp[ 0,0]
sideangl[ nstk, nder]= coeffsp[ 1,0]/(nder+1)

pa1fit, (nder+1)*pngl, 1, squintbeam_response, coeffs, coeffsp, /nodiscard
squintampl[ nstk, nder]= coeffsp[ 0,0]
squintangl[ nstk, nder]= coeffsp[ 1,0]/(nder+1)

pa1fit, (nder+1)*pngl, 1, squashbeam_response, coeffs, coeffsp, /nodiscard
squashampl[ nstk, nder]= coeffsp[ 0,0]
squashangl[ nstk, nder]= coeffsp[ 1,0]/(nder+1)

pa1fit, (nder+1)*pngl, 1, totalbeam_response, coeffs, coeffsp, /nodiscard
totalampl[ nstk, nder]= coeffsp[ 0,0]
totalangl[ nstk, nder]= coeffsp[ 1,0]/(nder+1)

;stop

ENDFOR

ENDFOR

end
