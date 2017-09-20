pro ct_reverse, low, high, OVERWRITE=overwrite
;+
; NAME:
;	CT_REVERSE
;
; PURPOSE:
;	Reverse the image display color tables over a specified range.
;
; CATEGORY:
;	Image processing, point operations.
;
; CALLING SEQUENCE:
;	CT_REVERSE, Low, High [, /OVERWRITE]
;
; OPTIONAL INPUTS:
;	Low:	The lowest pixel value to use.  If this parameter is omitted,
;		0 is assumed.  Appropriate values range from 0 to the number 
;		of available colors-1.
;
;	High:	The highest pixel value to use.  If this parameter is omitted,
;		the number of colors-1 is assumed.  Appropriate values range 
;		from 0 to the number of available colors-1.
;
; KEYWORD PARAMETERS:
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
;	Common block COLORS must be loaded before calling CT_REVERSE.
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
;       Now reverse the color table:
;               CT_REVERSE
;
;       Now reverse just the color table indices between 50 and 100:
;               CT_REVERSE, 50, 100
;
; MODIFICATION HISTORY:
;       19 Mar 2004  Written by Tim Robishaw, Berkeley
;       Added /OVERWRITE keyword. TR, 07 May 2004
;-

on_error, 2

; GET THE COLOR TABLE...
common colors, r_orig, g_orig, b_orig, r_curr, g_curr, b_curr

; HOW MANY COLORS ARE AVAILABLE TO THIS DEVICE...
nc = !d.table_size

switch N_params() of
    0 : low = 0
    1 : high = nc-1
endswitch

; CHECK FOR NONSENSICAL REQUEST...
if (low ge high) then $
  message, 'LOW index must be less than HIGH index.'

; GET THE CURRENT COLOR TABLE...
tvlct, r_curr, g_curr, b_curr, /GET

; HAS THE COLORS COMMON BLOCK BEEN DEFINED YET...
if (N_elements(r_orig) eq 0) then begin
    r_orig = r_curr
    g_orig = g_curr
    b_orig = b_curr
endif

; REVERSE THE COLOR TABLE INDICES...
ctindx = high - bindgen(high-low+1)

; MODIFY THE CURRENT COLOR TABLE...
r_curr[low:high] = r_curr[ctindx]
g_curr[low:high] = g_curr[ctindx]
b_curr[low:high] = b_curr[ctindx]

; LOAD THE CURRENT COLOR TABLE...
tvlct, r_curr, g_curr, b_curr

; DO WE WANT TO OVERWRITE THE ORIGINAL COLOR TABLE...
if keyword_set(OVERWRITE) then begin
    r_orig = r_curr
    g_orig = g_curr
    b_orig = b_curr
endif

end; ct_reverse
