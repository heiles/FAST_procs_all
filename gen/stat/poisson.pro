function poisson, n, nbar

;+
;CALLING SEQ
; result = poisson( n, nbar)
;given nbar and n, return the poisson probability.
;-
m = long(n)
mbar= double(nbar)

poisson = mbar^m * exp(-mbar)/factorial( m)

return, poisson
end

