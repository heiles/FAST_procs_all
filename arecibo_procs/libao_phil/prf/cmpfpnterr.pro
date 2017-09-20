;+
; cmpFpnterr - compute focus pointing error using a matrix rotation/translation
;
; SYNTAX:   cmpFpnterr,focRadIn,za,errAsecs
; ARGS:
;        focRadIn  :  float.. radial focus motion in inches.
;        za[npts]:  float.. za to evaluate fraction at
;        errAsecs[npts]: float.. 
; DESCRIPTION:
;   We are moving by the focus value (not the negative). We return
;  (zaNew-za)*3600. If this number is + then we are left at a higher
;  za. If you wanted to correct for this , you would move in the minus
;  direction to point back at the source.
;  eg:
;    suppose the focuspitch is positive.
;    1. we are pointing on source with the model and we then pitch the
;       platform by .1 degrees more..
;       - we have a positive error. move in the negative direction to  point
;         back at the source.
;    2. The dome has a .1 deg pitch, we made the model and it compensated
;       for it. We then repitched the dome so pitch is 0.
;       - the model has a negative pitch correction in it.
;       - after aligning the dome and using the same model, we must get
;         rid of the neg pitch error.. so we add a positive value..
;       
;-
pro cmpFpnterr,focus,za,errAsecs
;
; center of coordinate system at  center of curvature.
; x-hor, y-up
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

    len=n_elements(za)
    if n_elements(foc) eq 0 then foc=0
    pts=dblarr(4,len)
    pts[2,*]=0                 ; z=0
    pts[3,*]=1                 ; translation dimension
    pts[ix,*]= rc*sin(za*!dtor) ; x coord
    pts[iy,*]=-rc*cos(za*!dtor) ; y coord
    ptsn=pts
	dy= (focus/12.) /cos(za*!dtor)
;
   ptsn[iy,*]=pts[iy,*] + dy
;
; now compute za at each new x,y
;
    zan=atan(ptsn[1,*],ptsn[0,*]) * !radeg + 90.
	errAsecs=(zan-za)*3600.
    return
end
