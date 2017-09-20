pro onoffs_to_pacoeffs, qpa, apb, amb, ab, ba, sigmalimit, $
	pacoeffs, ngoodpoints=ngoodpoints

;+
;PURPOSE: Take the correlator outputs (APB, AMP, AB, BA in the RHSTK
;writeup and in the Heiles et al PASP article), corrected for cal phase
;and intensity, tracked across the sky and having a healthy range of
;parallactic angles QPA, and least square fit them a function of the form...
;
;
;	(AMB, AB, BA) = APB * [A + B cos(2QPA) + C sin(2QPA)],
;
;where (AMB, AB, BA) are the SOURCE DEFLECTION in one of the three
;polarized Stokes parameters, A+B is the 'total intensity' Stokes param,
;and QPA is the parallactic angle on the sky.  Because we multiply by
;the rhs above by APB, the fitted parameters A, B, and C are unitless;
;they are fractional Stokes parameters (i.e., Stokes parameters divided
;by Stokes I). For more info, see the documeentation to LSFIT_PACOEFFS. 
;
; CALLING SEQUENCE:
;
;STRIPFIT_TO_PACOEFFS, qpa, apb, amb, ab, ba, sigmalimit, $
;	pacoeffs, ngoodpoints=ngoodpoints
;
;INPUTS:
;
;	QPA, the set of astronomical parallactic angles on the sky of the
;observed points.
;
;	APB, AMB, AB, BA are the usual four correlator outputs,
;calibrated by CROSS3_GENCAL. For amplitudes, you should input
;fractional polarizations, so that all apb = unity and the rest are
;divided by apb.
;
;	SIGMALIMIT: discard points with residuals exceeding
;sigmalimit*sigma. 
;
;OUTPUTS:
;
;	PACOEFFS, the set of ls fit coefficients, defined as follows:
;
;		PACOEFFS = fltarr( 3, 2, 4), where
;
;	the FIRST index means A, B, or C above;
;	the SECOND index means the error in the ls fit for the above;
;	the THIRD is the correlator output (Stokes parameter0, defined
;as follows:
;
;	0 means a+b
;	1 means a-b
;	2 means ab
;	3 means ba
;
;Note that, because we are deriving FRACTIONAL POLARIZATIONS,
;PACOEFFS[0,*,0] is returned as unity and
;PACOEFFS[1:2,*,0] are returned as zero (within roundoff). 
;
;OPTIONAL OUTPUTS:
;
;	NGOODPOINTS[4], the nr of points included in the fit for each
;stokes parameter. 0th element is total nr of points; elements 1,2,3 are
;the nr of points used in the fit for amb, ab, and ba, respectively.
;
; RELATED PROCEDURES/FUNCTIONS:
;	LSFIT_PAONOFFS is used from this procedure
;
;MODIFICATION HISTORY: Jun 2013, CH lsfitted apb so that its pacoeffs
;   values aren't exactly 1,0,0. shouldn't matter down the line,k and this
;   makes the routine work whether or not things are normalized to apb.
;7aug2016: documentation cleaned up, extraneous stuff eliminated.
;28pr2017: erroneous documentation fixed (it said to input fractional
;pol stokes. not true! the fractionalization takes place in the fitting
;process (i.e., in LSFIT_PAONOFFS).
;-

;ZERO THE OUTPUT ARRAY...
pacoeffs = fltarr( 3, 2, 4)
ngoodpoints= intarr(4)
pacoeffs[ 0, 0, 0] = 1.

;stop

;;FIT USING THE MODIFIED STOKES...
lsfit_paonoffs, qpa, apb, apb, sigmalimit, icoeffs, sigma, fittedpointsi
pacoeffs[ *, *, 0] = icoeffs
;stop
lsfit_paonoffs, qpa, apb, amb, sigmalimit, qcoeffs, sigma, fittedpointsq
pacoeffs[ *, *, 1] = qcoeffs
;stop
lsfit_paonoffs, qpa, apb, ab, sigmalimit, ucoeffs, sigma, fittedpointsu
pacoeffs[ *, *, 2] = ucoeffs
;stop
lsfit_paonoffs, qpa, apb, ba, sigmalimit, vcoeffs, sigma, fittedpointsv
pacoeffs[ *, *, 3] = vcoeffs

ngoodpoints[ 0]= n_elements( qpa)
ngoodpoints[ 1]= n_elements( fittedpointsq)/2
ngoodpoints[ 2]= n_elements( fittedpointsu)/2
ngoodpoints[ 3]= n_elements( fittedpointsv)/2

;stop
return
end

