;+
;NAME:
;prwspc - compute the power spectrum of the input signal..
;SYNTAX: dfrq=pwrspc(dtm)
;ARGS:      
;     dtm[npts]: real or complex input time series
;RETURNS:
;    dfrq[npts]: real .. power spectrum squared magnitude of xform
;DESCRIPTION:
;   Return abs(fft(dtm))^2
;-
function pwrspc,dtm

    return, abs(fft(dtm))^2
end
