;+
;NAME:
;fitsinneval - evaluate the fitsinn fit
;SYNTAX: y=fitsinneval(x,coefI)
;ARGS:
;  x[n]:float  evaluate the fit at these x data points. Units should be
;              radians.
; coefI:{}     structure returned from fitsinn
;RETURNS:
;	y[n]:float fit evaluated at the x points.
;DESCRIPTION:
;   fitsinn() will fit a function: ai*cos(i*x) + bi*sin(i*x) where x=
; 0..n. It returns a structure containing the coef of the fit. This routine
;fitsinneval() will evaluate this fit at user specified x coordinates (which
;should be in radians). 
;-
function fitsinneval,x,coefI
;
	y=x*0. 	+ coefI.c0
	for i=0,coefI.n-1 do begin
		n=i+1
		y+= coefI.cossin[0,i]*cos(n*x) + coefI.cossin[1,i]*sin(n*x)
	endfor
	return,y
end
