;+ 
;NAME:
;mkazzagrid - make a grid of az,za values.
;SYNTAX: mkazzagrid,az,za,azstart=azstart,azend=azend,azstep=azstep
;                         zastart=zastart,zaend=zaend,zastep=zastep
;RETURNS:
;   az[nptsaz,nptsza]: float return azimuth values here
;   za[nptsaz,nptsza]: float return za values here
;KEYWORDS:
;   azstart          : float. starting azimuth . default 0.
;   azend            : float. ending   azimuth . default 359.
;   azstep           : float. step size for azimuth points. def:1
;   zastart          : float. starting za.     . default 0.
;   zaend            : float. ending   za.     . default 20.
;   zastep           : float. step size for za points. def:.5
;DESCRIPTION:
;   Return the 2d arrays az,za filled in with the requested az,za.
;These values can than be used to evaluate 2d functions of (az,za)
;or for plotting 2d fields.
;-
pro mkazzagrid,az,za,azstart=azstart,azend=azend,azstep=azstep,$
                zastart=zastart,zaend=zaend,zastep=zastep
    if n_elements(azstart) eq 0 then   azstart=0.
    if n_elements(azend)   eq 0 then   azend  =359.
    if n_elements(azstep)  eq 0 then   azstep =1.

    if n_elements(zastart) eq 0 then   zastart=0.
    if n_elements(zaend)   eq 0 then   zaend  =20.
    if n_elements(zastep)  eq 0 then   zastep =.5
    nptsaz= long((azend-azstart)/azstep + 1.5)
    nptsza= long((zaend-zastart)/zastep + 1.5)
    az=fltarr(nptsaz,nptsza)
    za=fltarr(nptsaz,nptsza)
    aztmp=findgen(nptsaz)*azstep + azstart
    for i=0,nptsza-1 do begin
        az[*,i]=aztmp
        za[*,i]= zastart + i*zastep
    endfor
    return
end
