;+
; cmpRpnterr - compute roll  pointing error using a matrix rotation/translation
;
; SYNTAX:   cmpRpnterr,roll,za,fracErr
; ARGS:
;        roll    :  float.. pitch angle to rotate thru.. degrees..
;        za[npts]:  float.. za to evaluate fraction at
;        fracErr[npts]: float.. zaErr/pitchangle
; DESCRIPTION:
;   We are rotating by the roll  value (not the negative). We return
;  (angleNew-angle)/roll. If this number is + then we are left at a higher
;  angle. If you wanted to correct for this , you would move in the minus
;  direction to point back at the source.
;       
;-
pro cmpRpnterr,roll,za,fracErr
;
; center of coordinate system at  center of curvature.
; x-hor, y-up,  let azimuth arm be in the x,y plane (say east west).
;   the z direction is then north
; rc -  radius of curvature
; pl -  center curvature to rotation axis of platform at working points
; plTofoc - platform to focus directly below
    rc = 435.
    pl = 374.342
;
;  center of curvature
;
; define points along azimuth arm from center of curvature
; [0,*] - x
; [1,*] - y
; [2,*] - z
; [3,*] - translation
;
    ix=0
    iy=1
    iz=2

    len=n_elements(za)
    if n_elements(foc) eq 0 then foc=0
;
;	equation of azimuth arm
    pts=dblarr(4,len)
    pts[iz,*]=0                 ; z=0
    pts[3,*]=1                 ; translation dimension
    pts[ix,*]= rc*sin(za*!dtor) ; x coord
    pts[iy,*]=-rc*cos(za*!dtor) ; y coord
;
    t3d,/reset
;
; to rotate by roll angle th
; 1. tranlate origin to rotate about platform
    t3d,translate=[0.,pl,0.]
;
; 2. rotate about x axis by th. + is counter clockwise  looking donw
;    the axis to the origin (same as lynn bakers clockwise looking up
;    the axis.
;
    t3d,rotate=[roll,0.,0.]
;
; 3. translate back to center of curvature origin
;
    t3d,translate=[0.,-pl,0.]
;
; apply transformation
;
    ptsn= !p.t ## transpose(pts)    ; tranpose to get row,col right
    ptsn=transpose(ptsn)
	da=atan(ptsn[iz,*],sqrt(ptsn[ix,*]^2+ptsn[iy,*]^2))*180./!pi
	if roll ne 0. then begin
		fracErr=da/roll
	endif else begin
		fracErr=0.
	endelse
    return
end
