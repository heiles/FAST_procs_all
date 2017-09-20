 function tdata_guess_2016, m_tot, qsrc, usrc, vsrc, pacoeffs_out=pacoeffs_out

;+
; PURPOSE:
;
;       Called by GUESS_TOT; purpose is to evaluate the three predicted
;coefficients A,B,C in A+Bcos(2pq)+Csin(2pa) for the three OBSERVED
;Stokes parameters Q, U, and V (a total of 3x3=9 parameters) from the
;Mueller matrix and the three SOURCE stokes parameters Qsrc, Usrc, and
;Vsrc.  These predicted coefficients response is then subtracted from
;the observed responses to form the dataset for the nonlinear ls fit for
;the matrix element parameteres and the source Stokes parameters, as in
;the discussion in AOTM 2000-XX.
;
; CALLING SEQUENCE:
; RESULT= tdata_guess, m_tot, qsrc, usrc, vsrc, pacoeffs_out=pacoeffs_out
;
; INPUTS:
;       M_TOT, the total Mueller matrix
;       QSRC, USRC, VSRC, the fractional Q, U, V for the source 
;
; OUTPUTS:
;       RESULT, the predicted pa coefficientsfor the given
;               parameters.
;KEYWORD OUTPUTS:
;       PACOEFFS_OUT=PACOEFFS_OUT, the pacoeffs calculated from the fit,
;       to be compared to the data's pacoeffs.
;-

if n_elements( vsrc) eq 0 then vsrc=0.0

guess2= dblarr( 3, 4)
for nrow=0, 3 do begin
guess2[ 0, nrow]= m_tot[0, nrow] + vsrc* m_tot[3, nrow]
guess2[ 1, nrow]= qsrc*m_tot[1, nrow] + usrc*m_tot[2, nrow]
guess2[ 2, nrow]= usrc*m_tot[1, nrow] - qsrc*m_tot[2, nrow]
endfor

guess= fltarr(9)
guess[ 0:2]= guess2[ *,1]
guess[ 3:5]= guess2[ *,2]
guess[ 6:8]= guess2[ *,3]

pacoeffs_out= fltarr( 3,2,4)
pacoeffs_out[*,0,*]= guess2

return, guess

end
