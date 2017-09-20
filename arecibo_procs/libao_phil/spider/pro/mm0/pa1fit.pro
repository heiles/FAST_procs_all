pro pa1fit, pa1, const, int, coeffs, coeffsp, sigma, resids, $
    niterations, cov, nodiscard=nodiscard
;+
;NAME:
;pa1fit
; PURPOSE: LEAST-SQUARE FITS 
;
;   INT = A*COS(PA1) + B*SIN(PA1) + C (C is optional)
;
;DISCARDS POINTS EXCEEDING 3 SIGMA!!!
;
; CALLING SEQUENCE:
;
;PA1FIT, pa1, const, int, $
;   coeffs, coeffsp, sigma, resids, niterations, cov
;
; INPUTS:
;
;   PA1, the array of angles. Units are DEGREEES
;   CONST: set equal to zero to NOT fit the C above, nonzero to fit
;the C. 
;   INT, the array of intensities.
;
;KEYWORD:
;   NODISCARD: setting it prevents testing residuals and discarding
;bad points.
;
; OUTPUTS:
;   COEFFS = fltarr( 3,2):
;       COEFFS[*,0] are the fitted coefficients
;       COEFFS[*,1] are the errors
;
;   COEFFSP = fltarr( 2,2). 
;       COEFFSP[0,*] is the amplitude and its error.
;       COEFFSP[1,*] is the phase angle and its error, units 
;       DEGREES!!!
;   
;   SIGMA: the sigma of the residuals from the fit
;   RESIDS: the array of residuals
;   NITERATIONS: number of iterations used in discarding 3sig
;points.
;   COV: the normalized covariance matrix
;
; EXAMPLE:
;
; MODIFICATION HISTORY:
;-

;REDEFINE THE INPUT VARIABLES, PROPER UNITS AND ALL...
x1 = reform(!dtor*reform(pa1))
t = reform(int)

nnrr=2
if (const ne 0) then nnrr=3

niterations=0

ITERATE:

;SET UP THE EQUATIONS OF CONDITION...
ndata = n_elements(t)
s = fltarr(nnrr, ndata, /nozero)
s[0,*] = cos(x1)
s[1,*] = sin(x1)
if (nnrr eq 3) then s[2,*]=1.

;SOLVE...
ss = transpose(s) ## s
st = transpose(s) ## transpose(t)
ssi = invert(ss)
a = ssi ## st
bt = s ## a
resid = t - bt
sigsq = total(resid^2)/(ndata-float(nnrr))
sigarray = sigsq * ssi[indgen(nnrr)*(nnrr+1)]
sigcoeffs = sqrt( abs(sigarray))
sigma = sqrt(sigsq)

IF KEYWORD_SET( NODISCARD) THEN GOTO, NODISCARD

;CHECK TO SEE IF RESIDUALS EXCEED 3 SIGMA...
jndx = where( abs(resid) lt 3.0*sigma, count)

;IF THEY EXCEED 3 SIGMA, ITERATE...
if ( (count-ndata) ne 0l) then begin
x1 = x1[jndx]
t = t[jndx]
niterations=niterations+1
goto, ITERATE
endif

NODISCARD:

;DEFINE OUTPUT VARIABLES...
coeffs = fltarr(nnrr,2)
coeffsp = fltarr(2,2)

coeffs[*,0] = a
coeffs[*,1] = sigcoeffs

;A[0] IS Q_SRC AND A[1] IS U_SRC, SO...
srcpol = fltarr(2)
srcpa = fltarr(2)
for nrn=0,0,2 do begin
srcpol[0] = sqrt( a[0+nrn]^2 + a[1+nrn]^2)
srcpol[1] = sqrt( (a[0+nrn]*sigcoeffs[0+nrn])^2 + $
    (a[1+nrn]*sigcoeffs[1+nrn])^2)/srcpol[0]

srcpa[0] = !radeg*atan(a[1+nrn],a[0+nrn])
srcpa[1] = !radeg* $
        sqrt( (a[0+nrn]*sigcoeffs[1+nrn])^2 + $
    (a[1+nrn]*sigcoeffs[0+nrn])^2)/(srcpol[0]^2)

coeffsp[0+nrn,*] = srcpol 
coeffsp[1+nrn,*] = srcpa
endfor

;CALCULATE RESIDUALS...
x1 = reform(!dtor*reform(pa1))
t = reform(int)

nnrr=2
if (const ne 0) then nnrr=3

ndata = n_elements(t)
s = fltarr(nnrr, ndata, /nozero)
s[0,*] = cos(x1)
s[1,*] = sin(x1)
if (nnrr eq 3) then s[2,*]=1.

bt = s ## a
residS = t - bt

;DERIVE THE NORMALIZED COVARIANCE ARRAY...
doug = ssi[indgen(nnrr)*(nnrr+1)]
doug = doug#doug
cov = ssi/sqrt(doug)

;stop
end

