;+
;NAME:
;medianbychan -  median 2d array by chan.
;SYNTAX:  result=medianbychan(d)
;   ARGS:
; d[m,n]: input array to compute median over 2nd dimension (n).
;   
;RETURNS:
;result[m]: result[i]= median(d[i,*])
;
;DESCTRIPTION:
;    Compute the median by channel for a 2d array. If the array
;is dimensioned d[m,n] then result[i]=median(d[i,*]).
;-
function medianbychan,d
    a=size(d)
    if a[0] ne 2 then begin
        print,'array should be 2d'
        return,0
    endif
    nx=a[1]
    ny=a[2]
    ret=d[*,0]
    for i=0L,nx-1L do ret[i]=median(d[i,*])
    return,ret
end
