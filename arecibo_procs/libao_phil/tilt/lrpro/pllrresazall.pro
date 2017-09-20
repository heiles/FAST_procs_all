pro plLrResAzAll,lr,lrfit,useroll
;
; plot res fits for all az swings
    overplot=0
    a=size(lr)
    if  a[0] eq 1 then last=0 else last=a[2]-1
    for i=0,last do begin
        plLrResAz,lr,lrfit,i,useroll,overplot
        overplot=1
    endfor
    return
end
