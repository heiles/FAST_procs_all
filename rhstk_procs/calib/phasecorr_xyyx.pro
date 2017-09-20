pro phasecorr_xyyx, xy, yx, frq, ozero, oslope, xyc, yxc

;+
; NAME:
;       PHASECORR_XYYX
;
; PURPOSE: 
;       Given a zero and slope of phase, calculate a corrected version
;
; CALLING SEQUENCE:
;       PHASECAL_CORR, xy, yx, frq, ozero, oslope, xyc, yxc
;
; INPUTS: 
;       XY[ nchnls, nspectra], YX [ nchnls, nspectra] the xy and
;       yx...the two correlated outputs from the ; correlator.
;
;       FRQ[ nchls]: the aray of frequencies for which OZERO, OSLOPE were
;                    calculated from PHASECAL_CROSS or some other similar
;                    program.
;
;       OZERO and OSLOPE - the linear fit coefficients and errors, the
;                          units are **** RADIANS ***** and *****
;                          RADIANS/MHZ *****. Each is a 2 element vector:
;                          the first element is the value, the second the 1
;                          sigma error.
;
; OUTPUTS: 
;       XYC, YXC: corrected versions of XY, YX (done according to
;                 CORRECTOPTION)
;
; MODIFICATION HISTORY:
;       05 jun 2009: ch found error; the statement labelled below was
;       wrong, meaning for only one spectrum no correction was done.
;-

xyc= xy
yxc= yx

sz= size( xy)
phase_fit = ozero[0] + oslope[0]*frq

;stop, 'middle'

nrmax= sz[2]
;pre-05jun2009 incorrect version: if sz[ 0] eq 1 then nrmax=0
if sz[ 0] eq 1 then nrmax=1

for nr=0, nrmax-1 do begin
   reunrotated = xyc[ *, nr]
   imunrotated = yxc[ *, nr]

   angrotate, reunrotated, imunrotated, (-!radeg*phase_fit), $
              rerotated, imrotated

   xyc[ *, nr] = rerotated
   yxc[ *, nr] = imrotated
endfor

;stop, 'end'

end ; phasecorr_xyyx


