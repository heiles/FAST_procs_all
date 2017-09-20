function fits_get_axis_par, axis
;+
; NAME:
;       FITS_GET_AXIS_PAR
;
; PURPOSE:
;       Return, in structure form, the FITS parameters necessary to
;       specify a coordinate axis.
;
; CALLING SEQUENCE:
;       Result = FITS_GET_AXIS_PAR(axis)
;
; INPUTS:
;       AXIS - vector containing values of coordinate axis.
;
; OUTPUTS:
;       Returns the AXIS_PAR structure:
;       AXIS_PAR.NAXIS - size of the axis
;               .CDELT - coordinate increment along axis
;               .CRPIX - coordinate system reference pixel
;               .CRVAL - coordinate system value at reference pixel
;               .CTYPE - name of the coordinate axis
;
; COMMON BLOCKS:
;       None.
;
; EXAMPLE:
;       AXIS is vector containing the values of an axis...
;       IDL> axis_par = fits_get_axis_par(axis)
;       IDL> help, axis_par, /structure
;       ** Structure <39fc40>, 4 tags, length=16, refs=1:
;       NAXIS           LONG              2048
;       CDELT           FLOAT           1.00000
;       CRPIX           FLOAT           1025.00
;       CRVAL           FLOAT           1024.00
;
; RELATED PROCEDURES:
;       FITS_ADD_AXIS_PAR, FITS_MAKE_AXIS()
;
; MODIFICATION HISTORY:
;   20 Aug 2003  Written by Tim Robishaw, Berkeley
;-

; HOW MANY ELEMENTS IN THIS COORDINATE AXIS...
naxis = N_elements(axis)

; PARTIAL DERIVATIVE OF THE COORDINATE WITH RESPECT TO PIXEL INDEX
; EVALUATED AT THE REFERENCE POINT CRPIX...
; JUST ASSUME DERIVATIVE IS SAME EVERYWHERE...
cdelt = (Naxis gt 1) ? (axis[1]-axis[0]) : 0

; GET THE CENTRAL PIXEL...
; N.B. HEADER ASSUMES 1-BASED INDICES, NOT ZERO-BASED...
crpix = float(naxis/2+1)

; GET THE VALUE AT THE CENTRAL PIXEL...
crval = axis[crpix-1]

return, {NAXIS:naxis,CDELT:cdelt,CRPIX:crpix,CRVAL:crval}

end; fits_get_axis_par
