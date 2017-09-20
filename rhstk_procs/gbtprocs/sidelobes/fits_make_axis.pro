function fits_make_axis, hdr, axisnum
;+
; NAME:
;FITS_MAKE_AXIS -- create axis values from a FITS header
;
; PURPOSE:
;       To create the axis values from the NAXISn, CDELTn, CRPIXn, and
;       CRVALn keyword values stored in a FITS header.
;
; CALLING SEQUENCE:
;       Result = FITS_MAKE_AXIS(hdr, axisnum)
;
; INPUTS:
;       HDR - FITS header (string array)
;       AXISNUM - The number of the axis to be created.
;
; KEYWORD PARAMETERS:
;       None.
;
; OUTPUTS:
;       Returns a vector of length NAXISn containing the axis values.
;
; COMMON BLOCKS:
;       None.
;
; PROCEDURES CALLED:
;       SXPAR()
;
; EXAMPLE:
;       Get the header from a FITS file...
;       IDL> hdr = headfits('datacube.fits')
;
;       Make the 1st and 2nd axes...
;       IDL> xaxis = fits_make_axis(hdr,1)
;       IDL> yaxis = fits_make_axis(hdr,2)
;
; RELATED PROCEDURES:
;       FITS_ADD_AXIS_PAR
;
; MODIFICATION HISTORY:
;   20 Aug 2003  Written by Tim Robishaw, Berkeley
;-

; CHECK TO MAKE SURE INFORMATION IS STORED FOR THIS AXIS...
naxes = sxpar(hdr,'NAXIS')
if (axisnum gt naxes) then begin
    message, 'There are only '+strtrim(naxes,2)+' axes!', /INFO
    return, -1
endif

straxis = strtrim(axisnum,2)

; MAKE SURE EACH OF THE REQUIRED AXIS KEYORDS EXISTS...
kwrd  = 'NAXIS'+straxis
naxis = call_function('sxpar',hdr,kwrd,COUNT=found)
if (found eq 0L) then goto, no_keyword

kwrd  = 'CRPIX'+straxis
crpix = call_function('sxpar',hdr,kwrd,COUNT=found)
if (found eq 0L) then goto, no_keyword

kwrd  = 'CRVAL'+straxis
crval = call_function('sxpar',hdr,kwrd,COUNT=found)
if (found eq 0L) then goto, no_keyword

kwrd  = 'CDELT'+straxis
cdelt = call_function('sxpar',hdr,kwrd,COUNT=found)
if (found eq 0L) then goto, no_keyword

; CONSTRUCT THE AXIS...
; N.B. HEADER ASSUMES 1-BASED INDICES, NOT ZERO-BASED...
return, cdelt * (findgen(naxis) - crpix + 1) + crval

no_keyword:

; GENERATE AN ERROR MESSAGE...
message, 'Header keyword '+kwrd+' not found.', /INFO
return, -1L

end; fits_make_axis
