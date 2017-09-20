;---------------------------------------------------
pro plLrPRAzA,lr,useroll
;
; plot pitch,roll vs az all swings
;
    overplot=0
    a=size(lr)
    if  a[0] eq 1 then last=0 else last=a[2]-1
    for i=0,last do begin
        pllrpraz,lr,i,useroll,overplot
        overplot=1
    endfor
    return
end
