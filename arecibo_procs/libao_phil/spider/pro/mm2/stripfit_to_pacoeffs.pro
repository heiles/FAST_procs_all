pro stripfit_to_pacoeffs, qpa, xpy, xmy, xy, yx, sigmalimit, $
	pacoeffs, qsource, usource, qtrue, utrue, $
	sig_sq_qsource, sig_sq_usource, $
	ngoodpoints=ngoodpoints, short=short, mmat_aplus= mmat_aplusf

;+
;PURPOSE:
;	Take the correlator outputs, corrected for cal phase and
;intensity, the ensemble of all patterns of a source tracked across the
;sky and having a healthy range of position angles, and least square fit
;them a function of the form...
;
;
;	XY = A + B cos(2PA) + C sin(2PA),
;
;where XY the SOURCE DEFLECTION in one of the three polarized Stokes
;parameters divided by X+Y, and PA is the position angle on the sky. 
;Note that we fit FRACTIONAL POLARIZATIONS; we do this to eliminate the
;az/za angle gain dependences. 
;
;
; CALLING SEQUENCE:
;
;	STRIPFIT_TO_PACOEFFS, mmat_aplusf, $
;	qpa, xpy, xmy, xy, yx, sigmalimit, $
;	pacoeffs, qsource, usource, qtrue, utrue, $
;	sig_sq_qsource, sig_sq_usource, short=short
;
;INPUTS:
;
;	QPA, the set of astronomical position angles on the sky of the
;observed points.
;
;	XPY, XMY, XY, YX are the usual four correlator outputs,
;calibrated by CROSS3_GENCAL.
;
;	SIGMALIMIT: discard points with residuals exceeding
;sigmalimit*sigma. 
;
;KEYWORDS:
;
;	SHORT: if set, it returns after deriving the coefficients for
;the fit (PACOEFFS) without evaluating the source parameters. ALWAYS SET
;SHORT!! DEFAULT IS SHORT BEING SET!!!
;
;	MMAT_APLUSF IS AN OBSOLETE INPUT PARAMETER. It was used back in
;the days when we did different fits for linear and circular feeds. The
;keyword /SHORT, which should ALWAYS be used, bypasses the use of
;MMAP_APLUSF. Documentation for the original case is provided at the end.
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
;	0 means x+y
;	1 means x-y
;	2 means xy
;	3 means yx
;
;Note that, because we are using FRACTIONAL POLARIZATIONS,
;PACOEFFS[0,*,0] is automatically defined to be unity and
;PACOEFFS[1:2,*,0] are automatically defined to be zero. 
;
;THE FOLLOWING OUTPUTS ARE OBSOLETE; THEY ARE RELEVANT TO USING THIS
;WITHOUT THE /SHORT KEYWORD SET, WHICH YOU SHOULD NEVER DO!!
;
;	QSOURCE, USOURCE: the Stokes Q and U of the source
;(fractional--units are Stokes I)
;
;	QTRUE, UTRUE: the set of the TRUE Q, U being measured for each
;observation, that is the Q and U that the system would be measuring if
;its Mueller matrix were diagonal. 
;
;	SIG_SQ_QSOURCE, SIG_SQ_USOURCE: SQUARES of the errors of
;qsource, usource.
;
;
;OPTIONAL OUTPUTS:
;
;	NGOODPOINTS[4], the nr of points included in the fit for each
;stokes parameter. 0th element is total nr of points; elements 1,2,3 are
;the nr of points used in the fit for xmy, xy, and yx, respectively.
;
; RELATED PROCEDURES/FUNCTIONS:
;
;	LSFITPA_ALLCAL is used from this procedure
;
;
;  HISTORICAL NOTE AND DANGER!!!!!
;This is obsolete documentation
;for MMAT_APLUSF, and is provided only for historical purposes!!!
; This is the current incremental Mueller matrix element that
;we are solving for. This is used only to decide whether this is the
;first iteration. This covers the particular case of dual linear feeds
;and a large phase error; here, the Stokes U won't contain much power so
;we don't want to use it estimating the source polarization. On later
;iterations the phase should be good enough to use it, so we do. This is
;a kluge and needs to be refined. For example, it isn't needed, and isn't
;desireable, for the dual circular case. 
;
;If short is not set and you want to derive the Mueller matrix from scratch, 
;then make MM_APLUSF diagonal 4 X 4.
;-

common plotcolors

if (keyword_set( short) ne 1) then short=1

;ZERO THE OUTPUT ARRAY...
pacoeffs = fltarr( 3, 2, 4)
ngoodpoints= intarr(4)
pacoeffs[ 0, 0, 0] = 1.

;;FIT USING THE MODIFIED STOKES...
lsfitpa_allcal, qpa, xmy, sigmalimit, qcoeffs, sigma, fittedpointsq
pacoeffs[ *, *, 1] = qcoeffs
lsfitpa_allcal, qpa, xy, sigmalimit, ucoeffs, sigma, fittedpointsu
pacoeffs[ *, *, 2] = ucoeffs
lsfitpa_allcal, qpa, yx, sigmalimit, vcoeffs, sigma, fittedpointsv
pacoeffs[ *, *, 3] = vcoeffs

ngoodpoints[ 0]= n_elements( qpa)
ngoodpoints[ 1]= n_elements( fittedpointsq)/2
ngoodpoints[ 2]= n_elements( fittedpointsu)/2
ngoodpoints[ 3]= n_elements( fittedpointsv)/2

if keyword_set(short) then return

print, '!!!!!!!!! short was not set !!!!!!!!!!! BEWARE !!!!!!!!!!'

;******* WHEN SHORT IS SET, THE FOLLOWING NEVER GETS ACCESSED ********

;IF THIS IS THE FIRST ITERATION, THEN JUST USE THE QCOEFFS TO DERIVE
;	THE SOURCE POLARIZATION BECAUSE THE XY CHANNEL MAY HAVE A
;	LARGE PHASE ERROR...
;IF THIS IS **NOT** THE FIRST ITERATION, THEN
;	TAKE A WEIGHTED AVERAGE OF THE Q AND U RESULTS TOGETHER 
;	TO GET SOURCE Q AND U...
;THESE ARE Q AND U WRT THE FEED. FOR THE SOURCE, THEY ARE DIFFERENT!

niteration = 1
IF ( abs( mmat_aplusf[ 2,3]) lt 0.1) then niteration=2
IF (niteration eq 1) then BEGIN
	qsource= qcoeffs[ 1,0]
	usource= qcoeffs[ 2,0]
ENDIF ELSE BEGIN
qsource = (qcoeffs[1,0]/(qcoeffs[1,1]^2) - $
           ucoeffs[2,0]/(ucoeffs[2,1]^2) ) / $
                    (1./(qcoeffs[1,1]^2) + $
                     1./(ucoeffs[2,1]^2) )
usource = (qcoeffs[2,0]/(qcoeffs[2,1]^2) + $
            ucoeffs[1,0]/(ucoeffs[1,1]^2) ) / $
                     (1./(qcoeffs[2,1]^2) + $
                      1./(ucoeffs[1,1]^2) )
ENDELSE

;DERIVE THE TRUE Q AND U THAT ENTER THE FEED FROM THE PA AND SOURCE Q AND U...
qtrue = qsource*cos(2.*!dtor*qpa) + usource*sin(2.*!dtor*qpa)
utrue = usource*cos(2.*!dtor*qpa) - qsource*sin(2.*!dtor*qpa)
            
sig_sq_qsource = 2./( (1./(qcoeffs[2,1]^2)) + (1./(ucoeffs[1,1]^2)) )
sig_sq_usource = sig_sq_qsource

;stop

return
end

