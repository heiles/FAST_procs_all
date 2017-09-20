pro ct_stretch, low, high, gamma, CHOP=chop, OVERWRITE=overwrite
;+
; NAME:
;	CT_STRETCH
;
; PURPOSE:
;	Stretch the image display color tables so the full range 
;	runs from one color index to another.
;
; CATEGORY:
;	Image processing, point operations.
;
; CALLING SEQUENCE:
;	CT_STRETCH, Low, High [, Gamma] [, /CHOP] [, /OVERWRITE]
;
; INPUTS:
;	Low:	The lowest pixel value to use.  If this parameter is omitted,
;		0 is assumed.  Appropriate values range from 0 to the number 
;		of available colors-1.
;
;	High:	The highest pixel value to use.  If this parameter is omitted,
;		the number of colors-1 is assumed.  Appropriate values range 
;		from 0 to the number of available colors-1.
;
; OPTIONAL INPUTS:
;	Gamma:	Gamma correction factor.  If this value is omitted, 1.0 is 
;		assumed.  Gamma correction works by raising the color indices
;		to the Gamma power, assuming they are scaled into the range 
;		0 to 1.
;
; KEYWORD PARAMETERS:
;	/CHOP:	If this keyword is set, color values above the upper threshold
;		are set to color index 0.  Normally, values above the upper 
;		threshold are set to the maximum color index.
;
;       /OVERWRITE: The original color table stored in the "colors"
;                   common block is overwritten with the reversed
;                   color table.
;
; OUTPUTS:
;	No explicit outputs.
;
; COMMON BLOCKS:
;	COLORS:	The common block that contains R, G, and B color
;		tables loaded by LOADCT, HSV, HLS and others.
;
; SIDE EFFECTS:
;	Image display color tables are loaded.
;
; RESTRICTIONS:
;	Common block COLORS must be loaded before calling CT_STRETCH.
;
; PROCEDURE:
;	New R, G, and B vectors are created by linearly interpolating
;	the vectors in the common block from Low to High.  Vectors in the 
;	common block are not changed.
;
;	If NO parameters are supplied, the original color tables are
;	restored.
;
; EXAMPLE:
;	Load the STD GAMMA-II color table by entering:
;
;		LOADCT, 5
;
;	Create and display an image by entering:
;
;		TVSCL, DIST(300)
;
;	Now adjust the color table with CT_STRETCH.  Make the entire 
;       color table fit in the range 0 to 70 by entering:
;
;		CT_STRETCH, 0, 70
;
;	Notice that pixel values above 70 are now colored white.
;	Restore the original color table by entering:
;
;		CT_STRETCH
;
;       To reverse the color table:
;               CT_STRETCH, !D.TABLE_SIZE-1, 0
;
;       To reverse the color table over only the range 50 to 120:
;               CT_STRETCH, 120, 50
;
; NOTES: 
;       RSI's STRETCH routine didn't cut the mustard.  (a) If the
;       color table hasn't been loaded, it creates a color table with
;       maximum values of (!D.TABLE_SIZE-1) rather than 255; (b) it
;       uses LONG() to interpolate the color table rather than
;       BYTSCL().
; 
; MODIFICATION HISTORY:
;       19 Mar 2004  Written by Tim Robishaw, Berkeley
;	Most of documentation from DMS, RSI.
;       Added /OVERWRITE keyword. TR, 07 May 2004
;-

on_error, 2                     ; Return to caller if error

; GET THE COLOR TABLE...
common colors, r_orig, g_orig, b_orig, r_curr, g_curr, b_curr

; HOW MANY COLORS ARE AVAILABLE TO THIS DEVICE...
nc = !d.table_size

; IS THERE A COLOR TABLE DEFINED...
if (N_elements(r_orig) eq 0) then tvlct, r_orig, g_orig, b_orig, /GET

; SET DEFAULTS...
switch N_params() of
    0 : low = 0
    1 : high = nc-1
    2 : gamma = 1.0
endswitch

if (high eq low) then return      ;Nonsensical

; DETERMINE THE COLOR TABLE INDICES...
ctindx = bytscl( ( (findgen(nc)-low)/(high-low) < 1.0 > 0.0 )^gamma, $
                 MIN=0.0, MAX=1.0, TOP=nc-1)

; DO WE WANT TO SET THE INDICES ABOVE HIGH TO 0...
if keyword_set(CHOP) then begin
    if (high gt low) then begin
        if (high lt nc-1) then ctindx[high+1:*] = 0B
    endif else begin
        if (high gt 0) then ctindx[0:high-1] = 0B
    endelse
endif

; ACCESS THE THE NEW COLOR TABLE FROM THE ORIGINAL COLOR TABLE...
r_curr = r_orig[ctindx]
g_curr = g_orig[ctindx]
b_curr = b_orig[ctindx]

; LOAD THE CURRENT COLOR TABLE...
tvlct, r_curr, g_curr, b_curr

; DO WE WANT TO OVERWRITE THE ORIGINAL COLOR TABLE...
if keyword_set(OVERWRITE) then begin
    r_orig = r_curr
    g_orig = g_curr
    b_orig = b_curr
endif

end; ct_stretch
