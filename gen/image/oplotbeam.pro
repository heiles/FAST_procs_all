pro oplotbeam, xcenter, ycenter, hpbw_major, hpbw_minor, $
               NOFILL=nofill, ANGLE=angle, _REF_EXTRA=_extra
;+
; NAME:
;       OPLOTBEAM
;
; PURPOSE:
;       Draw a half-power beam ellipse on an already-existing plot.
;
; CALLING SEQUENCE:
;       OPLOTBEAM, xcenter, ycenter, hpbw_major [, hpbw_minor] [,
;       /NOFILL] [, ANGLE=ccw_degrees_from_horiz]
;
; Other keywords accepted by both PLOTS and POLYFILL:
;       [, CLIP=[X0, Y0, X1, Y1]] [, COLOR=value] 
;       [, /DATA | , /DEVICE | , /NORMAL] 
;       [, LINESTYLE={0 | 1 | 2 | 3 | 4 | 5}] [, /NOCLIP] [, THICK=value]
;
; Other POLYFILL keywords accepted:
;       [, /LINE_FILL] [, ORIENTATION=ccw_degrees_from_horiz]  
;       [, PATTERN=array] [, SPACING=centimeters] 
;
; INPUTS:
;       XCENTER - Horizontal coordinate used to position the center of
;                 the beam area.  Assumed to be in DATA coordinates;
;                 override this with /NORMAL or /DEVICE keywords.
;
;       YCENTER - Vetical coordinate used to position the center of
;                 the beam area. Assumed to be in DATA coordinates;
;                 override this with /NORMAL or /DEVICE keywords.
;
;       HPBW_MAJOR - The half-power beamwidth of the major axis of the 
;                    telescope beam.  If the beam is circular, then this
;                    parameter is all that is necessary to define the beam.
;                    Must be given in the same coordinate system (DATA,
;                    DEVICE, NORMAL) as the XCENTER and YCENTER
;                    parameters.  Assumed to be in DATA coordinates;
;                    override this with /NORMAL or /DEVICE keywords.
;
; OPTIONAL INPUTS:
;       HPBW_MINOR - If the beam is elliptical, then this is the half-power 
;                    beamwidth of the minor axis of the telescope beam.
;
; KEYWORD PARAMETERS:
;       /NOFILL: Set this keyword if you want only the boundary of the beam
;                area to be drawn.
;
;       ANGLE = Specifies the counterclockwise angle in degrees from 
;               horizontal of the major axis of the beam ellipse.
;               Remember that astronomical position angles are
;               measured from the North towards the East.  If you've
;               displayed your map correctly, and you know the PA of
;               your beam, set ANGLE to 90+PA.
;
; OUTPUTS:
;       None.
;
; COMMON BLOCKS:
;       None.
;
; SIDE EFFECTS:
;       A beam ellipse is drawn on the current display device.
;
; EXAMPLE:
;       A map has been established on the display device.  Choose a
;       nice uncluttered place to draw the beam ellipse using the
;       cursor:
;
;       IDL> cursor, x, y
;
;       Try the default, a filled ellipse with the major axis along
;       the horizontal (the values of hpbw_maj and hpbw_min must be in
;       the same coordinates as x and y, in this case DATA coordinates):
;
;       IDL> oplotbeam, x, y, hpbw_maj, hpbw_min
;
;       Get fancy by adding a line fill at an orientation of 30
;       degrees ccw from the horizontal, increasing the line
;       thickness, and drawing the beam in color:
;
;       IDL> oplotbeam, x, y, hpbw_maj, hpbw_min, THICK=3, $
;       IDL> COLOR=green, ORIENTATION=-30
;
;       Now, also tilt the major axis of the beam at an angle
;       of 30 degrees ccw from horizontal:
;
;       IDL> oplotbeam, x, y, hpbw_maj, hpbw_min, THICK=3, $
;       IDL> COLOR=green, ORIENTATION=-30, ANGLE=-30
;
; NOTES:
;       Defaults:
;       (1) Plots major axis of the beam ellipse parallel to the
;           horizontal.  Use ANGLE keyword to change this orientation
;           of the ellipse.
;       (2) Fills the ellipse with a solid pattern.  To prevent the
;           ellipse from being filled, set the /NOFILL keyword.  To
;           fill the ellipse with lines, set the /LINE_FILL keyword
;           and/or the ORIENTATION keyword.
;
; RELATED PROCEDURES:
;       OPLOTSCALE
;
; MODIFICATION HISTORY:
;   26 Mar 2004  Written by Tim Robishaw, Berkeley
;   31 Mar 2004  Fixed angle so that CCW is always CCW, even if X axis
;                or Y axis is running backwards. TR
;-

on_error, 2

; ERROR CHECK AND SET DEFAULTS...
case 1 of
    (N_params() lt 3) : message, 'Incorrect number of arguments.'
    (N_params() eq 3) : hpbw_minor = hpbw_major
    else: if (hpbw_minor gt hpbw_major) then $
      message, "HPBW_MINOR can't be greater than the HPBW_MAJOR."
endcase

; IF THE ROTATION ANGLE ISN'T SET, DEFAULT IS ZERO...
if (N_elements(ANGLE) eq 0) then angle = 0

; GET THE COORDINATES OF THE BOUNDARY OF THE BEAM ELLIPSE...
xy_ellipse = 0.5 * [[hpbw_major *  cos(2*!dpi*findgen(1001)/1000.)],$
                    [hpbw_minor *  sin(2*!dpi*findgen(1001)/1000.)]]

; DON'T WASTE THE EFFORT IF THE ROTATION ANGLE IS ZERO OR
; THE ELLIPSE IS A CIRCLE...
if (angle ne 0) AND (N_params() eq 4) then begin

    ; CONVERT THE ROTATION ANGLE TO RADIANS AND ROTATE THE BEAM...
    angle = angle * !dtor * (1.-2.*(!x.s[1] lt 0)) * (1.-2.*(!y.s[1] lt 0))
    xy_ellipse = [[cos(angle),-sin(angle)],[sin(angle),cos(angle)]] $
                 ## xy_ellipse

endif

; SHIFT CENTER OF ELLIPSE TO INPUT COORDINATES... 
xbeam = xcenter + xy_ellipse[*,0]
ybeam = ycenter + xy_ellipse[*,1]

; PLOT THE BOUNDARY OF THE BEAM ELLIPSE AT HALF-POWER...
plots, xbeam, ybeam, /DATA, _EXTRA=_extra

if keyword_set(NOFILL) then return

; FILL THE BEAM AREA...
polyfill, xbeam, ybeam, /DATA, _EXTRA=_extra

end; oplotbeam
