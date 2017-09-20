pro hardimage24, landscape=landsc, $
        xsize=xinch, ysize=yinch, xoffset=xoffset, yoffset=yoffset
;+
;NAME:
;HARDIMAGE24 -- copy window to ps for 24 bit color

;PURPOSE:
;	THIS IS THE 24 BIT VERSION.
;	This procedure makes a postscript file of the image on the
;current window and gives EXACTLY what you see on your workstation
;window.
;
;CALLING SEQUENCE:
;	HARDIMAGE24
;
;REQUIRED INPUTS:
;	none
;
;KEYWORDS:
;
;       LANDSCAPE: The default is to produce a 'portrait' plot. If
;you set landscape, it will produce a 'landscape' plot.
;
;       XSIZE: The width of the printed plot in the X direction. See
;note under YSIZE. The default is 7 inch in portrait, 9.5 inch in landscape.
;
;       YSIZE: The width of the printed plotin the Y direction. The
;default is 9.5 inch in portrait, 7.0 in landscape.
;NOTE: IN ALL CASES THE ASPECT RATIO OF THE PLOT WILL BE PRESERVED.
;Thus, either XSIZE or YSIZE will determine the maximum size of the plot,
;depending on which is smaller.
;
;       XOFFSET: The x offset. See code for defaults.
;       YOFFSET: The y offset. See code for defaults. Be careful if
;you specify this...you need to know how it is defined!
;
;OUTPUTS:
;	The postscript file, whose name is prompted for.

;EXAMPLE:
;	First create the 24-bit color image in the window and make it look
;EXACTLY as you want it to look on paper.  Then type HARDIMAGE24.  Then
;check the postscript file using the UNIX command xv.  If it looks OK,
;then make the hard copy with the UNIX command lp. 

;HISTORY:
;	Written by Carl Heiles. Origin is hardimage. 14 Oct 1999
;	mofified and documented 8jan 00
;-

common colors, r_orig, g_orig, b_orig, r_curr, g_curr, b_curr
if (n_elements(r_curr) ne 0) then begin
rorig = r_orig
gorig = g_orig
borig = b_orig
rcurr = r_curr
gcurr = g_curr
bcurr = b_curr
endif

loadct,0,/silent

;FIRST TAKE CARE OF DEFINING INPUT PARAMETERS...
if not keyword_set(landsc) then landsc=0

if (landsc eq 0) then begin
if not keyword_set(xinch) then xinch=7.0
if not keyword_set(yinch) then yinch=9.5
endif else begin
if not keyword_set(xinch) then xinch=9.5
if not keyword_set(yinch) then yinch=7.0
endelse

if not keyword_set(xoffset) then begin
if (landsc eq 0) then begin
        xoffset = 0.5*(8.5 - xinch)
endif else begin
        xoffset = 0.5*(8.5 - yinch)
endelse
endif  

if not keyword_set(yoffset) then begin
if (landsc eq 0) then begin
        yoffset = 0.5*(11.0 - yinch)
endif else begin
        yoffset = 0.5*(11.0 - xinch) + xinch
endelse
endif    

;READ THE IMAGE FROM THE WINDOW.
imgtestred = tvrd(channel=1)
imgtestgreen = tvrd(channel=2)
imgtestblue = tvrd(channel=3)

;SCALE THE IMAGE ACCORDING TO THE CURRENT COLOR TABLE.
;redimg = r_curr[imgtestred]
;grnimg = g_curr[imgtestgreen]
;bluimg = b_curr[imgtestblue]
redimg = imgtestred
grnimg = imgtestgreen
bluimg = imgtestblue

;PROMPT FOR THE OUTPUT FILE NAME
filenm = 'test1.ps'
read, filenm, prompt='enter desired postscript file name (e.g. image1.ps): '
print, 'Filename will be... ', filenm

;SET TO POSTSCRIPT, COPY THE IMAGE ONTO THE PS FILE...
set_plot, 'ps'  ;, /copy
device, filename=filenm, bits=8, landscape=landsc, /inch, /color, $
        xsize=xinch, xoff=xoffset, $
        ysize=yinch, yoff=yoffset

;if (xinches ne 0.) then device, filename=filenm, bits=8, xsize=xinches, $
;	xoff=0.2, ysize=yinches, yoff=.2+yoffset,/inch, /portrait, /color
;if (xinches eq 0.) then device, filename=filenm, bits=8

tv, [[[redimg]], [[grnimg]], [[bluimg]]], true=3 ;$
;        ybotm, xtvleft, ysize=xplotsize, xsize=yplotsize, /normal

;stop

;CLOSE THE PS FILE AND GET BACK TO WINDOWS...
device, /close

if (n_elements(r_curr) ne 0) then begin
r_orig = rorig
g_orig = gorig
b_orig = borig
r_curr = rcurr
g_curr = gcurr
b_curr = bcurr
endif

set_plot, 'x'
;stop
return
end
