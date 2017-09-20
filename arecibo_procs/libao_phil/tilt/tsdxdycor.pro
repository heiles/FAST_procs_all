;+
;tsdxdycor - compute pitch, roll do to horizontal motion of platform.
;
; SYNTAX:
;	  tsdxdycor,az,za,pitch,roll
;
; ARGS:
;	  az	- azimuth position      in degrees (scalar or array)
;	  za	- zenith  position dome in degrees (scalar or array)
;
; RETURNS:
;	  pitch - the pitch in degrees for each entry. + is up
;	  roll  - the roll  in degrees for each entry. + clockwise looking 
;             from center.
;
; DESCRIPTION:
; 	Compute the pitch and roll of the dome caused by the horizontal 
; motion of the platform. These values should be added to the tilt 
; sensor measurement (since the tilt sensor can not measure horizontal
; motion). The computations come from the 08mar00 azimuth swings. The 
; functions are for the carriage house at stow. The x,y offset between
; the laser ranging origin and ao9 (about .4 inches) has been 
; included. 435 feet was used at the radius when converting dx,dy to
; pitch,roll.
;-
; history- 
; 05apr00 - don't use 3az term. theod doesn't see it. probably an 
;           artifact of the laser ranger compuation (fixed direction
;			cosines).
pro tsdxdycor,az,za,pitch,roll
;
;	without laser ranging offset included
;	pitch=.0207 - .0024*za + .0167*sin((az-111.)*!dtor) +  $
;							 .0042*sin((3.*az-275.4)*!dtor)
;	roll =-.0005 - .0001*za + .0166*sin((az-201.0)*!dtor) +  $
;							 .0045*sin((3.*az-5.6)*!dtor)
;
;	laser ranging offset included
;
 	pitch=.0207 - .0024*za + .0249*sin((az-105.)*!dtor) 
;; 							 .0042*sin((3.*az-275.4)*!dtor)
  	roll =-.0005 - .0001*za + .0249*sin((az-195.)*!dtor) 
;; 							 .0045*sin((3.*az-5.6)*!dtor)
	return
end
