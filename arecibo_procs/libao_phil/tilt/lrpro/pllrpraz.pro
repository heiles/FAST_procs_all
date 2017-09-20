;---------------------------------------------------
pro plLrPRAz,lr,ind,useroll,overplot
;
; plot pitch,roll vs az 1 swing
;
    if n_elements(ind)     eq 0 then ind    =0
    if n_elements(useroll) eq 0 then useroll=0
    if n_elements(overplot) eq 0 then overplot=0
    i=sort(lr[*,ind].az)
    if useroll eq 0 then begin
            y=lr[*,ind].p
            labtype='PITCH'
    endif else begin
        y=lr[*,ind].r
        labtype='ROLL'
    endelse
    if overplot eq 0 then  begin
        plot,lr[i,ind].az,y[i],xstyle=1,ystyle=1,$
            title=labtype+' from dx,dy motion for each azswing' ,$
            xtitle='az' ,ytitle=labtype+' [deg]'
    endif else begin
        oplot,lr[i,ind].az,y[i]
    endelse
    return
end
