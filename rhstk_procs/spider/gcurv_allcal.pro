pro gcurv_allcal, xdata, tsys1, slope1, alpha1, hgt1, cen1, wid1, tfit
;+
;
;PURPOSE:
;    Calculate the function used in beam and sidelobe fitting, which
;    consists of 3 gaussians plus zero plus slope.
;    The FIRST Gaussian is for the main beam and includes a coma parameter, alpha.

;CALLING SEQUENCE:
;    GCURV_ALLCAL, xdata, tsys1, slope1, alpha1, hgt1, cen1, wid1, tfit
;
;INPUTS:
;     xdata: the x-values at which the data points exist.
;     tsys1: the estimated constant zero offset of the data points.
;     slope1: the slope.
;     hgt1: the array of N estimated heights of the Gaussians.
;     cen1: the array of N estimated centers of the Gaussians.
;     wid1: the array of N estimated halfwidths of the Gaussians.
;
;OUTPUTS:
;     tfit: the calculated points.
;
;
;HISTORY:
;	Written by Carl Heiles. sep00
;-


;DETERMINE NR OF GAUSSIANS...
ngaussians = n_elements( hgt1)

;FIRST, DO THE FIRST GAUSSIAN WITH ITS COMA CORRECTION...
ng = 0
tfit = tsys1 + hgt1[ng]*exp(- ( (xdata-cen1[ng])/(0.6005612*wid1[ng]))^2) * $
	exp(-  alpha1*(xdata-cen1[ng])^3/ (0.6005612*wid1[ng])^2 )

IF (ngaussians gt 1) then begin
FOR ng = 1, ngaussians-1 do begin
if (wid1[ng] gt 0.) then $
tfit = tfit + hgt1[ng]*exp(- ( (xdata-cen1[ng])/(0.6005612*wid1[ng]))^2)
ENDFOR
ENDIF

tfit = tfit + slope1* xdata

;stop

return
end
