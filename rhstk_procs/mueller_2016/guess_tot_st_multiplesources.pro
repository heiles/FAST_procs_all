pro  guess_tot_st_multiplesources, $
   coeffs_out, sources_out, guess_tot, m_tot, pacoeffs_out=pacoeffs_out

;+
; PURPOSE:
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
;GUESS_TOT_ST_MULTIPLESOURCES, $
;   coeffs_out, sources_out, guess_tot, m_tot, $
;  pacoeffs_out=pacoeffs_out
;
;INPUTS:
;COEFFS_OUT, etc...the structure containing Mueller matrix
;	elements, used for the least squares program MMFIT_2016.
;
;OUTPUTS:
;GUESS_TOT: the predicted system response for the guessed values
;	of the parameters being iterated.
;M_TOT: the Mueller matrix for the given parameters
;-

forward_function tdata_guess_2016

m_tot, coeffs_out.deltag, coeffs_out.epsilon, coeffs_out.alpha, $
        coeffs_out.phi, coeffs_out.chi, coeffs_out.psi, m_tot

nrs= n_elements( sources_out)
guess_tot= fltarr(nrs*9)

;stop

for ns=0, nrs-1 do begin
   qsrc= sources_out[ns].qsrc
   usrc= sources_out[ns].usrc
   vsrc= sources_out[ns].vsrc
   guess_tt= tdata_guess_2016( m_tot, qsrc, usrc, vsrc, $
        pacoeffs_out=pacoeffs_out)
   guess_tot[ 9*ns:9*ns+8]= guess_tt
;stop
endfor
   
;stop

return

end


