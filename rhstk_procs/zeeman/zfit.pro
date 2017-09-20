pro  zfit, v0, i0, chnl1a, chnl2a, bfld, berr, gain, gainerr, $
	vpredicted, vmodified, a, $
	nogain=nogain, novoffset=novoffset, ncov=ncov, $
          sigsq=sigsq, resid=resid
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
;;CALLING SEQUENCE:
;zfit, v0, i0, chnl1a, chnl2a, bfld, berr, gain, gainerr, $
;	vpredicted, vmodified, a, $
;	nogain=nogain, novoffset=novoffset, ncov=ncov, $
;          sigsq=sigsq, resid=resid
;
;INPUTS:
;     v0: the data points of the Stokes V spectrum.
;     i0: the data points of the Stokes I/2 (***NOT Stokes I***) spectrum.
;     chnl1a: the first channel nr to include in the fit.
;     chnl2a: the last channel nr to include in the fit.
;
;KEYWORDS:
;	NOGAIN: set to inhibit fitting for gain
;       NOVOFFSET: set to inhibit fitting for voffset
;       NCOV=NCOV returns the normalized covariance matrix
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
;HISTORY
; 13,14 jul 2006. added nogain and novoffset keywords. returns ncov.
;-

nparams=3- keyword_set( nogain)- keyword_set(novoffset)
i0size = n_elements(i0)

;GET THE I0 DERIVATIVE SPECTRUM...SET ENDS EQUAL TO THEIR NEIGHBORS
i0der= 0.5* (shift(i0,-1)- shift( i0,1) )
i0der[0]=i0der[1]
i0der[ i0size-1]= i0der[ i0size-2]

chnl1=chnl1a & chnl2=chnl2a
if (chnl1 eq chnl2) then begin
chnl1 = 0
chnl2 = i0size-1
endif

sndx=0
;SET UP EQUATIONS OF CONDITION MATRIX...
ndata = fix(chnl2-chnl1+1)
s = fltarr( nparams, ndata)

;DERIVATIVE 
s[ sndx,*]=i0der[chnl1:chnl2]
sndx= sndx+1

;OFFSET
IF KEYWORD_SET( NOVOFFSET) EQ 0 THEN BEGIN
s[sndx,*]=1. + fltarr(ndata)
sndx= sndx+1
ENDIF

;GAIN
if keyword_set( nogain) eq 0 then s[sndx,*]=i0[chnl1:chnl2]

;DATA
t = transpose( v0[chnl1:chnl2])

;SOLVE...
ss = transpose(s) ## s
st = transpose(s) ## t
ssi = invert(ss)
a = ssi ## st
resid = t- (s ## a)
sigsq = total(resid^2)/(ndata- nparams)

sndx=0
;BFLD
bfld = a[0]
berr = sqrt( sigsq*ssi[0,0])
sndx= sndx+ 1

IF KEYWORD_SET( NOVOFFSET) EQ 0 THEN BEGIN
voffset = a[sndx]
voffseterr = sqrt( sigsq*ssi[ sndx, sndx])
vmodified = v0 - a[sndx]
sndx= sndx+ 1
ENDIF ELSE BEGIN
voffset= 0.
voffseterr= 0.
vmodified = v0
ENDELSE

IF KEYWORD_SET( NOGAIN) EQ 0 THEN BEGIN
gain = a[ sndx]
gainerr = sqrt( sigsq*ssi[ sndx, sndx])
vmodified = vmodified - a[ sndx]*i0
ENDIF ELSE BEGIN
gain=0.
gainerr=0.
ENDELSE

vpredicted = a[0]*i0der

;stop

;DERIVE THE NORMALIZED COVARIANCE ARRAY...
cov=ssi
doug = ssi[indgen(nparams)*(nparams+1)]
doug = doug#doug
ncov = ssi/sqrt(doug)

;resid= resid[0,*]


;stop
return
end
