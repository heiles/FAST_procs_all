;+
;NAME:
;ruze - evaluate the ruze formula for losses from surface errors.
;SYNTAX: loss=ruze(freq,surfaceErr,errlambda=errlambda,db=db)
;ARGS:
;    freq[]     : freq in Mhz
;    surfaceErr : rms surface error in mm
;KEYWORDS:
;    errlambda:   if set then surfaceErr is fractions of a wavelength
;    db       :   if set then return loss as db
;DESCRPIPTION:
;   Return loss do to surface irregularities. Use the ruze formula to
;evaluate it. loss=exp((-4pi*delta/2)**2 where delta is the rms surface
;error. The units are milimeters unles /errlambda is set, then the 
;error is fractions of a wavelength (and freq is immaterial but must be
;entered).
;   The loss is returned as a linear value unless keyword db is set. In
;that case the return value is db.
;-
function ruze,freq,err,errlambda=errlambda,db=db

    if not keyword_set(db) then db=0
    if not keyword_set(errlambda) then errlambda=0

    if not errlambda then begin
        lambda = (299792458.D)/(1d6*freq)
        val=exp(-((4.*!pi*err*1d-3)/lambda)^2)
    endif else begin
        val=exp(-(4.*!pi*err)^2)
    endelse
    if db then begin
        return,alog10(val)*10.
    endif else begin
        return,val
    endelse
end
