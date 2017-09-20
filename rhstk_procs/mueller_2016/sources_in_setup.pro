pro sources_in_setup, sources_in, $
    src=src, isrc=isrc, qsrc=qsrc, usrc=usrc, vsrc=vsrc

;+
;PURPOSE: Make a standard set of the source Stokes parameter guesses when
;using MMFIT_2016_MULTIPLESOURCES.PRO or MPARAMSFIT.PRO and
;insert them in the input-guess structure sources_IN
;
;CALLING SEQUENCE: SOURCES_IN_SETUP, sources_in, src=src, isrc=isrc,
;qsrc=qsrc, usrc=usrc, vsrc=vsrc
;
;OUTPUT:
;  sources_IN={.src, .isrc, .qsrc, .usrc, .vsrc, polsrc, pasrc } 
;
;KEYWORDS:
;SRC, the source name; and the guesses for the Stokes parameters
;Stokes parameters. Defaults are blank and zeros.
;-

sources_in= {src:'', isrc:1.0, qsrc:0.0, usrc:0.0, vsrc:0.0, polsrc:0.0, pasrc:0.0}

if n_elements( src) ne 0 then coeffs_in.src= src
if n_elements( isrc) ne 0 then coeffs_in.isrc= isrc
if n_elements( qsrc) ne 0 then coeffs_in.qsrc= qsrc
if n_elements( usrc) ne 0 then coeffs_in.usrc= usrc
if n_elements( vsrc) ne 0 then coeffs_in.vsrc= vsrc

; TR ADDED POLSRC AND PASRC TO THE MUELLER PARAMS JUN 19, 2007...
;               
sources_in.polsrc = sqrt( sources_in.qsrc^2 + sources_in.usrc^2)
pasrc = !radeg * 0.5*atan(sources_in.usrc, sources_in.qsrc)
sources_in.pasrc = modangle( pasrc,180.0,/NEGPOS)

return
end

