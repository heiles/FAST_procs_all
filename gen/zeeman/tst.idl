pro zfit, v0, i0, chnl1a, chnl2a, bfld, berr, gain, gainerr, $
	vpredicted, vmodified, a
;+
;NAME:
;ZFIT -- Fit B fields to Stokes V and I/2 data
;
;PURPOSE:
;    Fit B fields to Stokes V and I/2 data in the channel range
;         chnl1a to chnl2a. Fits the V spectrum to the derivative
;         of the I/2 spectrum (providing the field) and, also, to
;         the I/2 spectrum itself (providing the 'gain' error).
;
;CALLING SEQUENCE:
;    ZFIT, v0, i0, chnl1a, chnl2a, bfld, berr, gain, gainerr, $
;	vpredicted, vmodified, a
;
;INPUTS:
;     v0: the data points of the Stokes V spectrum.
;     i0: the data points of the Stokes I/2 (***NOT Stokes I***) spectrum.
;     chnl1a: the first channel nr to include in the fit.
;     chnl2a: the last channel nr to include in the fit.
;
;OUTPUTS:
;     bfld: the fitted magnetic field. UNITS ARE CHANNELS; SEE BELOW
;     berr: the uncertainty in the fitted field.
;     gain: the 'gain error', the fraction of residual I/2 leaked into V.
;     gainerr: the uncertainty in the gain error.
;     vpredicted: the V spectrum predicted from the bfld (all channels) 
;     vmodified: measured V spectrum with the 'gain error' removed.
;     a: the array of solved-for coefficients
; 
;UNITS OF FITTED FIELD:
;	Bfld is the frequency separation betweeen the RHC and LHC 
;components in units of channels. Thus, if the channel width is 2800 Hz
;and bfld is returned as 1.00, and if the splitting is 2.8 Hz per microG
;as it is for HI, then the freq separation between the two components is
;2800 Hz and the field is 1000 Microg.
;
;RESTRICTIONS:
;    None...that we know of.
;EXAMPLE:
;    You have measured a V and an I spectrum and you want to 
;         derive the associated field strength. 
;
;    ZFIT, v0, i0, chnl1a, chnl2a, bfld, berr, gain, gainerr, $
;	vpredicted, vmodified, a
;
;-

;GET THE I0 DERIVATIVE SPECTRUM...
i0size = n_elements(i0)
i0der = fltarr(i0size)
i0shiftup = fltarr(i0size)
i0shiftdn = fltarr(i0size)
i0shiftup[1:i0size-1]=i0[0:i0size-2]
i0shiftdn[0:i0size-2]=i0[1:i0size-1]
i0der = 0.5*(i0shiftdn-i0shiftup)

chnl1=chnl1a & chnl2=chnl2a
if (chnl1 eq chnl2) then begin
chnl1 = 0
chnl2 = i0size-1
endif

;SET UP EQUATIONS OF CONDITION MATRIX...
ndata = fix(chnl2-chnl1+1)
s = fltarr(3, ndata)
s[0,*]=1. + fltarr(ndata)
s[1,*]=i0[chnl1:chnl2]
s[2,*]=i0der[chnl1:chnl2]
t = v0[chnl1:chnl2]

;SOLVE...
ss = transpose(s) ## s
st = transpose(s) ## t
ssi = invert(ss)
a = ssi ## st
resid = t- (s ## a)
sigsq = total(resid^2)/(ndata-3.)
bfld = a[2]
berr = sqrt( sigsq*ssi[2,2])
gain = a[1]
gainerr = sqrt( sigsq*ssi[1,1])

;vpredicted = a[0] + a[1]*i0 + a[2]*i0der
vpredicted = a[2]*i0der
vmodified = v0 - a[0] - a[1]*i0
;stop
return
end
