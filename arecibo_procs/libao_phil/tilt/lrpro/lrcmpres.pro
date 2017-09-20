;---------------------------------------------------
function lrCmpRes,lr,lrfit,ind,useroll
;
; compute residuals  fit vs az
;
;
    forward_function azsweval
    if n_elements(ind)     eq 0 then ind    =0
    if n_elements(useroll) eq 0 then useroll=0
    if useroll eq 0 then begin
        lrf=lrfit[ind].p
        yy=lr[*,ind].p
    endif else begin
        lrf=lrfit[ind].r
        yy=lr[*,ind].r
    endelse
    return, (yy- azsweval(lrf,lr[*,ind].aznomod))
end
