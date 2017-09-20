;+
;NAME:
;terfdistpp - compute distance between two points
;SYNTAX: dist=terfdistpp(p1,p2)
;ARGS:
;	p1[3or4]: float  connection point for tertiary
;	p2[3or4]: float  connection point for tertiary
;DESCRIPTION:
;	Return the distance between the two tertiary connection points.
;They can be 3 or 4 dimensional vectors.
;-
;-----------------------------------------------------------------------------
function terfdistpp,p1,p2
    a=p1-p2
    return,sqrt(a[0]*a[0]+a[1]*a[1]+a[2]*a[2])
end
