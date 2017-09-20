;+
;NAME:
;pnterrplathght - compute pointing err vs platform height
;SYNTAX: istat=pnterrplathght(avgHgtFt,za,pntErrAsecs,defhght=defhght,
;                             deltahght=deltahght)
;ARGS:
; avgHght[n]:float  average platform heigth in feet.
;      za[n]: float zenith and in degrees for feed.
;KEYWORDS:
;    defhght: float correct platform height. default is 1256.22
;  deltaHght:       if set then the avgHght entered is the 
;                   delta height (measured height - correct height)
;RETURNS:
;istat      : int   > 0 .. how many entries in pntErrAsecs
;                     = -1   error in arguments entered
;pntErrAsecs[n]:float za error in arc seconcds.
;
;DESCRIPTION:
;   
;    Compute the za pointing error when platform is moved vertically.
;see http://www.naic.~phil/pnt/platMotion/pntErrVsPlatMotion.html
;
;	The default height is 1256.22 feet.
;	This reports the zaErr in arcseconds. The azimuth pointing error is not
;affected by vertical motions.
;
;The sign of the Error:
;	A height above the def hght will give a positive error. To correct for 
;this error you must subtract it from the model (or the requested az,za).
;
;-
function pnterrplathght,avgHghtFt,za,pntErrAsecs,defhght=defhght,$
		 deltahght=deltahght
;
;
	if keyword_set(deltahght) then begin
		delhght=avgHghtFt
	endif else begin
		defHght=(n_elements(defhght) eq 0)?1256.22:defhght
	
		delhght=avgHghtFt - defhght
	endelse
	radiusCurv=435.
	if n_elements(za) ne n_elements(avgHghtFt) then begin
		print,$
		"Err: params avgHghtFt and za must have the same # of elements" 
		return,-1
	endif
	pntErrAsecs= delhght*sin(za*!dtor)/radiusCurv *!radeg*3600.
	return,n_elements(pntErrAsecs)
end
