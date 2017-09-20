pro gcurvslope, xdata, zro1, slp1, hgt1, cen1, wid1, tfit
;+
;NAME:
;GCURVSLOPE --  Calculate multiple (N) Gaussians + offset + SLOPE
;
;PURPOSE:
;    Calculate multiple (N) Gaussians + offset + SLOPE
;
;CALLING SEQUENCE:
;    GCURV, xdata, zro1, slp1, hgt1, cen1, wid1, tfit
;
;INPUTS:
;     xdata: the x-values at which the data points exist.
;     zro1: the zero offset of the data points.
;     slp1: the slope.
;     hgt1: the array of N estimated heights of the Gaussians.
;     cen1: the array of N estimated centers of the Gaussians.
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
;	GCURV, xdata, zro1, slp1, hgt1, cen1, wid1, tfit
;
;RELATED PROCEDURES:
;	GFITSLOPE
;HISTORY:
;	Written by Carl Heiles. 21 Mar 1998.
;-


;DETERMINE NR OF GAUSSIANS...
hgt1size = size(hgt1)
hgt1size = reverse(hgt1size)
ngaussians = hgt1size[0]
if (ngaussians eq 0) then ngaussians=1
;stop
tfit = zro1 + slp1*xdata
for ng = 0, ngaussians-1 do begin
if (wid1[ng] gt 0.) then $
tfit = tfit + hgt1[ng]*exp(- ( (xdata-cen1[ng])/(0.6005612*wid1[ng]))^2)
endfor

return
end
