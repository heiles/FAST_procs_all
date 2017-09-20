;+
;NAME:
;mav - multiply an array by a vector 
;SYNTAX: val=mav(a,v,sec=sec)
;ARGS:
;       a[n,m] : array 
;       v[n]   : vector 
;KEYWORDS:
;     sec: if set then v should match the 2nd dimension of a
;
;returns:
;       val[n,m]
;DESCRIPTION: 
; return val[i,j]= a[i,j]*v[j].. i=0,n-1,j=0,m-1
;
; the routine will make v'[n,m] where v[i,*] is the same value
;-
; 
function mav,a,v,sec=sec
;
    on_error,1
    asize=size(a)
    vsize=size(v)
    if not keyword_set(sec) then begin
    if (asize[1] ne vsize[1]) or (vsize[0] ne 1) or (asize[0] ne 2 ) then begin
        message,'mav(a,v).. requires dimensions a[m,n] * v[m]'
        endif
        return,a * ( v # (make_array(asize[2],type=vsize[2],value=1)))
    endif else begin
     if (asize[2] ne vsize[1]) or (vsize[0] ne 1) or (asize[0] ne 2 ) then begin
        message,'mav(a,v,/sec).. requires dimensions a[n,m] * v[m]'
        endif
        return,a * ( v ## (make_array(asize[1],type=vsize[2],value=1)))
    endelse
end 
