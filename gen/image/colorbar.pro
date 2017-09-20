pro colorbar, POSITION=position, $
              CRANGE=crange, IRANGE=irange, $
              CGAMMA=cgamma, IGAMMA=igamma, $
              TOP=top, BOTTOM=bottom, $
              VERTICAL=vertical, $
              RGB=rgb, $
              LIGHTNESS, $
              _REF_EXTRA=_extra, $
              ; THIS IS PREVENT MANIPULATION OF THE ASPECT KEYWORD TO
              ; DISPLAY...
              ASPECT=aspect, $
              XRANGE=xrange, YRANGE=yrange, $ 
              XTITLE=xtitle, YTITLE=ytitle

;+
; NAME:
;       COLORBAR
;
; PURPOSE:
;       Produces either a 1D or 2D colorbar for an image.
;
; CALLING SEQUENCE:
;       COLORBAR [, POSITION=[X0,Y0,X1,Y1]][, CRANGE=[C0,C1]][,
;                IRANGE=[I0,I1]][, CGAMMA=scalar][, IGAMMA=scalar][,
;                TOP=byte scalar][, BOTTOM=byte scalar][,
;                /VERTICAL][, ASPECT=scalar][, XRANGE=[
;                RGB=256x3 array]
;
;       Accepts all DISPLAY keywords, including:
;       [, /NEGATIVE][, /NOIMAGE][, /NOSCALE][, /VERBOSE]
;       [, MIN=scalar][, MAX=scalar]
;
; INPUTS:
;       None.
;
; KEYWORD PARAMETERS:
;       /VERTICAL - If set, the colorbar will run vertically and the color
;                   axis labels and title will be placed along the Y axis;
;                   if a 2D colorbar, the intensity axis labels and title
;                   will run along the X axis.  The default is for the
;                   colorbar to be displayed horizontally such that the
;                   color axis labels and title will be placed along the X
;                   axis and, if 2D, the intensity axis labels and title
;                   will run along the Y axis.
;       POSITION = 4-element vector giving, in order, the coordinates 
;                  [(X0,Y0),(X1,Y1)], of the lower left and upper right
;                  corners of the colorbar. Coordinates are expressed in
;                  normalized units ranging from 0.0 to 1.0, unless the
;                  DEVICE keyword is present, in which case they are in
;                  actual device units.
;       BOTTOM = Set this keyword to the minimum value of the scaled byte
;                image. If BOTTOM is not specified, 0 is used.
;       TOP = Set this keyword to the maximum value of the scaled byte
;             image. If TOP is not specified, 255 is used.
;       CRANGE = the desired data range of the color axis, a 2-element
;                vector, [colormin,colormax].  The default is [BOTTOM,TOP].
;       IRANGE = the desired data range of the intensity axis, a 2-element
;                vector, [intensitymin,intensitymax].  Do not set this
;                keyword unless making a 2D colorbar.
;       CGAMMA = value of the gamma correction applied to the color table.
;                The gamma correction is a simple power law such that a
;                value of 1.0 is a linear ramp.  The default is 1.0.
;       IGAMMA = value of the gamma correction applied to the intensity.
;                Do not set this keyword unless displaying a 2D colorbar.
;                The default is 1.0, unless
;
;       All DISPLAY keywords are accepted by COLORBAR; here are some
;       useful ones:
;       /NEGATIVE - reverses the colorbar, i.e., if the color table runs
;                   from red through blue, setting /NEGATIVE will cause the
;                   color table to run from blue through red.
;       /NOIMAGE - if this keyword is set, the colorbar axes and labels are
;                  drawn but the image of the colorbar is not displayed.
;       /NOSCALE - if set, the input image will not be byte-scaled.  This
;                  allows the user to display "wrapped" images; i.e., since
;                  the input image is converted to byte type, any values
;                  outside the range [0,255] are wrapped into this range.
;
; OUTPUTS:
;       None.
;
; COMMON BLOCKS:
;       None.
;
; SIDE EFFECTS:
;       A colorbar is displayed on the current device.
;
; RESTRICTIONS:
;       The input to the RGB keyword must be a 256-by-3 array.
;
; EXAMPLES:
;       First decide where your image and color bar will reside in the
;       plot device.  Let's set the image position (in normalized
;       coordinates) to be:
;       IDL> imgpos = [0.1,0.1,0.75,0.75]
;       Now we can display an image at this position:
;       IDL> loadct, 5
;       IDL> display, dist(100,100), POSITION=imgpos
;       Next, let's make a vertical color bar to the right of the image.
;       We'll define the colorbar position using normalized coordinates:
;       IDL> cbpos = [0.8,0.1,0.9,0.75]
;       Next we use COLORBAR to display the colorbar to the right of the
;       image and since we want a vertical colorbar we set this keyword:
;       IDL> colorbar, /VERTICAL, POSITION=cbpos
;       You can see the tick marks are not very noticeable; this is because
;       the default length is 0.02.  To make the tick length match that of
;       the image, simply set:
;       YTICKLEN=0.02*(imgpos[2]-imgpos[0])/(cbpos[2]-cbpos[0])
;       Also, some folks prefer the colorbar ticks to point outward, in
;       which case you simply need to set YTICKLEN negative.
;       Now let's put a colorbar on top of the image with tickmarks
;       of the same size as the image and have them face outwards:
;       IDL> cbpos = [0.1,0.8,0.75,0.9]
;       IDL> colorbar, POSITION=cbpos, $
;       IDL> XTICKLEN=-0.02*(imgpos[3]-imgpos[1])/(cbpos[3]-cbpos[1])
;
;       To add the next level of complexity, let's now display an
;       image with a powerlaw mapping:
;       IDL> gamma = 0.33
;       IDL> 
;
;
;       Now for the most complex usage.  COLORBAR can display color
;       variations along one axis and intensity variations along the other.
;       We call this a 2-dimensional color bar or color-intensity bar and
;       the image displayed in this way is called a color-intensity image.
;       A very typical usage for this in astronomy is to map the velocity
;       field of a radio source; the color corresponds to the velocity and
;       the intensity of the image corresponds to the flux density or
;       temperature of the gas.  The details of how to create such an image
;       can be found in "One, Two, & Three Dimensional Color Images" at:
;       http://astro.berkeley.edu/~heiles/handouts/handouts_idl.html
;       If you are familiar with color-intensity images, then all that
;       you need to do to make COLORBAR work properly for such images is
;       the following two steps: (1) "loadct, 0" to establish the grayscale
;       color table; (2) send PSEUDO's colr 256-by-3 output vector to
;       COLORBAR via the RGB keyword.  In addition, the intensity range and
;       gamma for the colorbar can be controlled via the IRANGE and IGAMMA
;       keywords.  I include a painfully detailed example below because,
;       even for the initiated, creating a color-intensity image is a
;       complex undertaking.
;
;       Since the intensity axis is compressed compared to the color axis,
;       the axis labels and tickmarks are bound to be too closely spaced;
;       the tick separation can be set explicitly via X/YTICKINTERVAL.
;
;       First, let's create an intensity image; we'd like the intensity to
;       increase from left to right and we'll normalize the intensity
;       to run from zero to unity (this makes the process below a little
;       less detailed... but to learn the general, correct method, read the
;       report mentioned above):
;       IDL> intimg = transpose(findgen(101,101)/(101.^2-1))
;       Next, we'll create the color image.  Let's say we have a velocity
;       field that increases from bottom to top:
;       IDL> velocity = -230 + 0.005*findgen(101,101)       
;       We now use the PSEUDO routine to create a color table that is
;       supposedly optimal for the eye (see the report mentioned above for
;       more details):
;       IDL> pseudo, 100, 100, 100, 100, 20, 0.68, colr
;       Now we need to map our velocity field onto this color table.
;       Let's choose a minimum and maximum velocity (this is
;       something that we'll futz with to get the perfect image):
;       IDL> minvel = -222 & maxvel=-185
;       Now we bytescale the velocity field:
;       IDL> colorimg = bytscl(velocity,MIN=minvel,MAX=maxvel)
;       IDL> red_img = [[intimg*colr[colorimg, 0]]]
;       IDL> grn_img = [[intimg*colr[colorimg, 1]]]
;       IDL> blu_img = [[intimg*colr[colorimg, 2]]]
;       IDL> img = [[[red_img]], [[grn_img]], [[blu_img]]]
;       IDL> loadct, 0, /SILENT
;       IDL> imgpos = [0.1,0.1,0.75,0.75]
;       IDL> display, img, POSITION=imgpos, /NOSCALE
;       IDL> cbpos = [0.1,0.8,0.75,0.9]
;       IDL> ticklen = -0.02*(imgpos[2]-imgpos[0])/(cbpos[2]-cbpos[0])
;       IDL> colorbar, POSITION=cbpos, RGB=colr, /NOSCALE, $
;       IDL>           CRANGE=[minvel,maxvel], YTICKINTERVAL=0.5, $
;       IDL>           XTICKLEN=ticklen, YTICKLEN=-0.02, $
;       IDL>           XTITLE='Velocity [km/s]!C', YTITLE='Brightness'
;
;
;
;       Some examples on manipulating color tables.  Say you'd like
;       to draw the axes and labels of your image in green rather than the
;       default color and you'd like to add cyan annotations to your
;       image.  Let's display the image using color table 5.  We'll reserve
;       the top 2 colors of the table for cyan and green and we'll
;       stretch the 256 colors in color table #5 into the bottom 254 empty
;       spaces:
;       IDL> loadct, 5, NCOLORS=254, /SILENT
;       Now we'll load cyan and green at the top:        
;       IDL> tvlct, [0,0], [255,255], [255,0], 254
;       In our calls to DISPLAY and COLORBAR, we simply need to utilize the
;       TOP keyword to make sure that our images are scaled between 0 and
;       253 (to avoid including cyan and green in the images themselves):
;       IDL> imgpos = [0.1,0.1,0.75,0.75]
;       IDL> display, findgen(100,100), POSITION=imgpos, TOP=253
;       IDL> xyouts, 0.4, 0.4, 'I AM CYAN', COL=254, /NORM, CHARS=3, CHART=2
;       IDL> cbpos = [0.8,0.1,0.9,0.75]
;       IDL> colorbar, /VERTICAL, POSITION=cbpos, TOP=253
;
;       Unfortunately, the method above decreases the dynamic range of the
;       image.  If you can help it, you'd like to display your image
;       using all 256 available color table indices.  What you could do, if
;       using a static color table, is "loadct, 0" so that the color table
;       now occupies all 256 available indices and then display your image
;       without drawing the axes:
;       IDL> display, findgen(100,100), POSITION=imgpos, XSTYLE=4, YSTYLE=4
;       Now your image is displayed with the maximum number of colors.  Now
;       you can put as many colors as you want into the color table using
;       TVLCT and then call DISPLAY again specifying the axis and label
;       color but setting the /NOIMAGE and /NOERASE keywords to prevent the
;       image from being redrawn:
;       IDL> display, findgen(100,100), POSITION=imgpos, /NOIMAGE, /NOERASE
;       Now, if green was loaded into the top, the axes will be green. We
;       can do the same for the colorbar after reloading the table (the
;       /NOERASE is not needed for COLORBAR):
;       IDL> loadct, 5, NCOLORS=255, /SILENT
;       IDL> colorbar, /VERTICAL, POSITION=cbpos, XSTYLE=4, YSTYLE=4
;       IDL> tvlct, [0,0], [255,255], [255,0], 254
;       IDL> colorbar, /VERTICAL, POSITION=cbpos, /NOIMAGE
;
; NOTES:
;       +-------------------------------------------+
;       | This is NOT David Fanning's COLORBAR.PRO. |
;       | This is Tim Robishaw's COLORBAR.PRO.      |
;       | They are quite different.                 |
;       +-------------------------------------------+
;
;       Comment on tick marks: it's easy to have too many, especially in
;       the narrow dimension of the colorbar.  Control this using XTICKS
;       and YTICKS keywords (XTICKS=1 eliminates ticks altogether).
;       Likewise, if you want to get rid of minor tick marks, set XMINOR or
;       YMINOR to 1.
;
;       Comment on color dimensionality: if you set both CRANGE and IRANGE,
;       you will generate a 2D colorbar.  If you want only a 1D colorbar,
;       set *only* CRANGE.
;
;       For your own mental health, when creating PostScript images you
;       should work in the TrueColor visual class with color decomposition
;       off.
;
;       This is a work in progress.  Your mileage may vary.
;
;       There are still some problems here:
;       * X/YRANGE aren't quite properly dealt with.
;       * Busted for PseudoColor displays.
;
; PROCEDURES CALLED:
;       DISPLAY (Robishaw)
;
; MODIFICATION HISTORY:
;	Written by Tim Robishaw, Berkeley  17 Apr 2007
;-

resolve_routine, 'display', /NO_RECOMPILE

; if we have a gamma set, don't we want the tick labels to reflect
; this... right now the ticks are always linear!!!

; TO ADD A LIGHTNESS BOX:
; * LOOK AT CARL'S EXAMPLES
; * MAKE IT SQUARE
; * ADD GAMMA CORRECTION CURVE
; * ADD DATA AXIS
; * ADD LIGHTNESS AXIS
; * WHAT IF NEGATIVE TICKLEN IS SPECIFIED?
; * WHAT IF XTHICK/YTHICK ARE LARGE... OVERLAP OF LIGHTNESS BOX AND
;   COLORBAR

; SET DEFAULTS FOR KEYWORDS...
if (N_elements(TOP) eq 0) then top = !d.table_size-1
if (N_elements(BOTTOM) eq 0) then bottom = 0

ncolors = top - bottom + 1

if (N_elements(CRANGE) eq 0) then crange = [bottom,top]
if (N_elements(CGAMMA) eq 0) then cgamma = 1.0
if (N_elements(IGAMMA) eq 0) $
   then igamma = (N_elements(IRANGE) eq 0) ? 0.0 : 1.0

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

   ; MAKE SURE THE RGB KEYWORD IS 256-BY-3...
   rgbsz = size(RGB)
   if (rgbsz[0] ne 2) OR not(rgbsz[1] eq 256 AND rgbsz[2] eq 3) $
      then message, $
      'Keyword RGB must be set to a 256-by-3 array containing '+$
      'the (R,G,B) components of a color table.'
    
   cbar = bytscl(cbar,TOP=rgbsz[1]-1)
   
   redbar = ibar * rgb[cbar,0]
   grnbar = ibar * rgb[cbar,1]
   blubar = ibar * rgb[cbar,2]
   
   cbar = [[[redbar]],[[grnbar]],[[blubar]]]

endelse

if keyword_set(VERTICAL) then cbar = transpose(cbar)

; DON'T FORGET THE LOGIC OF THE EDGES... WHAT IF 20 COLORS...
; WHAT IF 256 COLORS OVER 100 PIXELS???

; USE DISPLAY TO REALIZE THE COLORBAR...
; USE THE EXACT POSITION THAT THE USER PASSES IN AND DON'T PLOT ANY
; AXES...

display, cbar, /NOERASE, $
         ; ADHERE TO THE SPECIFIED POSITION KEYWORD...
         POSITION=position, $
         ASPECT=0, $
         TOP=top, BOTTOM=bottom, $
         ; SUPPRESS THE DRAWING OF AXES...
         XSTYLE=4, YSTYLE=4, $
         XRANGE=xrange, YRANGE=yrange, $
         _EXTRA=_extra;, OUT=out

;stop

;!!!!!!!!
; THIS IS WHY WE NEED TO FIX X/YRANGE KEYWORD!!!
;print, xrange, yrange
;print, out.xrange, out.yrange

;stop

if not keyword_set(VERTICAL) then begin

   ; DISPLAY THE COLOR BAR HORIZONTALLY...
   if (N_elements(IRANGE) eq 0) then begin

      ; DO NOT PLOT ANY TICKMARKS OR LABELS ON THE Y AXIS...
      ; LEAVE THE TOP X AXIS OFF THE PLOT AND DO NOT PRINT
      ; ANY TICK LABELS ON THE BOTTOM X AXIS...
      plot, [0], /NODATA, /NOERASE, POSITION=position, $
            YTICKS=1, YTICKFORMAT='(A1)', YMINOR=1, $
            XSTYLE=9, XRANGE=xrange, XTICKFORMAT='(A1)', XTITLE='', $
            _EXTRA=_extra
      
   endif else begin

      ; PLOT TICKMARKS AND LABELS ON THE Y AXIS...
      ; LEAVE THE TOP X AXIS OFF THE PLOT AND DO NOT PRINT
      ; ANY TICK LABELS ON THE BOTTOM X AXIS...
      plot, [0], /NODATA, /NOERASE, POSITION=position, $
            YSTYLE=1, YRANGE=yrange, YTITLE=ytitle, $
            XSTYLE=9, XRANGE=xrange, XTICKFORMAT='(A1)', XTITLE='', $
            _EXTRA=_extra
      
   endelse

   ; ADD THE TOP X AXIS...
   axis, XAXIS=1, XSTYLE=1, XRANGE=xrange, XTITLE=xtitle, _EXTRA=_extra

endif else begin

   ; DISPLAY THE COLOR BAR VERTICALLY...
   if (N_elements(IRANGE) eq 0) then begin
      
      ; DO NOT PLOT ANY TICKMARKS OR LABELS ON THE X AXIS...
      ; LEAVE THE RIGHT Y AXIS OFF THE PLOT AND DO NOT PRINT
      ; ANY TICK LABELS ON THE LEFT Y AXIS...
      plot, [0], /NODATA, /NOERASE, POSITION=position, $
            XTICKS=1, XTICKFORMAT='(A1)', XMINOR=1, $
            YSTYLE=9, YRANGE=yrange, YTICKFORMAT='(A1)', YTITLE='',$
            _EXTRA=_extra
      
   endif else begin
      
      ; PLOT TICKMARKS AND LABELS ON THE X AXIS...
      ; LEAVE THE RIGHT Y AXIS OFF THE PLOT AND DO NOT PRINT
      ; ANY TICK LABELS ON THE LEFT Y AXIS...
      plot, [0], /NODATA, /NOERASE, POSITION=position, $
            XSTYLE=1, XRANGE=xrange, XTITLE=xtitle, $
            YSTYLE=9, YRANGE=yrange, YTICKFORMAT='(A1)', YTITLE=ytitle, $
            _EXTRA=_extra
      
   endelse
   
   ; ADD THE RIGHT Y AXIS...
   axis, YAXIS=1, YSTYLE=1, YRANGE=yrange, YTIT=ytitle, _EXTRA=_extra
   
endelse

end; colorbar

