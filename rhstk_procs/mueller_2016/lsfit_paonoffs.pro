pro lsfit_paonoffs, pa, apb, int, sigmalimit, coeffs, $
	sigma, fittedpoints, niterations 
;+ 
;PURPOSE: least square fit observed points to A + B cos(2PA + C sin(2PA),
;	excludes points with residuals gt SIGMALIMIT * sigma.
;CALLING SEQUENCE:
;       LSFIT_PAONOFFS, pa, apb, int, sigmalimit, coeffs, $
;	sigma, fittedpoints, niterations 
;INPUTS: 
;	PA, the set of parallactgic angles on the sky, DEGREES.
;       APB, the set of observed total intensities (A+B) for the PAs
;	INT, one set of the three observed 'pseudostokes' params (amb,ab,ba)
;	SIGMALLIMIT: discard points whose sigmas exceed sigmalimit times
;       sigma, where sigma is calculated from the residuals. 
;
;OUTPUTS:
;	COEFFS, SEE NOTE BELOW! the set of fitted coefficients:
;		COEFFS=fltarr[3,2]
;		COEFFS[*,2] are the dc, cos, and sin coefficients
;		COEFFS[3,*] are the value and error.
;IMPORTANT NOTE CONCERNING THE UNITS OF COEFFS:
;COEFFS is unitless because it is the fit of INT/APB. But it's
;not as simple as fitting 
;        (INT/APB) to A + B cos(2PA + C sin(2PA),
;which is bad practice because points with low APB (because of
;noise, say) receive large weights. So instead we fit
;        INT to APB*[A + B cos(2PA + C sin(2PA)]
;
;	FITTEDPOINTS: the array of points that were actually used in the
;fit. 
;	NITERATIONS: the number of iterations (used in discarding bad
;points)
;
;HISTORY:
;15oct2016 CH fixed problem with throwing out bad
;       data--apb wasn't treated properly.
;28apr2017: CH fixed documentation and added the 'important note'.
;-

;REDEFINE THE INPUT VARIABLES, PROPER UNITS AND ALL...
x = 2.*!dtor*pa
t = int
apbx=apb
niterations=0

ITERATE:

;SET UP THE EQUATIONS OF CONDITION...
nnrr=3
ndata = n_elements(x)
s = fltarr(nnrr, ndata, /nozero)
s[0,*] = apbx
s[1,*] = apbx* cos(x)
s[2,*] = apbx* sin(x)

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

;CHECK TO SEE IF RESIDUALS EXCEED sigmalimit * SIGMA...
jndx = where( abs(resid) lt sigmalimit*sigma, count)

;print, jndx
;print, size(x)
;stop, 'lsfitpa_allcal' ;;################

;IF THEY EXCEED sigmalimit * SIGMA, ITERATE...
;if ( (count-ndata) ne 0l) then begin
if ( (count-ndata) ne 0l and ( count ge 3) ) then begin
x = x[jndx]
apbx= apbx[ jndx]
t = t[jndx]
niterations=niterations+1
goto, ITERATE
endif

;DEFINE OUTPUT VARIABLES...
coeffs = fltarr(3,2)
coeffsp = coeffs

coeffs[*,0] = a
coeffs[*,1] = sigcoeffs
fittedpoints = [[0.5*!radeg*x], [reform(bt)]]

;A[1] IS Q_SRC AND A[2] IS U_SRC, SO...
srcpol = fltarr(2)
srcpa = fltarr(2)
srcpol[0] = sqrt( a[1]^2 + a[2]^2)
srcpol[1] = sqrt( (a[1]*sigcoeffs[1])^2 + (a[2]*sigcoeffs[2])^2)/srcpol[0]

srcpa[0] = !radeg*0.5*atan(a[2],a[1])
srcpa[1] = !radeg*0.5* $
            sqrt( (a[1]*sigcoeffs[2])^2 + (a[2]*sigcoeffs[1])^2)/(srcpol[0]^2)


coeffsp[0,0] = a[0]
coeffsp[0,1] = sigcoeffs[0]
coeffsp[1,*] = srcpol 
coeffsp[2,*] = srcpa

;stop
end

