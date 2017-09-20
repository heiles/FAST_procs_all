;+
; cmpPpnterr - compute pitch pointing error using a matrix rotation/translation
;
; SYNTAX:   cmpPpnterr,pitch,za,fracErr,foc=foc
; ARGS:
;        pitch   :  float.. pitch angle to rotate thru.. degrees..
;        za[npts]:  float.. za to evaluate fraction at
;        fracErr[npts]: float.. zaErr/pitchangle
; KEYWORDS:
;        FOC     : if not zero, then pull back up into focus before
;                  computing error.
; DESCRIPTION:
;   We are rotating by the pitch value (not the negative). We return
;  (zaNew-za)/pitch. If this number is + then we are left at a higher
;  za. If you wanted to correct for this , you would move in the minus
;  direction to point back at the source.
;  eg:
;    suppose the pitch is positive.
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
pro cmpPpnterr,pitch,za,fracErr,foc=foc
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
;
    t3d,/reset
;
; to rotate by pitch angle th
; 1. tranlate origin to rotate about platform
    t3d,translate=[0.,pl,0.]
;
; 2. rotate about z axis by th. + is counter clockwise
;
    t3d,rotate=[0.,0.,pitch]
;
; 3. translate back to center of curvature origin
;
    t3d,translate=[0.,-pl,0.]
;
; apply transformation
;
    ptsn= !p.t ## transpose(pts)    ; tranpose to get row,col right
    ptsn=transpose(ptsn)
;
;   see if we have to correct for focus motion
;
    if foc ne 0 then begin
;
;    compute how much we moved in the y direction.
;
        dy=ptsn[iy,*]-pts[iy,*]
        ptsn[iy,*]=ptsn[iy,*]-dy
    endif
;
; now compute za at each new x,y
;
    zan=atan(ptsn[1,*],ptsn[0,*]) * !radeg + 90.
    if pitch eq 0 then begin
        fracErr=fltarr(len)
    endif else begin
        fracErr=(zan-za)/pitch
    endelse
    return
end
