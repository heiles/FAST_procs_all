pro openplotps, nbits=nbits, landscape=landsc, $
	xsize=xinch, ysize=yinch, xoffset=xoffset, yoffset=yoffset, $
	filenm=filenm, eps=eps
;+
;NAME: 
;	OPENPLOTPS
;
;PURPOSE:
;	This procedure opens a postscript file for plotting.
;It prompts for the name of the output file.  Unless specified otherwise,
;the postscript interchanges black/white so that plots are dark lines on 
;a white background. You can specify the size and whether to make the
;output image include just black/white or also grey. 
;
;	If NBITS=1, then any nonzero pixel is given the value 255. Thus, 
;if you have a graph with several colors, they all come out looking the 
;same.
;
;CALLING SEQUENCE:
;	OPENPLOTPS
;The name of the postscript file is prompted for.
;
;REQUIRED INPUTS: 
;	None.
;
;KEYWORDS:
;	FILENM: the filename of the ps file. If not given, it is
;prompted for.
;	NBITS: The number of bits used to to write the postscript file. 
;For a strictly black/white graph use NBITS=1 to save disk space; this
;is the default. If there is shading, then use NBIT=8.
;
;	LANDSCAPE: The default is to produce a 'portrait' plot. If
;you set landscape, it will produce a 'landscape' plot.
;
;	XSIZE: The width of the printed plot in the X direction. See 
;note under YSIZE. The default is 7 inch in portrait, 9.5 inch in landscape.
;
;	YSIZE: The width of the printed plotin the Y direction. The
;default is 9.5 inch in portrait, 7.0 in landscape.
;
;	XOFFSET: The x offset. See code for defaults.
;	YOFFSET: The y offset. See code for defaults. Be careful if
;you specify this...you need to know how it is defined!
;
;	EPS: set for encapsulated ps. Note that once it is set, it remains
;set until explicitly un-set. Therefore, we explicitly un-set if it is not set.

;RESTRICTIONS:
;	If the colors common block has not been loaded, this loads it
;with color table 0. 
;
;	You must use CLOSEPS to close the ps device and return to X windows
;after invoking this procedure.
;	
;OUTPUTS: 
;	The only output is the postscript file. It needs to be closed
;with CLOSEPS
;
;EXAMPLE:
;	You want to generate a plot 8 inches wide and 4 inches tall in
;landscape mode, so type...OPENPLOTPS, XSIZE=8, YSIZE=4, /LANDSCAPE
;Be sure to use CLOSEPS after you're done.
;
;MODICATION HISTORY:
;	Written by Carl Heiles.  7 jan 2000.
;	keyword FILENM added 27 sep00
;-

;common colors, r_orig, g_orig, b_orig, r_curr, g_curr, b_curr

;FIRST TAKE CARE OF DEFINING INPUT PARAMETERS...
if not keyword_set(nbits) then nbits=1
;if not keyword_set(noreverse) then noreverse=0
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

if (nbits gt 8) then nbits=8

;DEFINE THE FILENAME...
IF (keyword_set( filenm) eq 0) then BEGIN
filenm = 'test1.ps'  ; this is just a simple way to define it as a string...
read, filenm, prompt = 'enter filename (e.g. test.ps) '
print, 'Filename will be...', filenm
ENDIF

;GENERATE THE PS PARAMETERS...
set_plot, 'ps'  ;,/copy

if (nbits eq 1) then begin
	device, filename=filenm, bits=nbits, landscape=landsc, /inch, $
        xsize=xinch, xoff=xoffset, $
        ysize=yinch, yoff=yoffset, encapsulated=eps
endif else begin
	device, filename=filenm, bits=nbits, landscape=landsc, /inch, $
        xsize=xinch, xoff=xoffset, $
        ysize=yinch, yoff=yoffset, /color, encapsulated=eps
endelse

;if (n_elements(r_orig) ne 0) then loadct, 0

;stop
return
end
