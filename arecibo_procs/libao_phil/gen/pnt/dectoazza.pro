;+
;NAME:
;decToAzZa - convert from dec to az,za for a strip.
;
;SYNTAX: npts=decToAzZa(dec,az,za,step=step,deg=deg,ha=ha)
;
;ARGS:
;   dec[3] : declination,degrees,minutes,seconds
;            unless /deg set then value is dec[0] degrees
;
;KEYWORDS:
;      step: float. seconds per step   
;      deg :       if set then the input data in in deg, not dd mm ss
;     ha[n]: float if provided, then compute the az,za for the
;                   provided hour angles (hours).&$
;    zamax:   float max za to use. default:19.69
; 
;
;RETURNS:
;   npts        : int number of points returned
;   az[npts]    : encoder azimuth angle in degrees. 
;   za[npts]    : encoder zenith  angle in degrees. 
;
;DESCRIPTION:
;   Convert from declination to azimuth, zenith angle for a 
;complete decstrip across the arecibo dish (latitude 18:21:14.2).
;The points will be spaced step sidereal seconds in time. The routine
;computes the track for +/- 2 hours and then limits the output points
;to zenith angle <= 19.69 degrees.
;-
;modhistory:
;
function decToAzZa,dec,az,za,step=step,deg=deg,ha=ha,zamax=zamax
;
    if n_elements(step) eq 0 then begin
        step=1.                 ; 1 sec step size
    endif
	if n_elements(zamax) eq 0 then zamax=19.69
    latRd= (18. + 21./60. + 14.2/3600.)/360. * 2.*!pi
    th=latRd - !pi/2.
    costh=cos(th)
    sinth=sin(th)
;
; generate ha vector once a step +/- 2 hours
;
    if n_elements(ha) gt 0 then begin
        npts=n_elements(ha)
        haRd=ha/24.*2.*!pi
    endif else begin
        npts  =long(2.* (2.*3600./step) + 1.)
        haRd  = step*(findgen(npts) - npts/2L) /(3600.*24) * 2.*!pi
    endelse
    decRd =(keyword_set(deg))?dec[0]*!dtor $
                             :(dec[0] + dec[1]/60. + dec[2]/3600.)*!dtor
    azElV=fltarr(3,npts)
;
;   convert ha,dec to 3 vector
;
    haDec=fltarr(3,npts)
    cosDec=cos(decRd)
    haDec[0,*]= cos(haRd)*cosDec
    haDec[1,*]= sin(haRd)*cosDec
    haDec[2,*]= fltarr(npts) + sin(decRd)
;
;   rotate to az,el
;
    azElV[0,*]=  -(costh*haDec[0,*])                  -(sinth * haDec[2,*])
    azElV[1,*]=                      -haDec[1,*]                 
    azElV[2,*]=  -(sinth*haDec[0,*])                  +(costh * haDec[2,*])
;
; now convert back to angles 
;
   c1Rad=atan(reform(azElV[1,*]),reform(azElV[0,*])); /* atan y/x */
;
;   azimuth convert from source to encoder (at dome)
    az=c1Rad* !radeg - 180.     ;
    ind=where( az lt 0.,count)
    if count gt 0 then begin
        az=az + 360.
    endif
    ind=where( az le 90.,count)
    if count gt 0 then begin
        az[ind]=az[ind] + 360.
    endif
    za=90. - !radeg*asin(azElV[2,*]) ;
    ind=where(za lt zamax,cnt)
    if cnt eq 0 then begin
        az=''
        za=''
        return,0 
    endif
    az=az[ind]
    za=za[ind]
    return,cnt 
end
