;------------------------------------------------------------------------------
; mapbase - base  a single bmapazctp map
function mapbase,map,pntsToUse
;
; SYNTAX:
;     basemap=mapbase(map,pntsToUse)
; ARGS:
;      map[smpPerStrip,numStrips] - input map .. float
;      pntsToUse : number points start/end of strip to use for baselining 
; returns:
;       map - with baseline subtracted
;
    a=size(map)
    smpPerStrip=a[1]
    numStrips  =a[2]
    if (n_elements(pntsToUse) eq 0) then pntToUse=1
;
;   average pntsToUse pnts at start/end of each strip (edgel,edger)
;   linear fit edgel,edger seperately
;   for each strip then remove linear baseline using the left, right
;   fitted value for each strip.
;
    edgel=total(map[0:pntsToUse-1,*],1)/pntsToUse 
    edger=total(map[smpPerStrip-pntsToUse:smpPerStrip-1,*],1)/pntsToUse
    x=findgen(numStrips)
;
    a=linfit(x,edgel)
    al=a[0] + a[1]*x
    a=linfit(x,edger)
    ar=a[0] + a[1]*x
    x=findgen(smpPerStrip)      ; get x 0..n-1 for 1 strip 
    b = (ar-al)/(smpPerStrip-1.)
;
;   loop over each strip
;
    bmap=fltarr(smpPerStrip,numStrips,/nozero)
    for i=0,numStrips-1 do begin
        bmap[*,i]=temporary(map[*,i]-(al[i]+b[i]*x))
    endfor
    return,bmap
end
