;+
;NAME:
;corcmpdist - compute distance (ra/dec) for scans
;SYNTAX: dist=corcmpdist(ra,dec,b=b,slar=slar,hms=hms)
;ARGS  :
;       ra:  float/double ra Hours    J2000
;      dec:  float/double dec Degrees J2000
;KEYWORDS:
;   b[n]: {corget} array of correlator recs/scans to use for distance
; sla[n]: {corsl} array of archive recs to use for distance
; hms   : if set then ra is in hms.s dec is in dms.s rather than hour,degrees
;RETURNS:
;dist[3,n]: float    distance from ra,dec to each measurement.
;           [0,*] = ra - measured ra  Arcminutes  (greatcircle angle)
;           [1,*] = dec - measured dec arcminutes (angle)
;           [3,*] = total distance arcminutes (greatcircle angle)
;
;DESCRIPTION:
;   Compute the distance from ra,dec to each measured entry. The measured
;entries are passed in via b=b or slar=slar (you can use only one of these).
;The requested ra,dec positions are used rather than the actual.
;   If  b= is used then it is the requested position for each record. 
;   If slar= is used then it is the average requested position of each scan.
;The ra,dec arguments should also be in j2000 coordinates.
;-
;modhistory
;
function corcmpdist,ra,dec,b=b,slar=slar,hms=hms
;
    ral=ra*1D
    decl=dec*1d
    if keyword_set(hms) then begin
        ral =hms1_rad(ral)*12.d/!dpi
        decl=dms1_rad(decl)*180.d/!dpi
        deltaRaH=0.
    endif
    if n_elements(b) gt 0 then begin
        ra1  =b.b1.h.pnt.r.RAJCUMRD*12.d/!dpi
        dec1 =b.b1.h.pnt.r.decJCUMRD*180.d/!dpi
    endif else begin
        if n_elements(slar) gt 0 then begin
            ra1  =slar.RAHRReq 
            deltaRaH=(slar.raDelta/(15.D*60.D))*.5d  ; average motion great circ
            dec1 =slar.DECDReq + slar.decDelta/(2.d*60.)
        endif else begin
            message,'You must specify b=b or slar=slar keyword'
        endelse
    endelse
    retval=fltarr(3,n_elements(ra1))
    rafact=cos((decl+dec1)*.5*!dtor)
    hrToAmin =360D/24d *60.D
    degToAmin=60.D
    retval[0,*]=(ral-(ra1+ deltaRaH/rafact))*rafact*hrToAmin
    retval[1,*]=(decl-dec1)*degToAmin
    retval[2,*]=sqrt(retval[0,*]^2 + retval[1,*]^2)
    return,retval
end
