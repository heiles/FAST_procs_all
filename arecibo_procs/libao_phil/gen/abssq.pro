;+
;NAME:
;abssq - compute absolute value then square
;SYNTAX: pwr=abssq(v)
;ARGS:
;   v[n]: complex voltage to compute power
;RETURNS:
; pwr[n]: float  real(v)*real(v) + img(v)*img(v)
;DESCRIPTION:
;   Compute the square of the absolute value
;-
function abssq,v
    return,(real_part(v)*real_part(v)+imaginary(v)*imaginary(v))
end
