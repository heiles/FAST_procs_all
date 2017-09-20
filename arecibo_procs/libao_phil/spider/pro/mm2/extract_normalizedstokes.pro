pro extract_normalizedstokes, indx, beamout_arr, mueller_az, $
	qpa, xpy, xmy, xy, yx, $
	negate_q= negate_q, chnl=chnl

;+

;PURPOSE; EXTRACT THE XPY, XMY, ETC... FROM THE STRP_CFS ARRAY. ALSO
;APPLY M_(prep) DISCUSSED IN MUELLER3.DOC, WHICH HERE IS CALLED
;MUELLER_AZ, 
;
;INPUTS:

;	indx, the array of indices telling which members of the
;dataset to treat.

;	BEAMIN_ARR, the array of beamin...

;	MUELLER_AZ, the prepatory mueller matrix M_(prep)

;OUTPUTS: 

;	QPA, the position angles on the sky of the datapoints.

;	XPY, XMY, XY, YX, the calibrated correlator values divided by
;each X+Y (so that all outputs are relative to Stokes I)..

;KEYWORD:

;	CHNL: does channel CHNL instead of continuum.

;	NEGATE_Q, multiplies the xmy spectra by -1 if it is set. AS OF 
;23 OCT 2002 IT IS NOT SET!!! 

;-

;EXTRACT THE ARRAY OF POSITION ANGLES FOR EACH STRIP SEPARATELY
;       BY USING ONE IN THE MIDDLE (NUMBER 29, COUNTING 0 TO 59)...
qpa= beamout_arr[ indx].pacntr

;EXTRACT THE CORRELATOR OUTPUTS, AND NORMALIZE THEM... 

IF ( KEYWORD_SET( CHNL)) THEN BEGIN
xpy_non = beamout_arr[ indx].stripfit_chnl[ chnl, 1, 0, *]
; <pjp004>
ind=where(xpy_non eq 0.,count)
if count gt 0 then xpy_non[ind]=1.
xpy =  beamout_arr[ indx].stripfit_chnl[ chnl, 1, 0, *]/xpy_non
xmy =  beamout_arr[ indx].stripfit_chnl[ chnl, 1, 1, *]/xpy_non
xy =  beamout_arr[ indx].stripfit_chnl[ chnl, 1, 2, *]/xpy_non
yx =  beamout_arr[ indx].stripfit_chnl[ chnl, 1, 3, *]/xpy_non
ENDIF ELSE BEGIN
xpy_non = beamout_arr[ indx].stripfit[ 1, 0, *]
xpy =  beamout_arr[ indx].stripfit[ 1, 0, *]/xpy_non
xmy =  beamout_arr[ indx].stripfit[ 1, 1, *]/xpy_non
xy =  beamout_arr[ indx].stripfit[ 1, 2, *]/xpy_non
yx =  beamout_arr[ indx].stripfit[ 1, 3, *]/xpy_non
ENDELSE

if  keyword_set( negate_q) then xmy= -xmy

qpa = reform( qpa, n_elements(qpa))
xpy = reform( xpy, n_elements(qpa))
xmy = reform( xmy, n_elements(qpa))
xy = reform( xy, n_elements(qpa))
yx = reform( yx, n_elements(qpa))

svi = fltarr( n_elements(qpa), 4)
svi[ *, 0] = xpy
svi[ *, 1] = xmy
svi[ *, 2] = xy
svi[ *, 3] = yx

svimod = mueller_az ## svi

xpymod = svimod[ *,0]
xmymod = svimod[ *,1]
xymod = svimod[ *,2]
yxmod = svimod[ *,3]
   
xpy=xpymod
xmy=xmymod
xy=xymod
yx=yxmod

;stop

return
end
