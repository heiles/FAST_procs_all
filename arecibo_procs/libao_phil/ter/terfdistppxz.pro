;+
;NAME:
;terfdistppxz - compute distance between two points (x,z coordinates only)
;SYNTAX: dist=terfdistppxz(p1,p2)
;ARGS:
;   p1[3or4]: float  connection point for tertiary
;   p2[3or4]: float  connection point for tertiary
;DESCRIPTION:
;   Return the distance between the two tertiary connection points using
;just the x and z coordinates.
;-
function terfdistppxz,p1,p2
    a=p1-p2
    return,sqrt(a[0,*]*a[0,*]+a[2,*]*a[2,*])
end
