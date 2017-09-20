function binomialdist, N
;+
; NAME:
;       binomialdist
;     
; PURPOSE:
;       Return the binomial distribution 
;     
; CALLING SEQUENCE:
;       RESULT = BINOMIALDIST(N)
;     
; INPUTS:
;       N : Number of Bernoulli trials to consider.
;
; OUTPUTS:
;       Returns a vector containing the binomial distribution.
;
; RESTRICTIONS:
;       N must be less than the value which makes N! larger than the
;       largest usable floating point value on your machine!
;       That's N < 151 on my machine, but will likely be different
;       for you.
;
; PROCEDURES CALLED:
;       FACTORIAL
;
; EXAMPLE:
;       distribution = binomialdist(134)
;
; NOTES:
;       The binomial distribution gives the probability distribution of 
;       obtaining exactly i successes out of N Bernoulli trials (where the 
;       result of each Bernoulli trial is true with probability p and false
;       with probability q=1-p).
;
; MODIFICATION HISTORY:
;   Written Tim Robishaw, Berkeley 01 Dec 2001.
;-

; MAYBE LOOK INTO USING LNGAMMA SOMEDAY TO REACH HIGHER N...

on_error, 2

; PROBABILITY FOR SUCCESS IN A BERNOULLI TRIAL...
p = 0.5d0
q = 1d0-p

N = double(N)
; SAVE SOME TIME BY STORING N! IN A VARIABLE...
N_factorial = GAMMA(N+1)

; CHECK THAT WE DON'T EXCEED THE LARGEST USABLE FLOATING-POINT VALUE...
if not (finite(N_factorial/q^N) and finite(N_factorial/p^N)) then begin
    message, 'N!/p^N and N!/q^N must be < '+$
      strtrim((machar(/double)).xmax,2), /CONTINUE
    message, 'Here, N = '+strtrim(N,2)+', p = '+strtrim(float(p),2)+$
      ', q = '+strtrim(float(q),2)
endif

dist = dindgen(N+1)
dist = (GAMMA(dist+1)*GAMMA(N-dist+1))^(-1)*p^dist*q^(N-dist)

return, N_factorial*dist

end; binomialdist
