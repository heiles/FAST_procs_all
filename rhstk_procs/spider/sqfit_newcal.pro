pro sqfit_newcal, nrstrip, nstk, offset, tdata, $    
        tfit, sigma, stripfit, sigstripfit, problem, cov

;+
;
;   SQFIT_NEWCAL, nrstrip, nstk, offset, tdata, $    
;        tfit, sigma, stripfit, sigstripfit, problem, cov
;
;PURPOSE: Given a single strip scan, the previously accomplished Stokes
;I fit to that scan with XPYFIT_NEWCAL, and a single one of the three
;polarized Stokes parameters, fit:
;       (1) Intensities of polarized power in the central beam and the 
;two sidelobes (the "gain error")'
;	(2) Beam squint (first derivative of Gaussian) and 
;	(3) Squash (diff in beamwidths) for ALL POL STOKES AND ONE STRIP.
;	For deriving polarization leakage, beam squint and 
;	beam squash. the parameters
;	of the original gaussian are already known.
;
;CALLING SEQUENCE:
;    SQFIT_NEWCAL, nrstrip, nstk, offset, tdata, $    
;        tfit, sigma, stripfit, sigstripfit, problem, cov
;
;INPUTS:
;       NRSTRIP, the sequential number of the strip (0 to NRSTRIPS-1)
;
;	NSTK, the Stokes parameter. (1,2,3) = (Q,U,V).
;
;       OFFSET, the angular offset from the assumed center IN UNITS OF
;THE ASSUMED HPBW.
;
;	TDATA, the Stokes Q, U, or V system temperatures at each point. 
;Units are Kelvins. 
;
;	STRIPFIT, the input/output data array.  STRIPFIT[ *, 0, NRSTRIP] are
;the PREVIOUSLY-DERIVED results for Stokes I
;
;OUTPUTS:
;     TFIT: the fitted values of the data at the points in offset.
;
;     SIGMA: the rms of the residuals (TDATA- TFIT).
;
;     STRIPFIT[ *, NSTK, NRSTRIP], SIGSTRIPFIT: array of fitted
;parameters and errors for this stokes parameter NSTK, this strip
;NRSTRIP. See full documentation in BEAM1DFIT.PRO .
;
;     SIGSTRIPFIT: the array of errors of coeffs.
;
;     problem: 0, OK;  -3, negative sigmas; 4, bad derived values.
;
;     cov: the normalized covariance matrix of the fitted coefficients.
;
;INTERMEDIATE RESULTS...
;	COEFFS: the array of fitted parameters, which are:
;	[zero offset, main beam polarized intensity, squint, squash, 
;		left sidelobe polarized intensity,
;		right sidelobe polarized intensity]
;
;RELATED PROCEDURES:
;	GCURV_ALLCAL
;HISTORY:
;	Derived from sqfit.pro, 13sep00
;	NEWCAL mod by carl, 9 oct 2002
;	2003feb06: factor of two error in squint, squash fixed. earlier
;squint/squash were factor of two too small. In PASP article, see
;equation 20: the factor (I/2) sits iin front of the second term instead
;of the factor (I). this factor of two repair is put in at the end of
;this program.
;-

;common plotcolors

;DEFINE THE INPUT DATA...
zro1 = stripfit[ 10, 0, nrstrip]
slope1 = stripfit[ 11, 0, nrstrip] 
alpha1 = stripfit[ 0, 0, nrstrip]

;NOTE THE 0.5, ADDED FOR THE FACTOR OF TWO PROBLEM (SEE 'HISTORY'):
hgt1 = 0.5* stripfit[ 1:3, 0, nrstrip] 
cen1 = stripfit[ 4:6, 0, nrstrip]
wid1 = stripfit[ 7:9, 0, nrstrip]

;DETERMINE THE SIZE OF THE DATA ARRAY...
dtsize = n_elements(tdata)

;CREATE THE NORMAL EQUATIONS...
indx = where( sigstripfit[ 1:3, 0, nrstrip] ne 0, count)

if (count eq 0) then begin
	problem = -1
	goto, problem
endif

nparams = 3 + count
s=fltarr( nparams, dtsize)
problem=0

;DEFINE MULTIPLIER FOR NUMERICAL DERIVATIVES...
dmult = 0.01

;POPULATE THE S MATRIX...

;	COEFFS: the array of fitted parameters, which are:
;	[zero offset, main beam polarized intensity, squint, squash, 
;		polarized intensity in first sidelobe,
;		polarized intensity in latter sidelobe]
;
sindx = 0
;ZERO OFFSET...
s[ sindx,*] = 1. + fltarr(dtsize) 
sindx = sindx + 1

;MAIN BEAM POLARIZED INTENSITY...
hgtoffset = hgt1
hgtoffset[ 0] = hgt1[ 0]*(1. + dmult)
gcurv_allcal, offset, zro1, slope1, alpha1, hgtoffset, cen1, wid1, gtfitplus
hgtoffset[ 0] = hgt1[ 0]*(1. - dmult)
gcurv_allcal, offset, zro1, slope1, alpha1, hgtoffset, cen1, wid1, gtfitminus
s[ sindx,*] = (gtfitplus- gtfitminus)/(2.*dmult*hgt1[ 0])
sindx = sindx + 1

;MAIN BEAM SQUINT...
cenoffset = cen1
cenoffset[ 0] = cen1[ 0] + wid1[ 0]*(0. + dmult)
gcurv_allcal, offset, zro1, slope1, alpha1, hgt1, cenoffset, wid1, gtfitplus
cenoffset[ 0] = cen1[ 0] + wid1[ 0]*(0. - dmult)
gcurv_allcal, offset, zro1, slope1, alpha1, hgt1, cenoffset, wid1, gtfitminus
s[ sindx,*] = (gtfitplus- gtfitminus)/(2.*dmult*wid1[ 0])
sindx = sindx + 1

;MAIN BEAM SQUASH...
widoffset = wid1
widoffset[ 0] = wid1[ 0]*(1. + dmult)
gcurv_allcal, offset, zro1, slope1, alpha1, hgt1, cen1, widoffset, gtfitplus
widoffset[ 0] = wid1[ 0]*(1. - dmult)
gcurv_allcal, offset, zro1, slope1, alpha1, hgt1, cen1, widoffset, gtfitminus
s[ sindx,*] = (gtfitplus- gtfitminus)/(2.*dmult*wid1[ 0])
sindx = sindx + 1

;LEFT SIDELOBE POLARIZED INTENSITY...
IF (sigstripfit[ 2, 0, nrstrip] ne 0.) then begin
hgtoffset = hgt1
hgtoffset[ 1] = hgt1[ 1]*(1. + dmult)
gcurv_allcal, offset, zro1, slope1, alpha1, hgtoffset, cen1, wid1, gtfitplus
hgtoffset[ 1] = hgt1[ 1]*(1. - dmult)
gcurv_allcal, offset, zro1, slope1, alpha1, hgtoffset, cen1, wid1, gtfitminus
s[ sindx,*] = (gtfitplus- gtfitminus)/(2.*dmult*hgt1[ 1])
sindx = sindx + 1
ENDIF

;RIGHT SIDELOBE POLARIZED INTENSITY...
IF (sigstripfit[ 3, 0, nrstrip] ne 0.) then begin
hgtoffset = hgt1
hgtoffset[ 2] = hgt1[ 2]*(1. + dmult)
gcurv_allcal, offset, zro1, slope1, alpha1, hgtoffset, cen1, wid1, gtfitplus
hgtoffset[ 2] = hgt1[ 2]*(1. - dmult)
gcurv_allcal, offset, zro1, slope1, alpha1, hgtoffset, cen1, wid1, gtfitminus
s[ sindx,*] = (gtfitplus- gtfitminus)/(2.*dmult*hgt1[ 2])
ENDIF

;CREATE AND SOLVE THE NORMAL EQUATION MATRICES...
t = tdata
ss = transpose(s) ## s
st = transpose(s) ## t
ssi = invert(ss)
a = ssi ## st
bt = s ## a

;DERIVE THE FITTED POINTS, RESIDUALS, THE ERRORS IN DERIVED COEFFICIENTS...
resid = tdata - bt
sigsq = total( resid^2)/(dtsize - nparams)
sigma = sqrt( sigsq)
sigarray = sigsq * ssi[indgen(nparams)*(nparams+1)]
sigcoeffs = sqrt( abs(sigarray))
coeffs = reform( a)
sigma = sqrt(sigsq)
badindx = where( abs(resid) gt 3.*sigma, nr3sig)

;STOP 
;TEST FOR NEG SQRTS...
indxsqrt = where( sigarray lt 0., countbad)
if (countbad ne 0) then begin
        print, countbad, ' negative sqrts in sigarray!' 
        sigcoeffs[indxsqrt] = -sigcoeffs[indxsqrt]
        problem=-3
endif

;TEST FOR INFINITIES, ETC...
indxbad = where( finite( a) eq 0b, countbad)
if (countbad ne 0) then problem=-4

;DERIVE THE NORMALIZED COVARIANCE ARRAY...
doug = ssi[indgen(nparams)*(nparams)]
doug = doug#doug
cov = ssi/sqrt(doug)

tfit=bt

sindx = 0

;ZERO OFFSET
stripfit[ 10, nstk, nrstrip] = coeffs[ sindx] 
sigstripfit[ 10, nstk, nrstrip] = sigcoeffs[ sindx]
sindx = sindx + 1

;MAIN BEAM POL INTENSITY
stripfit[ 1, nstk, nrstrip] = coeffs[ sindx]
sigstripfit[ 1, nstk, nrstrip] = sigcoeffs[ sindx]
sindx = sindx + 1

;MAIN BEAM SQUINT
stripfit[ 4, nstk, nrstrip] = coeffs[ sindx]
sigstripfit[ 4, nstk, nrstrip] = sigcoeffs[ sindx]
sindx = sindx + 1

;MAIN BEAM SQUASH
stripfit[ 7, nstk, nrstrip] = coeffs[ sindx] 
sigstripfit[ 7, nstk, nrstrip] = sigcoeffs[ sindx]
sindx = sindx + 1

;LEFT SIDELOBE POL INTENSITY
IF (sigstripfit[ 2, 0, nrstrip] ne 0.) then begin
stripfit[ 2, nstk, nrstrip] = coeffs[ sindx]
sigstripfit[ 2, nstk, nrstrip] = sigcoeffs[ sindx]
sindx = sindx + 1
ENDIF

;RIGHT SIDELOBE POL INTENSITY
IF (sigstripfit[ 3, 0, nrstrip] ne 0.) then begin
stripfit[ 3, nstk, nrstrip] = coeffs[ sindx]
sigstripfit[ 3, nstk, nrstrip] = sigcoeffs[ sindx]
sindx = sindx + 1
ENDIF

;STOP

return

PROBLEM:


return

end


