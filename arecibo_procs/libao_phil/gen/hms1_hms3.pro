;+
;NAME: 
;hms1_hms3 - convert hour,min,secs 1 word to hour,min,sec separate words
;SYNTAX - ret=hms1_hms3(hhmmss)
;ARGS: 
;   hhmmss : double angle to convert
;RETURNS:
;   ret[4] : double hour,min,sec, and sign 
;
;- 
function hms1_hms3,hms
    lhms=hms
;
;   make positive, remember sign
;
    sind=where(lhms lt 0.,scount)
    if scount gt 0 then lhms[sind]=-lhms[sind]
;
;   integer version
;
    itemp=long(lhms)
    s= hms - itemp + (itemp mod 100)
    h=itemp/10000
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
        h[ind]=h[ind]+1.
    endif
    h=h mod 24.
;
;   return array  , or single element
;
    n=n_elements(hms);
    if n gt 1 then begin
        ret=dblarr(4,n)
        ret[0,*]=h
        ret[1,*]=m
        ret[2,*]=s
        ret[3,*]=dblarr(n)+1.
        if scount gt 0 then ret[3,sind]=-1.
    endif else begin
        ret=[h,m,s,1.D]
        if scount gt 0 then ret[3]=-1.
    endelse
    return,ret
end
