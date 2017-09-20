;+
;NAME:
;focerr - return the radial focus error for the requested az,za.
;SYNTAX: focerr=focerr(az,za,date=yymmdd,ao9=ao9)
;ARGS:
;	az[n]	: float	azimuth position degrees
;	za[n]	: float	zenith angle position degrees.
;ARGS:
;	date    : long yymmdd use data valid on the date. default is most recent
;	ao9	    : if set the return correction relative to the ao9
;			  the default is to return the error relative to the dish
;			  this is only valid for the 01aug09 data.
;RETURNS:
;	focerr[n]:float radial focus error for azimuth and za.
;DESCRIPTION:
;	Return the radial focus error for the requested azimuth and zenith
;angles. Positive means that the dome is too far from the dish. The
;return value is the error. To correct, add the negative.
;	Data comes from the:
;  1.before 04aug01 ??
;  2 04aug01 ao9 survey aug01. default correction is relative to the dish
;            /ao9 returns it relative to ao9
;  3 17feb03 survey on 17feb03
;
;-
function focerr,az,za,ao9=ao9,date=date
;
; compute the focus error. + means you are above the
; paraxial surface
; distance is to move the dome radially along the paraxial ray.
;
;--------------------------------------------------------------------
; before 04aug01
;return,[-.7123 + .2711*za - .00856*za*za + $
;		.3990*sin((   az- 93.8)*!dtor) + $
;		.6252*sin((3.*az-146.1)*!dtor) + $
;		.0880*za*sin((3.*az-320.8)*!dtor)]
;--------------------------------------------------------------------
if not keyword_set(date) then date=999999l
zap=za-10.
azrd=az*!dtor
sinza=sin(zap*!dtor)
;----------------------------
;  prior to 04aug01
;
	if date lt 010804 then begin
	  return,[-.7123 + .2711*za - .00856*za*za + $
	         .3990*sin((   az- 93.8)*!dtor) + $
	         .6252*sin((3.*az-146.1)*!dtor) + $
	         .0880*za*sin((3.*az-320.8)*!dtor)]
	endif 
;----------------------------
; 	04aug01 to 16feb03
;
	if date  lt 030217 then begin
		if keyword_set(ao9) then begin
;	
; data comes from 04aug01 theod survey.. corrects to ao9
;
		return,[.70285 + .04139*zap-.01072*zap^2+.00028*zap^3 $
	    - .64074*cos(azrd)         + .01427*sin(azrd)       $
		+ .13840*cos(3.*azrd)      + .26548*sin(3.*azrd)    $
        +3.16539*sinza*cos(3.*azrd)+ .52009*sinza*sin(3.*azrd)]
		endif 
;
; 		this corrects to the reflector
;
return,[2.3013592 + .010105771*zap -.010433663*zap^2+.00033858093*zap^3 $
	 - 0.83053*cos(azrd) + ( 0.37115)*sin(azrd) $
	 + 0.10918*cos(3.*azrd) + ( 0.26122)*sin(3.*azrd) $
	 + 3.41120*sinza*cos(3.*azrd) + ( 0.55734)*sinza*sin(3.*azrd)]
	endif
;
;----------------------------
 	
return,[1.5896965 -.011188033*zap -.018012989*zap^2-.00030904655*zap^3 $
     - 0.41210412*cos(azrd)         + (  .062270569)*sin(azrd) $
     + 0.24408706*cos(3.*azrd)      + ( 0.16287717)*sin(3.*azrd) $
     + 3.7816341*sinza*cos(3.*azrd) + ( 0.57259180)*sinza*sin(3.*azrd)]

end
