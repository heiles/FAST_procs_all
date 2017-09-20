;+
;NAME:
;fluxsrc - return source flux
;SYNTAX: flux=(srcname,freq)
;ARGS:
;   srcname: string source to search for in files.
;      freq: float  the frequecy of interest in Mhz.
;RETURNS:
;   flux:    float The flux in janskies.
;DESCRIPTION:
;   The file aodefdir()/data/fluxsrc.dat has fits of flux versus frequency
;for a number of sources. This routine will return the flux given a
;frequency if the source name is in the file.
;SEE ALSO:
;fluxsrclist, fluxsrcload.
;-
function fluxsrc,src,freq
    common fluxcom,fluxdata,fluxcominit

    if not keyword_set(fluxcominit) then fluxsrcload
    ind=where( strupcase( src) eq fluxdata.name,count)
;    ind=where(src eq fluxdata.name,count)

;stop

IF COUNT GT 0 THEN BEGIN
x=alog10(freq)

IF ( FLUXDATA[ IND].CODE NE 5) THEN BEGIN
	return,10^(fluxdata[ind].coef[0]+fluxdata[ind].coef[1]*x+ $
                                       fluxdata[ind].coef[2]*exp(-x))
ENDIF ELSE $
	return,10^(fluxdata[ind].coef[0]+fluxdata[ind].coef[1]*x+$
                   fluxdata[ind].coef[2]*x^2)

ENDIF ELSE RETURN,0.

end
