;+
;NAME:
;imgflaty - flatten an image in the y direction
;SYNTAX: result=imgflaty(data,x1,x2)
;ARGS:   
;    data [m,n]   data to operate on
;    x1   int     index col average start (count from 0)
;    x2   int     index col average end   (count from 0)
;DESCRIPTION:
;    The data array d[m,n] has  m xpoints by n ypoints.
; average columns located at x1 thru x2 to give  a[n].
; expand a to be a[m,n] by duplicating the columns
; retun data/a
;-
function imgflaty,data,x1,x2

    a=size(data)
    if  (a[0] ne 2) or (x1 lt 0) or (x2 gt (a[1]-1)) or (x1 gt x2) then begin
        message,'data must be 2d, x1<=x2, and x1,x2 between 0..xmax'
    endif
    b=total(data[x1:x2,*],1)/(x2-x1+1.)
;;  b= (fltarr(a[1])+1.) # b
    return,data/((fltarr(a[1])+1.) # b)
end
