;
;NAME:
;lrmon - monitor the laser ranging
pro lrmon,hor=hor,ver=ver,sym=sym
;
    on_error,1

    if n_elements(hor) eq 2 then begin
        hor,hor[0],hor[1]
    endif else begin
        hor
    endelse
    if n_elements(ver) eq 2 then begin
        ver,ver[0],ver[1]
    endif else begin
        ver,1255.8,1256.8
    endelse
    if n_elements(sym) eq 0 then sym=0 
    while 1 do begin
        npts=lrpcinp(-1,b)
        if npts gt 1 then begin ; cannot plot arrays of length 1
             daynum=floor(b[0].date)
            lrplothght,b,sym=sym
        endif
        wait,120
    endwhile
end
