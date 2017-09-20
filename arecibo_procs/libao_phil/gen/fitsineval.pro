;+
;NAME:
;fitsineval - evaluate the fitsin() fit
;SYNTAX: y=fitsineval(x,coefAr,cossin=cossin)
;ARGS:
;  x[n]:float  evaluate the fit at these x data points. Units should be
;              radians.
; coefAr[m]:float  coeff returned from finsin
;KEYWORDS:
;cossin  :       if set then fitsin was called with /cossin, so the
;                coef are cos sin, order rather than amp,phase
;RETURNS:
;	y[n]:float fit evaluated at the x points.
;DESCRIPTION:
;   fitsin() will fit a function: c(0) + c(2*I)*sin(I*az - c(2i+1)) .. i=1,2,3,4.. 6 and
;return the coef of the fit in a float array.
;This routine will evaluate the fit at the positions specified y x. X must be in radians.
;
;	If the call to fitsin( /cossin) had cossin set , then you must also set that keyword
;in the call to fitsineval().
;-
function fitsineval,x,coef 
;
	ncoef=n_elements(coef)
	nord = (ncoef -1 )/2l
	y=x*0. + coef[0]
	if keyword_set(cossin) then begin
		for i=1,nord do begin
			y+= coef[2*i-1]*cos(i*x) + coef[2*i]*sin(i*x)
		endfor
	endif else begin
		for i=1,nord do begin
			y+=coef[2*i-1]*sin(i*x - coef[2*i])
		endfor
	endelse
	return,y
end
