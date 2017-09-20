;+
;NAME:
;terfmultmpnts - tertiary connection points by matrix.
;SYNTAX: newpnts=terfmultmpnts(m,pnts)
;ARGS:
;   m[4,4]   : float  matrix to multiply points by.
;   pnts[4,5]: float  5 tertiary connection points
;DESCRIPTION:
;   Apply to matrix m to each of the 5 tertiary connection points. The 
;matrix is a 4,4 matrix and each vector is dimension 4 (x,y,x, and translation).
;-
;-----------------------------------------------------------------------------
function terfmultmpnts,m,pnts
    npnts=pnts
    for i=0,4 do begin
        npnts[*,i]=m ## pnts[*,i]
    endfor
    return,npnts
end
