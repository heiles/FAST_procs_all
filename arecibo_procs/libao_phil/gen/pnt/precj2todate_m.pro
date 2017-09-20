;+
;NAME:
; precj2todate_m - matrix to precess J2000 to current.
;SYNTAX:  mat=precj2todate_m(juldat)
;ARGS:  
;   juldat: double   julian date in UTC system.
;RETURNS:
;   mat[3,3]:double to precess to J2000
;
; DESCRIPTION
;
; Return matrix that can be used to go from J2000 equatorial rectangular
; coordinates to  mean equatorial coordinates of  date (ra/dec). For
; equatorial rectangular coordinates, x points to equinox, z points north,
; and y points 90 to x increasing to the east.
;
; The input consists of the UTC julian date as a double. The routine
;uses the UTC time rather than converting to UT1. The difference
;is not important for the usage at AO.
;
; REFERENCE
; Astronomical Almanac 1992, page B18.
;-
function   precj2todate_m,juldate

        JULDAYS_IN_CENTURY=36525.D
        JULDATE_J2000     =2451545.D
        C_ASEC_TO_RAD     =4.84813681109535984270D-06
        DTOR=1.745329251994329577D-2
        RADEG=57.29577951308232087720D

        t=(juldate- JULDATE_J2000)/JULDAYS_IN_CENTURY
        xiRd = T*(.6406161D + T*( .0000839D + (T*.0000050D)))*DTOR
        zeRd = T*(.6406161D + T*( .0003041D + (T*.0000051D)))*DTOR
        thRd = T*(.5567530D - T*( .0001185D + (T*.0000116D)))*DTOR
 
        cosXi=cos(xiRd);
        sinXi=sin(xiRd);
        cosZe=cos(zeRd);
        sinZe=sin(zeRd);
        cosTh=cos(thRd);
        sinTh=sin(thRd);
 
        m=dblarr(3,3)
;        /* row 0        */
 
        m[0]= cosXi*cosTh*cosZe - sinXi*sinZe;
        m[1]=-sinXi*cosTh*cosZe - cosXi*sinZe;
        m[2]=      -sinTh*cosZe;
 
;        /* row 1        */
 
        m[3]= cosXi*cosTh*sinZe + sinXi*cosZe;
        m[4]=-sinXi*cosTh*sinZe + cosXi*cosZe;
        m[5]=      -sinTh*sinZe;
    
;        /* row 2        */
 
        m[6]= cosXi*sinTh;
        m[7]=-sinXi*sinTh;
        m[8]=       cosTh;
        
        return,m
end

