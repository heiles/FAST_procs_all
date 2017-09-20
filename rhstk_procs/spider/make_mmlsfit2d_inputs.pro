pro make_mmlsfit2d_inputs, indx, a, beamout_arr, $
        qpa, xpy, xmy, xy, yx, $
	muellerparams_init, muellerparams0, pacoeffs, ngoodpoints, $
	mueller_az=mueller_az, negate_q=negate_q, chnl=chnl, $
        nominal_linear=nominal_linear

;+
;PURPOSE:
;	Generate inputs for the Mueller LS fit.  These depend only on
;the input data and, also, the Mueller matrix by which they have been
;corrected.  If they have been corrected by a Mueller matrix MMM, then
;setting MUELLER_AZ equal to MMM gives you the incremental correction to
;MMM. 

;this 2d version uses the 2d beam fits instead of the 1d stripfits.

;######## question: how does MUELLER_AZ interact wiht MUELLERPARAMS0???

;INPUTS:
;
;	RCVR_NAME, the receiver name;
;
;	A, the input data structure that contains all hdr ifo
;
;	BEAMOUT_ARR, structure containing the stripfit data that will
;be least squares fit for the Mueller matrix

;	MUELLERPARAMS_INIT: the initialization muellerparams to use as
;guesses in the nonlinear ls fit.
;
;KEYWORDS:
;
;	MIELLERPARAMS0: the values of muellerparams_init changed to
;reflect the particular receiver being used.

;	MUELLER_AZ: See explanation under "purpose" above.
;
;	NEGATE_Q: changes sign of the Mueller-uncorrected measure Stokes
;Q. "Always set to zero"

;	CHNL; if set, does channel CHNL instead of continuum.

;OUTPUTS:
;
;	QPA, the position angle at the center of each scan
;
;	XPY, the X+Y I at the scan center, normalized to X+Y.
;Thus this is always unity.
;
;	XMY, the X-Y at the scan center, normalized to X+Y. If the
;calibration were perfect, this would be Stokes Q.
;
;	XY, YX--ditto.

;	PACOEFFS: the output from striptopacoeffs
;
;HISTORY: 18 nov 2008, removed call to mmparam_define_gbt, which
;generated fixpsi, alpha0, psi0
;-

forward_function muellerparams_init

;SET NEGATE_Q EQ 0 IF IT IS NOT DEFINED; WE "ALWAYS" DO THIS...
if (n_elements( negate_q) eq 0) then negate_q= 0

;MAKE A DIAGONAL MUELLER_AZ IF IT IS NOT DEFINED ON INPUT...
IF ( N_ELEMENTS( MUELLER_AZ) EQ 0) THEN BEGIN
mueller_az = fltarr(4,4)
mueller_az[ indgen(4)*5]= 1.
ENDIF

;;;;;GET RCVR PARAMETERS...removed 18 nov 2008
;;;;mmparam_define_gbt, a[ indx[0]].rcvnam, a[ indx[0]].cfr, fixpsi, alpha0, psi0

;GET NORMALIZED PARAMETERS...
extract_2d_normalizedstokes, indx, beamout_arr, mueller_az, $
        qpa, xpy, xmy, xy, yx, $
        negate_q= negate_q, chnl=chnl

IF ( N_ELEMENTS( QPA) LT 3) THEN BEGIN
	ngoodpoints= n_elements( qpa)
	return
ENDIF

;HARDWIRE THE SIGMA FOR RESIDUALS TO BE DISCARDED...
sigmalimit=3. 

;STOP
;DERIVE THE POSITION ANGLE FITS...
stripfit_to_pacoeffs, qpa, xpy, xmy, xy, yx, sigmalimit, $
        pacoeffs, qsource, usource, qtrue, utrue, $
        sig_sq_qsource, sig_sq_usource, ngoodpoints=ngoodpoints, /short

;define the set of mueller params that will be used...
muellerparams0= muellerparams_init(nominal_linear=nominal_linear)
;muellerparams0= {muellerparams_carl}

;the follolwing were removed 18 nov 2008
;;;;;muellerparams0.alpha= alpha0
;;;;;muellerparams0.psi= psi0
;;;;;muellerparams0.fixpsi= fixpsi
return
end



