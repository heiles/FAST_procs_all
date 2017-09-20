;
; get header info for all headers in the directory.
;
function x111getimg,imghdr,dir=dir,disp=disp,_extra=e
;
    if n_elements(dir) eq 0 then dir='/proj/x111/cor/img/nov30'
    gotit=0
    lun=-1
    on_ioerror,done
    fname=dir+'/'+imghdr.name+'.img'
    openr,lun,fname,/get_lun
    img=fltarr(imghdr.nx,imghdr.ny,/nozero)
    readu,lun,img
    gotit=1
done:
    if lun gt 0 then free_lun,lun
    if not gotit then begin
        img=''
    endif else begin
        if keyword_set(disp) then begin
            retimg=x111dispimg(img,imghdr,_extra=e)
        endif
    endelse
    return,img
end
