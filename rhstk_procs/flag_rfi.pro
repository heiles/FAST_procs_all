
; MAIN PROCEDURE FLAG_RFI DOWN BELOW...

;==========================================================================

pro flag_rfi_display, img, start, stop, blowup, $
                      FLAG_MASK=flag_mask, $
                      NCHAN=nchan, MIN=min_in, MAX=max_in, $
                      MEDIAN=median, SUBTRACT=subtract, $
                      IMG_REGION=img_region, $
                      MED_REGION=med_region, $
                      CROSS_GAIN=cross_gain, $
                      CHARSIZE=charsize, CHARTHICK=charthick, $
                      _REF_EXTRA=_extra

; FLAG_RFI_DISPLAY
; This is a wrapper for Robishaw's DISPLAY that displays an image for
; FLAG_RFI.
;
; The default is to simply display a vertical stack of spectra as a
; function of spectral channel.  Care is taken to not interpolate in either
; direction; this is important since we are trying to find interference and
; problem spectra.
;
; If /MEDIAN is set, the median of the image is determined in the spectrum
; number direction yielding a median spectrum for the time range being
; displayed.  This median spectrum is displayed below the image.
;
; For autocorrelation products XX and YY, the image is divided by the
; median spectrum before being displayed.  In addition, for each spectrum
; in this flattened image, the median across the inner 60% of channels is
; determined and subtracted from  the spectrum.  Each offset is plotted to
; the right of each image.  The median spectrum of the flattened and
; offset-subtracted image is displayed in gray below the image.
;
; For cross-correlation products XY and YX, the median spectrum is
; subtracted from the image before being displayed
;
; If the MED_REGION keyword is passed and it is a 4-elements vector, then
; the median spectrum is plotted is plotted in this region.

ngroup = stop-start+1
numspec = ngroup*blowup

if (N_elements(NCHAN) eq 0) $
   then nchan = (size(img))[1] $
   ; USE BILINEAR INTERPOLATION WHEN SHRINKING IN THE CHANNEL DIRECTION...
   else img = rebin(img,[nchan,ngroup])

; USE NEAREST-NEIGHBOR SAMPLING WHEN EXPANDING IN THE SPECTRUM DIRECTION...
img = rebin(img,[nchan,numspec],/SAMPLE)

; DEFINE THE IMAGE THAT WILL BE DISPLAYED...
disp_img = img

; IF /MEDIAN IS SET, WE DIVIDE EACH SPECTRUM BY THE MEDIAN IN THIS GROUP OF
; SPECTRA...
if keyword_set(MEDIAN) then begin

   ;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
   ; FOR CROSS PRODUCTS, SHOULD WE BE DIVIDING BY
   ; SQRT(MEDXX * MEDYY) ???
   ; WE'RE PASSING THIS IN VIA CROSS_GAIN, BUT WE'RE NOT USING IT
   ; RIGHT NOW BECAUSE CARL THINKS WE SHOULD JUST SUBTRACT THE MEDIAN FOR
   ; THE CROSS PRODUCTS RATHER THAN DIVIDING BY THE CROSS GAIN...
   ;med_spec = (N_elements(CROSS_GAIN) gt 0) ? rebin(cross_gain,nchan) $
   ;            : median(img,DIMENSION=2)

   ; WHEN TAKING A MEDIAN ACROSS CHANNELS, LET'S ONLY CONSIDER THE
   ; INNER 60% OF THE CHANNELS...
   medrange = round(nchan*[0.2,0.8])

   ; GET THE MEDIAN ACROSS THE TIME DIMENSION...
   med_spec = median(img,DIMENSION=2)

   ;img = img / (med_spec # replicate(1.0,numspec)) $
   ;      - 1 * (N_elements(CROSS_GAIN) eq 0)

   ; TURN THE MEDIAN SPECTRUM BACK INTO AN IMAGE...
   med_img = (med_spec # replicate(1.0,numspec))

   ; IF THE /SUBTRACT KEYWORD IS SET, JUST SUBTRACT THE MEDIAN KEYWORD...
   if keyword_set(SUBTRACT) then begin

      disp_img = img  - med_img

      ; JUST GET THE MEDIAN INTENSITY OF EACH SPECTRUM SO WE CAN PLOT IT,
      ; BUT DON'T SUBTRACT IT...
      level = median(disp_img[medrange[0]:medrange[1],*],DIMENSION=1)

   endif else begin

      ; DIVIDE BY MEDIAN SPECTRUM SHAPE...
      disp_img = img / med_img
      
      ; SUBTRACT OFF THE MEDIAN INTENSITY OF EACH SPECTRUM FROM EACH
      ; CORRESPONDING SPECTRUM...
      level = median(disp_img[medrange[0]:medrange[1],*],DIMENSION=1)
      disp_img = disp_img - (replicate(1.0,nchan) # level)
      
   endelse

   ; IF WE HAVEN'T EXPLICITLY PASSED IN THE MIN/MAX OR THEY HAVE BEEN
   ; PASSED BUT AS IEEE NAN, THEN ESTIMATE THE MIN AND MAX TO BE A FEW
   ; SIGMA...
   calculate_min = (N_elements(MIN_IN) eq 0) ? 1 : finite(min_in,/NAN)
   calculate_max = (N_elements(MAX_IN) eq 0) ? 1 : finite(max_in,/NAN)
   if calculate_min OR calculate_max then begin

      ; GET AN ESTIMATE OF THE RMS OF THE NOISE BY CUTTING OUT RFI AND MOST
      ; OF THE BRIGHT EXTENDED EMISSION...
      inner_img = disp_img[medrange[0]:medrange[1],*]
      goodindx = chauvenet(inner_img,/ITERATE)
      rms = stddev(inner_img[goodindx],/NAN)

      ; SET THE CLIPPING THRESHOLD FOR THE IMAGE...
      nsigma = 3.0

   endif
   min = calculate_min ? -nsigma*rms : min_in
   max = calculate_max ? +nsigma*rms : max_in

   ; IF WE WANT TO INSPECT MIN/MAX...
   ;wset, 0 & !p.region=0 & stop
   ;plot, disp_img
   ;oplot, !x.crange, min[[0,0]], co=!red
   ;oplot, !x.crange, max[[0,0]], co=!red

endif

; PROPERLY DEFINE THE AXES SO THAT THE PIXEL NUMBER IS CENTERED ON EACH
xaxis = lindgen(nchan)
yaxis = start + findgen(numspec)/blowup - 0.5*(blowup-1)/blowup

; IF WE'VE SPECIFIED A REGION, THEN SET IT...
if (N_elements(IMG_REGION) eq 4) then !p.region = img_region

; DISPLAY THE IMAGE.  DO NOT ALLOW DISPLAY TO RESIZE THE IMAGE; IF IT DOES
; THEN THE SPECTRA WILL BE INTERPOLATED OVER TIME AND THIS MAKES SEARCHING
; THROUGH EVERY SPECTRUM A USELESS TASK...
display, disp_img, xaxis, yaxis, /NORESIZE, TICKLEN=-0.008, $
         YTICKFORMAT='(I)', $
         /SILENT, MIN=min, MAX=max, $
         CHARSIZE=charsize, CHARTHICK=charthick, $
         _EXTRA=_extra

; IF REQUESTED, PLOT THE MEDIAN SPECTRUM...
if keyword_set(MEDIAN) AND (N_elements(MED_REGION) eq 4) then begin

   bangy_img = !y

   ; FIRST PLOT THE OFFSETS NEXT TO THE IMAGE...
   xpos = !x.window
   ypos = !y.window
   plot, level, yaxis, YRANGE=!y.crange, YSTYLE=5, /NOERASE, $
         XSTYLE=3, XTICKFORMAT='(A1)', XTICKLEN=-0.005, XTICKS=2, $
         XTICK_GET=xticks, $
         ;POSITION=[xpos[1],ypos[0],xpos[1]+0.1*(xpos[1]-xpos[0]),ypos[1]]
         POSITION=[xpos[1],ypos[0],xpos[1]+0.15*(xpos[1]-xpos[0]),ypos[1]], $
         CHARSIZE=charsize, CHARTHICK=charthick
   xtickpos = !x.s[0] + !x.s[1]*xticks
   for i = 0, N_elements(xtickpos)-1 do $
      xyouts, xtickpos[i], !y.window[0]-1.5*float(!d.y_ch_size)/!d.y_vsize, $
              /NORM, strtrim(xticks[i],2), ALIGN=0.0, ORIENTATION=-70.0

   ; WE'LL USE THE X POSITION OF THE Y AXES ESTABLISHED BY THE CALL TO
   ; DISPLAY...
   !p.region = med_region

   ; ESTABLISH PLOT SO THAT WE CAN GET Y POSITION OF AXES...
   plot, [0], /NODATA, XSTYLE=4, YSTYLE=4, /NOERASE
   ymin = min(med_spec[nchan*0.10:nchan*0.90],MAX=ymax)

   ; PLOT THE MEDIAN SPECTRUM; 
   plot, med_spec, TITLE='Median Spectrum', $
         XTIT='Channel', YTIT='Intensity', $
         XSTYLE=1, YRANGE=[ymin,ymax], YSTYLE=19, $
         POSITION=[xpos[0],!y.window[0],xpos[1],!y.window[1]], $
         CHARSIZE=charsize, CHARTHICK=charthick, $
         /NOERASE, /NODATA

   ; PLOT THE MEDIAN OF THE CORRECTED DATA IN THE BACKGROUND...
   if not keyword_set(SUBTRACT) then begin
      medmed = median(disp_img,DIMENSION=2) 
      oplot, (medmed-min(medmed)) * $
             (!y.crange[1]-!y.crange[0]) / (max(medmed)-min(medmed)) + $
             !y.crange[0], CO=!gray
   endif
   
   ; OPLOT THE MEDIAN SPECTRUM ON TOP...
   oplot, med_spec

   ; RE-ESTABLISH THE AXIS COORDINATES FOR THE IMAGE...
   !y = bangy_img

endif

end ; flag_rfi_display

;======================================================================

pro flag_rfi_draw_flags, xxout, yyout, flag_mask, $
                         group_spec, blowup, flag_color, $
                         blank_win, canv_win, temp_win, disp_win, $
                         cross_products, XYOUT=xyout, YXOUT=YXOUT

; FLAG_RFI_DISPLAY
; This routine draws the flags on the display window for Robishaw's
; FLAG_RFI routine.

; ANNOTATE THE CANVAS PIXMAP...
wset, canv_win

; DUMP THE BLANK PIXMAP INTO THE CANVAS PIXMAP...
device, COPY=[0,0,!d.x_vsize,!d.y_vsize,0,0,blank_win]

; DUMP THE TEMPLATE PIXMAP INTO THE CANVAS PIXMAP...
; USE XOR GRAPHICS FUNCTION SO THAT WE DON'T OVERWRITE AXIS
; LABELS AND TITLES...
device, COPY=[0,0,!d.x_vsize,!d.y_vsize,0,0,temp_win], $
        GET_GRAPHICS_FUNCTION=gf, SET_GRAPHICS_FUNCTION=6
      
; INDICATE FLAGGED SPECTRA...
group_flagged = where(flag_mask,nflagged)
if (nflagged gt 0) then begin
   
   ; GET THE NORMALIZED Y POSITION OF THE FLAGGED SPECTRA...
   flag_norm = !y.s[0]+!y.s[1]*group_spec[group_flagged]
   
   ; ONLY DRAW FLAG INDICATORS BETWEEN THE IMAGES... DON'T
   ; OVERWRITE THE SPECTRA...
   flag_xpos = cross_products $
               ? [0,$
                  xxout.position[[0,2]],$
                  yyout.position[[0,2]],$
                  xyout.position[[0,2]],$
                  yxout.position[[0,2]],$
                  1] $
               : [0,$
                  xxout.position[[0,2]],$
                  yyout.position[[0,2]],$
                  1]
   for j = 0, nflagged-1 do $
      for k = 0, 5+4*cross_products, 2 do $
         plots, flag_xpos[k+[0,1]], flag_norm[j], /NORM, $
                COLOR=flag_color, THICK=blowup
endif
device, SET_GRAPHICS_FUNCTION=gf

; DUMP THE CANVAS PIXMAP INTO THE DISPLAY WINDOW...
wset, disp_win
device, COPY=[0,0,!d.x_vsize,!d.y_vsize,0,0,canv_win]

end ; flag_rfi_draw_flags

;======================================================================

pro flag_rfi, xx_in, yy_in, xy_in, yx_in, flag_mask, $
              FLAG_FILE=flag_file, $
              FLAG_INIT=flag_init, $
              NGROUP=ngroup, BLOWUP=blowup_in, $
              MEDIAN=median, SILENT=silent, $
              XSIZE=xsize_in, YSIZE=ysize_in, $
              MIN=min_in, MAX=max_in, $
              NCHAN=nchan_in, $
              CURSOR_THICK=cursor_thick, $
              CURSOR_COLOR=cursor_color, $
              CURSOR_STANDARD=cursor_standard, $
              FLAG_COLOR=flag_color, $
              WINDOW=window, $
              _REF_EXTRA=_extra

;+
; NAME:
;       FLAG_RFI
;
; PURPOSE:
;       To flag bad spectra by visual inspection of a full-Stokes data set.
;
; CALLING SEQUENCE:
;        FLAG_RFI, xx, yy [, xy, yx][, flag_mask][,
;              BLOWUP=scalar][, NCHAN=scalar][, NGROUP=scalar][,
;              /MEDIAN][, /SILENT][, FLAG_INIT=vector][,
;              MIN=scalar or 4-element vector][, 
;              MAX=scalar or 4-element vector][, 
;              XSIZE=scalar][, YSIZE=scalar][,
;              CURSOR_THICK=scalar][, CURSOR_COLOR=scalar][,
;              CURSOR_STANDARD=scalar][,
;              FLAG_COLOR=scalar][,
;              FLAG_FILE=scalar string][, WINDOW=scalar]
;
;       Also accepts all keywords for WINDOW and Robishaw's DISPLAY.
;
; INPUTS: 
;       XX, YY - images of each auto-correlation product.  Each must be a
;                  2-dimensional array and arranged with spectral channel
;                  along the first dimension (the columns) and time along
;                  the second dimension (the rows), i.e,
;                  image[channel,time]; in other words, the input is a
;                  vertical stack of spectra. Both the XX and YY images
;                  must be passed together, i.e., one cannot pass only XX
;                  or YY; there must be 2 input images.
;
; OPTIONAL INPUTS:
;       XY, YX - images of each cross-correlation product.  Each must be a
;                2-dimensional array and arranged with spectral channel
;                along the first dimension (the columns) and time along the
;                second dimension (the rows), i.e, image[channel,time]; in
;                other words, the input is a vertical stack of spectra.
;                Both the XY and YX images must be passed together, i.e.,
;                one cannot pass only XY; there must be 4 input images.
;
; OUTPUTS:
;       FLAG_MASK - the vector of flags will be passed out, a byte
;                   vector of length N_SPECTRA.  Set to zero where spectra
;                   are not flagged and one where they are.  This mask can
;                   be used to find the indices of good and bad spectra
;                   using WHERE:
;                   badindx=where(flag_mask,nbad,COMP=goodindx,NCOMP=ngood)
;
; KEYWORD PARAMETERS:
;       BLOWUP = the number of vertical pixels each spectrum will be
;                displayed across; in other words, the number of times each
;                spectrum will be stacked in the vertical direction, a
;                scalar integer.  Default value is 1, i.e., no blowup.
;
;       NCHAN = number of channels that spectra will be binned down to, a
;               scalar integer.  This number must be an integer factor of
;               the original number of channels.  For instance, if the
;               input image is of size [512,1000], you could set NCHAN=128
;               to average together every group of 4 channels.  However,
;               setting NCHAN=100 will fail completely.  We choose to be so
;               restrictive because we use REBIN() to average the channels
;               in the spectral channel direction; using CONGRID(),
;               POLY_2D(), or (obviously) INTERPOLATE() would simply
;               interpolate the data across the spectral channel dimension.
;               If there is a huge spike in one channel it would just be
;               interpolated over rather than averaged into the new image,
;               and it's just such a spike we're trying to find.  Also, why
;               throw out the signal to noise that you gain by averaging
;               channels together?  Therefore, if the number of channels in
;               your input spectra cannot be divided by an integer yet you
;               wish to shrink the image in the spectral channel direction,
;               you must pad your image in this direction or resize the
;               image yourself before calling this routine.  In this way,
;               if you choose to interpolate prior to running this routine
;               and therefore miss RFI spikes, our conscience will be
;               clean.
;
;       NGROUP = number of spectra to stack in each image, a scalar
;                integer.  Default will be calculated to fit as many as
;                possible into the window.
;
;       FLAG_INIT = set this keyword to a previously determined flag mask
;                   and this will serve as the initial flag mask rather
;                   starting from scratch.  Obviously, the input needs to
;                   be a vector (preferably of byte type) whose length must
;                   equal the number of spectra sent in.
;
;       /MEDIAN - if set, then we divide each spectrum in a group by the
;                 median spectrum of that group; this makes for a flat
;                 image to be displayed.  Particularly useful if the
;                 spectra being displayed have not yet been calibrated and
;                 have not had their bandpasses removed.  Two notes:
;                 (1) One typically wants to inspect one's spectra BEFORE
;                 dividing out a bandpass because the OFF spectrum might
;                 have problems; at the very least, inspect the uncorrected
;                 off spectrum before applying it to the ON spectra!
;                 (2) If the group of spectra being displayed contains
;                 copious relatively constant RFI in some channels, then
;                 the median is likely to also contain this RFI.  Upon
;                 dividing by this infected median, the resulting image
;                 will contain black vertical streaks where the spectra are
;                 NOT AFFECTED by the RFI!!
;
;       MIN = the mininum value to be displayed in each image, either a
;             scalar or a 4-element vector.  If not passed, default is to
;             clip image at a few times the RMS of the RFI-excised image.
; 
;       MAX = the maximum value to be displayed in each image, either a
;             scalar or a 4-element vector.  If not passed, default is to
;             clip image at a few times the RMS of the RFI-excised image.
;
;       /SILENT - if set, detailed instructions are not printed to the IDL
;                 screen for the user when viewing the image profiles.
;
;       FLAG_FILE = if this keyword is set to a filename, a scalar string,
;                   then the indices of flagged spectra will be written to
;                   the named file after each group of spectra has been
;                   edited.  This serves two functions: (1) as a safety net
;                   in case anything happens while in the midst of a large
;                   editing job; (2) as a way to store the flags so that
;                   the flagging only needs to be done once.
;
;       FLAG_COLOR = color with which to indicate flagged spectra. Default
;                    is !red.
;
;       CURSOR_COLOR = color with which to draw the full-screen
;                      cursor. Default is !gray.
;
;       CURSOR_THICK = the thickness of full-screen cursor. Default is 3
;                      pixels.
;
;       CURSOR_STANDARD = this keyword can be used to change the cursor
;                         appearance, see IDL help for DEVICE.  The
;                         author's favorite cursor (on Linux X11
;                         anyway) is 129.  The default is the standard
;                         cross-hair cursor, but it can be difficult to
;                         pinpoint positions using this cursor because it
;                         is rather thick.
;
;       XSIZE = the horizontal size of the image display window in pixels,
;               a scalar.  Default value is 90% of the screen width.
;
;       YSIZE = the vertical size of the image display window in pixels, a
;               scalar.  Default value is 90% of the screen height.
;
;       WINDOW = if set to an integer, the program will use the already
;                established window rather than creating a new window.
;
; OUTPUTS:
;       None.
;
; SIDE EFFECTS:
;       Two windows will be opened on the X display; one for displaying an
;       image of the intensity as a function of spectral channel and time,
;       and another to show the intensity profiles versus either row (time)
;       or column (spectral channel).  Three pixmap windows will be created
;       as well, and then destroyed when the program exits.
;
; RESTRICTIONS:
;       The input images must be 2-dimensional and arranged with spectral
;       channel along the first dimension (the columns) and time along the
;       second dimension (the rows).
;
;       If the images need to be shrunk in the spectral channel direction
;       via the NCHAN keyword, the value for NCHAN must be an integral
;       factor of the original number of channels.  This is because we
;       employ REBIN() so that the image is averaged in the spectral
;       channel direction rather than interpolated.  It is after all the
;       RFI spikes that we're trying to find, so interpolating over
;       them is useless.  If the spectra have a number of channels that is
;       not divisible by an integer and yet you need to shrink the image,
;       we suggest padding the images in the spectral channel direction so
;       that the number of channels is divisible by an integer thereby
;       allowing REBIN() to be used.
;
;       This routine is unlikely to work unless the user selects the "Focus
;       follows mouse" or "Focus under mouse" options in the user's window
;       manager.
;
;       Color values must be stored in system variables named after each
;       color; this can be done easily with Robishaw's SETCOLORS routine:
;       IDL> setcolors, /system
;
;       This routine must be run locally; trying to TV over the internet,
;       even with the fastest connections is a losing proposition.  Copy
;       the necessary data to your local machine and run this routine.  It
;       also pays to use a dual-headed display to have as much real estate
;       as possible.
;
; PROCEDURE:
;       A large window 0 is opened and the stacked spectra are displayed
;       for all the input correlation products.  We show them all
;       simultaneously because RFI that shows up in one polarization is
;       often found in the others as well. If spectra are flagged by means
;       of the cursor, the flagged spectra are indicated on the display.
;
;       If the user chooses to look at image profiles, then another window
;       is opened and the user can move the cursor around in window 0 while
;       the column profile (spectrum) of the corresponding position in the
;       image is shown in the PROFILES window.  To switch to row profiles,
;       click the left mouse button. To print out the pixel position, the
;       channel and spectrum numbers, and the intensity of the current
;       pixel, click the middle cursor button.  To exit the profile
;       display, click the right cursor button.
;
; PROCEDURES CALLED:
;       Robishaw's DISPLAY, TR_RDPLOT, and TR_PROFILES
;
; EXAMPLE:
;       We have images of all four correlation products from a night of GBT
;       or Arecibo observing, call these XXIMG, YYIMG, XYIMG, YXIMG. We
;       want to flag any bad spectra and we'd like each displayed
;       spectrum in each image to be expanded across 5 vertical pixels to
;       make the visual detection of any problems easier.  So we set
;       BLOWUP=5.  We'd like to indicate each flagged spectrum with a
;       cyan bar and we'd like the cursor thickness to be 3 pixels wide.
;
;       IDL> flag_rfi, xximg, yyimg, xyimg, yximg, flag_mask, $
;       IDL> BLOWUP=5, THICK=3, CURSOR_THICK=3, 
;       IDL> FLAG_COLOR=!cyan, FLAG_FILE='~/flag.dat'
;
;       After all the flagging is complete, we can retrieve the indices of
;       the flagged and unflagged spectra:
;
;       IDL> flagged = where(flag_mask,n_flagged,$
;       IDL>                 COMP=unflagged,NCOMP=n_unflagged)
;
; NOTES:
;       You can load the color table of your choice before calling
;       FLAG_RFI; the images will be displayed using the current color
;       table. We suggest "loadct, 0" followed by "setcolors, /system"
;       before calling FLAG_RFI.
;
;       Extreme care is taken to not interpolate spectra in time.  In order
;       to spot a single bad spectrum, you need to see each spectrum
;       individually.
;
;       If you are flagging raw, bandpass-uncorrected spectra then it is
;       preferable to flag using /MEDIAN to remove the bandpass shape.  If
;       you are searching for RFI in spectra that have been bandpass and
;       gain corrected, it should be preferable to NOT set /MEDIAN to
;       confirm that the calibrated spectra are properly calibrated.
;
;       Note that flags are toggled on and off with each successive
;       flagging.  So if one spectrum is flagged and then is subsequently
;       included in a range to be flagged, that previously flagged spectrum
;       will be unflagged.
;
;       If the displayed images begin behaving badly, it is likely that the
;       user interrupted the routine via CTRL-C and left IDL in a very
;       confused state; first try to remedy the situation by running
;       RESET_RDPLOT.  If that doesn't work, try restarting IDL.  If that
;       doesn't work, let me know!
;
; TO-DO:
;       * median is wrong for cross products
;         -> what if XX/YY spectra are dist about zero??
;       * better explanation of MIN/MAX
;       * More automatic determination of MIN/MAX for each pol.
;       * what if there is some nasty rfi?
;         -> any good reason to provide channel indices??
;       * Should be a way to adjust y scales for profiles.
;         -> one RFI spike in the image compresses the rest of the spectra!
;       * do we want to flag each pol separately?
;         -> this would be really tough!
;
; MODIFICATION HISTORY:
;	Written by Tim Robishaw, Berkeley  29 Jun 2007
;	Added the WINDOW, FLAG_INIT keywords; set !P.REGION back to 0
;	before splitting T. Robishaw  05 Jul 2007
;       Added the CURSOR_STANDARD keyword. T. Robishaw  08 Jul 2007
;       Added FLAG_RFI_DRAW_FLAGS; if flags are passed in via
;       FLAG_INIT, then these preset flags will be drawn right away on
;       the display. T. Robishaw 01 Feb 2008
;       Corrected titles so that they displayed image number / total
;       images. T. Robishaw 20 Jun 2008
;       Added note about color table. T. Robishaw 13 Apr 2012
;-

;on_error, 2

;forward_function flag_rfi_display

resolve_routine, ['display','tr_rdplot','tr_profiles','interpol', $
                 'flag_rfi_display', 'chauvenet', 'inverf'], $
                 /NO_RECOMPILE, /COMPILE_FULL_FILE, /EITHER

; HOW MANY PARAMETERS WERE PASSED IN...
nparms = N_params()

; WE ONLY ACCEPT EITHER 2 (XX/YY) OR 4 (XX/YY/XY/YX) INPUT PARAMETERS
; AND FORCE THE FLAG_MASK OUTPUT PARAMETER TO BE PASSED...
if (nparms ne 3) AND (nparms ne 5) then $
   message, 'Must either input 2 images (the autocorrelation products '+$
            'XX and YY) or 4 images (the auto and cross products, XX/YY/XY/YX'

; HAS THE USER PASSED IN CROSS-CORRELATION PRODUCTS...
cross_products = nparms eq 5

; MAKE SURE THE IMAGES ARE 2-DIMENSIONAL...
sz = size(xx_in)
if (sz[0] ne 2) then message, 'This is not an image!'
nchan = (N_elements(NCHAN_IN) gt 0) ? nchan_in : sz[1]
nspec = sz[2]

; MAKE SURE ALL IMAGES ARE OF THE SAME SIZE...
if not array_equal((size(yy_in))[0:2],sz[0:2]) $
   then message, 'YY must be of the same size as XX.'
if cross_products then begin
   if not array_equal((size(xy_in))[0:2],sz[0:2]) $
      then message, 'XY must be of the same size as XX.'
   if not array_equal((size(yx_in))[0:2],sz[0:2]) $
      then message, 'YX must be of the same size as XX.'
endif

; SET BACK TO USER'S CURSOR PREFERENCE WHEN DONE...
if (N_elements(CURSOR_STANDARD) eq 0) then begin
   defsysv, '!cursor_standard', EXISTS=cursor_defined
   if cursor_defined $
      then cursor_standard=!cursor_standard
endif

; ARE WE REQUESTING THAT THE SPECTRAL CHANNEL DIMENSION BE INTERPOLATED...
if (N_elements(NCHAN_IN) gt 0) then begin 
   xx = rebin(xx_in,[nchan,nspec])
   yy = rebin(yy_in,[nchan,nspec])
   if cross_products then begin
      xy = rebin(xy_in,[nchan,nspec])
      yx = rebin(yx_in,[nchan,nspec])
   endif
endif else begin
   xx = xx_in
   yy = yy_in
   if cross_products then begin
      xy = xy_in
      yx = yx_in
   endif
endelse

; WE WANT A VERY LARGE WINDOW...
device, Get_Screen_Size=scrnsz

; OPEN THE DISPLAY WINDOW...
if (N_elements(WINDOW) eq 0) then begin
   xsize = (N_elements(XSIZE_IN) eq 0) ? 0.9*scrnsz[0] : xsize_in
   ysize = (N_elements(YSIZE_IN) eq 0) ? 0.9*scrnsz[1] : ysize_in
   window, XSIZE=xsize, YSIZE=ysize, _EXTRA=_extra
   disp_win = !d.window
endif else begin
   wset, window
   disp_win = !d.window
   xsize = !d.x_vsize
   ysize = !d.y_vsize
endelse

; MAKE A TEMPLATE PIXMAP TO DUMP THE IMAGES INTO...
window, /FREE, XSIZE=xsize, YSIZE=ysize, /PIXMAP
temp_win = !d.window

; MAKE A BLANK PIXMAP WINDOW...
window, /FREE, XSIZE=xsize, YSIZE=ysize, /PIXMAP
blank_win = !d.window

; MAKE A CANVAS PIXMAP INTO WHICH WE CAN DUMP THE TEMPLATE AND THEN
; ANNOTATE THE FLAGGED SPECTRA...
window, /FREE, XSIZE=xsize, YSIZE=ysize, /PIXMAP
canv_win = !d.window

; SET UP THE PROFILES WINDOW SIZE...
pxsize = 1200
pysize = 300

; IF BLOWUP KEYWORD IS NOT SET, THEN WE DON'T STACK SPECTRA...
blowup = (N_elements(BLOWUP_IN) eq 0) ? 1 : round(blowup_in)

if (N_elements(FLAG_COLOR) eq 0) then flag_color = !red
if (N_elements(CURSOR_COLOR) eq 0) then cursor_color = !gray
if (N_elements(CURSOR_THICK) eq 0) then cursor_thick = 3

; HAS THE USER SPECIFIED MIN OR MAX VALUES...
case 1 of 
   (N_elements(MIN_IN) eq 0) : min = replicate(!values.f_nan,4)
   (N_elements(MIN_IN) eq 1) : min = replicate(min_in,4)
   (N_elements(MIN_IN) eq 4) : min = min_in 
   else : message, 'MIN keyword must contain either 1 or 4 elements.'
endcase
case 1 of 
   (N_elements(MAX_IN) eq 0) : max = replicate(!values.f_nan,4)
   (N_elements(MAX_IN) eq 1) : max = replicate(max_in,4)
   (N_elements(MAX_IN) eq 4) : max = max_in 
   else : message, 'MAX keyword must contain either 1 or 4 elements.'
endcase

; DEFINE THE IMAGE REGIONS...
xreg = findgen(2+2*cross_products)/(2+2*cross_products)
dxreg = 1./(2+2*cross_products) * (1.0 - 0.12*keyword_set(MEDIAN))
yreg = keyword_set(MEDIAN) ? [0.15,1.0] : [0,1]

; DISPLAY SPECTRA AS A FUNCTION OF POSITION...
; BREAK POSITIONS INTO GROUPS...
if (N_elements(NGROUP) eq 0) $
   then ngroup = floor((yreg[1]-yreg[0])*0.90*ysize/blowup)
nimgs = ceil(float(nspec)/ngroup) ; total number of images in dataset

; PRINT FLAGGING INSTRUCTIONS...
if not keyword_set(SILENT) then begin
 message, 'Double left click on a spectrum to flag a single spectrum.', /INFO
 message, 'Single left click on a spectrum to begin flagging a range.', /INFO
 message, 'Single middle click on a spectrum to end flagging a range.', /INFO
 message, 'Single right click to stop flagging.', /INFO
 message, 'Unflag spectra by selecting them a second time.', /INFO
endif

; DEFINE THE FLAG MASK...
if (N_elements(FLAG_INIT) gt 0) then begin
   if (N_elements(FLAG_INIT) ne nspec) $
      then message, 'FLAG_INIT keyword must be a flag mask of length '+$
                    strtrim(nspec,2) $
      else flag_mask = flag_init
endif else flag_mask = bytarr(nspec)

; OPEN THE FLAGGING FILE FOR WRITING...
; THIS OVERWRITES ANY EXISTING FILE, SO BE CAREFUL...
if (N_elements(FLAG_FILE) gt 0) then begin
   message, 'Indices of flagged spectra being written to file '+flag_file, $
            /INFO
   openw, lun, flag_file, /GET_LUN
endif

; GO THROUGH EACH GROUP OF SPECTRA...
for i = 0l, nimgs-1l do begin

   ; NUMBER OF SPECTRA WE'LL BE DISPLAYING IN THIS IMAGE...
   start = i*ngroup
   stop = ((i+1)*ngroup-1)<(nspec-1)

   group_spec = start + lindgen(ngroup) ; the indices of this group

   ptitle = 'Image '+strtrim(i+1,2)+' / '+strtrim(nimgs,2)+'!C'

   ; DISPLAY THE IMAGES IN THE TEMPLATE PIXMAP...
   wset, temp_win

   ;================================================================
   ; XX...
   flag_rfi_display, xx[*,start:stop], start, stop, blowup, $
                     FLAG_MASK=flag_mask[start:stop], $
                     NCHAN=nchan, MIN=min[0], MAX=max[0], $
                     MEDIAN=keyword_set(MEDIAN), $
                     TIT='XX '+ptitle, YMARGIN=[3,3], $
                     XTIT='Channel', YTIT='Spectrum Index', $
                     IMG_REGION=[xreg[0],yreg[0],xreg[0]+dxreg,yreg[1]],$
                     MED_REGION=[xreg[0],0,xreg[0]+dxreg,yreg[0]],$
                     CHARSIZE=1.0, CHARTHICK=1.0, $
                     _EXTRA=_extra, OUT=xxout

   ;================================================================
   ; YY...
   flag_rfi_display, yy[*,start:stop], start, stop, blowup, $
                     FLAG_MASK=flag_mask[start:stop], $
                     NCHAN=nchan, MIN=min[1], MAX=max[1], $
                     MEDIAN=keyword_set(MEDIAN), $
                     TIT='YY '+ptitle, YMARGIN=[3,3], $
                     XTIT='Channel', YTIT='Spectrum Index', $
                     IMG_REGION=[xreg[1],yreg[0],xreg[1]+dxreg,yreg[1]],$
                     MED_REGION=[xreg[1],0,xreg[1]+dxreg,yreg[0]],$
                     CHARSIZE=1.0, CHARTHICK=1.0, $
                     _EXTRA=_extra, OUT=yyout, /NOERASE

   if cross_products then begin

      crossgain = sqrt(median(xx[*,start:stop],DIM=2) * $
                       median(yy[*,start:stop],DIM=2))

      ;================================================================
      ; XY...
      flag_rfi_display, xy[*,start:stop], start, stop, blowup, $
                        FLAG_MASK=flag_mask[start:stop], $
                        NCHAN=nchan, MIN=min[2], MAX=max[2], $
                        MEDIAN=keyword_set(MEDIAN), $
                        TIT='XY '+ptitle, YMARGIN=[3,3], $
                        XTIT='Channel', YTIT='Spectrum Index', $
                        IMG_REGION=[xreg[2],yreg[0],xreg[2]+dxreg,yreg[1]],$
                        MED_REGION=[xreg[2],0,xreg[2]+dxreg,yreg[0]],$
                        CROSS_GAIN=crossgain, SUBTRACT=keyword_set(MEDIAN), $
                        CHARSIZE=1.0, CHARTHICK=1.0, $
                        _EXTRA=_extra, OUT=xyout, /NOERASE
      
      ;================================================================
      ; YX...
      flag_rfi_display, yx[*,start:stop], start, stop, blowup, $
                        FLAG_MASK=flag_mask[start:stop], $
                        NCHAN=nchan, MIN=min[3], MAX=max[3], $
                        MEDIAN=keyword_set(MEDIAN), $
                        TIT='YX '+ptitle, YMARGIN=[3,3], $
                        XTIT='Channel', YTIT='Spectrum Index', $
                        IMG_REGION=[xreg[3],yreg[0],xreg[3]+dxreg,yreg[1]],$
                        MED_REGION=[xreg[3],0,xreg[3]+dxreg,yreg[0]],$
                        CROSS_GAIN=crossgain, SUBTRACT=keyword_set(MEDIAN), $
                        CHARSIZE=1.0, CHARTHICK=1.0, $
                        _EXTRA=_extra, OUT=yxout, /NOERASE
      
      ;================================================================

   endif

   if (total(flag_mask[start:stop]) gt 0) then begin

      ; IF THE FLAG_INIT KEYWORD IS NON-ZERO THEN DISPLAY THE
      ; INITIAL FLAGS...
      flag_rfi_draw_flags, xxout, yyout, flag_mask[start:stop], $
                           group_spec, blowup, flag_color, $
                           blank_win, canv_win, temp_win, disp_win, $
                           cross_products, XYOUT=xyout, YXOUT=YXOUT

   endif else begin

      ; DUMP THE TEMPLATE PIXMAP INTO THE CANVAS PIXMAP...
      wset, canv_win
      device, COPY=[0,0,!d.x_vsize,!d.y_vsize,0,0,temp_win]

      ; DUMP THE TEMPLATE PIXMAP INTO THE DISPLAY WINDOW...
      wset, disp_win
      device, COPY=[0,0,!d.x_vsize,!d.y_vsize,0,0,temp_win]

   endelse

   match_str = cross_products ? '[f1-4]' : '[f12]'
   io = '1'
   while strmatch(io,match_str,/FOLD_CASE) do begin
      
      ; OFFER THE USER A MENU TO SELECT THE NEXT STEP...
      print, 'Profiles: '+(cross_products ? '<1|2|3|4>' : '<1|2>')+$
             '; Flag: <f>; Next: <ANY OTHER KEY>.', $
             FORM='($,A,%"\R")'

      io = get_kbrd(1)

      ;=====================

      ; IF THE USE HAS PRESSED ANY OTHER KEY, MOVE TO NEXT IMAGE...
      if not strmatch(io,match_str,/FOLD_CASE) then continue

      ;=====================

      ; IF USER HITS THE <F> KEY, FLAG THE CURRENT IMAGE...
      if strmatch(io,'f',/FOLD_CASE) then begin

         ; DOUBLE LEFT CLICK ON A SPECTRUM TO FLAG A SINGLE SPECTRUM
         ; SINGLE LEFT CLICK ON SPECTRUM TO START FLAGGING A RANGE...
         ; SINGLE MIDDLE CLICK ON A SPECTRUM TO END A FLAGGING RANGE...
         ; RIGHT CLICK TO STOP EDITING.
         
         ; CLEAR THE INSTRUCTIONS...
         print, '', FORM='($,A60,%"\R")'

         flag_start = -1
         flag = -1
         range_find_on = 0b
         !mouse.button = 0l
         button_pushed = 0l
         while (button_pushed ne 4) do begin
            
            ; PLACE A FULL-SCREEN CURSOR ON THE FLAGGING WINDOW...
            tr_rdplot, x, y, /NOCLIP, /FULL, $
                       COLOR=cursor_color, THICK=cursor_thick, /CHANGE, $
                       CURSOR_STANDARD=cursor_standard

            ; WAIT FOR THE BUTTON TO BE RELEASED...
            button_pushed = !mouse.button
            if (button_pushed gt 0) then $
               while (!mouse.button gt 0) do cursor, xfoo, yfoo, /NOWAIT 

            ; IF THE RIGHT BUTTON IS CLICKED, THEN JUST SPLIT...
            if (button_pushed eq 4) then break

            ; PREVENT USER FROM FLAGGING OUTSIDE OF IMAGE...
            if (y gt !y.crange[1]) OR (y lt !y.crange[0]) then continue
            
            y = round(y)
            
            ; HAVE WE INITIATED A FLAG RANGE...
            if (button_pushed eq 1) then begin

               ; IS THIS A SECOND LEFT CLICK...
               if range_find_on then begin
                  ; IF WE HAVEN'T MOVED THE MOUSE AND THIS IS OUR SECOND
                  ; LEFT CLICK THEN WE FLAG ONLY THE SPECTRUM UNDER THE
                  ; CURSOR...
                  if (flag_start eq y) then begin
                     flag = flag_start
                     range_find_on = 0b
                     msg = 'Flagging spectrum: '+strtrim(flag,2)
                     print, msg, '', FORM='(A,A'+$
                            string((60-N_elements(msg))>0)+')'
                     flag_mask[flag] = flag_mask[flag] XOR 1b
                     goto, plot_flags
                  endif else begin
                     ; IF WE MOVED THE CURSOR SINCE BEGINNING THE FLAG
                     ; RANGE, THEN WE ASSUME USER IS ASKING FOR A NEW
                     ; BEGINNING...
                     flag_start = y
                     print, 'Range now starting at spectrum '+strtrim(y,2), $
                            '', FORM='($,A,A30,%"\R")'
               endelse
               endif else begin
                  ; THE USER IS ASKING TO BEGIN A NEW FLAG RANGE...
                  range_find_on = 1b
                  flag_start = y
                  print, 'Range now starting at spectrum '+strtrim(y,2), '', $
                         FORM='($,A,A30,%"\R")'
               endelse
            endif
            
            ; CHECK TO SEE IF WE'RE ENDING THE FLAG RANGE...
            if (button_pushed eq 2) AND range_find_on then begin
               nflag = abs(y-flag_start)
               flag = flag_start - nflag*(y lt flag_start) + lindgen(nflag+1)
               flag_start = -1
               range_find_on = 0b
               flag_str = strjoin(strcompress(flag))
               msg = 'Flagging spectra: '+flag_str
               print, msg, '', FORM='(A,A'+string((60-N_elements(msg))>0)+')'
               flag_mask[flag] = flag_mask[flag] XOR 1b
               goto, plot_flags
            endif 

            continue
         
            ;=====================
            
            plot_flags:
            
            flag_rfi_draw_flags, xxout, yyout, flag_mask[start:stop], $
                                 group_spec, blowup, flag_color, $
                                 blank_win, canv_win, temp_win, disp_win, $
                                 cross_products, XYOUT=xyout, YXOUT=YXOUT
            
         endwhile ; not right mouse button

      endif

      ;=====================

      ; IF THE USER SELECTS 1-4, SHOW CORRESPONDING PROFILES...
      if strmatch(io,'[1-4]') then begin
         case io of 
            '1' : out = xxout
            '2' : out = yyout
            '3' : out = xyout
            '4' : out = yxout
         endcase
         
         ; CALL TR_PROFILES WITH USEFUL OPTIONS...
         !x.window = out.position[[0,2]]
         !y.window = out.position[[1,3]]
         !p.region=0
         tr_profiles, out.image_unscaled, /AXIS, $
                      ; THE LOWER LEFT CORNER OF THE AXES...
                      SX=out.position[0]*!d.x_vsize, $
                      SY=out.position[1]*!d.y_vsize, $
                      ; LET'S ALWAYS STICK THE PROFILE WINDOW IN THE UPPER RIGHT...
                      XSIZE=pxsize, YSIZE=pysize, $
                      XPOS=scrnsz[0]-pxsize, YPOS=0, $
                      ; LET'S MAKE A FULL-SCREEN GREEN CURSOR...
                      CLENGTH=1.0, /CCLIP, CCOLOR=!green, _EXTRA=_extra,$
                      SILENT=keyword_set(SILENT)
      endif

      ;=====================

   endwhile ; string matches f1-4

   ; IF A FILENAME HAS BEEN SUPPLIED, WE DUMP THE INDICES OF THE FLAGGED
   ; SPECTRA FOR THIS GROUP INTO A DATA FILE...
   if (N_elements(FLAG_FILE) gt 0) then begin
      group_flagged = where(flag_mask[start:stop],nflagged)
      if (nflagged gt 0) then begin
         printf, lun, transpose(group_spec[group_flagged])
      endif
   endif

endfor


; CLEAR THE INSTRUCTIONS...
print, '', FORM='($,A60,%"\R")'

; DELETE ALL THE PIXMAP WINDOWS WE'VE OPENED...
wdelete, blank_win, canv_win, temp_win

; CLOSE THE FLAG FILE...
if (N_elements(FLAG_FILE) gt 0) then begin
   message, 'Indices of flagged spectra written to file '+flag_file, /INFO
   free_lun, lun
endif

; IF IMG_REGION WAS SENT, THEN PUT REGION BACK TO ZERO...
if (N_elements(IMG_REGION) eq 4) then !p.region = 0

;!!!!!!!!!!!!!!!!!!!!
; THIS IS A KLUDGE... SHOULD BE SMARTER WAY OF FIGURING OUT WHY THIS IS
; NECESSARY...
!p.region=0

end ; flag_rfi
