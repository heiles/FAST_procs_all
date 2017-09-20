function gaussdist, x, zro, cen, wid, hgt
;+
; NAME:
;       GAUSSDIST
;     
; PURPOSE:
;       Creates Gaussian distribution(s) with the width, center and
;       height as specified.  
;     
; CALLING SEQUENCE:
;       RESULT = GAUSSDIST(X, ZRO, CEN, WID, HGT)
;     
; INPUTS:
;       X : Vector of abscissa values.
;
;       ZRO : The zero offset of the Gaussian distribution. A scalar.
;
;       CEN : Array (or scalar) of centers of Gaussian components.
;
;       WID : Array (or scalar) of widths of Gaussian components.
;
;       HGT : Array (or scalar) of heights of Gaussian components.
;
; OUTPUTS:
;       Returns the Gaussian distribution of the input parameters.
;
; EXAMPLE:
;  Plot two Gaussians:
;    IDL> plot, gaussdist(findgen(2000)/100., 0, [10,15], [6,3], [6,3])
;
; MODIFICATION HISTORY:
;       Written Tim Robishaw, Berkeley 01 Dec 2001.
;-

on_error, 2

; DID WE SEND IN ENOUGH INFORMATION...
if (N_params() lt 5) $
  then message, 'Syntax: RESULT = GAUSSDIST(x, zro, cen, wid, hgt)'

; DETERMINE NR OF GAUSSIANS...
ngaussians = N_elements(cen)

; DID WE SEND IN THE RIGHT VALUES...
if (ngaussians ne N_elements(wid)) OR (ngaussians ne N_elements(hgt)) $
  then message, 'HGT, CEN, and WID arrays must be the same size!'

; PUT THE DISTRIBUTION TOGETHER...
dist = dblarr(N_elements(x)) + zro
for i = 0, ngaussians-1 do $
  dist = dist+hgt[i]*exp(-((x-cen[i])/(0.60056120439323d0*wid[i]))^2)

return, dist

end; gaussdist
