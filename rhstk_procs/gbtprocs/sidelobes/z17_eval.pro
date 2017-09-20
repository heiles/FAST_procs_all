function z17_eval, derivs, deltax, deltay

;+
;Z17_EVAL...evaluate T from the z17 derivatives...

;INPUTS
;the DERIVS VECTOR from FIT_Z17. derivs is an array; input derivs[nch,*]
;deltax[], deltay[]--the offsets from zero. can be vectors.

;RETURNS the SUM of the spectra evaluated from the derivatives.
;-

nrd= n_elements( deltax)
ncoeffs= n_elements( derivs)

s= fltarr( ncoeffs, nrd)

s[0,*]= 1.+fltarr( nrd)
s[1,*]= deltax
s[2,*]= deltay
s[3,*]= deltax^2/ 2.
s[4,*]= deltay^2/ 2.
s[5,*]= deltax* deltay

if ncoeffs eq 10 then begin
s[6,*]= deltax^3/ 6.
s[7,*]= deltax^2* deltay/ 2.
s[8,*]= deltax* deltay^2/ 2.
s[9,*]= deltay^3/ 6.
endif

result= s ## transpose( derivs)

return, result
end

