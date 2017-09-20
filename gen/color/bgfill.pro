pro bgfill, bgcolor
;+
; NAME:
;       BGFILL
;     
; PURPOSE:
;       Fills the background of a plot window with a specified color.
;     
; CALLING SEQUENCE:
;       BGFILL, BGCOLOR
;     
; INPUTS:
;       BGCOLOR - Color table index (8-bit color) or 24-bit color
;                 index of the color with which you would like to 
;                 fill the background.
;
; OUTPUTS:
;       None.
;
; COMMON BLOCKS:
;       None.
;
; SIDE EFFECTS:
;        Display device is filled with the input color.
;
; RESTRICTIONS:
;       The /NOERASE keyword MUST be sent to any plotting routine that
;       you call after using this routine!
;       This causes problems if you are using !p.multi values
;       other than zero.  See example below for how to do this.
;
; EXAMPLE:
;       Fill the background with the color in the 0th index of the
;       color table, then plot a line:
;
;        IDL> bgfill, 0
;        IDL> plot, findgen(30), /NOERASE
;
;       In order to use !p.multi with this method, you must explicitly
;       place each plot with a !p.multi assignment (since you must include 
;       the /NOERASE keyword when starting a new plot!)  Remember the
;       first element of !p.multi is the number of empty sectors remaining
;       on the page and the default order of placement (the 5th element of
;       !p.multi) is left-right and top-bottom. Here's an example:
;
;        IDL> bgfill, 0
;        IDL> !p.multi=[4,2,2]
;        IDL> plot, findgen(30), /NOERASE
;        IDL> !p.multi=[3,2,2]
;        IDL> plot, findgen(30)^2, /NOERASE
;        IDL> !p.multi=[2,2,2]
;        IDL> plot, findgen(30)^3, /NOERASE
;
; NOTES:
;       Note that in order for this to work, you need to set the
;       /NOERASE keyword to any plotting routine you call directly
;       after using this routine!
;
; MODIFICATION HISTORY:
;       01 Mar 2002  Written by Tim Robishaw, Berkeley
;-

on_error, 2

if (N_params() eq 0) then message, 'Syntax: BGFILL, COLOR', /INFO

polyfill, [1,1,0,0,1], $
          [1,0,0,1,1], $
          /NORMAL, COLOR=bgcolor

; POLYFILL IS AN INTERNAL PROCEDURE AND I DON'T KNOW HOW IT WORKS...
; HOWEVER, I HAVE DETERMINED EMPIRICALLY THAT IT OFTEN WILL NOT
; FILL THE BOTTOM ROW IF YOU REQUEST A SOLID FILL.
; HERE'S THE SOLUTION...
plots, [0,float(!d.x_vsize-1)/!d.x_vsize], [0,0], /NORMAL, COLOR=bgcolor

end; bgfill
