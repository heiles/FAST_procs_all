;+
;NAME:
;stripmask - interactively make masks for strips in a map.
;SYNTAX: maskAr=stripmask(d,remavg=remavg)
;ARGS:
;   d[m,n]: float map of m samples per strips and n strips
;KEYWORDS:
;   remavg: if set then remove the median from each strip before 
;           displaying a strip. In this case you may not have to fiddle 
;           with the vertical scale on each strip.
;RETURNS:
;   maskAr[m,n]: int holds n masks of 0,1's
;
;DESCRIPTION:
;   Let the user interactively define masks for a number of strips of a
;map. For each of n strips, call bluser() and allow the user to define
;a mask array using the cursor. When all n strips have been done,
;return the maskAr.
;   If the user does not define a mask for a particular strip, then the
;mask from the previous strip will be used.
;
;   This routine calls bluser() but it is the users responsibility to
;enter the keys:
; m .. then define the mask with the cursor
; q .. to exit from bluser for each strip
;
;
;EXAMPLE:
;   Suppose you've call cormapinp and you want to create a mask that
;does not include continuum sources in the map. Use the total power in 
;polA+polB to find the continuum. Suppose there are 120 samples per 
;strip and 36 strips. The following code will call bluser 36 times. 
;
;   istat=cormapinp(lun,scan,brdA,brdB,m,cals); input the map
;   polAvg=total(m.p)/2.            ; average pola,polB
;   ver, -.001,.015                 ; vertical scale for plot
;   maskArr=stripmasks(polAvg,/remavg)
;   .. maskArr will now be dimensioned maskArr[120,36]
;SEE ALSO:
;   bluser()
;-
function stripmask,d,remavg=remavg
;
; get size of map
;
    a=size(d)
    case  a[0] of 
        1: begin
            nstrips=1
            lenstrip=a[1]
           end
        2: begin
            nstrips=a[2]
            lenstrip=a[1]
           end
        else: message,'stripmask array dimension should be 1 or 2d'
    endcase
    maskArr=intarr(lenstrip,nstrips)
    mask=intarr(lenstrip)
    x=findgen(lenstrip)
    for i=0,nstrips-1 do begin
        y=d[*,i]
        print,'strip: ',i,' (count from 0)'
        if keyword_set(remavg) then y=y-median(y)
        istat=bluser(x,y,coef,mask)
        maskArr[*,i]=mask
    endfor
    return,maskArr
end
