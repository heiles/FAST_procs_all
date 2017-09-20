;+
;NAME:
;polyffteval - evaluate the fit from robfit_polyfft
; 
;SYNTAX:  yfit=polyffteval(x,coef,xminmax)
;ARGS:   
; x[n]: float   x points where we should evaluate fit
; coef: {}      fit info returned by robfit_polyfft
;xminmax[2]:float the min max values for that y data that was 
;               passed to robfit_polyfft. 
;                 
;RETURNS  :
; yfit[n] : fltarr(n) the fit data
;
;DESCRIPTION:
;   Evaluate the fit done by robfit_polyfft. You need to pass in the
;coefInfo returned by robfit_polyfft plus the x data range for the
;data the was initially fit (since robfit_polyfft actualy fits -pi to pi
;Any x datapoints outside th xminmax range will be evaluated at the
;min or max of xminmax
;
; assume x in radians (-pi,pi)
function polyffteval,x,coefI,xminmax

	
	xmin=xminmax[0]
	xmax=xminmax[1]
    xspan=xmax - xmin
	xx= (x - xmin)/xspan
	xx= (((xx > 0.) < 1.) - .5)* 2.*!pi

	deg=coefI.deg
	fsin=coefI.fsin
	z=poly(xx,coefI.coefAr[0:deg])
	if fsin gt 0 then begin
		ii=deg+1
	    hcoef=reform(coefI.coefAr[ii:ii+fsin*2-1],2,fsin)
		for i=1,fsin do begin
			z=z + hcoef[0,i-1]*cos(i*xx) + hcoef[1,i-1]*sin(i*xx) &$
		endfor
	endif
	return,z
end
