pro zec2_zfit, v0, i0, bchnls, degree, $
        coeffs, sigma, vpredicted, vzmn, resids1, resids2, $
	niterations, indxincluded, WEIGHT=weight, printcoeffs=printcoeffs, $
        sigmalim=sigmalim       
;+
;NAME:
;   ZEC2_ZFIT
;
;PURPOSE:
;    Fit I plus dI/dchnl plus a polynomial baseline to a stokes parameter.
;
;***important note on sign of derived B***
;       ZFIT gives opposite sign from ZEC2_ZFIT. tim says that zec2_zfit
;       is correct.
;
;CALLING SEQUENCE:
;    zec2_zfit, v0, i0, bchnls, degree, $
;	coeffs, sigma, vpredicted, vzmn, resids1, resids2, $
;	niterations, indxincluded
;
;INPUTS:
;     v0: the data points of the Stokes Q,U,V spectrum.
;     i0: the data points of the Stokes I/2 (***NOT Stokes I***) spectrum.
;     BCHNLS:  the entire array of chnls to include in the fit.
;     DEGREE: order of baseline (2 is second order, for example)
;
;OPTIONAL INPUTS:
;     WEIGHT = array of weights for weighted least-squares fit
;     SIGMALIM - data having residuals exceeding sigmalim*sigma are
;                discarded. Default is 3
;
;KEYWORDS
;     PRINTCOEFFS -- set to print the coeffs in this proc.
;
;OUTPUTS:
;     COEFFS[*,2]; the fitted coeffs and their errors. coeffs[0,*] is gain,
;     [1,*] is B
;     SIGMA: the dispersion from the fit.
;     VPREDICTED: the fitted line including polynomial, gain, and zmn fit.
;	VZMN: the 'S-curve' of the FIT: fitted line including only the 
;		polynomial and gain parts.
;     RESIDS1: the S-curve of the DATA: the data minus the polynomial + I0 fit, 
;		NOT including dI0/dchnl
;		thus, it is the data minus the extraneous effects of
;		baseline and gain error, so it shows the zmn splitting by 
;               itself.
;     RESIDS2: the data minus the FULL fit including the I0 part.
;     NITERATIONS: nr of iterations (it discards bad datapoints)
;     INDXINCLUDED: the channel nrs that were included in the final fit
;     COV: the normalized covariance matrix.
;
;UNITS OF FITTED FIELD:
;       Bfld is the frequency separation betweeen the RHC and LHC 
;components in units of channels. Thus, if the channel width is 2800 Hz
;and bfld is returned as 1.00, and if the splitting is 2.8 Hz per microG
;as it is for HI, then the freq separation between the two components is
;2800 Hz and the field is 1000 Microg.
;
;HISTORY: 11 jul 2000: derived from a combination of iifitpoly.pro and
;	zfitao.pro
;5may03: sign of B fixed. I/2 instead of I fixed. for GBT.
;29jun05: Tim changes I derivative to form advertised, rather than the
;         ad hoc negative sign stuck in the derivative by Carl.  This
;         provides the "correct" sign of B and makes trying to parse the
;         code a little easier.
;07jul05: Tim adds weighting option... the V spectra should be weighted by the
;         1/RMS of the data, but to do this right, you need to consider that
;         RMS is larger in channels where the emission is large.
;25mar09: changed 3.0 to sigmalim
;-

if n_elements( sigmalim) eq 0 then sigmalim=3.0
niterations=0
n2048 = n_elements(v0)
indx = bchnls
indxincluded = indx
ndata = n_elements(indx)
ncoeffs = degree+3

t =  double(v0[indx])
x1 = double(indx) - (n2048/2)
x2 = double(i0[indx])
;GET THE I0 DERIVATIVE SPECTRUM...
   ; B IS PROPORTIONAL TO dI(nu)/dnu
   ; FURTHER DOWN THE PIPELINE, WE CALCULATE B ASSUMING
   ; THE SPLITTING IS DERIVED HERE AS dI(channel)
   ; THE ROUTINE THAT CALCULATES B FROM THE SPLITTING
   ; TAKES CARE OF WHETHER YOU WERE OBSERVING
   ; I(nu) OR I(vlsr) AND ADDS A NEGATIVE IF THE LATTER
   ; WE WANT THE DERIVATIVE WITH RESPECT TO CHANNEL
   ; SO WE JUST TAKE THE DIFFERENCE BETWEEN THE UP-SHIFTED
   ; AND DOWN-SHIFTED SPECTRA...
i0der = 0.5*(shift(double(i0),+1) - shift(double(i0),-1))
x3 = i0der[ indx]

if (N_elements(weight) eq 0) $
  then wgt = dblarr(ndata) + 1d0 $
  else wgt = weight[ indx]

;plot, wgt, ps=-4
;plot, i0[indx]
;oplot, x3, co=!red
;wait,2

;STOP
ITERATE:
ndata = n_elements(t)

; BUILD THE EQUATIONS OF CONDITION...
s = dblarr(ncoeffs, ndata, /nozero)
s[0,*] = x2 * wgt ; FIRST, STOKES I
s[1,*] = x3 * wgt ; THEN, DERIVATIVE OF STOKES I
; THEN ADD POLYNOMIAL COMPONENTS...
for ndeg = 0, degree do s[ ndeg+2,*] = x1^ndeg * wgt

ss = transpose(s) ## s
st = transpose(s) ## transpose(t * wgt)
;st = transpose(s) ## transpose(t)
ssi = invert(ss)
a = ssi ## st
bt = reform(s ## a)
resid = t * wgt - bt
sigsq = total(resid^2)/(ndata-ncoeffs)
sigma = sqrt(sigsq)

;STOP 

;CHECK TO SEE IF RESIDUALS EXCEED 3. SIGMA...
jndx = where( (abs(resid) lt sigmalim*sigma) , count)

;IF THEY EXCEED 3 SIGMA, ITERATE...
if ( ( count-ndata) ne 0l) then begin
    x1 = x1[ jndx]
    x2 = x2[ jndx]
    x3 = x3[ jndx]
    t = t[ jndx]
    wgt = wgt[ jndx]
    indxincluded = indxincluded[ jndx]
    niterations=niterations+1
    goto, ITERATE
endif

;STOP, 'finished iterating'

sigarray = sigsq * ssi[indgen(ncoeffs)*(ncoeffs+1)]
sigcoeffs = sqrt( (sigarray))

;DEFINE OUTPUT VARIABLES...
coeffs = fltarr(ncoeffs,2)
coeffs[*,0] = float(a)
coeffs[*,1] = float(sigcoeffs)
sigma=float(sigma)

;help, coeffs
if keyword_set( printcoeffs) then print, 'coeffs',coeffs

;stop

;===============================================

;CALCULATE RESIDUALS...
x1 = dindgen(n2048) - (n2048/2) 
x2 = double(i0)
x3 = i0der
t =  double(v0)

ndata = n_elements(t)
s = dblarr(ncoeffs, ndata, /nozero)
s[ 0,*] = x2
s[ 1,*] = x3
for ndeg = 0, degree do s[ ndeg+2,*] = x1^ndeg

;     RESIDS2: the data minus the FULL fit including the I0 part.
vpredicted = reform(s ## a)
resids2 = float( t - vpredicted)

; TAKE A LOOK AT RESULTS...
;look = 1
if keyword_set(look) then begin
    plot, bchnls, v0[bchnls], xs=19, /NODATA
    oplot, bchnls, v0[bchnls], co=!cyan
    oplot, bchnls, vpredicted[bchnls], co=!yellow, thick=2
    oplot, indxincluded, indxincluded*0-0.2, ps=4, co=!green, symsiz=0.2
    wgt = weight[bchnls]
    oplot, bchnls, (wgt-min(wgt))*(!y.crange[1]-!y.crange[0])/(max(wgt)-min(wgt))+!y.crange[0], co=!red
endif

;     RESIDS1: the S-curve of the DATA: the data minus the polynomial + I0 fit,
;               NOT including dI0/dchnl
;               thus, it is the data minus the extraneous effects of
;               baseline and gain error, so it shows the zmn splitting by itself.
a[ 1]=0.d0  ; EXCLUDE THE STOKES I DERIVATIVE...
bt = s ## a
resids1 = float( t - bt)

;	VZMN: the 'S-curve' of the FIT: fitted line including only the 
;		polynomial and gain parts.
vzmn = vpredicted - bt

;oplot, vzmn, co=!green

;STOP
end

