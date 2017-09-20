pro pafit, eoption, pangle, data, $
	coeffs, coeffsp, panglef, dataf, cov, panglefit,datafit
;+
;FIT INPUT NUMBERS TO 
;	E + A*COS(PANGLE) + B*SIN(PANGLE) + C*COS(2*PANGLE) + D*SIN(2*PANGLE)
;AND EXCLUDE OUTLIERS EXCEEDING 3 SIGMA.
;
;EOPTION=1 MEANS INCLUDE E IN THE FIT
;ANYTHING ELSE MEANS DON'T INCLUDE E IN THE FIT, FORCE E TO ZERO.

;THE OUTPUTS ARE...
;COEFFS=FLTARR[5,2]
;	COEFFS[*,0] ARE THE A, B, C, D, E ABOVE. NOTE ZERO POINT E IS LAST.
;	COEFFS[*,1] ARE THE ERRORS.
;COEFFSP=FLTARR[5,2]
;	COEFFSP[*,0] ARE B, THE INTENSITIES, AND POSN ANGLES (DEGREES)
;	COEFFSP[*,1] ARE THE ERRORS IN ABOVE.
;
;	SRCPOS=FLTARR[1], THE POLARIZED INTENSITY ANGLE AND ITS ERROR
;	SRCPA=FLTARR[2], THE POSITION ANGLE AND ITS ERROR
;PANGLEF, DATAF ARE THE ACTUAL POINTS THAT WERE FITTED AND NOT TOSSED OUT.
;common plotcolors
;common lsfitpa
;-

;REDEFINE THE INPUT VARIABLES, PROPER UNITS AND ALL...
x = reform(!dtor*reform(pangle))
t = reform(data)
niterations=0

ITERATE:

;SET UP THE EQUATIONS OF CONDITION...
nnrr=4 + 1*(eoption eq 1)
ndata = n_elements(x)
s = fltarr(nnrr, ndata, /nozero)
s[0,*] = cos(x)
s[1,*] = sin(x)
s[2,*] = cos(2.*x)
s[3,*] = sin(2.*x)
if (eoption eq 1) then s[4,*] = 1.

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
sigslope = sigcoeffs[0]
sigma = sqrt(sigsq)

;CHECK TO SEE IF RESIDUALS EXCEED 3.0 SIGMA...
jndx = where( abs(resid) lt 3.0*sigma, count)

;IF THEY EXCEED 3.0 SIGMA, ITERATE...
if ( (count-ndata) ne 0l) then begin
x = x[jndx]
t = t[jndx]
dataf=t
niterations=niterations+1
goto, ITERATE
endif

;END OF ITERATING...CLEAN UP...

panglefit=!radeg*x
datafit= reform(bt)

;DERIVE THE NORMALIZED COVARIANCE ARRAY...
doug = ssi[indgen(nnrr)*(nnrr+1)]
doug = doug#doug
cov = ssi/sqrt(doug)

;DEFINE OUTPUT VARIABLES...
coeffs = fltarr(5,2)
coeffsp = fltarr(5,2)

a = reform(a)
;print, a
;print, sigcoeffs

aatemp = fltarr(5)
sigaatemp=fltarr(5)
if (eoption eq 1) then begin
	aatemp=a 
	sigaatemp= sigcoeffs
endif else begin
	aatemp[0:3]=a
	aatemp[4]=0.
	sigaatemp[0:3]=sigcoeffs
	sigaatemp[4]=0.
endelse
a=aatemp
sigcoeffs=sigaatemp

;print, a
;print, sigcoeffs

coeffs[*,0] = a
coeffs[*,1] = sigcoeffs
panglef = !radeg*x

;AMPLITUDES, PHASES...
ampl1 = sqrt( a[0]^2 + a[1]^2)
ampl2 = sqrt( a[2]^2 + a[3]^2)
phase1 = !radeg*atan(a[1],a[0])
phase2 = !radeg*0.5*atan(a[3],a[2])

;ERRORS...
sigampl1 = sqrt( (a[0]*sigcoeffs[0])^2 + (a[1]*sigcoeffs[1])^2)/ampl1
sigampl2 = sqrt( (a[2]*sigcoeffs[2])^2 + (a[3]*sigcoeffs[3])^2)/ampl2
sigphase1 = !radeg* $
            sqrt( (a[0]*sigcoeffs[1])^2 + (a[1]*sigcoeffs[0])^2)/(ampl1^2)
sigphase2 = !radeg*0.5* $
            sqrt( (a[2]*sigcoeffs[3])^2 + (a[3]*sigcoeffs[2])^2)/(ampl2^2)

;CREATE COEFFSP...
coeffsp[0,0] = ampl1 
coeffsp[1,0] = phase1
coeffsp[0,1] = sigampl1 
coeffsp[1,1] = sigphase1
coeffsp[2,0] = ampl2 
coeffsp[3,0] = phase2
coeffsp[2,1] = sigampl2 
coeffsp[3,1] = sigphase2
coeffsp[4,0] = a[0]
coeffsp[4,1] = sigcoeffs[0]

;stop
end

