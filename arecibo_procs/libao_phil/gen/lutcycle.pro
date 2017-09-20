;+
;NAME:
;lutcycle - cycle through all the idl luts..
;SYNTAX: lutcycle,delay
;ARGS:
;   delay:  int/float. secs to wait between each step.
;DESCRIPTION:
;   Cycle through all of the lookup tables supplied by idl.
;EXAMPLE:
;   display an image.
;   imgdisp,dat
;   lutcycle,5      ; cycle through 40 luts waiting 5 seconds at each 1.
;-
pro lutcycle,delay
    if n_params() eq 0 then delay=.3
    for i=0,40 do begin
        print,'loading lut #',i
        loadct,i
        wait,delay
    endfor
    loadct,0
    return
end
