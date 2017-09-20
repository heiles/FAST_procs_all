;+
;NAME:
; parAngle - compute the parallactic angle for AO.
;SYNTAX: parAngleD=parangle(azdeg,decDeg,sitelat=sitelat)
;ARGS:
;azDeg  : float     the azimuth in degrees
;decDeg : float     the declination of date (current) in degrees
;KEYWORDS:
;siteLat: float the site lattitude in degrees. If not supplied then
;               it uses ao's lattitude of 18:21:14.2 (but in degrees)
;
; DESCRIPTION
;Compute the parallactic angle given the source azimuth, source declination
; (off date apparent) for ao. The input angles are in
; degrees, the output angle is also in degrees. You can specify a different
; site using the sitelatdeg
;
;RETURNS
; The parallactic angle in degrees.
;
;REFERENCE
; Spherical astronomy, smart pg 49.
; Note: this probably does not yet work on arrays. need to 
;       fix the test of  deg gt 89.9..
;
;-
function parangle,azDeg,decDeg,sitelat=sitelat

    aolatDeg=dms1_rad(182114.2)*!radeg
    if n_elements(sitelat) eq 0 then sitelat=aolatDeg
    sgn=(decDeg lt 0.)  ? -1. : 1. ;
    decDegL=(abs(decDeg) gt 89.99)? sgn*89.99 : decDeg;
    return,asin( (sin(azDeg*!dtor) * cos(sitelat*!dtor)) / $
                  cos(decDegL*!dtor)) * !radeg  
end
