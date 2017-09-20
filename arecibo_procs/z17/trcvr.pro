pro trcvr, ffrx, treceiver

;+
;PURPOSE: calculate cold sky temp given za. fully vectorized
;
;INPUTS:
;	FFRX, the za in degrees. 
;
;OUTPUTS:
;
;	TRECEIVER, the array of rcvr temps.
;-

;define poly coeffs from phil's web page...

coeffs= fltarr(4)
coeffs[0] = 36.55+ 35.739
coeffs[1]= .12215+ .14101
coeffs[2]= .23766+ .19771
coeffs[3]= -(.01514 + .00774)

;ffrx = reform( hdr2info[9, 2, *])

treceiver= replicate( coeffs[0], n_elements( ffrx))

treceiver= treceiver+ coeffs[1]* ffrx

indx= where( ffrx gt 14., count)

if (count gt 0) then begin
treceiver[ indx]= treceiver[ indx]+ coeffs[2]* (ffrx[indx]-14.)^2
treceiver[ indx]= treceiver[ indx]+ coeffs[3]* (ffrx[indx]-14.)^3
endif

;stop

return
end

