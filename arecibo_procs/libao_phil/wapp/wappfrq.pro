;+
;NAME:
;wappfrq - return freq array for wapp data.
;SYNTAX: frq=wappfrq(h,decrease=decrease)
;ARGS:
; hdr:  {}  wapp header
;RETURNS:
;   frq[n]: float freq array for the wapp data.
; decrease: int  0 data in increasing freq order,
;                1 data in decreasing freq order
;
;DESCRIPTION:
;   Return the frequency array for the wapp data. It will have the
;same number of channels as the data. It will be in increasing or
;decreasing frequency order depending on the data (it does not
;assume that the data has already been put in increasing freq order).
;
;-
function wappfrq,h,decrease=decrease
;     
;
;   some constants that belong in an include file
;
; if alfa, look at rf, first lo, to determine the flip
;
    if (h.isalfa) then begin
        flip=((h[0].syn1 * 1e-6 ) gt h[0].cent_freq)? -1. : 1.
        flip=(h[0].bandwidth ge 99.)? flip : -1.*flip
    endif else begin
        flip=(h.freqinversion eq 1)? -1.:1.
        flip=(h.iflo_flip[0])? -flip :flip
    endelse
    fstep=h.bandwidth/(h.num_lags*1.) 
    cen_chan=h.num_lags/2               ; index center chan .. 0 based.
    if (flip lt 0.) then begin
        fstep=-fstep
        cen_chan=h.num_lags/2 -1               ; index center chan .. 0 based.
    endif
    return,(lindgen(h.num_lags) - cen_chan)*fstep + h.cent_freq
end
