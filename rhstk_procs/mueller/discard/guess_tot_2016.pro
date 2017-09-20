pro guess_tot, deltag, epsilon, alpha, phi, chi, psi, qsrc, usrc, vsrc, $
	guess_tot, m_tot

;+
; PURPOSE:
;
;	Evaluate predicted system response from the Mueller matrix and
;the source Q, U, and V.  This predicted response is then subtracted from the
;observed responses to form the dataset for the nonlinear ls fit for the
;matrix element parameteres and the source Q, U, V, as in the discussion
;in AOTM 2000-XX.
;
; CALLING SEQUENCE:
;  GUESS_TOT, deltag, epsilon, alpha, phi, chi, psi, qsrc, usrc, vsrc, $
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

forward_function tdata_guess

m_tot, deltag, epsilon, alpha, phi, chi, psi, m_tot

guess_tot= tdata_guess_2016( m_tot, qsrc, usrc, vsrc)

;stop

return

end


