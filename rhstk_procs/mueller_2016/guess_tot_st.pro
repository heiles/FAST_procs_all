pro guess_tot_st, coeffs_out, guess_tot, m_tot, pacoeffs_out=pacoeffs_out

;+
; PURPOSE:
;
;	Evaluate predicted system response from the Mueller matrix and
;the source Q and U.  This predicted response is then subtracted from the
;observed responses to form the dataset for the nonlinear ls fit for the
;matrix element parameteres and the source Q and U, as in the discussion
;in AOTM 2000-XX.
;
; CALLING SEQUENCE:
;       GUESS_TOT_ST, coeffs_out, guess_tot, m_tot, pacoeffs=pacoeffs
;
; INPUTS:
;	coeffs_out, etc...the structure containing Mueller matrix
;	elements, used for the least squares program MMFIT_2016.
;
; OUTPUTS:
;	GUESS_TOT: the predicted system response for the given
;parameters.
;	M_TOT: the Mueller matrix for the given parameters
;
;-

;forward_function tdata_guess
forward_function tdata_guess_2016

;if n_elements( vsrc) eq 0 then vsrc=0.0

m_tot, coeffs_out.deltag, coeffs_out.epsilon, coeffs_out.alpha, $
        coeffs_out.phi, coeffs_out.chi, coeffs_out.psi, m_tot

guess_tot= tdata_guess_2016( m_tot, coeffs_out.qsrc, coeffs_out.usrc, $
        coeffs_out.vsrc, pacoeffs_out=pacoeffs_out                      )

;stop

return

end


