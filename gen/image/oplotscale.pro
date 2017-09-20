pro oplotscale, xcenter, ycenter, scale, scale_string, $
                ABOVE=above, BELOW=below, LEFT=left, RIGHT=right, $
                NOHAT=nohat, THICK=thick, COLOR=color, $
                CHARSIZE=charsize, CHARTHICK=charthick, FONT=font
;+
; NAME:
;       OPLOTSCALE
;
; PURPOSE:
;       Draw a scale bar on an already-existing plot.
;
; CALLING SEQUENCE:
;       OPLOTSCALE, xcenter, ycenter, scale, scale_string [,
;       /ABOVE | /BELOW | /LEFT | /RIGHT] [, /NOHAT] [, THICK=value] [, 
;       COLOR=value] [, CHARSIZE=value] [, CHARTHICK=value] [, 
;       FONT=integer]
;
; INPUTS:
;       XCENTER - Horizontal coordinate used to position the center
;                 of the scale bar.  Must be given in DATA coordinates.
;
;       YCENTER - Vertical coordinate used to position the center
;                 of the scale bar.  Must be given in DATA coordinates.
;
;       SCALE - The length of the scale bar in DATA coordinates.
;
;       SCALE_STRING - String containing the scale size and units of
;                      the scale bar.
;
; OUTPUTS:
;       None.
;
; KEYWORD PARAMETERS:
;       /ABOVE - Places the scale bar annotation ABOVE the scale bar;
;                this is the default.
;
;       /BELOW - Places the scale bar annotation BELOW the scale bar.
;
;       /LEFT - Places the scale bar annotation to the left of the
;               scale bar.
;
;       /RIGHT - Places the scale bar annotation to the right of the
;                scale bar.
;
;       /NOHAT - If this keyword is set, the scale bar is drawn without 
;                hats at each end.  Default is to draw hats.
;
;       THICK = The line thickness.
;
;       COLOR = The color index of the scale bar and the scale text.
;
;       CHARSIZE = The overall character size for the annotation of the 
;                  scale.
;
;       CHARTHICK = An integer value specifying the line thickness of 
;                   characters.
;
;       FONT = An integer that specifies the graphics text font system to 
;              use. Set FONT equal to 0 (zero) to select the device font 
;              (e.g., PostScript font).
;
; COMMON BLOCKS:
;       None.
;
; SIDE EFFECTS:
;       A scale bar is drawn on the current display device.
;
; RESTRICTIONS:
;       A plot must already be established.  All inputs must be in
;       DATA coordinates.
;
; EXAMPLE:
;       A map has been established on the display device.  Choose a
;       nice uncluttered place to draw the scale bar using the
;       cursor:
;
;       IDL> cursor, x, y
;
;       Now display the scale bar and its annotation:
;
;       IDL> oplotscale, x, y, scale, scale_string
;
;       To place the annotation to the right of the scale bar, set the
;       /RIGHT keyword:
;
;       IDL> oplotscale, x, y, scale, scale_string, /RIGHT
;
;       To place the annotation below the scale bar, set the /BELOW
;       keyword; to remove the hats at each end of the scale bar, set
;       the /NOHAT keyword:
;
;       IDL> oplotscale, x, y, scale, scale_string, /BELOW, /NOHAT
;
; NOTES:
;       Defaults:
;       (1) Plots hats at the each end of scale bar.  The hats will
;           have the height of one character.  Set the /NOHAT keyword
;           to exclude the hats.
;
;       (2) Places the scale annotation above the scale bar.  Set the
;           /LEFT, /RIGHT, or /BELOW keywords to place the text to the
;           right of, to the left of, or below the scale bar,
;           respectively.
;
; RELATED PROCEDURES:
;       OPLOTBEAM
;
; MODIFICATION HISTORY:
;   26 Mar 2004  Written by Tim Robishaw, Berkeley
;   31 Mar 2004  Added /LEFT, /RIGHT, /BELOW keywords. TR
;-

on_error, 2

; ERROR CHECK...
if (N_params() lt 4) then message, 'Incorrect number of arguments.'

; SET DEFAULT VALUES...
if not keyword_set(CHARSIZE) then charsize=1

; GET THE CHARACTER SIZE IN DATA COORDINATES...
data_x_ch_size = charsize * !d.x_ch_size / !x.s[1] / !d.x_vsize
data_y_ch_size = charsize * !d.y_ch_size / !y.s[1] / !d.y_vsize

; PLOT THE SCALE BAR...
plots, xcenter + 0.5*scale*[-1,1], ycenter*[1,1], COLOR=color, THICK=thick

if not keyword_set(NOHAT) then begin
  ; MAKE HAT THE SIZE OF ONE CHARACTER...
  hat = 0.5 * data_y_ch_size

  ; PLOT THE HATS AT THE END...
  plots, xcenter+0.5*scale*[1,1], ycenter+hat*[-1,1], COLOR=color, THICK=thick
  plots, xcenter-0.5*scale*[1,1], ycenter+hat*[-1,1], COLOR=color, THICK=thick
endif

case 1 of 
    ; PLACE THE SCALE SIZE ONE CHARACTER TO THE LEFT OF THE SCALE BAR...
    keyword_set(LEFT) : begin
        xstr = xcenter - (1-2*(!x.s[1] lt 0)) * 0.5*scale - data_x_ch_size
        ystr = ycenter - 0.35*data_y_ch_size
        align = 1.0
    end
    ; PLACE THE SCALE SIZE ONE CHARACTER TO THE RIGHT OF THE SCALE BAR...
    keyword_set(RIGHT) : begin
        xstr = xcenter + (1-2*(!x.s[1] lt 0)) * 0.5*scale + data_x_ch_size
        ystr = ycenter - 0.35*data_y_ch_size
        align = 0.0
    end
    ; PLACE THE SCALE SIZE BELOW THE SCALE BAR...
    keyword_set(BELOW) : begin
        xstr = xcenter
        ystr = ycenter - 1.5*data_y_ch_size
        align = 0.5
    end
    ; DEFAULT:
    ; PLACE THE SCALE SIZE ABOVE THE SCALE BAR...
    else : begin
        xstr = xcenter
        ystr = ycenter + data_y_ch_size
        align = 0.5
    end

endcase

; PLACE THE SCALE ANNOTATION APPROPRIATELY...
xyouts, xstr, ystr, scale_string, ALIGNMENT=align, $
        COLOR=color, CHARSIZE=charsize, CHARTHICK=charthick, FONT=font

end; oplotscale
