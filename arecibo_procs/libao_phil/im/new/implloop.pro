;---------------------------------------------------------------------------
;implloop,d{imday},delaySecs  - loop plotting array with delay
;---------------------------------------------------------------------------
pro implloop,d,delay
; d     {imday} data to plot
; delay  secs   to wait
;
    for i=0,d.nrecs-1 do begin
        if ((d.cfrq eq -1.) or (d.cfrq eq d.r[i].h.cfrDataMhz)) then begin
            implot,d.r[i]
            if delay gt 0 then wait,delay
        endif
    endfor
    return
end
