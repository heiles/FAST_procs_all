pro theta_random, n, theta_random, seed=seed, pi_over2=pi_over2

;+ 
;NAME:
;theta_random -- generate random numbers distributed according to sin theta.
;
;PURPOSE: generate random numbers distributed according to sin theta.
;CALLING SYNTAX:
;	theta_random, nr, theta_random, seed=seed, pi_over2=pi_over2
;
;INPUT:
;	nr, nr of random theta's to generate.
;KEYWORDS:
;	seed--the usual
;	pi_over2--restricts theta range to 0 --> pi/2 instead of 0 --> pi.
;OUTPUT:
;	theta_random, the set of random theta's.
;-

r= randomu( seed, n)

if  keyword_set( pi_over2) then begin
	theta_random= acos( r)
endif else begin
	theta_random= acos( 1. - 2.*r) 
endelse

indx= where( finite( theta_random)  ne 1, count)

;if (count ne 0) then begin
;print, count
;stop
;endif

return
end
