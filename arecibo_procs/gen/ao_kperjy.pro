function ao_kperjy, za

;+
;GIVES K PER JY FOR ARECIBO AS A FUNCTION OF ZA IN DEGREES.
;THIS IS FULLY VECTORIZED...

;COEFFS FOR BOTH FEB99 AND MAR00 SOURCES TOGETHER ARE DERIVED AS:
;      19.516136     -0.17253222   -0.0016366700
;     0.023612855    0.0043309366   0.00092864432
;-

coeffs = [ 19.516136, -0.17253222, -0.0016366700]

za10 = za - 10.

za10s = [ [ 1.+fltarr(n_elements(za))], [ za10], [ za10^2]]

kperjy = coeffs ## za10s

;stop

return, kperjy

end
