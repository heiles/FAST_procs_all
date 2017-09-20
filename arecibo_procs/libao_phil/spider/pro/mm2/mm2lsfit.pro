pro mmwlsfit, indx, rcvr_name, a, beamout_arr, $
        qpa, xpy, xmy, xy, yx, $
	mueller_az=mueller_az, negate_q=negate_q

;+
;PURPOSE:
;	Do the Mueller LS fit. Consists of two procs: one generates
normalized uncorrected data, the other does the lsfit. The results depend only on
the input data and, also, the Mueller matrix by which they have been
corrected.  If they have been corrected by a Mueller matrix MMM, then
setting MUELLER_AZ equal to MMM gives you the incremental correction to
MMM. 

;INPUTS:
;
;	RCVR_NAME, the receiver name;
;
;	A, the input data structure that contains all hdr ifo
;
;	BEAMOUT_ARR, structure containing the stripfit data

;KEYWORDS:
;
;	MUELLER_AZ: See explanation under "purpose" above.
;
;	NEGATE_Q: changes sign of the Mueller-uncorrected measure Stokes
;Q. "Always set to zero"

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

;-

;SET NEGATE_Q EQ 0 IF IT IS NOT DEFINED; WE "ALWAYS" DO THIS...
if (n_elements( negate_q) eq 0) then negate_q= 0

;MAKE A DIAGONAL MUELLER_AZ IF IT IS NOT DEFINED ON INPUT...
IF ( N_ELEMENTS( MUELLER_AZ) EQ 0) THEN BEGIN
mueller_az = fltarr(4,4)
mueller_az[ indgen(4)*5]= 1.
ENDIF

;GET RCVR PARAMETERS...
mmparam_define, rcvr_name, a[ 0].cfr, fixpsi, alpha0, psi0

;GET NORMALIZED PARAMETERS...
extract_normalizedstokes, indx, beamout_arr, mueller_az, $
        qpa, xpy, xmy, xy, yx, $
        negate_q= negate_q

;HARDWIRE THE SIGMA FOR RESIDUALS TO BE DISCARDED...
sigmalimit=3. 

;DERIVE THE POSITION ANGLE FITS...
stripfit_to_pacoeffs, qpa, xpy, xmy, xy, yx, sigmalimit, $
        pacoeffs, qsource, usource, qtrue, utrue, $
        sig_sq_qsource, sig_sq_usource, ngoodpoints=ngoodpoints, /short

return
end



