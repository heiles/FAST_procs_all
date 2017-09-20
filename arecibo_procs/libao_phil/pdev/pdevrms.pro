;+
;NAME:
;pdevrms -  compute rms by channel
;SYNTAX: brms=pdevrms(b,nodiv=nodiv,median=median)
;ARGS:
;    b[n]: {}  data from pdevget()
;KEYWORDS: 
;   median:    if set then don't normalize each channel to mean/median value
;    nodiv:    if set then don't normalize each channel to mean/median value
;  nocross:    if set then don't bother to process cross spectra
;RETURNS:
;    brms: {]  pdev data structure with rms instead of spectra
;DESCRIPTIION:
;   Compute standard deviation/mean by channel.
;
;-
function pdevrms,b,nodiv=nodiv,median=median,nocross=nocross
;
;
;
    nsbc=b[0].nsbc
    nchan=b[0].nchan
    nrecs=n_elements(b)
    if (nsbc eq 4) and (keyword_set(nocross)) then begin
        nsbc=2
        brms={$
        nsbc  : (b[0].nsbc <2) ,$
        nchan : b[0].nchan,$
        beam  : b[0].beam     ,$ beam 0..6
     subband  : b[0].subband  ,$ 0 low,1 high
     chanWidth: b[0].chanWidth,$ channel width Mhz
       integTm: b[0].integTm  ,$ actual integration, not wall time.
        h     : b[0].h        ,$
        d     : fltarr(b[0].nchan,b[0].nsbc <2)}
        
    endif else begin 
        brms=b[0]
    endelse
    for i=0,nsbc-1 do begin
        if i lt 2 then begin
            brms.d[*,i]=rmsbychan(b.d[*,i],nodiv=nodiv,median=median)
        endif else begin
            if i eq 2 then begin
                b12=(total(b.d[*,0],2) + total(b.d[*,1],2))/(2.*nrecs)
            endif
            brms.d[*,i]=rmsbychan(b.d[*,i],nodiv=1,median=median)
            brms.d[*,i]/=b12
        endelse
    endfor
    return,brms
end
