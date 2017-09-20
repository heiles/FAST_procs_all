function rosat12fits, filename, hdr, verbose=verbose

;+
; NAME: rosat12fits
;
; PURPOSE: read rosat 12 arcmin fits and return the data and a correct
; header. The original headers are no good for getting positions.
;
; CALLING SEQUENCE: img= rosat12fits( filename, hdr)
;
; INPUTS:
;       filename, the fits file name. should look like g000m90r1b120pm.fits
;
;KEYWORD: verbose
;
; OUTPUTS:
; img, the data image (returned by the function)
; hdr, the corrected fits header.
;-

posn= strpos( filename, '/', /reverse_search)
;
posn=posn+ 1
;if posn eq -1 then posn = 0

img= readfits( filename, hdr)
hdr_original= hdr

;stop
CRVAL1= float( strmid( filename, posn+ 1, 3))

CRVAL2= float( strmid( filename, posn+ 5, 2))
sign= strmid( filename, posn+ 4, 1)
if sign eq 'm' then CRVAL2= -CRVAL2
sxaddpar, hdr, 'CRVAL1', CRVAL1
sxaddpar, hdr, 'CRVAL2', CRVAL2
if keyword_set( verbose) then $
  print, nf, ' ', filename, hdr_original[14], hdr_original[19], hdr[14], hdr[19]
return, img
end

