;---------------------------------------------------
pro plLrResAz,lr,lrfit,ind,useroll,overplot
;
; pllrresaz .. plot residuals for each az spin,
;
    forward_function lrCmpRes
    if n_elements(ind)     eq 0 then ind    =0
    if n_elements(useroll) eq 0 then useroll=0
    if n_elements(overplot) eq 0 then overplot=0
    if useroll eq 0 then labtype='PITCH' else labtype='ROLL'
    y=lrCmpRes(lr,lrfit,ind,useroll)
    i=sort(lr[*,ind].az)
    if (overplot) then begin
        oplot,lr[i,ind].az,y[i]
    endif else begin
        plot,lr[i,ind].az,y[i],title=labtype+' residuals fit',xstyle=1,ystyle=1
    endelse
    return
end
