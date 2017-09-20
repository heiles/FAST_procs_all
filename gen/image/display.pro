;============================================================

function display_getpos, aspect, XSIZE=xsize, YSIZE=ysize, $
                         NORESIZE=noresize, VERBOSE=verbose

; This function determines the proper position for the axes in the current
; device.  If the user supplies an aspect ratio, this is honored.  If the
; user sets the /NORESIZE keyword, the displayed image will have the same
; size as the input image.

compile_opt idl2, hidden

; IF THE USER DOESN'T ASK FOR INFORMATION, THEN DON'T PROVIDE ANY...
verb = (N_elements(VERBOSE) eq 0) ? 0b : byte(verbose)

; GET THE CURRENT DEVICE COORDINATES OF THE AXES...
dev_xrange = round(!x.window*!d.x_vsize)
dev_yrange = round(!y.window*!d.y_vsize)
;dev_xrange = !x.window*!d.x_vsize
;dev_yrange = !y.window*!d.y_vsize
;dev_xrange = [ceil(dev_xrange[0]),floor(dev_xrange[1])]
;dev_yrange = [ceil(dev_yrange[0]),floor(dev_yrange[1])]

if ((verb and 2b) ne 0) then begin
   print, !x.window, !y.window
   print, !x.window*!d.x_vsize, !y.window*!d.y_vsize
   print, dev_xrange
   print, dev_yrange
endif

; THE IMAGE WILL BE DISPLAYED WITHIN THESE AXES...
; MOST DISPLAY ROUTINES PLACE THE AXES *ON TOP* OF THE DISPLAYED IMAGE.  I
; CHOOSE NOT TO DO THIS (THIS ONLY WORKS FOR AN AXIS THICKNESS OF 1)...
; GET THE NUMBER OF PIXELS BETWEEN THE AXES, NOT INCLUDING THE AXES...
dev_xsize_now = (dev_xrange[1]-1) - (dev_xrange[0]+1) + 1
dev_ysize_now = (dev_yrange[1]-1) - (dev_yrange[0]+1) + 1

; IF THE USER WANTS THE IMAGE RESIZED, THEN SET THE WIDTH AND HEIGHT
; OF THE IMAGE TO THE SPACE BETWEEN THE CURRENTLY ESTABLISHED AXES...
if not keyword_set(NORESIZE) then begin
    xsize = dev_xsize_now
    ysize = dev_ysize_now
endif

; DETERMINE THE NEW IMAGE SIZE BASED ON THE ASPECT RATIO...
aspect_now = double(xsize)/ysize

;stop

; IF THE ASPECT HAS BEEN SET TO ZERO, THEN WE FILL THE SPACE
; BETWEEN THE CURRENTLY ESTABLISHED AXES...
if (aspect ne 0) AND (aspect ne aspect_now) then begin

    ; IF THE NEW ASPECT RATIO IS GREATER THAN THE CURRENT ASPECT
    ; RATIO, THEN THE XSIZE IS ANCHORED TO THE CURRENT XSIZE AND THE
    ; YSIZE IS ADJUSTED TO MATCH THE NEW ASPECT RATIO AS NEARLY AS
    ; POSSIBLE...
    if (aspect gt aspect_now) $
      then ysize = round(xsize / aspect) $
      else xsize = round(ysize * aspect)

endif

if ((verb and 2b) ne 0) then begin

   print, 'Location of dummy X axes in pixels: ', dev_xrange, FORM='(A45,2I6)'
   print, 'Location of dummy Y axes in pixels: ', dev_yrange, FORM='(A45,2I6)'
   print, 'Size of dummy region between axes in pixels: ', dev_xsize_now, dev_ysize_now, FORM='(A45,2I6)'
   print, 'Size of input image in pixels: ', xsize, ysize, FORM='(A45,2I6)'
   print, 'Aspect ratio of image: ', aspect, FORM='(A45,F7.3)'

;   help, n='*aspect*'
;   help, n='*xsize*'
;   help, n='*ysize*'
endif

; IF EITHER THE NEW HEIGHT OR WIDTH IS LESS THAN 2 PIXELS,
; THEN THE ASPECT RATIO IS RIDICULOUS...
if (xsize lt 2) then $
  message, 'The ASPECT RATIO (width/height) is ridiculously small.'
if (ysize lt 2) then $
  message, 'The ASPECT RATIO (width/height) is ridiculously large.'

;!!!!!!!!!!
; IS THE ASPECT RATIO NOW CORRECT HERE???
;help, aspect, double(xsize)/ysize

;stop
;help, dev_xrange[0], dev_xrange[0] + 0.5*(dev_xsize_now-xsize)

; CENTER THE IMAGE IN THE WINDOW...
dev_xrange[0] = round(dev_xrange[0] + 0.5*(dev_xsize_now-xsize))
dev_yrange[0] = round(dev_yrange[0] + 0.5*(dev_ysize_now-ysize))

;stop

return, [dev_xrange[0],$        ; POSITION OF LEFT AXIS
         dev_yrange[0],$        ; POSITION OF BOTTOM AXIS
         dev_xrange[0] + xsize + 1,$ ; POSITION OF RIGHT AXIS
         dev_yrange[0] + ysize + 1]  ; POSITION OF TOP AXIS

end; display_getpos

;============================================================

function display_imgresize, image, nx, ny, xsize, ysize

; This function resizes an input image to the specified dimensions.
; It uses the IDL routine POLY_2D to shrink or expand the input image.

compile_opt idl2, hidden


;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
; THERE IS NO INTERPOLATE KEYWORD!!!
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

;interpolate=1

xfactor = double(nx)/xsize
yfactor = double(ny)/ysize

;stop

if not keyword_set(INTERPOLATE) then begin

    p = [[0.5*(xfactor-1)*(xfactor gt 1),0],[xfactor,0]]
    q = [[0.5*(yfactor-1)*(yfactor gt 1),yfactor],[0,0]]

    return, poly_2d(image,p,q,0,xsize,ysize)

endif

;!!!!!!!!!!!!
; ARE WE SURE THERE'S NOT A XSIZE-1 MISSING ANYWHERE???

xi = xfactor * (dindgen(xsize) + 0.5) - 0.5
yi = yfactor * (dindgen(ysize) + 0.5) - 0.5

;stop
return, interpolate(image, xi, yi, /GRID)

end; display_imgresize

;============================================================

function display_imgscl, image, MIN=mn, MAX=mx, $
                         BOTTOM=btm, TOP=top, NEGATIVE=negative

; This function byte-scales the input image.  It should be noted that the
; /NAN keyword is always set in our call to BYTSCL().

compile_opt idl2, hidden

if (N_elements(mn) eq 0) then mn = min(image,/NAN)
if (N_elements(mx) eq 0) then mx = max(image,/NAN)
if (N_elements(btm) eq 0) then btm = 0L
if (N_elements(top) eq 0) then top = !d.table_size-1L

byte_image = bytscl(image,MIN=mn,MAX=mx,TOP=byte(top-btm),/NAN)

if not keyword_set(NEGATIVE) then return, byte_image + byte(btm)

return, byte(top - byte_image + btm)

end; display_imgscl

;============================================================

pro display, image_in, $
             x, y, $
             MIN=minval_in, MAX=maxval_in, $
             ASPECT=aspect_in, $
             VERBOSE=verbose, $
             NODISPLAY=nodisplay, $
             NOIMAGE=noimage, $
             NORESIZE=noresize, $
             NOSCALE=noscale, $
             BOTTOM=bottom_in, $
             TOP=top_in, $
             NEGATIVE=negative, $
             OUT=out, $
             ; PLOT KEYWORDS THAT WE NEED TO MANIPULATE...
             COLOR=color, $
             POSITION=position, $
             DEVICE=device, $
             NORMAL=normal, $
             XSTYLE=xstyle_in, $
             YSTYLE=ystyle_in, $
             TITLE=title, $
             SUBTITLE=subtitle, $
             TICKLEN=ticklen, $
             XTICKLEN=xticklen_in, $
             YTICKLEN=yticklen_in, $
             ; TV KEYWORDS THAT WE NEED TO MANIPULATE...
             XSIZE=xsize_in, $
             YSIZE=ysize_in, $
             TRUE=true, $
             CHANNEL=channel, $
             ORDER=order, $
             ; COLOR_QUAN KEYWORDS THAT WE NEED TO MANIPULATE...
             TRANSLATION=translation, $
             ; PLOT, TV, COLOR_QUAN() KEYWORDS PASSED BY REFERENCE...
             _REF_EXTRA = extra
;+
; NAME:
;       DISPLAY
;
; PURPOSE:
;       Displays an image properly scaled, gridded, and centered in current
;       device.
;
; CALLING SEQUENCE:
;        DISPLAY, Image_In [, X, Y] [,
;             MIN=scalar][, MAX=scalar][,
;             ASPECT=scalar][,
;             VERBOSE=byte scalar][,
;             /NODISPLAY][,
;             /NOIMAGE][,
;             /NORESIZE][,
;             /NOSCALE][,
;             BOTTOM=scalar][,
;             TOP=scalar][,
;             /NEGATIVE][,
;             OUT=variable][,
;             COLOR=scalar][,
;             POSITION=[X0,Y0,X1,Y1]][,
;             /DEVICE][,
;             /NORMAL][,
;             {X|Y}STYLE=scalar][,
;             TITLE=string scalar][,
;             SUBTITLE=string scalar][,
;             TICKLEN=scalar][,
;             {X|Y}TICKLEN=scalar][,
;             TRUE={1|2|3}][,
;             CHANNEL={0|1|2|3}][,
;             ORDER={0|1}][,
;             TRANSLATION=vector]

;        Graphics keywords: Accepts all graphics keywords accepted by TV,
;        PLOT, and COLOR_QUAN.
;
; INPUTS:

;       IMAGE_IN - A two- or three-dimensional array to be displayed; if
;                  3-dimensional, then the input is a TrueColor image and
;                  one of the dimensions must have a size of exactly 3
;                  (e.g., a band-interleaved TrueColor image has dimensions
;                  (NX,NY,3)).
;
; OPTIONAL INPUTS:
;
;       X - A vector representing the abscissa values to be plotted.  X
;           must contain the same number of elements as the horizontal
;           dimension of IMAGE_IN. It is assumed that X is a monotonic and
;           linear vector.
;
;       Y - A vector representing the ordinate values to be plotted. Y must
;           contain the same number of elements as the vertical dimension
;           of IMAGE_IN. It is assumed that Y is a monotonic and linear
;           vector.
;
; KEYWORD PARAMETERS:
;
;       MIN = Set this keyword to the minimum value of IMAGE_IN to be
;             considered. If MIN is not provided, IMAGE_IN is searched for
;             its minimum value. All values less than or equal to MIN are
;             set equal to 0 in the result.
;       MAX = Set this keyword to the maximum value of IMAGE_IN to be
;             considered. If MAX is not provided, IMAGE_IN is searched for
;             its maximum value. All values greater or equal to MAX are set
;             equal to TOP in the result.
;       ASPECT = the ratio of the width to the height of the displayed
;                image.  If set to zero, the displayed image will be
;                resized to aspect ratio of the plotting device.  If not
;                set at all, the aspect ratio will be determined by the
;                extent of the X and Y vectors if passed in; otherwise it
;                will be set to the size of IMAGE_IN.
;       VERBOSE = prints out some possibly useful information 
;       /NODISPLAY - if set, the image is not displayed and the axes are
;                    not drawn, but the axes are established so that their
;                    parameters are now available via the !x & !y system
;                    variables.
;       /NOIMAGE - if set, the image is not displayed, but the axes are
;                  drawn.
;       /NORESIZE - if set, the input image is not resized; an image of
;                   size NX by NY will be displayed on the current device
;                   using NX * NY pixels.  It should be noted that the
;                   PostScript device uses scalable pixels; this keyword
;                   should not be set for PostScript images.
;       /NOSCALE - if set, the input image will not be byte-scaled.  This
;                  allows the user to display "wrapped" images; i.e., since
;                  the input image is converted to byte type, any values
;                  outside the range [0,255] are wrapped into this range.
;       BOTTOM = Set this keyword to the minimum value of the scaled byte
;                image. If BOTTOM is not specified, 0 is used.  
;       TOP = Set this keyword to the maximum value of the scaled byte
;             image. If TOP is not specified, 255 is used.
;       /NEGATIVE - ; has no effect if /NOSCALE is set.
;       OUT = set to a named variable to return a structure containing
;             information about the displayed image.  The structure
;             contains the following tags:
;
;             IMAGE: resized and byte-scaled image that is displayed
;             IMAGE_UNSCALED: the input image resized, but not byte-scaled
;             XSIZE: the width (in device units) of the displayed image
;             YSIZE: the height (in device units) of the displayed image
;             ASPECT: aspect ratio of the displayed image
;             XRANGE: the xrange of the displayed axes
;             YRANGE: the xrange of the displayed axes
;             POSITION: the normalized position of the axes
;
;             If /NODISPLAY, /NOIMAGE, or /NOSCALE is set, then the IMAGE
;             tag will be identical to the IMAGE_UNSCALED tag.  Otherwise,
;             it will be a byte array.  It should be noted that this means
;             the type of IMAGE and IMAGE_UNSCALED will depend on the type
;             of IMAGE_IN and whether the keywords mentioned above are set.
;
;       Accepts all graphics keywords accepted by TV, PLOT, and COLOR_QUAN:
;
;       PLOT keywords:
;       BACKGROUND, CHARSIZE, CHARTHICK, CLIP, COLOR, DATA, DEVICE, FONT,
;       NOCLIP, NODATA, ERASE, NORMAL, POSITION, SUBTITLE, T3D, THICK,
;       TICKLEN, TITLE, [XYZ]CHARSIZE, [XYZ]GRIDSTYLE, [XYZ]MARGIN,
;       [XYZ]MINOR, [XYZ]RANGE, [XYZ]STYLE, [XYZ]THICK, [XYZ]TICKFORMAT,
;       [XYZ]TICKINTERVAL, [XYZ]TICKLAYOUT, [XYZ]TICKLEN, [XYZ]TICKNAME,
;       [XYZ]TICKS, [XYZ]TICKUNITS, [XYZ]TICKV, [XYZ]TICK_GET, [XYZ]TITLE,
;       ZVALUE
;
;       Explain the TICKLEN/XTICKLEN/YTICKLEN keywords and how they are
;       dealt with.
;
;       DEFAULT UNITS FOR POSITION ARE NORMAL.  /DATA WILL BE COMPLETELY
;       IGNORED... IT CAN'T BE USED TO SPECIFY POSITION ANYWAY, SO NO LOSS.
;       THE CLIP KEYWORD IS ABSOLUTELY USELESS FOR OUR PURPOSES AND IF IT
;       WERE PASSED IN BY REFERENCE, IT WILL BE THOROUGHLY IGNORED...
;
;       TV keywords:
;       CENTIMETERS, ORDER, TRUE, WORDS, CHANNEL, DATA,
;       DEVICE, NORMAL, T3D, Z
;       --> IGNORED: XSIZE, YSIZE
;
;       COLOR_QUAN keywords:
;       COLORS, CUBE, GET_TRANSLATION, DITHER, ERROR, TRANSLATION 
;
;       But some of these keywords will have limited affect; there are:
;       XSTYLE =
;       YSTYLE =
;       /DATA -
;
; OUTPUTS:
;       None.
;
; COMMON BLOCKS:
;       None.
;
; SIDE EFFECTS:
;       Image is displayed.  If the current device is set to X and no
;       windows are open, then one will be opened.
;
; RESTRICTIONS:
;       Not supported for IDL versions below 5.1.
;
;       Currently, no plot parameters can be set via !p, !x, !y.
;
;       The input image must be either 2-dimensional or, if it is a
;       TrueColor image, it must be 3-dimensional with one of the
;       dimensions having a size of exactly 3.  E.g., a pixel-interleaved
;       image has dimensions (3,NX,NY), a row-interleaved image has
;       dimensions (NX,3,NY), and a band-interleaved image has dimensions
;       (NX,NY,3).
;
; PROCEDURE:
;
;
;
; EXAMPLE:
;
;       /NOSCALE can be used to display images in which the color table
;       wraps.
;
; NOTES:

;       Gleaned a lot of useful ideas over the years from the code of the
;       following folks: Fen Tamanaha (DISPLAY.PRO), Liam Gumley
;       (IMDISP.PRO), and David Fanning (TVIMAGE.PRO).
;
;       /NAN keyword is set in call to BYTSCL() so that NaN or Infinity are
;       treated as missing data in the image.
;
;       If the aspect ratio of the image is ridiculous, then the plot
;       axis labels are bound to overlap each other in the short direction;
;       an option, if the aspect ratio must be retained is to set
;       X/YTICKFORMAT='(A1)' in the short direction and get the tick mark
;       values via X/YTICK_GET; then you can place the labels at the tick
;       mark positions and rotate them using XYOUTS so they don't overlap.
;
; INTERNAL ROUTINES:
;       DISPLAY_GETPOS(), DISPLAY_IMGRESIZE(), DISPLAY_IMGSCL()
;
; MODIFICATION HISTORY:
;	Written by Tim Robishaw, Berkeley in ancient times.
;	Finally added documentation. T. Robishaw  31 Oct 2006
;	Changed behavior for TrueColor images; had been bytescaling each
;	color plane independently. That was crazy.  In order to preserve
;	relative scaling between color planes, we bytescale the entire
;	image, all color planes simultaneously. T. Robishaw  19 Apr 2007
;-

; WE USE ALL OF THE FOLLOWING EXPLICITLY IN CALLS TO PLOT/TV...
; SO THEY CAN BE OVERRULED BY _REF_EXTRA UNLESS WE DO SOMETHING ABOUT IT!
;
; PLOT
; ======
; XSTYLE 
; YSTYLE
; XRANGE
; YRANGE

; TV
; ====
; XSIZE
; YSIZE


; PLOT KEYWORDS...
;===========================
; EXPLICITLY SET IN HEADER...
;[, POSITION=[X0, Y0, X1, Y1]]  
;[, COLOR=value] 
;[, /DATA | , /DEVICE | , /NORMAL] 
;[, {X | Y | Z}STYLE=value] 
;
; TEST THESE:
;[, /POLAR] 
;[, /XLOG] ; WHAT DO WE DO HERE?
;[, /YLOG] ; WHAT DO WE DO HERE?
;[, /T3D] 
;[, {X | Y | Z}RANGE=[min, max]] 
;[, ZVALUE=value{0 to 1}]

;!!!!!!!!!!!!!!!!!!!!
; MIN, MAX keywords for imgscl...

; USEFUL:
;[, BACKGROUND=color_index]
;[, CHARSIZE=value] 
;[, CHARTHICK=integer] 
;[, FONT=integer] 
;[, /NOERASE] 
;[, SUBTITLE=string] 
;[, TICKLEN=value] 
;[, TITLE=string] 
;[, {X | Y | Z}CHARSIZE=value] 
;[, {X | Y | Z}GRIDSTYLE=integer{0 to 5}] 
;[, {X | Y | Z}MARGIN=[left, right]] 
;[, {X | Y | Z}MINOR=integer] 
;[, {X | Y | Z}THICK=value] 
;[, {X | Y | Z}TICK_GET=variable] 
;[, {X | Y | Z}TICKFORMAT=string] 
;[, {X | Y | Z}TICKINTERVAL= value] 
;[, {X | Y | Z}TICKLAYOUT=scalar] 
;[, {X | Y | Z}TICKLEN=value] 
;[, {X | Y | Z}TICKNAME=string_array] 
;[, {X | Y | Z}TICKS=integer] 
;[, {X | Y | Z}TICKUNITS=string] 
;[, {X | Y | Z}TICKV=array] 
;[, {X | Y | Z}TITLE=string] 
;
; USELESS:
; [, MAX_VALUE=value] [, MIN_VALUE=value] [, NSUM=value] 
; [, /YNOZERO] [, /NODATA] 
; [, CLIP=[X0, Y0, X1, Y1]] [, /NOCLIP] [, LINESTYLE={0 | 1 | 2 | 3 | 4 | 5}] 
; [, PSYM=integer{0 to 10}] [, SYMSIZE=value] [, THICK=value] 
;
; TV KEYWORDS...
;===========================
; DENY USER ACCESS:
;[, XSIZE=value] 
;[, YSIZE=value] 

; EXPLICITLY SET:
;[, CHANNEL=value] 
;[, /ORDER] 
;[, TRUE={1 | 2 | 3}] 
;[, /DATA | , /DEVICE | , /NORMAL] 
;
; TEST:
;[, /WORDS] 
;[, /T3D | Z=value]
;
; USELESS:
;[, /CENTIMETERS | , /INCHES] 

; COLOR_QUAN KEYWORDS...
;===========================
; DENY USER ACCESS:
;[, COLORS=integer{2 to 256}]
;
; USEFUL:
;[, /DITHER] 
;[, ERROR=variable] 
;[, TRANSLATION=vector]
;
; TEST:
;[, CUBE={2 | 3 | 4 | 5 | 6} | , GET_TRANSLATION=variable [, /MAP_ALL]] 

;On_Error, 2

; TO SEE THAT COMPRESSION WORKS...
; window, xs=779, ys=618
; HERE WE COMPRESS 9 PIXELS...
; display, dindgen(5013,5013)
; USE RDPLOT TO SEE THAT FIRST PIXEL IS CENTERED AT 4.0, NEXT AT 13.0
; HERE WE COMPRESS 10 PIXELS...
; display, dindgen(5570,5570)
; USE RDPLOT TO SEE THAT FIRST PIXEL IS CENTERED AT 4.5, NEXT AT 14.5

; TO SEE THAT EXPANSION WORKS...
; HERE WE EXPAND 4 PIXELS...
; display, dindgen(2228,2228)
; USE RDPLOT TO SEE THAT FIRST PIXEL IS CENTERED AT 1.5, NEXT AT 5.5
; HERE WE EXPAND 5 PIXELS...
; display, dindgen(2785,2785)    
; USE RDPLOT TO SEE THAT FIRST PIXEL IS CENTERED AT 2.0, NEXT AT 7.0

;!!!!!!!!!!!!!!!
; TODO:
; * should be able to use !p.position, !x/y.ticklen, etc.
;   -> useless:
;      * !p.region - just is
;      * !x/y.region, !x/y.position - aren't estab. until first plot
; * finish extensive notes file
; * add notes to documentation



; ALSO WANT TO REMOVE X/YRANGE KEYWORDS AS WELL, RIGHT!?
; BUT USER MAY WANT THE XRANGE AND YRANGE VALUES PASSED BACK!!!
; -> well, they can get them via !x.crange and !y.crange!!

;!!!!!!!!!!!
; --> IF !P.REGION IS TOO SMALL, EVEN IF WINDOW IS WAY HUGE, IT CHOKES.
;     --> well, this is good!!
;         --> but what is the suggested window size in this case??

;!!!!!!!!!!!!!!!!!
; WILL EVERYTHING BE COOL IF SOMEONE SETS THE VARIOUS !P,!X,!Y VARS?
; LIKE !P.TICKLEN, !X.TICKLEN...
; -> NO! THESE ARE NOT USED!!

; !P.BACKROUND
; !P.CHARSIZE
; !P.CHARTHICK
; !P.COLOR
; !P.FONT
; !P.NOERASE
; !P.CLIP
; !P.NOCLIP
; !P.POSITION
; !P.REGION
; !P.THICK
; !P.TITLE
; !P.TICKLEN
; !P.CHANNEL

; !X.TITLE
; !X.STYLE
; !X.TICKS
; !X.TICKLEN
; !X.THICK
; !X.RANGE
; !X.CRANGE
; !X.MARGIN
; !X.OMARGIN
; !X.REGION
; !X.WINDOW
; !X.CHARSIZE
; !X.MINOR
; !X.TICKV
; !X.TICKNAME
; !X.GRIDSTYLE
; !X.TICKFORMAT
; !X.TICKINTERVAL

; ADD EXTRA VERBOSENESS...

;!!!!!!!!!!!!!!!!!
; ASPECT RATIO HAS BECOME RIDICULOUS ONCE CHARACTERS START OVERLAPPING!

;!!!!!!!!!!!!!!!!!
; THE RESIZING IS DONE VIA POLY_2D(), SO IF YOU HAPPEN TO HAVE AN IMAGE
; THAT IS LARGER THAN THEN DISPLAY, THEN INFORMATION WILL BE LOST WHEN
; DISPLAYED BECAUSE THE ORIGINAL IMAGE WILL JUST BE SAMPLED.  SO A REALLY
; BRIGHT FEATURE THAT OCCURS IN ONLY ONE PIXEL COULD BE COMPLETELY
; INTERPOLATED OVER.  IT IS MUCH BETTER TO USE REBIN() ON THE INPUT IMAGE
; IF IT NEEDS TO BE SHRUNK, THEN PASS IT INTO DISPLAY.  REBIN() WILL
; ACTUALLY AVERAGE THE DATA IN THE IMAGE UPON SHRINKING.  NOTE THAT
; CONGRID() WILL NOT HELP HERE BECAUSE IT INTERPOLATES RATHER THAN
; AVERAGING.  THIS IS JUST SOMETHING THAT THE USER MUST BE SAVVY ENOUGH TO
; GRASP BEFORE CALLING DISPLAY.

; DETERMINE THE IDL RELEASE...
release = float(!version.release)

if (release lt 5.1) then $
  message, 'DISPLAY.PRO is not supported for IDL versions before 5.1.'

; IF THE USER DOESN'T ASK FOR INFORMATION, THEN DON'T PROVIDE ANY...
verb = (N_elements(VERBOSE) eq 0) ? 0b : byte(verbose)

; GET THE DIMENSIONS OF THE INPUT IMAGE...
sz = size(image_in)
ndims = sz[0]
if (ndims eq 0) then $
  message, 'IMAGE is undefined.'

if (ndims lt 2) OR (ndims gt 3) then $
  message, 'IMAGE must have 2 (or 3, if TRUECOLOR) dimensions.'
dims = sz[1:ndims]

; MAKE SURE BOTH X AND Y ARE SENT...
if (N_params() eq 2) then $
   message, 'Incorrect number of arguments. Both X and Y must be sent.'

image = image_in

; ARE WE DEALING WITH A TRUECOLOR IMAGE...
truecolor = (ndims eq 3)
if truecolor then begin

    ; HAVE WE PASSED THE TRUE KEYWORD...
    if (N_elements(TRUE) eq 0) then begin
        ; OVER WHICH DIMENSION IS THE IMAGE INTERLEAVED...
        dim3 = where(dims eq 3,ndim3)
        ; IS THIS REALLY A TRUECOLOR IMAGE...
        if (ndim3 eq 0) then $
           message, 'This is not a truecolor image.  Image needs to be '+$
                    '2-dimensional or a 3-dimensional TrueColor '+$
                    'interleaved image.'

        ; HAS USER PASSED AN AMBIGUOUSLY CONSTRUCTED IMAGE...
        if (ndim3 gt 1) then $
          message, 'Unclear how IMAGE is interleaved; use TRUE keyword.'
    endif else begin
        case 1 of
            ; DOES TRUE HAVE MORE THAN ONE ELEMENT...
            (N_elements(TRUE) gt 1) : $
              message, 'TRUE must be a scalar or 1 element array.'
            ; WAS CHANNEL PASSED IN AS AN ARRAY...
            (N_elements(CHANNEL) gt 1) : $
              message, 'CHANNEL must be a scalar or 1 element array.'
            ; IS TRUE IN THE ALLOWED RANGE...
            (true[0] lt 1) OR (true[0] gt 3) : $
              message, 'Value of TRUE keyword is out of allowed range.'
            else : begin
                dim3 = true-1
                ; IS IMAGE REALLY INTERLEAVED OVER THIS DIMENSION...
                if (dims[dim3] ne 3) then $
                  message, 'Color is not interleaved over dimension '$
                  +strtrim(true,2)
            end
        endcase
    endelse

    ; IF THE IMAGE IS NOT IMAGE-INTERLEAVED, THEN TRANSPOSE IT SO THAT
    ; IT IS...
    if (dim3[0] ne 2) then begin
        imdim = where([0,1,2] ne dim3[0])
        image = transpose(image,[imdim,dim3])
        dims  = sz[[imdim,dim3]+1]
     endif

endif

; GET THE NUMBER OF COLUMNS AND ROWS IN THE IMAGE...
nrow = dims[0]
ncol = dims[1]

; MAKE SURE X AND Y ARE NOT PASSED IN UNDEFINED...
nx = N_elements(x)
ny = N_elements(y)
if (nx eq 0) AND arg_present(x) then $
   message, 'Expression must be an array in this context: X.'
if (ny eq 0) AND arg_present(y) then $
   message, 'Expression must be an array in this context: Y.'

; MAKE SURE IMAGE, X, AND Y SIZES ARE COMPATIBLE...
if (nx eq 0) then begin
   x = lindgen(nrow)
   nx = nrow
endif else if (nx ne nrow) $
   then message, 'IMAGE and X array dimensions are incompatible.'
if (ny eq 0) then begin
   y = lindgen(ncol)
   ny = ncol
endif else if (ny ne ncol) $
   then message, 'IMAGE and Y array dimensions are incompatible.'

; SET DEFAULTS FOR KEYWORDS...
; WE GO TO PAINS TO MAKE SURE KEYWORDS THE ARE PASSED IN AS AN UNDEFINED
; VARIABLE ARE NOT PASSED BACK OUT...
xstyle = (N_elements(XSTYLE_IN) eq 0) ? 1 : xstyle_in
ystyle = (N_elements(YSTYLE_IN) eq 0) ? 1 : ystyle_in
bottom = (N_elements(BOTTOM_IN) eq 0) ? 0B : bottom_in
top    = (N_elements(TOP_IN) eq 0) ? byte(!d.table_size-1) : top_in
minval = (N_elements(MINVAL_IN) eq 0) ? min(image,/NAN) : minval_in
maxval = (N_elements(MINVAL_IN) eq 0) ? max(image,/NAN) : maxval_in
if (N_elements(POSITION) gt 0) then begin

   ; MAKE SURE /NORESIZE IS NOT SET...
   if keyword_set(NORESIZE) then message, $
      'The POSITION keyword cannot be used when /NORESIZE is set.'

   ; ERROR CHECK POSITION KEYWORD...
   case 1 of
      (N_elements(position) ne 4) : $
         message, 'Keyword array parameter POSITION must have 4 elements.'
      (position[0] ge position[2]) : $
         message, 'Normalized POSITION[0] must be less than POSITION[2].'
      (position[1] ge position[3]) : $
         message, 'Normalized POSITION[1] must be less than POSITION[3].'
      (position[0] lt 0) OR (position[1] lt 0) : $
         message, 'Normalized POSITION[0:1] must be >= 0.'
      else: begin
         ; IF /DEVICE IS SET THEN TRANSFORM POSITION TO NORMAL
         ; COORDINATES, OTHERWISE MAKE SURE POSITION IS FLOATING...
         position = keyword_set(DEVICE) $
                    ? position/float(([!d.x_vsize,!d.y_vsize])[[0,1,0,1]]) $
                    : float(position)
         if (position[2] gt 1.0) OR (position[3] gt 1.0) then $
            message, 'Normalized POSITION[2:3] must be less than 1.'
      end
   endcase

   ; BECAUSE IDL IS DUMB, IT ALLOWS YOU TO PLACE THE LAST COLUMN
   ; OR ROW ONE PIXEL OFF OF THE DISPLAY, AT A NORMALIZED POSITION OF
   ; 1.0.  SINCE IT CALCULATES THE NORMALIZED COORDINATES AS
   ; PIXEL/!D.X_VSIZE, THEN THE LAST PIXEL IS LOCATED AT
   ; (!D.X_VSIZE-1)/!D.X_VSIZE, WHICH IS ALWAYS < 1.0. WE DON'T WANT
   ; AN AXIS OFF THE DISPLAY...
   position[2] = position[2] < float(!d.x_vsize-1)/!d.x_vsize
   position[3] = position[3] < float(!d.y_vsize-1)/!d.y_vsize
endif

; MAKE SURE THAT TOP GE BOTTOM...
if (top lt bottom) then message, 'TOP must be GE BOTTOM.'

;!!!!!!!!!!!!!!!!
; WHAT IF NO X/Y SENT IN, BUT XRANGE AND YRANGE ARE SENT IN???
;delx = abs(xrange[1] - xrange[0])
;dely = abs(yrange[1] - yrange[0])

; WHAT ARE SEPARATIONS IN X AND Y UNITS BETWEEN PIXELS...
delx = abs(x[1] - x[0])
dely = abs(y[1] - y[0])

; COMPUTE THE ASPECT RATIO...
case 1 of
    ; IF /NORESIZE IS SET, FORCE ASPECT TO ZERO...
    keyword_set(NORESIZE) : aspect = 0d0
    ; DOES ASPECT HAVE MORE THAN ONE ELEMENT...
    (N_elements(ASPECT_IN) gt 1) : $
      message, 'ASPECT keyword must be a scalar or 1 element array.'
    ; HAS THE USER PASSED A NEGATIVE ASPECT RATIO...
    (N_elements(ASPECT_IN) eq 1) : $
      if (aspect_in lt 0) $
       then message, 'ASPECT keyword must be non-negative.' $
       else aspect = aspect_in
    ; THE ASPECT RATIO IS *DEFINED* AS WIDTH/HEIGHT...
    else: aspect = (double(max(x))-double(min(x))+delx) $
      / (double(max(y))-double(min(y))+dely)
endcase

;stop

; DOES THE DEVICE SUPPORT WINDOWS...
windows  = (!d.flags AND 256) ne 0
; DOES THE DEVICE HAVE SCALABLE PIXELS...
scalable = (!d.flags AND 1) ne 0

; A WINDOW NEEDS TO HAVE BEEN CREATED TO ESTABLISH THE VISUAL TYPE...
if windows AND (!d.window lt 0) then begin
  window, /FREE, /PIXMAP
  wdelete, !d.window
endif

; USE A DUMMY PLOT TO ESTABLISH THE POSITION OF THE PLOT DATA WINDOW,
; I.E., THE PLOT END POINTS... DON'T WORRY, PASSING NODATA=0 BY
; REFERENCE DOES NOT OVERRIDE OUR SETTING /NODATA BELOW...
if not keyword_set(POSITION) $
  then plot, [0], /NODATA, XSTYLE=4, YSTYLE=4, _EXTRA=extra $
  else plot, [0], /NODATA, XSTYLE=4, YSTYLE=4, POSITION=position, _EXTRA=extra

;plot, [0], _EXTRA=extra

; DO WE NOT WANT TO RESIZE...
if keyword_set(NORESIZE) then begin
   if (not scalable) then begin

      ; GET THE TOTAL NUMBER OF PIXELS IN THE PLOTTING REGION...
      nxd = !d.x_vsize
      nyd = !d.y_vsize
      if (total(!p.region) gt 0) then begin
         xreg = !p.region[[0,2]]
         yreg = !p.region[[1,3]]
      endif else begin
         xreg = [0.0,1.0]
         yreg = [0.0,1.0]
      endelse
      
      ; THE DUMMY PLOT ABOVE SETS UP THE LARGEST POSSIBLE SET OF AXES IN
      ; THE CURRENTLY DEFINED REGION SUCH THAT WE HAVE ENOUGH ROOM ON THE
      ; SIDES OF THE IMAGE TO PLACE AXIS LABELS; IF THE USER PASSED
      ; X/YMARGIN KEYWORDS, THESE WILL ALSO AFFECT THE PLACEMENT OF THE
      ; AXES IN THE DUMMY PLOT CALL.  NOW, SINCE WE'VE REQUESTED THAT THE
      ; IMAGE NOT BE RESIZED, THEN A NUMBER OF THINGS ARE TRUE:
      ; (1) THE ASPECT RATIO WILL BE DEFINED AS THE RATIO OF THE NUMBER OF
      ; PIXELS IN THE HORIZONTAL AND VERTICAL DIRECTIONS.
      ; (2) IF THE NUMBER OF PIXELS IN THE VERTICAL DIRECTION IS LARGER
      ; THAN THE NUMBER OF PIXELS BETWEEN THE X AXES SET UP BY THE DUMMY
      ; PLOT, THEN THE IMAGE WILL NOT BE DISPLAYED AND THE USER WILL BE
      ; TOLD THE APPROPRIATE MINIMUM WINDOW HEIGHT NECESSARY TO DISPLAY
      ; THIS IMAGE.
      ; (3) IF THE NUMBER OF PIXELS IN THE HORIZONTAL DIRECTION IS LARGER
      ; THAN THE NUMBER OF PIXELS BETWEEN THE Y AXES SET UP BY THE DUMMY
      ; PLOT, THEN THE IMAGE WILL NOT BE DISPLAYED AND THE USER WILL BE
      ; TOLD THE APPROPRIATE MINIMUM WINDOW WIDTH NECESSARY TO DISPLAY THIS
      ; IMAGE.

      ; CALCULATE THE MINIMUM NUMBER OF PIXELS THE DISPLAY MUST CONTAIN IN
      ; ORDER TO DISPLAY THIS IMAGE USING MARGIN AREAS CALCULATED FROM THE
      ; DUMMY PLOT...
      ;minxpix0 = nx + (round(nxd*!x.window[0])+1) + round(nxd*(1-!x.window[1]))
      ;minypix0 = ny + (round(nyd*!y.window[0])+1) + round(nyd*(1-!y.window[1]))

      ; WHAT PIXELS DO THE REGION BOUNDARIES FALL ON...
      lreg = round(xreg[0]*!d.x_vsize)
      rreg = round(xreg[1]*!d.x_vsize)
      breg = round(yreg[0]*!d.y_vsize)
      treg = round(yreg[1]*!d.y_vsize)

      ;help, lreg, rreg, breg, treg

      ; WHAT PIXELS DO THE AXES FALL ON...
      lwin = round(!x.window[0]*!d.x_vsize)
      rwin = round(!x.window[1]*!d.x_vsize)
      bwin = round(!y.window[0]*!d.y_vsize)
      twin = round(!y.window[1]*!d.y_vsize)

      ;help, lwin, rwin, bwin, twin

      ; HOW MANY TOTAL PIXELS ARE BETWEEN (AND INCLUDING) THE REGION
      ; BOUNDARIES AND THE AXES...
      nl = lreg - lwin + 1
      nr = rreg - rwin + 1
      nb = breg - bwin + 1
      nt = treg - twin + 1

      ;help, nl, nr, nb, nt

      ; GET THE MININUM NUMBER OF PIXELS THE WINDOW MUST HAVE IN ORDER TO
      ; DISPLAY THIS IMAGE IN THIS REGION WITHOUT RESIZING IT...
      minxpix = round((nx + nl + nr) / (xreg[1] - xreg[0]+1./nxd))
      minypix = round((ny + nb + nt) / (yreg[1] - yreg[0]+1./nyd))

      ; IF DISPLAY IS TOO SMALL, TELL USER HOW BIG THE DISPLAY MUST BE...
      if (minxpix gt !d.x_vsize) OR (minypix gt !d.y_vsize) then $
         message, string('IMAGE will not fit in window. Here are some'$
                         +' options: (a) allow IMAGE to be compressed'$
                         +' (omit /NORESIZE keyword); (b) decrease YMARGIN'$
                         +' and/or XMARGIN; (c) create a window with the'$
                         +' following dimensions: '$
                         +'XSIZE = '+strtrim(minxpix,2)+', '$
                         +'YSIZE = '+strtrim(minypix,2)$
                         +(total(!p.region) gt 0 ? $
                           '; (d) increase !P.REGION settings.' : ''))

      ; SET THE XSIZE AND YSIZE TO THE NUMBER OF PIXELS IN THE IMAGE...
      ysize = ny
      xsize = nx
   endif else begin
      
      ; IF USING A DEVICE WITH SCALABLE PIXELS, LIKE POSTSCRIPT, WE DON'T
      ; ALLOW THE /NORESIZE KEYWORD TO BE SET...
      message, 'When using DISPLAY on a device with scalable pixels, '+$
               'the /NORESIZE keyword cannot be used; please set XSIZE '+$
               'and YSIZE explicitly.'
   endelse
endif

; GET THE POSITION OF THE COORDINATE AXES IN DEVICE COORDINATES...
; RETURN THE WIDTH AND HEIGHT OF THE IMAGE AS KEYWORDS...
dev_pos = display_getpos(aspect, XSIZE=xsize, YSIZE=ysize, $
                         NORESIZE=keyword_set(NORESIZE))

;print, dev_pos[[0,2,1,3]]

;stop

; DETERMINE WHAT THE VALUES OF X AND Y SHOULD BE AT THE AXIS ENDPOINTS...
xfactor = double(nx) / xsize
yfactor = double(ny) / ysize
x_per_pixel = delx * xfactor ; = 1./(!x.s[1]*!d.x_vsize)
y_per_pixel = dely * yfactor ; = 1./(!y.s[1]*!d.y_vsize)
xrange = interpol(x,dindgen(nx),xfactor*([0,xsize-1]+0.5)-0.5) $
         + x_per_pixel*[-1,1]
yrange = interpol(y,dindgen(ny),yfactor*([0,ysize-1]+0.5)-0.5) $
         + y_per_pixel*[-1,1]

if ((verb and 4b) ne 0) then help, xfactor, yfactor, nx, xsize, ny, ysize
if ((verb and 2b) ne 0) then help, x_per_pixel, y_per_pixel

;!!!!!!!!
; PROBABLY AN EASY WAY TO JUST GET ENDPOINT VALUES HERE...
; USING VALUE_LOCATE AND INTERPOL() CODE...
; DETERMINE THE ENDPOINTS OF THE AXES...
;xi = double(nx)/xsize*(dindgen(xsize) + 0.5) - 0.5
;yi = double(ny)/ysize*(dindgen(ysize) + 0.5) - 0.5
;xnew = interpol(x,dindgen(nx),xi)
;ynew = interpol(y,dindgen(ny),yi)
;xrange = (xnew)[[0,xsize-1]]; + x_per_pixel*[-1,1]
;yrange = (ynew)[[0,ysize-1]]; + y_per_pixel*[-1,1]
;xfoo = image[*,0]
;stop

; IF /NODISPLAY OR /NOIMAGE IS SET, THEN WE WON'T BE CALLING TV AND WE
; DON'T NEED TO SCALE OR RESIZE THE INPUT IMAGE...
if keyword_set(NOIMAGE) OR keyword_set(NODISPLAY) then begin
   if arg_present(OUT) then image_unscaled = image
   goto, plotaxes
endif

; RESIZE THE IMAGE...
; WE DO NOT NEED TO RESIZE IF THE DEVICE HAS SCALABLE PIXELS...
if (not scalable) AND (not keyword_set(NORESIZE)) $
;   AND (not ((nx eq xsize) AND (ny eq ysize))) $
    then begin
    if ((verb and 1b) ne 0) then message, "Resizing image...", /INFO
    image = (not truecolor) $
            ? display_imgresize(image, nx, ny, xsize, ysize) $
            : [[[display_imgresize(image[*,*,0],nx,ny,xsize,ysize)]], $
               [[display_imgresize(image[*,*,1],nx,ny,xsize,ysize)]], $
               [[display_imgresize(image[*,*,2],nx,ny,xsize,ysize)]]]
endif

; SAVE A COPY OF THE RESIZED BUT UNSCALED IMAGE FOR PASSING OUT...
if arg_present(OUT) then image_unscaled = image

; DO WE WANT TO BYTE-SCALE THE IMAGE...
if not keyword_set(NOSCALE) then begin
    if ((verb and 1b) ne 0) then message, "Byte-Scaling image...", /INFO
    image = display_imgscl(image,MIN=minval,MAX=maxval,$
                           BOTTOM=bottom,TOP=top,$
                           NEGATIVE=keyword_set(NEGATIVE))
endif

if windows then begin

    ; WHAT IS THE DEPTH OF THE VISUAL CLASS...
    device, GET_VISUAL_DEPTH=depth;, GET_VISUAL_NAME=visual

    ; IF WE HAVE A TRUECOLOR IMAGE AND WE'RE ON A 24-BIT DISPLAY,
    ; THEN MAKE SURE DECOMPOSED COLOR IS TURNED ON...
    if (depth gt 8) AND truecolor then begin
          if (release ge 5.2) $
            then device, GET_DECOMPOSED=decomposed_in $
            else decomposed_in=0
        device, DECOMPOSED=1
    endif

endif else depth = 8



; ARE WE TRYING TO DISPLAY A TRUECOLOR IMAGE ON A PSEUDOCOLOR DISPLAY...
if truecolor AND (depth le 8) AND (!d.name ne 'PS') then begin

    ; IF CHANNEL KEYWORD IS SET, THEN BLANK OUT THE OTHER
    ; CHANNELS...
    if (N_elements(CHANNEL) gt 0) then begin
        if (channel lt 0) OR (channel gt 3) $
          then message, 'Value of CHANNEL is out of allowed range.'
        if (channel ne 0) then begin
            blank = where([1,2,3] ne channel)
            image[*,*,blank] = 0B
        endif
    endif

    ; FIND (TOP-BOTTOM+1) COLORS THAT ACCURATELY REPRESENT THE ORIGINAL 
    ; COLOR DISTRIBUTION...
    if ((verb and 1b) ne 0) then $
      message, 'Color quantizing TrueColor image...', /INFO
    image = color_quan(image, 3, r, g, b, COLORS=(top-bottom+1), $
                       TRANSLATION=translation, _EXTRA=extra) $
            + byte(bottom)
    ;!!!!!!!!!!!!!!!!!!!!!
    ; ^^^^^^^^^^^^^^^^
    ; WHAT IF /NOSCALE IS SET... THEN BOTTOM ISN'T USED, RIGHT?

    ;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    ; WHY WOULD TRANSLATION BE EMPTY IF WE JUST GOT IT BACK???

    ; LOAD THE COLOR PALETTE...
    if (N_elements(TRANSLATION) eq 0) then tvlct, r, g, b, bottom
    truecolor = 0B

endif

; DISPLAY THE IMAGE ON THE DEVICE...
tv, image, dev_pos[0]+1, dev_pos[1]+1, /DEVICE, $
    XSIZE=xsize, YSIZE=ysize, $
    ORDER=keyword_set(ORDER), $
    TRUE=truecolor*3, CHANNEL=channel, $
    _EXTRA=extra

; IF WE HAVE A 24-BIT VISUAL CLASS, RETURN THE COLOR DECOMPOSITION
; BACK TO ITS ORIGINAL STATE...
if windows AND (depth gt 8) then device, DECOMPOSED=decomposed_in

plotaxes:

; IF THE USER HAS SUPPLIED BOTH THE XTICKLEN AND YTICKLEN KEYWORDS
; THEN WE ASSUME THE USER WANTS TO EXPLICITLY SET THE LENGTHS...
xticklset = N_elements(XTICKLEN_IN) gt 0
yticklset = N_elements(YTICKLEN_IN) gt 0
if xticklset then xticklen = xticklen_in
if yticklset then yticklen = yticklen_in
if not (xticklset AND yticklset) then begin
   
   ; IF THE X/YTICKLEN KEYWORD IS SET, IF NONZERO, OVERRIDES THE GLOBAL
   ; TICK LENGTH SPECIFIED IN !P.TICKLEN, AND/OR THE TICKLEN KEYWORD
   ; PARAMETER, WHICH IS EXPRESSED IN TERMS OF THE WINDOW SIZE...
   
   tick_aspect = double(dev_pos[2]-dev_pos[0]) / (dev_pos[3]-dev_pos[1])
   
   case 1 of
      xticklset : yticklen = xticklen / tick_aspect
      yticklset : xticklen = yticklen * tick_aspect
      else : begin
         xticklen = (N_elements(TICKLEN) eq 0) ? 0.02 : ticklen
         yticklen = (N_elements(TICKLEN) eq 0) ? 0.02 : ticklen
         ; USE THE TICKLENGTH THAT PROVIDES SHORTER TICKS...
         if (tick_aspect gt 1.0) $
            then xticklen = yticklen * tick_aspect $
            else yticklen = xticklen / tick_aspect
      end
    endcase
   
endif

; PLOT THE AXES...
; EVEN IF PASSED IN BY REFERENCE, /NOERASE AND /NODATA TAKE PRECEDENCE
; BELOW...
if keyword_set(ORDER) then yrange = yrange[[1,0]]
plot, [0], /NOERASE, /NODATA, $
      XSTYLE=(xstyle OR 1 OR 4*keyword_set(NODISPLAY)), $
      YSTYLE=(ystyle OR 1 OR 4*keyword_set(NODISPLAY)), $
      XRANGE=xrange, YRANGE=yrange, $
      TICKLEN=ticklen, XTICKLEN=xticklen, YTICKLEN=yticklen, $
      TITLE=title, SUBTITLE=subtitle, $
      /DEVICE, POSITION=dev_pos, $
      COLOR=color, $
      _EXTRA=extra

;x0 = !x.window[0]*!d.x_vsize
;x1 = !x.window[1]*!d.x_vsize
;y0 = !y.window[0]*!d.y_vsize
;y1 = !y.window[1]*!d.y_vsize
;help, image, x0, x1, y0, y1

; PASS OUT A STRUCTURE FULL OF RESULTS THAT MIGHT BE USED LATER...
; IF /NOSCALE, /NODISPLAY OR /NOIMAGE IS SET, THEN IMAGE AND 
; IMAGE_UNSCALED WILL BE IDENTICAL...
if arg_present(OUT) $
   then out = {image:image, $    ; RESIZED AND SCALED IMAGE THAT IS DISPLAYED
               image_unscaled:image_unscaled, $ ; UNSCALED IMAGE
               xsize:xsize, $    ; THE WIDTH (IN DEVICE UNITS) OF IMAGE
               ysize:ysize, $    ; THE HEIGHT (IN DEVICE UNITS) OF IMAGE
               ;x_vsize:!d.x_vsize, $ ; THE WIDTH (IN DEVICE UNITS) OF WINDOW
               ;y_vsize:!d.y_vsize, $ ; THE HEIGHT (IN DEVICE UNITS) OF WINDOW
               aspect:double(xsize)/ysize, $ ; ASPECT RATIO OF IMAGE
               xrange:xrange, $  ; XRANGE OF AXIS
               yrange:yrange, $  ; YRANGE OF AXIS
               ; THE NORMALIZED POSITION OF THE AXES...
               position:double(dev_pos)/([!d.x_vsize,!d.y_vsize])[[0,1,0,1]]}

end; display


