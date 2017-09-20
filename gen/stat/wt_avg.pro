function wt_avg, data, wt, dimension, $
                 SIGMA=sigma, DOUBLE=double, WT_SIGMA=wt_sigma
;+
; NAME:
;       WT_AVG
;
; PURPOSE:
;       To take a simple weighted average of data.
;
; CALLING SEQUENCE:
;       Result = WT_AVG(data, weight [, dimension] [, /SIGMA] [, /DOUBLE] [,
;       WT_SIGMA=variable]
;
; INPUTS:
;       data - an array of data.
;       weight - an array of weights. If the /SIGMA keyword is set, these
;                values are assumed to be the uncertainties in each datum.
;
; OPTIONAL INPUTS:
;       dimension - the dimension over which to average.
;
; KEYWORD PARAMETERS:
;       /SIGMA: set this keyword when inputing the uncertaintied in each 
;               datum. The weight will then be set to 1/sigma^2.
;       /DOUBLE: return the result in double precision.
;       WT_SIGMA - set this keyword to a named variable that will contain
;                  uncertainty of the weighted mean.
;
; COMMON BLOCKS:
;       None.
;
; EXAMPLE:
;       The example from Bevington:
;
;       IDL> d = [fltarr(40)+1.022,fltarr(10)+1.018]
;       IDL> s = [fltarr(40)+0.01,fltarr(10)+0.004]
;       IDL> print, wt_avg(d,s,/SIGMA,WT_SIGMA=wt_sigma)
;             1.01956
;       IDL> print, wt_sigma
;         0.000987730
;
; MODIFICATION HISTORY:
;   17 Jun 2004  Written by Tim Robishaw, Berkeley
;-

on_error, 2

weight = wt

; THERE MUST BE AS MANY WEIGHTS AS THERE ARE DATA...
if not array_equal(size(data,/DIM),size(weight,/DIM)) then $
  message, 'DATA and WEIGHT vectors must have the same dimensions.'
if (N_elements(data) ne N_elements(weight)) then $
  message, 'DATA and WEIGHT vectors must have the same number of elements.'

; WHERE ARE THE WEIGHTS AND DATA FINITE...
wfin = where(finite(weight) AND finite(data),n_fin,$
             COMPLEMENT=wnfin, NCOMPLEMENT=N_nfin)
if (n_fin eq 0) then message, 'There are no finite data with finite weights.'
if (n_nfin gt 0) then weight[wnfin] = 0.0

; HAVE WE PASSED IN UNCERTAINTIES...
; ALLOW FOR THE POSSIBILITY THAT UNCERTAINTIES HAVE BEEN MASKED WITH NAN...
if keyword_set(SIGMA) then begin
    wnz  = where(weight[wfin] gt 0.0)
    weight[wfin[wnz]] = 1./weight[wfin[wnz]]^2
endif 

; DO WE WANT DOUBLE-PRECISION...
isdouble = (size(data,/TYPE) eq 5) OR keyword_set(DOUBLE)

; HAVE WE SPECIFIED A DIMENSION...
if (N_elements(dimension) eq 0) then dimension = 0

; CALCULATE THE SUM OF THE WEIGHTS...
sum_weight = total(weight,dimension,/NAN,DOUBLE=isdouble)

; IF THE USER WANTS IT, CALCULATE THE WEIGHTED SIGMA...
if arg_present(wt_sigma) then wt_sigma = 1./sqrt(sum_weight)

; RETURN THE WEIGHTED AVERAGE...
return, total(weight*data,dimension,/NAN,DOUBLE=isdouble)/sum_weight

end; wt_avg
