pro guess_tot, deltag, epsilon, alpha, phi, chi, psi, qsrc, usrc, $
	guess_tot, m_tot, vsrc=vsrc

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
;	guess_tot, m_tot, vsrc=vsrc
;
; INPUTS:
;	DELTAG, etc...the Mueller matrix element parameters.
;	QSRC, USRC, the fractional Q and U for the source whose data 
;               are being fit
;
;KEYWORD:
;       VSRC=VSRC. the fractional V for the source whose data are being
;       fit. In earlier version, this was assumed zero; now we allow
;       nonzero, useful for OH masers.

; OUTPUTS:
;	GUESS_TOT: the predicted system response for the given
;parameters.
;	M_TOT: the Mueller matrix for the given parameters
;
;-

forward_function tdata_guess

if n_elements( vsrc) eq 0 then vsrc=0.0

m_tot, deltag, epsilon, alpha, phi, chi, psi, m_tot

guess_tot= tdata_guess( m_tot, qsrc, usrc, vsrc)

;stop

return

end


