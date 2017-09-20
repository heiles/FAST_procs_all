;+
;NAME:
;tecchk - return indices of good data
;SYNTAX: ngood=tecchk(tar,indgood,elmin=elmin)
;ARGS:
; tar[]: {}  array of tec structures
;KEYWORDS:
; elMin: float  minimum elevation to allow. Default is 0.
;RETURNS:
;ngood  : long number of good points in indgood
;indgood[ngood]: long indices into tar for the good points.
;DESCRIPTION:
;   Check the data quality. A good point must have:
;1. tar.el between minEl and 90 deg
;2. tar.flat between -10 and 50
;3. tar.vhf lt 49.5 (seems to saturate at vhf=50??)
;
;-
function tecchk,tar,indgood,elmin=elmin 

    if n_elements(elmin) eq 0 then elmin=0.
    elMax=90.1
    flatMin=-10.
    flatMax=50.
    vhfMax=51.          ; a noop

    indgood=where((tar.el gt elmin) and (tar.el lt elMax) and $
             (tar.flat gt flatMin) and (tar.flat lt flatMax) and $
             (tar.vhf lt vhfmax),cnt)
    return,cnt
end
