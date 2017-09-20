;+
;NAME:
;pos_xyoff - offsets for positions A (A1-A6) and (C1-C6) (D1-D6)
;SYNTAX: n=pos_xyoff(a,c,d)
;RETURNS:
;n - 6
;a[2,6] float  A position x,y cm from center 
;c[2,6] float  C position x,y cm from center 
;d[2,6] float  C position x,y cm from center 
;DESCRIPTION 
; 	Return the xy offsets for positions a1..a6,c1_c6, d1_d6
;These are the overlapped positions.
; the order is similar to germans:
; a1 -  xoff 2*dro
;       yoff 2*dr0*cos(30)
; a2-6 ccw 60 degree rotations.
;
; c1 -  xoff 4.5*dr0
;       yoff 1*dr0*cos(30)
; d1 -  xoff 4.*dr0
;       yoff 4*dr0*cos(30)
;-
function pos_xyoff,a,c,d

	n=6
	dr0=11.24
;   center
	vA=2*dr0*[1.,cos(30*!dtor)]
	vC=dr0*[4.5,cos(30*!dtor)]
	vD=2*Va
	A=fltarr(2,6)
	C=fltarr(2,6)
	D=fltarr(2,6)
;   inside hexagon A 
	for i=0,5 do A[*,i]=rotvec(vA,60.*i)
;   2nd hexagon   C
	for i=0,5 do C[*,i]=rotvec(vC,60.*i)
;   3rd hexagon   D
	for i=0,5 do D[*,i]=rotvec(vD,60.*i)
	return,n
end
