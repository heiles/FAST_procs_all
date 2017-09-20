function gauss_cdf, x, sigma

;+
;PURPOSE:
;	return the cumulative pdf of a gaussian pdf. 
;
;INPUTS: 
;	x, the x value
;	sigma, the sigma value of the Gaussian pdf
;
;OUTPUTS: 
;	returns the cdf of gaussian distribution.
;-

return, (1. + errorf( x/( sigma*sqrt(2))) )/ 2.


end


