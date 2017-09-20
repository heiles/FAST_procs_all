pro img_cbar_posns, w_left, w_rght, w_bot, w_top, space, width, $
        imgposn, cbarposn, f_hor, f_ver, vertical=vertical, $
        colorbaryes=colorbaryes

;+
;NAME: IMG_CBAR_POSNS -- calculate position vectors for img, cbar 
;given desired spcings.
;
;CALLING SEQUENCE:
;img_cbar_posns, w_left, w_rght, w_bot, w_top, space, width, $
;        imgposn, cbarposn, f_hor, f_ver
;
;INPUTS: ALL INPUTS IN UNITS OF IMAGE SIZE and DO NOT INCLUDE LABELS. 
;If inputs are undefined they are set to defaults as indicated.
;        w_left, width of left margin (0.1)
;        w_rght, width of right margin (0.05)
;        w_bot, width of bottom margin (0.12)
;        w_top, width of top margin (above colorbar) (0.1)
;        space, spacing between top of image and bottom of colorbar (0.1)
;        width, width of colorbar (0.1)
;
;KEYWORD
;   VERTICAL, set if colorbar should be vertical on rhs of
;       image. Default is horizontal top.
;   COLORBARYES, forces defaults to assume a horizontal colorbar.
;        No need to set this unless space and width are undefined 
;        and, also, you want a colorbar with default values of 
;        space and width.
;OUTPUTS: 
;       IMGPOSN, the 4-element vector for image corner positions,
;       normalized coordinatese
;       CBARPOSN, the 4-element vector for colorbar corner positions,
;       normalized coordinates
;F_HOR, the horizontal window size in units of the horizontal image size
;F_VER, the vertical window size in units of the vertical image size
;
;EXAMPLE
;        You are making an image IMG with a colorbar. To do so, you first 
;TV the image, specifying the lower left coordinates and the image
;size in normalized coordinates. Then you label the image with the
;PLOT command. Then you TV the colorbar using tim's COLORBAR command.
;
;        The TV, PLOT, and COLORBAR command need position information. 
;Here's how you specify them. (ps is 0 for X, 1 for PS):
;
;IMG_CBAR_POSNS, 0.1, 0.05, 0.12, 0.1, 0.1, 0.1, 
;        imgposn, cbarposn, f_hor, f_ver
;
;TV, img, imgposn[0], imgposn[1], xsize=1./f_hor, ysize=1./f_ver
;
;PLOT, [0], pos=imgposn, /xsty, /ysty, /norm, /noerase, /nodata, font=ps-1, $
;        xtit= 'RA', ytit='Dec', tit='408 MHz -- Haslam', $
;        xra=[24,0]
;
;COLORBAR, pos= cbarposn, $
;        crange=[maxi, 14.], gamma=0.55, xrange=[-40,40], yrange=[200,400],$
;        xtit='Brightness Temp, Kelvins', font=ps-1 
;-

if n_elements( w_left) eq 0 then w_left=0.1
if n_elements( w_rght) eq 0 then w_rght=0.05
if n_elements( w_bot) eq 0 then w_bot=0.12
if n_elements( w_top) eq 0 then w_top=0.05

if keyword_set( colorbaryes) then begin
   if n_elements( space) eq 0 then space=0.03       ;default is no colorbar
   if n_elements( width) eq 0 then width=0.1      ;default is no colorbar
endif else begin
if n_elements( space) eq 0 then space=0.0       ;default is no colorbar
if n_elements( width) eq 0 then width=0.0       ;default is no colorbar
endelse

if keyword_set( vertical) then goto, vertical

;ALL SIZES ARE IN UNITS OF THE IMAGE SIZE
f_hor=1.+ w_left+ w_rght
f_ver= 1.+ w_bot+ w_top+ space+ width

;DEFINE IMAGE CORNERS IN NORMALIZED COORDINATES...
ximg_00= w_left/f_hor
yimg_00= w_bot/f_ver
ximg_11= ximg_00+ 1./f_hor
yimg_11= yimg_00+ 1./f_ver

;DEFINE COLORBAR COORDINATES IN NORMALIZED COORDINATES...
xcbar_00= ximg_00
ycbar_00= yimg_11+ space/f_ver
xcbar_11= ximg_11
ycbar_11= ycbar_00+ width/f_ver

imgposn= [ximg_00, yimg_00, ximg_11, yimg_11]
cbarposn= [xcbar_00, ycbar_00, xcbar_11, ycbar_11]

return

VERTICAL:

;ALL SIZES ARE IN UNITS OF THE IMAGE SIZE
f_hor=1.+ w_left+ w_rght+ space+ width
f_ver= 1.+ w_bot+ w_top

;DEFINE IMAGE CORNERS IN NORMALIZED COORDINATES...
ximg_00= w_left/f_hor
yimg_00= w_bot/f_ver
ximg_11= ximg_00+ 1./f_hor
yimg_11= yimg_00+ 1./f_ver

;DEFINE COLORBAR COORDINATES IN NORMALIZED COORDINATES...
xcbar_00= ximg_11+ space/f_hor
ycbar_00= yimg_00
xcbar_11= xcbar_00+ width/f_hor
ycbar_11= yimg_11

imgposn= [ximg_00, yimg_00, ximg_11, yimg_11]
cbarposn= [xcbar_00, ycbar_00, xcbar_11, ycbar_11]

return

end
