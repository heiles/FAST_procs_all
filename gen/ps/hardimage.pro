pro hardimage, nointerp=nointerp, landscape=landsc, $
        xsize=xinch, ysize=yinch, xoffset=xoffset, yoffset=yoffset, $
	filenm=filenm, eps=eps
;+
;NAME:
;hardimage -- copy window to postscript for 8-bit color table. 
;
;PURPOSE:
;	This procedure makes a postscript file of the image on the
;current window and gives EXACTLY what you see on your workstation
;window, including the contrast selected with (for example) XLOADCT, 
;OPTIONS, REVERSE TABLE. 
;Thus, if you see white on a black background and on your final printed
;output you want black on a white background (AND THIS IS THE RECOMMENDED
;STYLE!!! IT LOOKS BETTER AND SAVES TONER!!!), then go into XLOADCT and
;use it to reverse the color table before using HARDIMAGE. 

;CALLING SEQUENCE:
;	HARDIMAGE
;The name of the postscript file is prompted for.
;
;REQUIRED INPUTS:
;	None.
;
;
;KEYWORDS:
;
;       FILENM: the filename of the ps file. If not given, it is
;prompted for; hitting return gives default name test.ps.
;
;	NOINTERP: If undefined or zero, the byte values are scaled up to
;255. If nonzero, the byte values are left unchanged.
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
;       EPS: set for encapsulated ps. Note that once it is set, it remains
;set until explicitly un-set. Therefore, we explicitly un-set if it is not set.
;
;       OUTPUTS:
;       The only output is the postscript file.
;
;COMMON BLOCKS: 
;	Uses the IDL common block 'colors'.  The user doesn't need to
;know anything about this. 
;
;EXAMPLE:
;	First create the grey scale image in the window and make it look
;EXACTLY as you want it to look on paper. If you want the width to be
;6binches, then type HARDIMAGE, xsize=6.  
;Afterwards, check the postscript file using the UNIX command xv.  
;If it looks OK, then make the hard copy with the UNIX command lp. 
;
;HISTORY:
;	Written by Carl Heiles. Documented 13 Dec 1997. Further work 1 Oct 98.
;More revision and documentation 7 jan 00. Fixed for 24 bits 22 jan 01.
;-

;FIRST TAKE CARE OF DEFINING INPUT PARAMETERS...

;DEAL WITH LANDSCAPE...
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

if ( keyword_set( eps) ne 1) then eps=0

;----------------------------------
;DEFINE THE FILENAME...
IF (keyword_set( filenm) eq 0) then BEGIN
filenm = 'test.ps'  ; this is the default if nothing is entered...
filenm1 = ''
read, filenm1, prompt = 'enter filename; blank default is test.ps) '
if ( strtrim( filenm1, 2) ne '') then filenm = filenm1
ENDIF

;CHECK FOR PROPER ENDING...
;FIRST DO PS CASE...
if (eps eq 0) then begin
existing = strpos( filenm, '.ps', /reverse_search)
ending = strlen( filenm) - existing
if ( (ending ne 3) or (existing eq -1) )then filenm = filenm + '.ps'
endif
;NEXT DO EPS CASE...
if (eps ne 0) then begin
existing = strpos( filenm, '.eps', /reverse_search)
ending = strlen( filenm) - existing
if ( (ending ne 4) or (existing eq -1) )then filenm = filenm + '.eps'
endif  

;------------------- BEGIN 8-bit pseudocolor case -------------------------
IF ( !d.n_colors le 256) then begin

;READ THE IMAGE FROM THE WINDOW.
imgtestorig = tvrd()
;imgtest1 = imgtestorig
imgtest=imgtestorig

if ( n_elements(nointerp) eq 0) then nointerp=0
if (nointerp eq 0) then $
imgtest = byte( ((255./(float(!d.table_size)-1.)) * float(imgtestorig)) < 255.)
;print, 'nointerp = ', nointerp

;write the image to the postscript file...
;set_plot, 'ps',/copy
set_plot, 'ps' ;,/interpolate
device, filename=filenm, bits=8, landscape=landsc, /inch, /color, $
        xsize=xinch, xoff=xoffset, $
        ysize=yinch, yoff=yoffset
;print, !d.table_size
tv, imgtest
;stop
device, /close
;return to xwindows...
set_plot, 'x'
return        

ENDIF

;------------------- END 8-bit pseudocolor case -------------------------


;READ THE IMAGE FROM THE WINDOW.
;imgtestred = tvrd(channel=1)
;imgtestgreen = tvrd(channel=2)
;imgtestblue = tvrd(channel=3)

redimg = tvrd(channel=1)
grnimg = tvrd(channel=2)
bluimg = tvrd(channel=3)

;SET TO POSTSCRIPT, COPY THE IMAGE ONTO THE PS FILE...
set_plot, 'ps'  ;, /copy
device, filename=filenm, bits=8, landscape=landsc, /inch, /color, $
        xsize=xinch, xoff=xoffset, $
        ysize=yinch, yoff=yoffset

tv, [[[redimg]], [[grnimg]], [[bluimg]]], true=3 

device, /close
set_plot, 'x'
return

end


