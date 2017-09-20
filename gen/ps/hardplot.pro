pro hardplot, nbits=nbits, noreverse=noreverse, landscape=landsc, $
	xsize=xinch, ysize=yinch, xoffset=xoffset, yoffset=yoffset, $
	filenm=filenm, eps=eps
;+
;NAME: 
;HARDPLOT -- copy graph on current window to ps, 8 bit colortable
;
;PURPOSE:
;	This procedure makes a postscript file of what is displayed on
;the current window. 
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
;	HARDPLOT
;The name of the postscript file is prompted for.
;
;REQUIRED INPUTS: 
;	None.
;
;KEYWORDS:
;       FILENM: the filename of the ps file. If not given, it is
;prompted for; hitting return gives default name test.ps.
;
;	NBITS: The number of bits used to to write the postscript file. 
;For a strictly black/white graph use NBITS=1 to save disk space; this
;is the default. If there is shading, then use NBITS=8. For 24 bit 
;color, NBITS is always 8, set internally.
;
;	NOREVERSE: Normally the colors are interchanged, with the 
;black X-windows background becoming white on the postscript plot and
;the white X-window lines becoming black. This saves our toner!!
;If Noreverse is specified
;as nonzero, then the colors are NOT reversed. This is usually not
;recommended--it uses lots of toner and makes bad-looking plots.
;
;	LANDSCAPE: The default is to produce a 'portrait' plot. If
;you set landscape, it will produce a 'landscape' plot.
;
;	XSIZE: The width of the printed plot in the X direction. See 
;note under YSIZE. The default is 7 inch in portrait, 9.5 inch in landscape.
;
;	YSIZE: The width of the printed plotin the Y direction. The
;default is 9.5 inch in portrait, 7.0 in landscape.
;NOTE: IN ALL CASES THE ASPECT RATIO OF THE PLOT WILL BE PRESERVED.
;Thus, either XSIZE or YSIZE will determine the maximum size of the plot,
;depending on which is smaller.
;
;	XOFFSET: The x offset. See code for defaults.
;	YOFFSET: The y offset. See code for defaults. Be careful if
;you specify this...you need to know how it is defined!
;
;       EPS: set for encapsulated ps. Note that once it is set, it remains
;set until explicitly un-set. Therefore, we explicitly un-set if it is not set.
;
;	OUTPUTS: 
;	The only output is the postscript file.
;
;	EXAMPLE:
;	After the plot is the way you want it, and you want the width 
;to be 6 inches, type...HARDPLOT, XSIZE=8
;
;	MODICATION HISTORY:
;	Written by Carl Heiles. Modified and redocumented 1 Sep 1998.
;	Modified and redocumented 7 jan 2000.
;-

;;SAVE THE CURRENT COLOR TABLE:
;common colors, r_orig, g_orig, b_orig, r_curr, g_curr, b_curr
;if (n_elements(r_orig) ne 0) then begin
;r0=r_orig
;g0=g_orig
;b0=b_orig
;r1=r_curr
;g1=g_curr
;b1=b_curr
;endif

;FIRST TAKE CARE OF DEFINING INPUT PARAMETERS...
if not keyword_set(nbits) then nbits=1
;if ( !d.n_colors gt 256) then nbits=8
if not keyword_set(noreverse) then noreverse=0
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
 
;;EXCLUDED 24 NOV 00...
;if (!d.table_size lt 255) then $
; 	imgtest = byte( (float(imgtest1)*255./!d.table_size) < 255.5 > 0.)

if (nbits eq 1) then begin
indx=where(imgtest ne 0)
imgtest[indx]=255b
endif

jmgtest = imgtest
;do the b-w inversion if desired...
if (noreverse eq 0) then jmgtest = not(jmgtest)

;stop

;write the image to the postscript file...
;set_plot, 'ps',/copy
set_plot, 'ps' ;,/interpolate
device, filename=filenm, bits=8, landscape=landsc, /inch, /color, $
        xsize=xinch, xoff=xoffset, $
        ysize=yinch, yoff=yoffset
;print, !d.table_size
;tv, imgtest
tv, jmgtest
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

print, 'noreverse= ', noreverse, ' and nbits= ', nbits
IF (noreverse eq 0) then begin
;indxw = where( redimg eq 255 and grnimg eq 255 and bluimg eq 255, countw)
indxw = where( redimg ne 0 or grnimg ne 0 or bluimg ne 0, countw)
indxb = where( redimg eq 0 and grnimg eq 0 and bluimg eq 0, countb)

if (countw ne 0) then begin
	redimg[ indxw] = 0 & grnimg[ indxw] = 0 & bluimg[ indxw] = 0
endif

if (countb ne 0) then begin
	redimg[ indxb] = 255 & grnimg[ indxb] = 255 & bluimg[ indxb] = 255
endif
;print, countw, countb
ENDIF

tv, [[[redimg]], [[grnimg]], [[bluimg]]], true=3
 
device, /close
set_plot, 'x'
return

end

;write the image to the postscript file...
set_plot, 'ps',/copy
device, filename=filenm, bits=nbits, landscape=landsc, /inch, $
	xsize=xinch, xoff=xoffset, $
	ysize=yinch, yoff=yoffset
;print, !d.table_size
tv, jmgtest
;stop
device, /close

;return to xwindows...
set_plot, 'x'

;stop
;RESTORE THE ORIGINAL COLOR TABLE...
if (n_elements(r0) ne 0) then begin
r_orig=r0
g_orig=g0
b_orig=b0
r_curr=r1
g_curr=g1
b_curr=b1
endif

;stop

return
end
