;+
;NAME:
;rmsbychan - compute the rms/mean  by chan for 2d array.
;SYNTAX:  result=rmsbychan(d,median=median,nodiv=nodiv)
;  ARGS:
;     d[m,n]  : array to compute rms
;KEYWORDS:
;     median: if set then use median rather than mean
;     nodiv : if set then don't divide by the mean
;   
; RETURNS:
;     result[m]: result[i]= rms(d[i,*])/mean(d[i,*])
; DESCTRIPTION:
;    compute the standard deviation/mean  by channel.
;-
function rmsbychan,d,median=median,nodiv=nodiv
    a=size(d)
    if not keyword_set(nodiv) then nodiv=0
    if a[0] ne 2 then begin
        print,'array should be 2d'
        return,0
    endif
    nx=a[1]
    ny=a[2]
    ret=dblarr(nx)
    meany=dblarr(nx)
    if keyword_set(median) then begin
        if !version.release ge '5.6' then begin
            meany=median(d,dimension=2)
        endif else begin
            for i=0,nx-1 do meany[i]=median(d[i,*])
        endelse
    endif else begin
        meany=total(d,2)/ny
    endelse
    res=(d- (meany # make_array(ny,type=a[3],value=1.)))
    var=total(res^2,2,/double)/(ny-1.0)
    if not keyword_set(nodiv) then return,(sqrt(var))/meany
    return,(sqrt(var))
end
