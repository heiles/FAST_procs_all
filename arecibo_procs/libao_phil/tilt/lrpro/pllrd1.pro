;---------------------------------------------------
pro plLrD1,lr,ind,over,nolab
;
;   plot data dy vs dx for 1 az spin
;
    if (n_elements(over) eq 0) then   over=0
    if (n_elements(nolab) eq 0) then nolab=0
    hor,-2.5,3.5
    ver,-1,5
    if over eq 0 then begin
        plot,lr[*,ind].dx,lr[*,ind].dy,xstyle=1,ystyle=1, $
            xtitle="dx inches (west<->east)",$
            ytitle="dy inches (south<->north)", $
            title='az swing horizontal platform motion'
    endif else begin
        oplot,lr[*,ind].dx,lr[*,ind].dy
    endelse
    label=string(format= '("za=",i2)',fix(lr[5,ind].za+.5))
    print,nolab
    if nolab eq 0 then begin
        note,3,label
        if (ind mod 2 ) eq 0 then begin
             label=string(format='("AZ : ",i3)',fix(lr[0,ind].az))
            xyouts,lr[0,ind].dx, lr[0,ind].dy,label
        endif else begin
            label=string(format='("AZ : ",i3)',fix(lr[14,ind].az))
            xyouts,lr[14,ind].dx, lr[14,ind].dy,label
        endelse
    endif
    return
end
