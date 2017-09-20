;
;NAME:
;lrmovie - display range of daynumbers
pro lrmovie,daynum1,daynum2,hor=hor,ver=ver,delay=delay
;
    on_error,1
    if n_elements(delay) eq 0 then delay=0
    if n_elements(hor) eq 2 then begin
        hor,hor[0],hor[1]
    endif else begin
        hor
    endelse
    if n_elements(ver) eq 2 then begin
        ver,ver[0],ver[1]
    endif else begin
        ver,1256,1257
    endelse
    for i=daynum1,daynum2 do begin
        npnts=lrpcinp(-1,b,daynum=i)
        if npnts gt 2 then begin
            lrplothght,b
            if delay gt 0 then wait,delay
        endif
    endfor
end
