function filterphase, bandpass, phase, phasenew

;+ 
;PURPOSE: for a baseband filter, calculate the phase delay according to
;the approx of eqn 22 in O'donnell, Jaynes, and Miller to the
;strict equation 2 of Bode.
;
;CALLING SEQUENCE: 
;       phase = filterphase( bandpass, phase, phasenew)
;
;BANDPASS is the input filter power gain shape. The calculation uses
;the natural log of bandpassin, which is called bndpass below. We
;assume a baseband filter in which the first element of the bandpass is
;at DC.  -
;
;it returns PHASE, the phase delay through the filter in DEGREES. 
;therre are two additional output parameters, PHASE and PHASENEW. PHASE
;is identical to the returned values. PHASENEW is for testing.
;-

;METHOD_ORIGINAL:
nchnls= n_elements( bandpass)
gratio= shift( bandpass, -1)/shift( bandpass, 1)

indx= findgen( nchnls)
ncratio= shift( indx,-1)/ shift( indx, 1)

;stop

phase= -90. * alog( gratio)/ alog( ncratio)
phase[0]= phase[1]
phase[ nchnls-1]= phase[ nchnls-2]

return, phase

;METHOD_NEW
bndpass= alog( bandpass)
nrc= n_elements( bndpass)
phasenew= fltarr( nrc)
indx= findgen( nchnls)

for nc= 2, nrc-2 do begin
deltag= bndpass[nc+1]- bndpass[nc-1]
u= alog( indx/indx[nc])
deltau= u[nc+1]- u[nc-1]
phasenew[ nc]= -90.* deltag/deltau
endfor
phasenew[0]= phasenew[2]
phasenew[1]= phasenew[2]
phasenew[nrc-1]= phasenew[nrc-2]

return, phase
end


