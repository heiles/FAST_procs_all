;+
;NAME:
;dms1_dms3 - convert deg,min,secs 1 word to deg,min,sec separate words
;SYNTAX - ret=dms1_dms3(hhmmss)
;ARGS: 
;   ddmmss : double angle to convert
;RETURNS:
;   ret[4] : double deg,min,sec, and sign 
;
;- 
function dms1_dms3,dms
    ldms=dms
;
;   make positive, remember sign
;
    sind=where(ldms lt 0.,scount)
    if scount gt 0 then ldms[sind]=-ldms[sind]
;
;   integer version
;
    itemp=long(ldms)
    s= ldms - itemp + (itemp mod 100)
    d=itemp/10000
    m=(itemp/100) mod 100
;
;   see if overflow
;
    ind=where(s ge 60.,count)
    if count gt 0 then begin
        s[ind]=s[ind]-60.
        m[ind]=m[ind]+1.
    endif
    ind=where(m ge 60.,count)
    if count gt 0 then begin
        m[ind]=m[ind]-60.
        d[ind]=d[ind]+1.
    endif
    d=d mod 360.
;
;   return array  , or single element
;
    n=n_elements(dms);
    if n gt 1 then begin
        ret=dblarr(4,n)
        ret[0,*]=d
        ret[1,*]=m
        ret[2,*]=s
        ret[3,*]=dblarr(n)+1.
        if scount gt 0 then ret[3,sind]=-1.
    endif else begin
        ret=[d,m,s,1.D]
        if scount gt 0 then ret[3]=-1.
    endelse
    return,ret
end
