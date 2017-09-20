pro extract_2d_normalizedstokes, indx, beamout_arr, mueller_az, $
	qpa, xpy, xmy, xy, yx, $
	negate_q= negate_q, chnl=chnl

;+

;PURPOSE; EXTRACT THE XPY, XMY, ETC... FROM THE B2DFIT ARRAY. ALSO
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
qpa= beamout_arr[ indx].b2dfit[ 18,0]

;EXTRACT THE CORRELATOR OUTPUTS, AND NORMALIZE THEM... 

IF ( KEYWORD_SET( CHNL)) THEN BEGIN
print, 'WE ARE NOT SET UP TO USE CHNL OPTION WITH MM4_2D'
STOP
ENDIF ELSE BEGIN
xpy_non = beamout_arr[ indx].b2dfit[ 2,0]
xpy =     beamout_arr[ indx].b2dfit[ 2,0]/xpy_non
xmy =     beamout_arr[ indx].b2dfit[ 22,0]/xpy_non
xy =      beamout_arr[ indx].b2dfit[ 32,0]/xpy_non
yx =      beamout_arr[ indx].b2dfit[ 42,0]/xpy_non
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
