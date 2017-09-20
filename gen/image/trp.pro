pro trp, out, SCALED=scaled, _EXTRA=_extra
;+
; NAME:
;       TRP
;
; PURPOSE:
;       A wrapper to call TR_PROFILES with useful settings.
;
; CALLING SEQUENCE:
;
;       TRP, Out_Struct [, SX = sx, SY = sy] [, /AXIS] [, ORDER=order]
;        [, WSIZE=wsize | , XSIZE=xsize, YSIZE=ysize] 
;        [, XPOS=xpos, YPOS=ypos ]
;        [, PSYM=psym] [, SSIZE=ssize] [, COLOR=color] 
;        [, CCOLOR=ccolor] [, CLENGTH=clength] [, /CCLIP] [, /SILENT]
;        [, /SCALED]  
;
; INPUTS:
;       Out_Struct - the structure returned by Robishaw's DISPLAY routine;
;                    must contain the proper tags, in particular this
;                    routine uses the IMAGE, IMAGE_UNSCALED, and POSITION
;                    tags.
;
; KEYWORD PARAMETERS:
;        /SCALED - if set, plots profiles of the byte-scaled image; this
;                  allows you make the vertical scale of the profiles plot
;                  the same as that of the displayed byte-scaled image. The
;                  default is to plot profiles of the unscaled image, i.e.,
;                  the actual values of the image before they were
;                  byte-scaled to the range [0,255].
;
;       Accepts all keywords for TR_PROFILES.  For full documentation:
;       IDL> doc_library, 'tr_profiles'
;
; SIDE EFFECTS:
;       An X-window and a pixmap window are created.
;
; RESTRICTIONS:
;       Can only be used on an X-windows device.
;
; MODIFICATION HISTORY:
;	Written by Tim Robishaw, Berkeley  01 Nov 2006
;       Added /SCALED keyword and documentation. CH/TR 26 Apr 2009.
;-

on_error, 2

; MAKE SURE THE INPUT STRUCTURE CONTAINS THE PROPER TAGS...
if (N_params() eq 0) then message, 'Incorrect number of arguments.'
tags = tag_names(out)
if (total(strmatch(tags,'IMAGE_UNSCALED',/FOLD_CASE)) eq 0) then $
   message, 'Input structure must be the output from the OUT '+$
            'keyword of DISPLAY.'

; SET UP THE PROFILES WINDOW SIZE...
scrnsz = get_screen_size()
xsize = 0.75*640
ysize = 0.75*512

; DO WE WANT THE UNSCALED IMAGE...
image = keyword_set(SCALED) ? out.image : out.image_unscaled

; CALL TR_PROFILES WITH USEFUL OPTIONS...
tr_profiles, image, /AXIS, $
             ; THE LOWER LEFT CORNER OF THE AXES...
             SX=out.position[0]*!d.x_vsize, $
             SY=out.position[1]*!d.y_vsize, $
             ; LET'S ALWAYS STICK THE PROFILE WINDOW IN THE UPPER RIGHT...
             XSIZE=xsize, YSIZE=ysize, $
             XPOS=scrnsz[0]-xsize, YPOS=scrnsz[1]-ysize, $
             ; LET'S MAKE A FULL-SCREEN GREEN CURSOR...
             CLENGTH=1.0, /CCLIP, CCOLOR=!green, _EXTRA=_extra

end ; trp
