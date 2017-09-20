;+
;NAME:
;dipolexyoff - return dipole xy offsets
;SYNTAX: n=dipoleoffsets(dipOffxy)
;RETURNS:
;n - number of dipoles
;dipOffXY[2,n] float  [0,*] x offsets in cm from center
;                     [1,*] y offsets in cm from center
;DESCRIPTION:
;	return the x,y offset for the 19 dipoles. 
;positive x is downhill
;positive y is toward the stairwell
;-
function dipolexyoff,xy

	n=19L
	dr0=12.8
	xy=fltarr(2,n)
;   center
	xy[0,0]=0.
    xy[0,0]=0.
	hex1=fltarr(2,6)
	hex2=fltarr(2,6)
	hex3=fltarr(2,6)
	v0=[0.,dr0]
;   inside hexagon pnt 1 along y
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
	return,n
end
