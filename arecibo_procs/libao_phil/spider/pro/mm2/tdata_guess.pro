function tdata_guess, m_tot, qsrc, usrc

;+
; PURPOSE:
;
;       Called by GUESS_TOT; purpose is to
;Evaluate predicted system response from the Mueller matrix and
;the source Q and U.  This predicted response is then subtracted from the
;observed responses to form the dataset for the nonlinear ls fit for the
;matrix element parameteres and the source Q and U, as in the discussion
;in AOTM 2000-XX.
;
; CALLING SEQUENCE:
;	RESULT= TDATA_GUESS( m_tot, qsrc, usrc)
;
; INPUTS:
;       M_TOT, the total Mueller matrix
;       QSRC, USRC, the fractional Q and U for the source 
;
; OUTPUTS:
;       RESULT, the predicted system response for the given
;parameters.
;
;-

guess= dblarr( 9)

guess[ 0:2]= m_tot[ 0,1:3]
guess[ 3:5]= qsrc* m_tot[ 1,1:3] + usrc* m_tot[ 2,1:3]
guess[ 6:8]= -qsrc* m_tot[ 2,1:3] + usrc* m_tot[ 1,1:3]

return, guess
end
