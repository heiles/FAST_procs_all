;+
;NAME: 
;radecdist - compute great circle distance between 2 points
;SYNTAX: angle=radecdist(ra1,dec1,ra2,dec2,deg=deg)
;  ARGS:
;    ra1[n]:  float  right ascension point 1 (hours unless /deg set)
;   dec1[n]:  float  declination point 1 degrees.
;    ra2[n]:  float  right ascension point 2 (hours unless /deg set)
;   dec2[n]:  float  declination point 2 degrees.
;                  of the day.
;KEYWORDS:
;   deg :         if set then the right ascension is in degrees, not hours
;
;RETURNS:
;  ngle[n]: float  the great circle distance between the two point (in degrees).
;
;DESCRIPTION:
;   Compute the great circle distance between the two ra,dec points. Return
;the distance in degrees.
; 
;EXAMPLE:
;   ra1=11.1234     ; hours
;  dec1=33.345
;   ra2=12.321      ; hours
;  dec2=31.368
; angle=radecdist(ra1,dec1,ra2,dec2)
;
;   ra1=28.1234     ; deg
;  dec1=33.345
;   ra2=37.321      ; deg
;  dec2=31.368
; angle=radecdist(ra1,dec1,ra2,dec2,/deg)
;
;Computation:
; given points: 1,2 and let point 3 be the north pole then
; the spherical astronomy cosine law is:
; cosc=cosa * cosb + sina * sinb * cosC (spherical astronomy , smart pg8)
;
;   let:
;         A (pnt 1) angle bewteen pnt 2,3
;         B (pnt 2) angle between pnt 1,3
;         C (pnt 3) angle between 1,2 just abs(ra1-ra2)
;         a - distance  between b,Pole just (90- dec2)
;         b - distance  between a,Pole just (90 -dec1)
;         c - distance  between a,b .. what we want..
;-
;
function radecdist,ra1,dec1,ra2,dec2,deg=deg
;
; points: A,B,C then
;         A pnt 1 angle bewteen pnt 2,3
;         B pnt 2 angle between pnt 1,3
;         C pnt 3 (north pole) angle between 1,2 (just ra1-ra2)
;         a - distance  between b,Pole (just 90- dec2)
;         b - distance  between a,Pole (just 90 -dec1)
;         c - distance  between a,b
;
; cosc=cosa * cosb + sina * sinb * cosC
;
    dtorD= !dpi/180D
    if not keyword_set(deg) then begin
        ra1L=ra1*15D
        ra2L=ra2*15D
    endif else begin
        ra1L=ra1*1D
        ra2L=ra2*1D
    endelse
    al=(90D - dec2)*dtorD
    bl=(90D - dec1)*dtorD
    CA= abs(ra1l -ra2l)*dtorD       ; C angle
    cosc= cos(al)*cos(bl) + sin(al)*sin(bl)*cos(CA)
    return,acos(cosc)/dtorD
end
