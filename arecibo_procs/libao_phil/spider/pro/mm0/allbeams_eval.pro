pro allbeams_eval, nterms, arcmin, pixelsize, azarray, zaarray, $
    stripfit, b2dfit, $
    mainbeam, sidelobe, $
    squintbeam, squashbeam, totalbeam, $
    mainbeam_integral, sidelobe_integral, $
    squintbeam_integral, squashbeam_integral, totalbeam_integral

;+
;NAME:
;allbeams_eval -  Return maps of all beams
;PURPOSE: Return maps of all beams (the Stokes I beam, the sidelobe, the
;         squintbeam, the squashgeam0 on a 60 by 60 grid.
;
;CALLING SEQUENCE:
;	ALLBEAMS_EVAL, nterms, arcmin, pixelsize, azarray, zaarray, $
;   			stripfit, b2dfit, $
;   			mainbeam, sidelobe, $
;   			squintbeam, squashbeam, totalbeam, $
;  			    mainbeam_integral, sidelobe_integral, $
;               squintbeam_integral, squashbeam_integral, totalbeam_integral
;
;INPUTS:
;   NTERMS: the nr of terms in the Fourier expansion of the first
;			sidelobe to include. We set nterms=6, which allows it to get the
;			triangle contribution.
;
;   ARCMIN: the nominal HPBW in arcmin used in the observing
;			pattern. From HDR1INFO[28, *].
;
;PIXELSIZE: the size of the pixels. From MAKE_AZZA
;
;  AZARRAY: ZAARRAY, the az,za array used for observing and for
;			which the beam is calculated. From MAKE_AZZA
;
; STRIPFIT: the STRIPFIT array for this particular pattern. See
;			BEAM_DESCRIBE 
;
;   B2DFIT: the main beam description array for this particular
;			pattern. See BEAM2D_DESCRIBE.
;
;OUTPUTS:
;   MAINBEAM:The Stokes I main beam (no sidelobes). This array is
;			 fltarr(60,60,4), giving the possibility of 4 stokes parametres,
;            but only Stokes I is represented.
;
;   SIDELOBE[60,60,4]:The sidelobe in all four stokes parameters
;
;   SQUINTBEAM[60,60,4]: The squint beam in the latter 3 Stokes
;						parameters, so there are only three squintbeams.
;
;   SQUASHBEAM[60,60,4]:The squash beam in the latter 3 Stokes
;				parameters, so there are only three squashbeams.
;
;   TOTALBEAM: SQUINTBEAM+ SQUASHBEAM+ SIDELOBE
;
;-

;purpose: 
;retall

mainbeam= fltarr( 60, 60, 4)
sidelobe= fltarr( 60, 60, 4)
squintbeam= fltarr( 60, 60, 4)
squashbeam= fltarr( 60, 60, 4)

mainbeam_integral= fltarr( 4)
sidelobe_integral= fltarr( 4)
squintbeam_integral= fltarr( 4)
squashbeam_integral= fltarr( 4)

;MAINBEAM IN STOKES I...
mainbeam_eval_newcal, azarray, zaarray, b2dfit, mainbeamt
mainbeam[ *,*, 0]= mainbeamt/b2dfit[2,0]
mainbeam_integral[ 0]=  pixelsize^2 * total( mainbeamt)/b2dfit[2,0]

;FIRST EVALUATE THE SIDELOBE BEAMS...
FOR NSTKN=0, 3 DO BEGIN
ft_sidelobes_newcal, stripfit, b2dfit, fhgt, fcen, fhpbw, nstk= nstkn
sidelobe_eval, nterms, fhgt, fcen, fhpbw, azarray, zaarray, sidelobet
sidelobe[ *,*,nstkn]= sidelobet/b2dfit[2,0]
sidelobe_integral[ nstkn]= pixelsize^2 * total( sidelobet)/b2dfit[2,0]
ENDFOR

;POL BEAMS IN THE REQUESTED STOKES PARAMETER NSTKN...
FOR NSTKN=1, 3 DO BEGIN
polbeam_eval, arcmin, azarray, zaarray, b2dfit, nstkn, $
    squintbm, squashbm
squintbeam[ *,*, nstkn]= squintbm/b2dfit[2,0]
squashbeam[ *,*, nstkn]= squashbm/b2dfit[2,0]
squintbeam_integral[ nstkn]= pixelsize^2 * total( squintbm)/b2dfit[2,0]
squashbeam_integral[ nstkn]= pixelsize^2 * total( squashbm)/b2dfit[2,0]
ENDFOR

totalbeam= sidelobe+ squintbeam+ squashbeam
totalbeam_integral= sidelobe_integral+ mainbeam_integral

end
