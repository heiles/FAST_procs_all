pro colorbar, POSITION=position, $
              CRANGE=crange, IRANGE=irange, $
              CGAMMA=cgamma, IGAMMA=igamma, $
              TOP=top, BOTTOM=bottom, NEGATIVE=negative, $
              VERTICAL=vertical, $
              ;LIGHTNESS=lightness, 
              ; don't want user to manipulate!
              ; or do we?  and what would happen if sent to display?
;              ASPECT=aspect, $ ; right?
              XTITLE=xtitle, YTITLE=ytitle, $ 
              RGB=rgb, $
              _REF_EXTRA=extra

;+ NAME: COLORBAR. make a colorbar for an image 
;
;*************************** NOTICE  ********************************************
;*                                                                              *
;*                                                                              *
;*      This is ROBISHAW's colorbar. Not Fanning's colorbar. They differ.       *
;*                                                                              *
;*For an illustration of use, see                                               *
;*                                                                              *
;*  'IACIDL: IMAGE ANNOTATION AND COLORBARS IN IDL'                              *
;*                                                                              *
;*  http://astro.berkeley.edu/~heiles/handouts/handouts_images.html                *
;*  (click on 'annotated_images.ps')                                            *
;*                                                                              *
;*                                                                              *
;**** WORK IN PROGRESS; DOCUMENTATION MAY WELL BE WRONG!!!!!!!!                 *
;*                                                                              *
;*                                                                              *
;********************************************************************************

;This will do either a 1-d or a 2-d colorbar. 

;For 2-d, The 'color' (CRANGE) goes lengthwise along the colorbar. 
;  and    The 'intensity' (IRANGE) goes shortwise across the colorbar. 
;For 1-d, you want to inhibit the 'intensity', which you do by not
;setting IRANGE.
;
;EXAMPLE OF USE:
;
;COLORBAR, POSITION={.79,.15,.85,.88}, locations of corners (norm coord)
;        CRANGE={0,.08}	 DATA numbers spanning color range. 
;	IRANGE={0,1}  DATA numbers spanning intensity range. make numbers about
;		unity to avoid crowding on axis label. DON'T SET FOR 1-d. 
;	CGAMMA=cgamma, IGAMMA=igamma gamma values for color and intensity (1.0)
;       /VERTICAL, This determines the locations of axis labels. Set if
;               colortable runs vertically. If set, (intensity,color) labels are
;               on (bottom, right). 
;        Default is =horizontal; labels are on (left, top)
;	/vertical implies colorbar on rhs of image and
;		vertical=0 implies colorbar on top of image.
;	RGB= colr, the [256,3] colortable being used
;	XTITLE=xtitle, YTITLE=ytitle ; x, y titles for colorbar
;	TOP=top, BOTTOM=bottom	top and bottom nrs of colortable (0,255 usual) 
;		applies in both directions.
;		smaller numbers make a pixellated looking colorbar.
;       NEGATIVE=negative set to reverse colorbar direction
;
;_REF_EXTRA KEYWORDS:
;	COLOR=255* (ps eq 0),   set color in psopen call
;	FONT=ps-1,              set font in psopen call
;	format='(f5.2)',        FORMAT TO WRITE COLORBAR NUMBERS (doesn't seem to work)
;        charsize=charsize, 	SIZE OF CHARACTERS IN COLORBAR
;	xthick=3, ythick=3	THICKNESSES
;
;COMMENT ON TICK MARKS
;	it's easy to have too many, particularly in the narrow direction of the colorbar.
;		define how many: xticks=4, yticks=2. setting xticks=1 eliminates tick marks.
;	also, you probably don't want minor tick marks. eliminate with xminor=1, yminor=1
;
;COMMENT ON COLOR DIMENSIONALITY
;	this will do a 2d colorbar if you set both crange and irange. 
;	to do a 1d colorbar, set ONLY crange.
;
;HISTORY
; 24 apr 06, carl changed default igamma from 0 to 1 for 2d colorbar case
;		(if irange is defined);
;	default is 0 if iranage is not defined (1d colorbar case)
; 14 nov 06, carl added negative keyword and prettified the
; documentation. also changed name to colorbar to differentiate from fanning's.
;-
 
;!!!!!!!!!!!!!!!
; NEED TO TAKE THE !D SUBSCRIPTS INTO ACCOUNT FOR THE XTITLE!!!

resolve_routine, 'display', /NO_RECOMPILE

;if N_elements(XTITLE) eq 0 then xtitle = 'temporary x'
;if N_elements(YTITLE) eq 0 then ytitle = 'temporary y'

; if we have a gamma set, don't we want the tick labels to reflect
; this... right now the ticks are always linear!!!

; DOES THE DEVICE SUPPORT WINDOWS...
;windows  = (!d.flags AND 256) ne 0

; A WINDOW NEEDS TO HAVE BEEN CREATED TO ESTABLISH THE VISUAL TYPE...
;if windows AND (!d.window lt 0) then begin
;  window, /FREE, /PIXMAP
;  wdelete, !d.window
;endif

if (N_elements(TOP) eq 0) then top = !d.table_size-1
if (N_elements(BOTTOM) eq 0) then bottom = 0

ncolors = top - bottom + 1

if (N_elements(CRANGE) eq 0) then crange = [bottom,top]
if (N_elements(CGAMMA) eq 0) then cgamma = 1.0

;if (N_elements(IGAMMA) eq 0) then igamma = 1.0 $
;  else if (N_elements(IRANGE) eq 0) then irange = [0,1]

if n_elements( igamma) eq 0 then begin
	if n_elements( irange) eq 0 then igamma = 0.0 else igamma=1.0
endif

if keyword_set(VERTICAL) then begin
    xrange = (N_elements(IRANGE) eq 0) ? [0,1] : irange
    yrange = crange
endif else begin
    xrange = crange
    yrange = (N_elements(IRANGE) eq 0) ? [0,1] : irange
endelse

intensity = (dindgen(ncolors)/(ncolors-1))^igamma
color = (dindgen(ncolors)/(ncolors-1))^cgamma

ibar = intensity ## (fltarr(ncolors)+1)
cbar = color # (fltarr(ncolors)+1)

if not keyword_set(RGB) then begin

    cbar = ibar * cbar

endif else begin

    ;!!!!!!
    ; THIS SHOULD BE MORE ROBUST...
    ; what if rgb -> [3,256]
    ; what if it has 6 dimensions??
    rgbsz = (size(RGB))[1]
    cbar = bytscl(cbar,TOP=rgbsz-1)

    redbar = ibar * rgb[cbar,0]
    grnbar = ibar * rgb[cbar,1]
    blubar = ibar * rgb[cbar,2]

    cbar = [[[redbar]],[[grnbar]],[[blubar]]]

endelse

;stop

if keyword_set(VERTICAL) then cbar = transpose(cbar)

; DON'T FORGET THE LOGIC OF THE EDGES... WHAT IF 20 COLORS...
; WHAT IF 256 COLORS OVER 100 PIXELS???

; USE DISPLAY TO REALIZE THE COLORBAR...
; USE THE EXACT POSITION THAT THE USER PASSES IN AND DON'T PLOT ANY
; AXES...

display, cbar, /NOERASE, POSITION=position, ASPECT=0, $
;tr_display, cbar, /NOERASE, POSITION=position, ASPECT=0, $
         TOP=top, BOTTOM=bottom, $
         XSTYLE=4, YSTYLE=4, XRANGE=xrange, YRANGE=yrange, $
         _EXTRA=extra, negative=negative  ;;;;;, OUT=out

;stop

;!!!!!!!!
; THIS IS WHY WE NEED TO FIX X/YRANGE KEYWORD!!!
;print, xrange, yrange
;print, out.xrange, out.yrange

;stop

if not keyword_set(VERTICAL) then begin

    if (N_elements(IRANGE) eq 0) then begin
        
        plot, [0], /NODATA, /NOERASE, POSITION=position, $
              YTICKS=1, YTICKFORMAT='(A1)', YMINOR=1, $
              XSTYLE=9, XRANGE=xrange, XTICKFORMAT='(A1)', XTITLE='', $
              _EXTRA=extra
    
    endif else begin

        plot, [0], /NODATA, /NOERASE, POSITION=position, $
              YSTYLE=1, YRANGE=yrange, YTITLE=ytitle, $
              XSTYLE=9, XRANGE=xrange, XTICKFORMAT='(A1)', XTITLE='', $
              _EXTRA=extra

    endelse

    axis, XAXIS=1, XSTYLE=1, XRANGE=xrange, XTITLE=xtitle, _EXTRA=extra

endif else begin

    if (N_elements(IRANGE) eq 0) then begin

        plot, [0], /NODATA, /NOERASE, POSITION=position, $
              XTICKS=1, XTICKFORMAT='(A1)', XMINOR=1, $
              YSTYLE=9, YRANGE=yrange, YTICKFORMAT='(A1)', YTITLE='',$
              _EXTRA=extra
    
    endif else begin

        plot, [0], /NODATA, /NOERASE, POSITION=position, $
              XSTYLE=1, XRANGE=xrange, XTITLE=xtitle, $
              YSTYLE=9, YRANGE=yrange, YTICKFORMAT='(A1)', YTITLE=ytitle, $
              _EXTRA=extra

    endelse

    axis, YAXIS=1, YSTYLE=1, YRANGE=yrange, YTIT=ytitle, _EXTRA=extra

endelse

end; colorbar

