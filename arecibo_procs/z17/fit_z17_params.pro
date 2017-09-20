pro fit_z17_params, z17, bchnls, result
; GO THROUGH EACH CHANNEL IN THE Z17 SPECTRA AND LS FIT THE SPATIAL
; STOKES I DISTRIBUTION...

; GET THE ANGULAR OFFSETS IN THE HORIZONTAL AND VERTICAL DIRECTIONS...
;delta_x = 60d0*(z17.ra - z17[16].ra)   ;arcmin
;delta_y = 60d0*(z17.dec - z17[16].dec) ; arcmin

delta_x = z17.delta_ra_arcmin
delta_y = z17.delta_dec_arcmin

;delta_x = z17.azoffset * 60.    ; arcmin
;delta_y = z17.zaoffset * 60.    ; arcmin

;=====================================================
; DO THE LEAST-SQUARES FIT FOR EACH CHANNEL...

nchnls = N_elements(bchnls)
result = dblarr(6,nchnls)

for chnl = 0, nchnls-1 do begin

    t = z17.i_fsw[bchnls[chnl]]
    s = [[dblarr(17)+1d0],$
         [delta_x],$
         [delta_y],$
         [0.5*(delta_x)^2],$
         [0.5*(delta_y)^2],$
         [delta_x*delta_y]]
    
    ss = s ## transpose(s)
    st = s ## transpose(t)
    ssi = invert(ss)
    a = ssi ## st
    bt = transpose(s) ## a
    resid = t - bt
    
    result[*,chnl] = a

endfor

end; fit_z17_params
