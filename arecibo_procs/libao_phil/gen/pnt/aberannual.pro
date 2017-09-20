;+
;NAME:
;aberAnnual - compute the annual aberration offset.
;SYNTAX: v=aberAnnual(julianDate)
;ARGS:
;   juliandate[n]: double julian data of interest. ut1 or utc base is equiv.
;RETURNS:
;          v[3,n]: double 3vector for the aberation correction. Add this
;                         to the curret true ra,dec when going ra,dec->az,el.
;
; DESCRIPTION
;
; Return the annual aberration vector offset. This vector should be added
; to the true object position to get the apparent position of the object.
;
; Aberration requires the observer to point at a direction different from
; the geometrical position of the object. It is caused by the relative motion
; of the two objects (think of it as having to bend the umbrella toward your
; direction of motion to not get wet..). It is the velocity vector offset of
; the observer/object from the geometric direction measured in an inertial 
; frame.
;
; Complete aberration is called planetary aberration and includes the motion
; of the object and the motion of the observer. For distant objects the
; objects motion can be ignored. Stellar aberration is the portion due to the
; motion of the observer (relative to some inertial frame). It consists of
; secular aberration (motion of the solar system), annual aberration
; (motion of the earth about the sun), and diurnal aberration (caused by
; the rotation of the earth about its axis.
;
; Secular aberration is small and ignored (the solar system is assumed to be
; in  the inertial frame of the stars). The earths velocity about the sun of
; +/- 30km/sec = +/- .0001v/c gives  +/- 20" variation for annual aberration.
; diurnal variation gives a maximum of about +/- .32" at the equator over a day.
; This routine computes annual aberration using the approximate routines no
; page B17 and C24 of the AA.
;
; EXAMPLE:
;   radedJ2000 -> precNut -> raDecCurrentTrue -> addAberV->radDecCurApparent
;-
function  aberAnnual,julianDate
        
        ddtor=!dpi/180.D
        JULDATE_J2000=2451545.D
        AU_SECS=499.004782D
 
        n=julianDate - JULDATE_J2000   
        L=(280.460D + .9856474D*n) mod 360.D
        ind=where(L lt 0.D,count)
        if count gt 0 then L[ind]=L[ind] + 360.D
        gRd=((357.528D + .9856003D*n)*ddtor) mod (!dpi*2.D)
        ind=where(gRd lt 0.D,count)
        if count gt 0 then gRd[ind]=gRd[ind] + (2.D*!pi)
        lambdaRd=(L + 1.915*sin(gRd) + .020*sin(2.D*gRd))*ddtor
        C= AU_SECS/86400.D;
        cosl=cos(lambdaRd);
;
;       the constants below are:
;       .0172   = k
;       .0158   = k * cos(eps)
;       .0068   = k * sin(eps)
;       in AU/day. k is the constant of aberration: 20.49" and eps is the
;       ecliptic angle.
;       C converts from AU/day and divides by c at the same time (since
;       we want v/c for the correction.
;
        v=dblarr(3,n_elements(julianDate))
        v[0,*]= .0172*C*sin(lambdaRd);
        v[1,*]=-.0158*C*cosl;
        v[2,*]=-.0068*C*cosl;
        return,v
end
