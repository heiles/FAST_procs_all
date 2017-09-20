pro tr_profiles, image, ORDER=order, AXIS=axis, $
                 SX=sx, SY=sy, $
                 WSIZE=wsize, $
                 XSIZE=xsize, YSIZE=YSIZE, $
                 XPOS=xpos, YPOS=ypos, $
                 PSYM=psym, SSIZE=ssize, COLOR=color, $
                 CCOLOR=ccolor, CLENGTH=clength, CCLIP=cclip, $
                 SILENT=silent

;+
; NAME:
;	TR_PROFILES
;
; PURPOSE:
;	Interactively draw row or column profiles of an image in a separate
;	window.
;
; CATEGORY:
;	Image analysis.
;
; CALLING SEQUENCE:
;	TR_PROFILES, Image [, SX = sx, SY = sy] [, /AXIS] [, ORDER=order]
;        [, WSIZE=wsize | , XSIZE=xsize, YSIZE=ysize] 
;        [, XPOS=xpos, YPOS=ypos ]
;        [, PSYM=psym] [, SSIZE=ssize] [, COLOR=color] 
;        [, CCOLOR=ccolor] [, CLENGTH=clength] [, /CCLIP] [, /SILENT]
;
; INPUTS:
;	Image:	The variable that represents the image displayed in current
;		window.  This data need not be scaled into bytes.
;		The profile graphs are made from this array.
;
; KEYWORD PARAMETERS:
;       ORDER:	Set this keyword param to 1 for images written top down or
;		0 for bottom up.  Default is the current value of !ORDER.
;
;       /AXIS:  Set this keyword if the image intensities are to be plotted 
;               against axis value rather the pixel number.  The image
;               must be bordered by an axis for this to work properly.
;
;	SX:	Starting X position (in device coordinates) of the
;               image in the window.  The default value is 0.
;
;	SY:	Starting Y position (in device coordinates) of the
;               image in the window.  The default value is 0.
;
;       WSIZE:	The size of the PROFILES window as a fraction or multiple
;		of 640 by 512.
;
;       XSIZE:  The width of the profiles window in pixels.
;
;       YSIZE:  The height of the profiles window in pixels.
;
;       XPOS: The horizontal position of the window in pixels.
;
;       YPOS: The vertical position of the window in pixels.
;
;       PSYM:   The plotting symbol used to plot the profile.
;
;       SSIZE:  The symbol size of the plot symbols.
;
;       COLOR:  The color of the plot symbols.
;
;       CCOLOR: The color of the cross marking the cursor position.
;
;       CLENGTH: The length of the cross marking the cursor position,
;                expressed as a fraction of the window size.  Default
;                size is 0.1.  A value of >1.0 produces a cursor that
;                extends to each axis.
;
;       /CCLIP: Set this keyword to force cursor-position cross to be
;               clipped at the axes.  Especially useful when setting
;               CLENGTH to a value > 1.
;
;      /SILENT: No instructions are printed to the IDL window.
;
; OUTPUTS:
;	No explicit outputs.
;
; COMMON BLOCKS:
;	None.
;
; SIDE EFFECTS:
;	A new window and two new pixmap windows are created and used
;	for the profiles.  When done, the new windows are deleted and
;	the system variables !p, !x, and !y are restored for the image
;	window.
;
; RESTRICTIONS:
;	None.
;
; PROCEDURE:
;	A new window is created and the mouse location in the original
;	window is used to plot profiles in the new window.  Pressing the
;	left mouse button toggles between row and column profiles.
;	The right mouse button exits.
;
; EXAMPLE:
;	Create and display an image and use the PROFILES routine on it.
;	Create and display the image by entering:
;
;		A = BYTSCL(DIST(256))
;		TV, A
;
;	Run the TR_PROFILES routine by entering:
;
;		TR_PROFILES, A
;
;	The profiles window should appear.  Move the cursor over the original
;	image to see the profile at the cursor position.  Press the left mouse
;	button to toggle between row and column profiles.  Press the right
;	mouse button (with the cursor over the original image) to exit the
;	routine.
;
;
;       Take advantage of new bells and whistles.  Display an image
;       and surround it with axes...
;       IDL> loadct, 5
;       IDL> image = findgen(250,250)
;       IDL> tv, bytscl(image), 101, 101
;       IDL> plot, [0], POSITION=[100,100,351,351], /DEVICE, /NOERASE
;
;       Make sure it's backwards compatible! Does it work like it used to?
;       IDL> tr_profiles, image, sx=101, sy=101
;
;       Now add some new keywords; make the data blue and the cross red: 
;       IDL> device, DECOMPOSED=0
;       IDL> tr_profiles, image, sx=101, sy=101, COLOR=48, CCOLOR=110
;
;       Now add the /AXIS keyword to plot the profiles against axis values 
;       rather than pixel number, and make the PROFILES window larger:
;       IDL> tr_profiles, image, sx=101, sy=101, /AXIS, XSIZE=500, YSIZE=500
;
;       Now plot the data as small diamonds; also, make the cross fill the 
;       entire axis range and clip the cross at the axes:
;       IDL> tr_profiles, image, sx=101, sy=101, /AXIS, XS=500, YS=500, $
;       IDL> COLOR=48, PSYM=4, SSIZE=0.1, CCOLOR=110, CLENGTH=1.5, /CCLIP
;
; NOTES:
;       The IDL routine PROFILES has been rewritten to reflect 16 years of 
;       IDL development, and a little cleverness.  
;
;       Here is what has been changed:
;       (1) Rather than redrawing the plot every time the cursor is moved,
;       a pixmap is created to store a template of the axes, then the 
;       template is dumped to another pixmap in which the plot data are 
;       drawn; finally, this pixmap is dumped into the display window.
;       This allows for a smooth animation of the profiles.
;       This also prevents the gradual erasing of your axes and labels
;       by the cursor-position cross that was a "feature" of the 
;       previous PROFILES.
;       (2) The axis styles are chosen more intelligently to not waste
;       space and to leave a little buffer between the axes and data.
;       (3) Unlike the previous version, does not turn the cursor off after 
;       the profile window is closed.  I never understood this behavior!
;       (4) Restores the !p, !x, and !y system variables for the image 
;       window upon exiting; the previous version lost this information.
;
;       Here is what has been added:
;       (1) The axes are labelled to minimize the amount of user thought.
;       (2) Added XSIZE and YSIZE keywords for manually setting the
;       width and height (in pixels) of the PROFILES window.
;       (2) Added the PSYM, SSIZE, and COLOR keywords to allow the profile 
;       data to be plotted with the user's choice of symbol, size and 
;       color, respectively.
;       (3) Added the CCOLOR keyword to allow the cursor-position cross
;       to have a different color than the data, making it easier to see.
;       (4) Added the CLENGTH keyword to allow the user to change the
;       size of the cursor-position cross.  A value > 1.0 will cause
;       the cross to extend to each axis.
;       (5) Added the /CCLIP keyword to prevent the cursor-position
;       cross from extending beyond the axes; useful when CLENGTH>1.
;       (6) Added the /AXIS keyword.  When set, rather than plotting
;       the profile as a function of row number or column number, the
;       profile is plotted as a function of the row or column values.
;       The image must be bounded by axes for this option to produce
;       meaningful results.
;
;       All the changes and additions leave PROFILES backwards compatible
;       such that any routines that called PROFILES will not need to be
;       changed and the performance of the routine will not be changed!
;
; MODIFICATION HISTORY:
;	DMS, Nov, 1988.
;       16 Mar 2004  Complete overhaul. Tim Robishaw, Berkeley
;       09 Jun 2004  If /AXIS is set, use the lower left corner of
;                    the axes instead of setting SX and SY. T. Robishaw
;       22 Oct 2006  Added /SILENT keyword and XPOS/YPOS keywords. T.R.
;	01 Nov 2006  Fixed pixel spacing; don't exit until user
;                    lets go of the right button in case this routine is
;                    called inside a loop; middle button now prints out
;                    the cursor position. T. Robishaw  
;       12 Nov 2006  Nothing printed on middle click if outside the plot
;                    axes. Now printing out the image value on middle
;                    click.
;       05 Dec 2006  Checks for left click before mouse movement.
;-

COMPILE_OPT strictarr
on_error,2                      ; RETURN TO CALLER IF AN ERROR OCCURS

; WHAT IS THE WINDOW NUMBER OF THE IMAGE WINDOW...
orig_w = !d.window

; SAVE THE ORIGINAL !P, !X, !Y STRUCTURES...
sysv_in = {p:!p,x:!x,y:!y}

; TAKE CARE OF SETTING KEYWORD DEFAULTS...
if (N_elements(WSIZE) eq 0) then wsize = .75
if (N_elements(XSIZE) eq 0) then xsize = wsize*640
if (N_elements(YSIZE) eq 0) then ysize = wsize*512
if (N_elements(ORDER) eq 0) then order = !order
if (N_elements(COLOR) eq 0) then color = !p.color
if (N_elements(PSYM) eq 0) then psym=0
if (N_elements(SSIZE) eq 0) then ssize=1.0
if (N_elements(CCOLOR) eq 0) then ccolor = !p.color
if (N_elements(CLENGTH) eq 0) then clength=0.1

; SET THE POSITION OF THE LOWER LEFT CORNER OF THE IMAGE...
if not keyword_set(AXIS) then begin
    x0 = ( (N_elements(SX) eq 0) ? 0L : long(sx) ) + 1
    y0 = ( (N_elements(SY) eq 0) ? 0L : long(sy) ) + 1
endif else begin
    x0 = !x.window[0] * !d.x_vsize + 1
    y0 = !y.window[0] * !d.y_vsize + 1
endelse

; DETERMINE THE SIZE OF THE IMAGE...
sz = size(image)
nx = sz[1]                      ; COLS IN IMAGE
ny = sz[2]                      ; ROWS IN IMAGE

; DETERMINE THE XRANGE AND YRANGE OF IMAGE AND THE INTENSITY RANGE...
xcrange = keyword_set(AXIS) ? !x.crange : [0,nx-1]
ycrange = keyword_set(AXIS) ? !y.crange : [0,ny-1]
maxv = max(image,min=minv,/NAN) ; GET EXTREMA
imgrange = [minv,maxv]

; WHAT ARE THE DATA VALUES AT EACH PIXEL...
xpix = (xcrange[1]-xcrange[0])*(findgen(nx)+1)/(nx+1) + xcrange[0]
ypix = (ycrange[1]-ycrange[0])*(findgen(ny)+1)/(ny+1) + ycrange[0]

; TELL USER HOW TO USE...
if not keyword_set(SILENT) then begin
   message,'Left mouse button to toggle between rows and columns.', /INFO
   message,'Middle mouse button to print the cursor position.', /INFO
   message,'Right mouse button to Exit.', /INFO
endif

; CREATE AXIS TEMPLATE PIXMAP...
window, /FREE, XSIZE=xsize, YSIZE=ysize, /PIXMAP
template_w = !d.window

; CREATE PIXMAP THAT SERVES AS CANVAS FOR PROFILES...
window, /FREE, XSIZE=xsize, YSIZE=ysize, /PIXMAP
pix_w = !d.window

; MAKE NEW WINDOW...
window, /FREE, XSIZE=xsize, YSIZE=ysize, XPOS=xpos, YPOS=ypos, TITLE='Profiles'
new_w = !d.window

; THE MODE WILL BE SET TO 0 WHEN DISPLAYING ROW PROFILES AND 1 WHEN
; DISPLAYING COLUMN PROFILES; START OUT DISPLAYING ROWS...
old_mode = 1B
mode = 0B

while 1 do begin

   ; SET THE IMAGE WINDOW...
   wset, orig_w                
   
   ; READ THE POSITION...
   cursor, xdev, ydev, /CHANGE, /DEVICE 
   
   ; IF RIGHT BUTTON IS CLICKED, THEN DELETE WINDOWS AND QUIT...
   if (!mouse.button eq 4) then begin 
      ; DELETE ALL THE WINDOWS...
      wdelete, new_w, template_w, pix_w
      ; SET THE WINDOW TO THE ORIGINAL IMAGE WINDOW...
      wset,orig_w
      ; RESTORE THE ORIGINAL SYSTEM VARIABLE STRUCTURES...
      !p = sysv_in.p & !x = sysv_in.x & !y = sysv_in.y
      ; WAIT FOR THE USER TO LET GO OF THE BUTTON...
      repeat cursor, xdev, ydev, /NOWAIT, /DEVICE until (!mouse.button eq 0)
      return                  ; SPLIT
   endif
   
   ; DID WE CLICK THE LEFT MOUSE BUTTON...
   if (!mouse.button eq 1) then begin
      mode = 1B-mode          ; TOGGLE MODE
      ; WAIT FOR THE USER TO LET GO OF THE BUTTON...
      repeat cursor, xdev, ydev, /NOWAIT, /DEVICE until (!mouse.button eq 0)
   endif

   ; REMOVE BIAS...
   xdev = long(xdev - x0)
   ydev = long(ydev - y0)

   ; ARE WE SWITCHING MODES...
   if (mode ne old_mode) OR $
      (mode eq 1B and old_mode eq 1B AND N_elements(crossx) eq 0) then begin

      old_mode = mode

      ; PLOT THE AXES TO THE TEMPLATE PIXMAP...
      wset, template_w
      if mode then begin	; COLUMN PROFILES
         plot, [0], /NODATA, FONT=0, $
               XRANGE=imgrange, YRANGE=ycrange, $
               XSTYLE=3, YSTYLE=3, $
               XTITLE='Data', YTITLE='Row', TITLE='Column Profile'
         
         vecy = ypix
         crossx = clength*[-1,1]*(maxv-minv)
         crossy = clength*[-1,1]*(ycrange[1]-ycrange[0])

      end else begin          ; ROW PROFILES
         plot, [0], /NODATA, FONT=0, $
               XRANGE=xcrange, YRANGE=imgrange, $
               XSTYLE=3, YSTYLE=3, $
               XTITLE='Column', YTITLE='Data', TITLE='Row Profile'
         vecx = xpix
         crossx = clength*[-1,1]*(xcrange[1]-xcrange[0])
         crossy = clength*[-1,1]*(maxv-minv)
      endelse

      ; DETERMINE THE DATA COORDINATES OF THE AXIS POSITIONS...
      clip = (convert_coord(!x.window,!y.window,/NORM,/TO_DATA))[[0,1,3,4]]
   endif

   ; ONLY UPDATE THE PLOT IF THE CURSOR IS INSIDE THE PLOT WINDOW...
   if (xdev ge nx) OR (xdev lt 0) OR (ydev ge ny) OR (ydev lt 0) $
      then continue

   ; IF MIDDLE BUTTON IS CLICKED, PRINT OUT RESULTS...
   if (!mouse.button eq 2) then begin
      outstr = 'Pix: ('+string(xdev,FORMAT='(I4)')+', '+$
               string(ydev,FORMAT='(I4)')+')'
      if keyword_set(AXIS) then $
         outstr = outstr + ' | Pos: ('+strtrim(xpix[xdev],2)+$
                  ', '+strtrim(ypix[ydev],2)+')'
      outstr = outstr + ' | Image: '+strtrim(image[xdev,ydev],2)
      print, outstr
      ; WAIT FOR THE USER TO LET GO OF THE BUTTON...
      repeat cursor, xhold, yhold, /NOWAIT until (!mouse.button eq 0)
   endif

   ; DRAW THE PLOT...
   if order then ydev = (ny-1)-ydev ; INVERT Y?
   ixy = image[xdev,ydev]      ; Data value
   if mode then begin          ; COLUMN PROFILES?
      vecx = image[xdev,*]	; GET COLUMN
      ; DETERMINE THE CURSOR-POSITION CROSS ENDPOINTS...
      verx = crossx + ixy
      very = ypix[[ydev,ydev]]
      horx = [ixy, ixy]
      hory = crossy + ypix[ydev]
   endif else begin            ; ROW PROFILES?
      vecy = image[*,ydev]	; GET ROW
      ; DETERMINE THE CURSOR-POSITION CROSS ENDPOINTS...
      verx = xpix[[xdev,xdev]]
      very = crossy + ixy
      horx = crossx + xpix[xdev]
      hory = [ixy,ixy]
   endelse

   ; DUMP THE TEMPLATE PIXMAP INTO THE CANVAS PIXMAP...
   wset, pix_w
   device, copy=[0,0,!d.x_vsize,!d.y_vsize,0,0,template_w]

   ; PLOT THE DATA PROFILE AND THE CURSOR-POSITION CROSS...
   plots, vecx, vecy, PSYM=psym, SYMSIZE=ssize, COLOR=color
   plots, horx, hory, COLOR=ccolor, CLIP=clip, NOCLIP=(1-keyword_set(CCLIP))
   plots, verx, very, COLOR=ccolor, CLIP=clip, NOCLIP=(1-keyword_set(CCLIP))

   ; PRINT THE PIXEL LOCATION ON THE PLOT...
   xyouts, 0.10, 0, /NORMAL, FONT=0, $
           strtrim(xdev,2)+"  "+strtrim(ydev,2)
   if keyword_set(AXIS) then $
      xyouts, 0.50, 0, /NORMAL, FONT=0, $
              strtrim(xpix[xdev],2)+"  "+strtrim(ypix[ydev],2)

   ; DUMP THE CANVAS PIXMAP INTO THE PROFILES WINDOW...
   wset, new_w
   device, copy=[0,0,!d.x_vsize,!d.y_vsize,0,0,pix_w]

endwhile
end; tr_profiles
