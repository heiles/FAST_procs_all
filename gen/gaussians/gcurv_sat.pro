pro gcurv_sat, xdata, zro1, tx1, tau1, cen1, wid1, tfit
;+
;NAME:
;GCURV_sat --  Calculate multiple (N) saturated Gaussians + offset.
;     the equation is...
;                       tfit= zro1 + tx1 * (1 - exp( -tau_xdata))
;     where
;                       tau = tau1 exp( -( (xdata-cen1)^2/wid_fwhm^2)
;     by which we mean to say that wid1 is the fwhm of the gaussian.
;
;PURPOSE:
;    Calculate multiple (N) saturated Gaussians + offset.
;
;CALLING SEQUENCE:
;    GCURV_sat, xdata, zro1, tx1, tau1, cen1, wid1, tfit
;
;INPUTS:
;     xdata: the x-values at which you want to calculate values.
;     zro1: the zero offset.
;     tx1: the array of N TXs of the Gaussians.
;     tau1: the array of N TAUs of the Gaussians.
;     cen1: the array of N centers of the Gaussians.
;     wid1: the array of N halfwidths of the Gaussians.
;
;OUTPUTS:
;     tfit: the calculated points.
;
;EXAMPLE:
;
;RELATED PROCEDURES:
;	GFIT_sat 
;HISTORY:
;	Adapted from gfit by CH 22 jun 2009.
;-


;DETERMINE NR OF GAUSSIANS...
tau1size = size(tau1)
tau1size = reverse(tau1size)
ngaussians = tau1size[0]
if (ngaussians eq 0) then ngaussians=1
;stop
tfit = 0.*xdata + zro1
for ng = 0, ngaussians-1 do begin
if (wid1[ng] gt 0.) then $
tfit = tfit + tx1[ng]* (1.- $$
  exp(-tau1[ng]*exp(- ( (xdata-cen1[ng])/(0.6005612*wid1[ng]))^2)))
endfor

return
end
