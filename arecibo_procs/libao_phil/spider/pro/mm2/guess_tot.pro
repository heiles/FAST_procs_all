pro guess_tot, deltag, epsilon, alpha, phi, chi, psi, qsrc, usrc, $
	guess_tot, m_tot

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
;	GUESS_TOT, deltag, epsilon, alpha, phi, chi, psi, qsrc, usrc, $
;	guess_tot, m_tot
;
; INPUTS:
;	DELTAG, etc...the Mueller matrix element parameters.
;	QSRC, USRC, the fractional Q and U for the source whose data 
;are being fit
;
; OUTPUTS:
;	GUESS_TOT: the predicted system response for the given
;parameters.
;	M_TOT: the Mueller matrix for the given parameters
;
;-

m_tot, deltag, epsilon, alpha, phi, chi, psi, m_tot

guess_tot= tdata_guess( m_tot, qsrc, usrc)

;stop

return

end


