pro gcurvpoly, xdata, coeffs1, hgt1, cen1, wid1, tfit
;+
;NAME:
;GCURVSLOPE --  Calculate multiple (N) Gaussians + polynomial fit
;
;PURPOSE:
;    Calculate multiple (N) Gaussians + offset + polynomial fit
;
;CALLING SEQUENCE:
;    GCURVPOLY, xdata, coeffs1, hgt1, cen1, wid1, tfit
;
;INPUTS:
;     xdata: the x-values at which the data points exist.
;     coeffs1: the array of polynomial coefficients
;     hgt1: the array of N estimated heights of the Gaussians.
;     cen1: the array of N estimated centers of the Gaussians.
;     wid1: the array of N estimated halfwidths of the Gaussians.
;
;OUTPUTS:
;     tfit: the calculated points.
;
;EXAMPLE:
;    You have two Gaussians plus an n-degree polyfit with coeffs
;     The heights are hgt1=[1.5, 2.5], the centers cen1=[12., 20.],
;     and the widths are wid1=[5., 6.]. There are  
;     100 values of x (xdata). 
;
;	GCURV, xdata, coeffs1, hgt1, cen1, wid1, tfit
;
;RELATED PROCEDURES:
;	GFITPOLY
;HISTORY:
;	Modified from gfitslope Carl Heiles. 23 Mar 2006.
;-

degree= n_elements( coeffs1) -1
ngaussians = n_elements( hgt1)

tfit= fltarr( n_elements( xdata))

for nd=0, degree do tfit= tfit+ coeffs1[ nd]*xdata^nd

for ng = 0, ngaussians-1 do begin
if (wid1[ng] gt 0.) then $
tfit = tfit + hgt1[ng]*exp(- ( (xdata-cen1[ng])/(0.6005612*wid1[ng]))^2)
endfor

return
end
