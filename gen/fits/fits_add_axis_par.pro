pro fits_add_axis_par, axis, hdr, axisnum, $
                       CTYPE=ctype, CUNIT=cunit, AXIS_PAR=axis_par
;+
; NAME:
;       FITS_ADD_AXIS_PAR
;
; PURPOSE:
;       Add to FITS header the FITS parameters necessary to
;       specify a coordinate axis.
;
; CALLING SEQUENCE:
;       FITS_ADD_AXIS_PAR, axis, hdr, axisnum
;
; INPUTS:
;       AXIS - vector containing values of coordinate axis.
;       HDR - FITS header.
;       AXISNUM - The number of the coordinate axis.
;
; KEYWORD PARAMETERS:
;       CTYPE - name of the coordinate axis, a character string.
;       CUNIT - name of units of coordinate, a character string.
;       AXIS_PAR - Set this keyword to a variable in order to
;                  return the AXIS_PAR stucture:
;                  .NAXIS - size of the axis
;                  .CDELT - coordinate increment along axis
;                  .CRPIX - coordinate system reference pixel
;                  .CRVAL - coordinate system value at reference pixel
;                  .CTYPE - name of the coordinate axis
;
; OUTPUTS:
;       None.
;
; COMMON BLOCKS:
;       None.
;
; SIDE EFFECTS:
;       The coordinate axis header keywords are added or changed in 
;       the FITS header.
;
; PROCEDURES CALLED:
;       FITS_GET_AXIS_PAR(), SXPAR(), SXADDPAR
;
; EXAMPLE:
;       Create a header for a data cube...
;       IDL> cube = bytarr(512,12,36)
;       IDL> mkhdr, hdr, cube
;
;       Now make coordinate axes for the cube...
;       IDL> axis1 = findgen(512)*0.33 - 100
;       IDL> axis2 = findgen(12)
;       IDL> axis3 = findgen(36)*0.5 + 50
;
;       Add the NAXISn, CRVALn, CRPIXn and CRDELTn header
;       keywords to HDR...
;       IDL> fits_add_axis_par, axis1, hdr, 1
;       IDL> fits_add_axis_par, axis2, hdr, 2
;       IDL> fits_add_axis_par, axis3, hdr, 3
;
;       Also add the CTYPEn and CUNITn keywords...
;       IDL> fits_add_axis_par, axis1, hdr, 1, $
;       IDL> CTYPE='Right Ascension (B1950)', CUNIT='deg'
;
; RELATED PROCEDURES:
;       FITS_MAKE_AXIS()
;
; MODIFICATION HISTORY:
;   20 Aug 2003  Written by Tim Robishaw, Berkeley
;-

; HOW MANY AXES ARE IN THE HEADER...
naxes = sxpar(hdr,'NAXIS')
if (axisnum gt naxes) then begin
    message, 'There are only '+strtrim(naxes,2)+' axes!', /INFO
    return
endif

; GET THE AXIS KEYWORD PARAMETERS...
axis_par = fits_get_axis_par(axis)

straxis = strtrim(axisnum,2)

; MAKE SURE NAXISn MATCHES THE HEADER...
naxis = call_function('sxpar',hdr,'NAXIS'+straxis)
if (axis_par.naxis ne naxis) then begin
    message, 'You cannot change the NAXIS'+straxis+' keyword!', /INFO
    message, 'Coordinate axis must have the same size as data.', /INFO
    return
endif

; ADD THESE PARAMETERS...
call_procedure, 'sxaddpar', hdr, 'NAXIS'+straxis, axis_par.naxis
call_procedure, 'sxaddpar', hdr, 'CRVAL'+straxis, axis_par.crval
call_procedure, 'sxaddpar', hdr, 'CRPIX'+straxis, axis_par.crpix
call_procedure, 'sxaddpar', hdr, 'CDELT'+straxis, axis_par.cdelt

; ADD THE COORDINATE NAME...
if keyword_set(CTYPE) then $
  call_procedure, 'sxaddpar', hdr, 'CTYPE'+straxis, ctype 

; ADD THE COORDINATE UNIT...
if keyword_set(CUNIT) then $
  call_procedure, 'sxaddpar', hdr, 'CUNIT'+straxis, cunit

end; fits_add_axis_par
