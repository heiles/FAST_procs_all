;+
;NAME:
;dipolexyoff - return dipole xy offsets
;SYNTAX: n=dipoleoffsets(dipOffxy,altmount=altmount)
;KEYWORDS:
; altmount:      if set then use the 2nd mounting position
;                for dipoles of 10.8934. this is for the outer c1-c6  ring
;RETURNS:
;n - number of dipoles
;dipOffXY[2,n] float  [0,*] x offsets in cm from center
;                     [1,*] y offsets in cm from center
;DESCRIPTION:
;	return the x,y offset for the 19 dipoles. this if for the
;positioner at rotation angle 0 and radius=0.
;-
function dipolexyoff,xy,altmount=altmount

;  40.8934
    dipRot=-40.8934
    if keyword_set(altmount) then dipRot-=30.
	n=19L
	dr0=11.24
	xy=fltarr(2,n)
;   center
	xy[0,0]=0.
    xy[0,0]=0.
	hex1=fltarr(2,6)
	hex2=fltarr(2,6)
	hex3=fltarr(2,6)
	v0=[dr0,0.]
;   inside hexagon pnt 1 along x
	for i=0,5 do hex1[*,i]=rotvec(v0,60.*i)
;   2nd hexagon   lines up with th=0 2*v0
	for i=0,5 do hex2[*,i]=rotvec(2*v0,60.*i)
;   3rd hexagon   start at 30 deg offset from hex2[0]
	v3=total(hex2[*,0:1],2)*.5
	for i=0,5 do hex3[*,i]=rotvec(v3,60.*i)
;
; load x,y
;
	xy[*,1:6]=hex1

	ii=lindgen(6)*2
	xy[*,ii+7]=hex2
	xy[*,ii+8]=hex3
;
;   now rotate by 40.8934
;   the outer 6 would have a rotation of 10.8934 but you
;   need to change the mount
;
	xy=rotvec(xy,dipRot)
	return,n
end
