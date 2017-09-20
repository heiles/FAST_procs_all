pro ps_ch, psfilename, $
           xsize=xsize, ysize=ysize, inches=inches, color=color, $
           close=close, defaults=defaults, $
           pcharsize=pcharsize, pthick=pthick, xthick=xthick, ythick=ythick, $
           verbose=verbose

;+
;CALLING SEQUENCE:
;        ps_ch, psfilename, $
;           xsize=xsize, ysize=ysize, inch=inch, color=color, $
;           close=close, defaults=defaults, $
;           pcharsize=pcharsize, pthick=pthick, xthick=xthick, ythick=ythick
;
;PURPOSE: set up standard defaults for ps plots. 
;
;INPUTS;
;       PSFILENAME, the ps file name
;
;KEYWORDS:
;        CLOSE, set to close ps, return defaults to std values, 
;               return to X, and set the colortable back to X
;        XSIZE, xsize of the ps window, default 8.0 inch
;        YSIZE, ysize of the ps window, default 10.5 inch
;        INCH, set if sizes are in inch; defaut is cm
;        COLOR, set if image contains color
;        DEFAULTS, set to set the following keywords to their default
;           values. If the following are defined, it sets to those; 
;           otherwise to the values indicated below.
;        PCHARSIZE, !p.charsize value; default is 1.75
;        PTHICK, !p.thick value; default is 4
;        XTHICK, !x.thick value; default is 6
;        YTHICK, !y.thick value; default is 6
;
;EXAMPLE:
;       You have the commands to make a ps plot. Do the following:
;         ps_ch, 'example.ps', /defaults       
;         put the plot commands here
;         ps_ch, /close
;-

if keyword_set( close) then begin
      !p.charsize=0
      !p.thick=0
      !x.thick=0
      !y.thick=0
if !d.name eq 'X' then return
   psclose
   setcolors, /sys
   !p.font=-1
   return
endif

if n_elements( inch) eq 0 then inch=1
if n_elements( color) eq 0 then color=0

if keyword_set( defaults) eq 1 then begin
   if n_elements( pcharsize) eq 0 then !p.charsize=1.75 else !p.charsize=pcharsize
   if n_elements( pthick) eq 0 then !p.thick=4 else !p.thick=pthick
   if n_elements( xthick) eq 0 then !x.thick=6 else !x.thick=xthick
   if n_elements( ythick) eq 0 then !y.thick=6 else !y.thick=ythick
endif

if n_elements( xsize) eq 0 then xsize=8.0  
if n_elements( ysize) eq 0 then xsize=10.5

   psopen, psfilename, /times, /bold, /isolatin1, color=color, $
           xsize=xsize,ysize=ysize, inch=inch
   setcolors, /sys
   !p.font=0

if keyword_set( verbose) then help, /st, !p
;if keyword_set( verbose) then help, /st, !x
;if keyword_set( verbose) then help, /st, !y

return
end
