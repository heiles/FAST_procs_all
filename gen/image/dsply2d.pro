pro dsply2d, $
                c_img, i_img, $
                xaxis, yaxis, $
                c_title, i_title, $
                intmin=intmin, intmax=intmax, $
                PS=ps, GAMMA=gamma, CAPTION=caption, $
                ENCAPSULATED=encapsulated, $
                EPOCH=epoch, $
		style= style, xaxlbl=xaxlbl, yaxlbl=yaxlbl, $
                _REF_EXTRA=_extra, xpage=xpage, ypage=ypage, $
	gryrev=gryrev, original=original, c_range=c_range, filename=filename

;+
;it is much more flexible to use the combo of colorbar and tv, as we did for
;snez_stream. need to write a simple wrapper to do that.

;**** ----> congrids all images to 541 by 541 <------*****.

;NAME:
;dsply2d -- display intensity/color (2d color image) using pseudocolor table
; KEYWORDS: ENCAPSULATED
;
;c_img is the color image. trim min max and leave in original units as float
;i_img is the intensity image. trim min max and leave in original units as float
;...i_img should be properly scaled, zero to max. 
;if INTMIN is not set, it displays image between min and max intensities,
;black to full. normally, set INTMIN equal to zero. 
;
;style =1 means put axes on the image; 5 means not.
;xaxlbl and yaxlbl are the x and y axis labels.
;
;c_range: specify labels of colorbar; otherwise, label is 1 to 255
;
; the ps device is closed; if you want to annotate after callig, modify
; the program so that psclose is not called (last few lines). 
;
; !!!!! PROBABLY SMARTER WAY TO DO CONGRID THAN JUST TAKING 541 PIXELS???
; !!!!! WHAT DO WE DO ABOUT VALUES WE REALLY WANT TO IGNORE?
; A COLOR FIELD WITH VALUES FROM -320 TO -200 WILL HAVE A BUNCH
; OF ZEROS WHERE THERE'S NO DATA.  WHAT IF COLOR STRETCHED FROM -10 TO
; +10, THEN TROUBLE CITY.  --> NAN!!!!
;
;gryrev: set if this is a negative (bright means small) 
;       instead of pos (bright means large)
;original: use original pseudo; defalt is pseudo_ch
;
;UNUSED KEYWORDS:
;epoch is meaningless
;       caption, xpage, ypage...deal with sizing ps output, not useful?
;
;history: 16nov2007 carl changed default to pseudo_ch. setting 'original'
;         does the originally-conceived pseudo color table
;       16nov2007 appllied 'scheme2' to the bar as well as the image; they
;       were treated differently.
;       16hov2007 made default gamma 1.0 instead of 0.8
;-

csz = size(c_img)
isz = size(i_img)
if (csz[0] ne 2) OR (isz[0] ne 2) $
  then message, 'Images must both be two-dimensional.'
if (total(csz[1:2] - isz[1:2]) ne 0) $
  then message, 'Images must have the same dimensions.'

; IF THERE'S A WINDOW OPEN, ERASE THE CONTENTS FIRST!
if keyword_set(ps) eq 0 and (!d.window ge 0) then erase

    charsize=1.0
    charthick=1.0

;========================================================================
; THE PRINTABLE AREA ON AN 8.5 X 11 INCH PAGE IS 7.5 X 10 INCHES 
; (19 X 25 CM)... FOR APJ IT'S (18.5 X 24.75)
; IF PRINTING IN A JOURNAL, GIVE ABOUT 2 CM IN Y FOR THE CAPTION!
if keyword_set( xpage) eq 0 then xpage = 18.5 / 2.54 ; inches
if keyword_set( ypage) eq 0 then $
	ypage = (24.75 - 2.0 * keyword_set(CAPTION)) / 2.54 ; inches
aspectpage = xpage / ypage

;================= DEFINE THE REGIONS TO BE PLOTTED ======================

; WHAT IS THE PIXEL SIZE OF THE PLOT?
xplotsizepix = 541
yplotsizepix = 541

; CREATE A LITTLE EXTRA SPACE AROUND THE IMAGE FOR PLOT LABELS...
yblank       = 20  ; BLANK SPACE BETWEEN COLORBAR AND IMAGE
ywedge       = 80  ; HEIGHT OF COLORBAR
yextrabottom = 50  ; BLANK SPACE AT BOTTOM
yextratop    = 50  ; BLANK SPACE AT TOP
xextraleft   = 80  ; BLANK SPACE AT LEFT
xextraright  = 50  ; BLANK SPACE AT RIGHT

; WINDOW SIZE IN PIXELS; INCLUDE MARGINS...
wxsize = xextraleft + xplotsizepix + xextraright
wysize = yextrabottom + yplotsizepix + yblank + ywedge + yextratop

; DEFINE THE PLOT SIZE IN **NORMAL** COORDINATES...
xplotsize = xplotsizepix/float(wxsize)
yplotsize = yplotsizepix/float(wysize)

; DEFINE THE **NORMAL** COORDINATES OF THE TV WINDOW...
ytvbottom = float(yextrabottom)/float(wysize)
ytvtop    = ytvbottom + yplotsize
xtvleft   = float(xextraleft)/float(wxsize)
xtvright  = xtvleft + xplotsize

; DEFINE THE **NORMAL** COORDINATES OF THE BAR WINDOW...
ybarsize   = float(ywedge)/float(wysize)
ybarbottom = float(yextrabottom + yplotsizepix + yblank)/float(wysize)
ybartop    = ybarbottom + ybarsize

;=========================================================================

; DEFINE THE INTENSITY ...
; INTIMG = A 541 BY 541 ARRAY, ARBITRARY UNITS AND RANGE 
; IT DEFINES THE INTENSITY
intimg = congrid(i_img, xplotsizepix, yplotsizepix)

; DEFINE THE VELOCITY/CHANNEL CONVERSION...
; DEFINE A VELOCITY FOR EACH PIXEL IN THE IMAGE.
; COLORIMG1 = A 541 BY 541 ARRAY WITH ARBITRARY UNITS AND RANGE.
; IT DEFINES THE COLOR
colorimg = congrid(c_img, xplotsizepix, yplotsizepix)

; MIN AND MAX INTENSITIES TO DISPLAY...
; INTMIN IS BLACK, INTMAX IS MAX INTENSITY, INTGAMMA IS THE GAMMA.
; THE DISPLAYED INTENSITY IS...
; DISPLAYED INTENSITY = ((INTIMG-INTMIN)/(INTMAX-INTMIN))^INTGAMMA
if n_elements( intmin) eq 0 then intmin = min(intimg, /NAN)
if n_elements( intmax) eq 0 then intmax = max(intimg, /NAN)

; SELECT GAMMA...
;if not keyword_set(GAMMA) then gamma = 0.8
if not keyword_set(GAMMA) then gamma = 1.0

; THESE PARAMETERS DEFINE THE MIN AND MAX VEL OF THE COLOR RANGE.
; COLORMIN CORRESPONDS TO ONE COLOR EXTREME
; COLORMAX CORRESPONDS TO THE OTHER COLOR EXTREME.
colormin = min(c_img[where(c_img ne 0)], max=colormax, /NAN) 

; TELL US ABOUT RANGE...
message, string(intmin, intmax,$
                format='("Intensity Range : [ ",F8.2,",",F8.2," ]")')+$
         string(gamma,format='(", Gamma : ",f10.5)'), /INFO
message, string(colormin, colormax,$
                format='("    Color Range : [ ",F8.2,",",F8.2," ]")'), /INFO

; DEFINE THE COLOR PART OF THE COLORBAR...
colorbar = (colormin + $
            double(colormax-colormin) * $
            dindgen(xplotsizepix)/(xplotsizepix-1)) $
           # (dblarr(ywedge)+1)

; SCALE THE COLOR PART OF THE COLORBAR FROM 0 TO 255.
colorbar = bytscl(reverse(colorbar,1), MIN=colormin, MAX=colormax)

; TAKE CARE OF PLOTTING DEVICE DEFINITIONS...
if keyword_set(PS) then begin

if keyword_set( filename) eq 0 then filename='dsply2d.ps'
!p.font= 0
    ; DETERMINE THE CORRECT PLOT SIZE...
    aspectimg = float(wxsize) / float(wysize)
    if (aspectimg ge aspectpage) then begin
        xsize = xpage
        ysize = xpage / aspectimg
    endif else begin
        ysize = ypage
        xsize = ypage * aspectimg
    endelse

    ; SET UP THE OFFSETS...
    ; !!! SHOULDN'T MATTER IF ENCAPSULATED, NO???
    xoffset = (8.5-xsize)*0.5 * (keyword_set(EPS) eq 0)
    yoffset = (11.-ysize)*0.5 * (keyword_set(EPS) eq 0)

    charsize=1.0
    charthick=1.7
psopen, filename, xsize=xsize, /inch,/color,ysize=ysize, /times, /bold, /isolatin1

endif else window, 13, ysize=wysize, xsize=wxsize

;DEFINE THE COLORTABLE...
pseudo_ch, colr, original=original ;;, notvlct=notvlct

;================= CREATE THE COLORBAR ===============

thick = 1.0 + 2.0 * keyword_set(PS)

; DEFINE THE INTENSITY PART OF THE COLORBAR...
intbar = (intmin + $
          double(intmax-intmin) * $
          dindgen(ywedge)/(ywedge-1)) $
         ## (dblarr(xplotsizepix)+1)
; THE FOLLOWING IS 'SCHEME2'
intbar = ((intbar-intmin)/(intmax-intmin))^gamma
redbar = byte( (0 > (intbar*colr[colorbar, 0])) < 255)
grnbar = byte( (0 > (intbar*colr[colorbar, 1])) < 255)
blubar = byte( (0 > (intbar*colr[colorbar, 2])) < 255)


;================== CREATE THE IMAGE =================;
; SCALE THE COLOR PART OF THE IMAGE FROM 0 TO 255.
colordenom = float(colormax-colormin)
colorimg1 = (0. > ( float( colormax-colorimg)/colordenom)) < 1.0
colorimg = byte( (0. > (255.*colorimg1)) < 255.5)

; THE FOLLOWING IS 'SCHEME2'
intimg = (((intimg-intmin)/(intmax-intmin)) > 0)^gamma
redimg = byte( (0 > (intimg*colr[colorimg, 0])) < 255)
grnimg = byte( (0 > (intimg*colr[colorimg, 1])) < 255)
bluimg = byte( (0 > (intimg*colr[colorimg, 2])) < 255)

;================== DISPLAY THE COLORBAR AND IMAGE ========

; DISPLAY THE IMAGE INTERLEAVED DATA CUBE...
loadct,0

    tv, [[[redimg]], [[grnimg]], [[bluimg]]], $
      xtvleft, ytvbottom, ysize=yplotsize, xsize=xplotsize, $
      /normal, true=3


    tv, [[[redbar]], [[grnbar]], [[blubar]]], $
      xtvleft, ybarbottom, ysize=ybarsize, xsize=xplotsize, $
      /normal, true=3


;============= WRITE ANNOTATIONS, AXES, ETC...

setcolors,/dev
; CREATE THE COLORBAR PLOT AREA.
yrnge= [intmin,intmax]
if keyword_set( gryrev) then yrnge=reverse( yrnge)

plot, [colormin, intmin], /noerase, /nodata, $
      xstyle=5, ystyle=5, $
      yrange=yrnge, xrange=[colormin, colormax],  $
      position=[xtvleft, ybarbottom, xtvright, ybartop], /normal

; DISPLAY THE X AXIS ON THE TOP OF THE BAR.
if n_elements( c_range) ne 2 then c_range=[colormin, colormax]
axis, xaxis=1, xstyle=1, xrange=c_range, $
      xticks=4, xminor=2, xticklen=1, xthick=thick, $
      charsize=charsize, charthick=charthick

; XYOUTS THE X-AXIS TITLE... TOO STUFFY WHEN AXIS PLACES IT!
titlepos = 2*float(!d.y_ch_size)/!d.y_size
xyouts, xtvleft+0.5*xplotsize-0.05, ybartop+titlepos, c_title, $
        /normal, charsize=charsize, charthick=charthick

; PLOT THE Y AXIS ON THE LEFT OF THE BAR.
axis, yaxis=0, ystyle=1, yrange=yrnge, $
      yticks=2, yminor=2, yticklen=1, ythick=thick, $
      ytitle=i_title, charsize=charsize, charthick=charthick

; OVERPLOT THE BOUNDARY TO SHARPEN CORNERS...
corners = [0,0,0,1,1,1,1,0,0,0,0,1]
for i = 0, 4 do $
  plots, [!x.window[corners[2*i]], !x.window[corners[2*(i+1)]]], $
         [!y.window[corners[2*i+1]], !y.window[corners[2*(i+1)+1]]], $
         /NORMAL, THICK=thick

;======================================================


; X(Y)STYLE=5 SUPPRESSES THE AXIS AND FORCES THE EXACT RANGE.
if keyword_set( style) eq 0 then style= 5
if keyword_set( xaxlbl) eq 0 then xaxlbl= ''
if keyword_set( yaxlbl) eq 0 then yaxlbl= ''

plot, xaxis, yaxis, xstyle=style, ystyle=style, $
	xtit= xaxlbl, ytit= yaxlbl, $
;      xrange=[max(xaxis),min(xaxis)], $
;      yrange=[min(yaxis),max(yaxis)], $
      position=[xtvleft, ytvbottom, xtvright, ytvtop], /normal, $
      /noerase, /nodata

; OVERPLOT THE BOUNDARY TO SHARPEN CORNERS...
corners = [0,0,0,1,1,1,1,0,0,0,0,1]
for i = 0, 4 do $
  plots, [!x.window[corners[2*i]], !x.window[corners[2*(i+1)]]], $
         [!y.window[corners[2*i+1]], !y.window[corners[2*(i+1)+1]]], $
         /NORMAL, THICK=thick

if keyword_set(PS) then begin
	psclose
	!p.font = -1
        setcolors,/sys
endif

end; dsply2

