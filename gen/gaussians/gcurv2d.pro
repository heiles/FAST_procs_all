pro gcurv2d, xdata, ydata, zro1, hgt1, cenx1, ceny1, wid1, tfit
;+
;NAME:
;   GCURV2D
;
;PURPOSE:
;    Calculate multiple (N) Gaussians + offset.
;
;CALLING SEQUENCE:
;    GCURV2D, xdata, ydata, zro1, hgt1, cenx1, ceny1, wid1, tfit
;
;INPUTS:
;     xdata: the x-values at which the data points exist.
;     ydata: the y-values at which the data points exist.
;     zro1: the estimated constant zero offset of the data points.
;     hgt1: the array of N estimated heights of the Gaussians.
;     cenx1: the array of N estimated x-centers of the Gaussians.
;     ceny1: the array of N estimated y-centers of the Gaussians.
;     wid1: the array of N estimated halfwidths of the Gaussians.
;
;OUTPUTS:
;     tfit: the calculated points.
;
;EXAMPLE:
;    You have two Gaussians.
;     The heights are hgt1=[1.5, 2.5], the centers cen1=[12., 20.],
;     and the widths are wid1=[5., 6.]. There are  
;     100 values of x (xdata). 
;
;	GCURV, xdata, zro1, hgt1, cen1, wid1, tfit
;
;RELATED PROCEDURES:
;	GFIT2D 
;HISTORY:
;	GCURV Written by Carl Heiles. 21 Mar 1998.
;       Upgraded to 2D by Paul Demorest 6 jan 2003
;-


;DETERMINE NR OF GAUSSIANS...
hgt1size = size(hgt1)
hgt1size = reverse(hgt1size)
ngaussians = hgt1size[0]
if (ngaussians eq 0) then ngaussians=1
;stop
tfit = 0.*xdata + zro1
for ng = 0, ngaussians-1 do begin
if (wid1[ng] gt 0.) then $
tfit = tfit + hgt1[ng]*exp(- ( (xdata-cenx1[ng])/(0.6005612*wid1[ng]))^2 - $
  ( (ydata-ceny1[ng])/(0.6005612*wid1[ng]))^2 )
endfor

return
end
