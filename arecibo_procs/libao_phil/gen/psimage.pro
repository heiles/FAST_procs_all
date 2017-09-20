;+
;NAME:
;psimage - prepare to send image output to a postscript file.
;SYNTAX: psimage,filename,xlen=xlen,ylen=ylen,xoff=xoff,yoff=yoff,$
;                landscape=landscape,xroff=xroff,yroff=yroff
;ARGS: 
;   filename: string filename to write to. default is idl.ps
;   xlen    : float  number of inches for xdimension. default
;                  is 7 inches.
;   ylen    : float  number of inches for ydimension. default
;                  is 9 inches.
;   xoff    : float offset in inches for the left edge of image.
;                   the default is to center the plot.
;   yoff    : float offset in inches for the bottom edge of image.
;                   the default is to center the plot.
;   xroff   : float relative offset x direction in inches. add to xoff.
;   yroff   : float relative offset y direction in inches. add to yoff.
;                   the default is to center the plot.
;  landscape: if set then plot in landscape mode.
;DESCRIPTION:
;   Set the output plot device to a postscript file. Add keywords for
;image display (8 bits per pixel). Try and center the imageon the 
;page. Landscape mode causes problems when offsets are used. See
;imgdisp for how to get around it.
;SEE ALSO:
;ps,hardcopy,x,imgdisp
;-
pro psimage, filename,xlen=xlen,ylen=ylen,xoff=xoff,yoff=yoff,$
        landscape=landscape,xroff=xroff,yroff=yroff
;
; setup for ps image ..
set_plot, 'ps',/copy
if (n_params() gt 0) then begin
  device, file=filename
endif
;
maxlen  =11.
minlen  =8.5
deflenmax=9.
deflenmin=7.
;
; portrait mode
;

if not keyword_set(landscape) then landscape=0
;
;   if portrait mode ..
;
if not keyword_set(landscape) then begin
    if not keyword_set(xlen) then xlen=deflenmin
    if not keyword_set(ylen) then ylen=deflenmax
    if not keyword_set(xoff) then xoff=(minlen-xlen)/2.
    if keyword_set(xroff) then xoff=xoff+xroff
    if not keyword_set(yoff) then yoff=(maxlen-ylen)/2.
    if keyword_set(yroff) then yoff=yoff+yroff
endif  else begin
    if not keyword_set(xlen) then xlen=deflenmax
    if not keyword_set(ylen) then ylen=deflenmin
;
;   postscript does offsets before rotation to landscape..
;
    if n_elements(xoff) eq 0 then xoff=(maxlen-xlen)/2. 
    if keyword_set(xroff)    then xoff=xoff+xroff
    if n_elements(yoff) eq 0 then yoff=(minlen-ylen)/2. 
    if keyword_set(yroff)    then yoff=yoff+yroff
    if (xoff ne 0) or (yoff ne 0) then begin
        temp=xoff
        xoff=yoff
        yoff=maxlen-temp
        print,'rotating'
    endif
endelse
device,/color,/inches,bits_per_pixel=8,xoffset=xoff,yoffset=yoff,$
    xsize=xlen,ysize=ylen,landscape=landscape
return
end
