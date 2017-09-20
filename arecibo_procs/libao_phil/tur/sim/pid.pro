;+
;NAME:
;pid - evaluate pid function
;ARGS:
;	delta - error
;   area  - integral of error
;   coef  - hold pid coef to use
;RETURNS:
;	dac value to use for velocity
;-
function pid,delta,area,coef
;

	area-= .5*delta
	rval=  coeff.P * delta +  coeff.I * Area + coeff.D * delta
	return,long( (rval < 2047L) > -2047L)
end
