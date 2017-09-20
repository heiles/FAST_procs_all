pro corloopinit,luntouse,xdim,ydim
common corloop,lun,str
;
on_error,1
if (n_elements(xdim) eq 0) then xdim=640
if (n_elements(ydim) eq 0) then ydim=510
window,3,xsize=xdim,ysize=ydim
window,4,/pixmap,xsize=xdim,ysize=ydim
device,set_graphics=3
str={xdim: xdim,ydim:ydim,win:3,pixwin:4}
lun=luntouse
return
end
