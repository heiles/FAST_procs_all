pro ad2xy_ez, lon, lat, hdr, xpixo, ypixo, fract=fract, $
              ranr=ranr, decnr=decnr, pix_to_angle=pix_to_angle
;+
;cartesian ez version.
;fract allows for returning fractional pixel values. 
;       normally you want properly floored integers so don't set it
;ranr is longitude=like posnr. normally 1; set if diff. use 2 for co data
;decnr is latitude=like posnr. normally 2; set if diff. use 1 for co data

;if pix_to_angle is NOT set, then 
;LON, LAT are angle inputs aand XPIXO, YPIXO are pixel value outputs

;if pix_to_angle is set, then 
; XPIXO, YPIXO are pixel inputs aand lon, lat are anngle outputs
;-


if keyword_set( ranr) eq 0 then ranr=1
if keyword_set( decnr) eq 0 then decnr=2

cdelt2= sxpar( hdr, 'CDELT' + string( ranr, format='(i1)') )
cdelt3= sxpar( hdr, 'CDELT' + string( decnr, format='(i1)') )
crpix2= sxpar( hdr, 'CRPIX' + string( ranr, format='(i1)') )
crpix3= sxpar( hdr, 'CRPIX' + string( decnr, format='(i1)') )
crval2= sxpar( hdr, 'CRVAL' + string( ranr, format='(i1)') )
crval3= sxpar( hdr, 'CRVAL' + string( decnr, format='(i1)') )

;;TO GO FROM PIXELS TO ANGLES. FRACTIONAL PIXELS ARE OK.
if keyword_set( pix_to_angle) then begin
lon= crval2+ (ypixo- (crpix2- 1.))* cdelt2
lat= crval3+ (xpixo- (crpix3- 1.))* cdelt3
return
endif

if keyword_set( fract) then begin
;;TO GO FROM ANGLES TO PIXELS; FRACTIONAL PIXELS OK.
xpixo= (lon-crval2)/cdelt2 + (crpix2-1.)
ypixo= (lat-crval3)/cdelt3 + (crpix3-1.)
return
endif

;;TO GO FROM ANGLES TO PIXELS; INTEGER PIXELS ONLY.
xpixo= floor( (lon-crval2)/cdelt2 + (crpix2-1.)+ 0.5)
ypixo= floor( (lat-crval3)/cdelt3 + (crpix3-1.)+ 0.5)

return
end
