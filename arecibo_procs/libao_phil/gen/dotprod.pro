;+
;NAME:
;dotprod - compute the dot product of two vectors
;SYNTAX: val=dotprod(v1,v2)
;ARGS:
;       v1[m] : vector
;       v2[m] : vector
;returns:
;       val
;DESCRIPTION:
; return val=total(v1*v2)
;
;-
;
function dotprod,v1,v2
;
    return,total(v1*v2)
end

