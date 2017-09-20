;+
;NAME:
; nutation_M - nutation matrix for mean position of date.
;SYNTAX: nutM=nutation_M(juldate,eqOfEq=eqOfEq)
;ARGS:
;   juldate:    double scalar julian date for nutation.
;RETURNS:
;   nutM[3,3]: double matrix to go from mean coordinates of date to
;   eqOfEq: double  if keyword supplied then the equation of the equinox will
;                   be returned here. This is needed to go from mean to
;                   apparent lst.
; DESCRIPTION
;
; Return nutation matrix that is used to go from mean coordinates of date to
; the true coordinates of date. The nutation matrix corrects for the short
; term periodic motions of the celestial pole (18 year and less....).
; This matrix should be applied after the precession matrix that goes from
; mean position of  epoch to mean position of date. This uses the 1980
; IAU Theory of Nutation.
; The equation of the equinox is also returned. This is the value to take
; you from mean sidereal time to apparent sidereal time (see page B6 of AA).
; It is nut[3] (counting from 0).
;
; Input is the julian date as a double
;
; To create the matrix we:
;   1. rotate from mean equatorial system of date  to ecliptic system about x
;      axis (mean equinox).
;   2. rotate about eclipitic pole by delta psi (change in longitude due to
;      nutation.
;   3. rotate from true eclipitic system back to true equatorial by rotating
;      about x axis (true equinox) by -(eps + delta) eps ( mean obliquity of
;      eclipitic plus nutation contribution).
;
; Since the eclipitic pole  is not affected by nutation (we ignore the
; planetary contribution to the eclptic motion) only the equinox of the
; eclipitic is affected by nutation. When going back from true ecliptic
; to  true equatorial, use eps (avg obliquity) + deleps (obliquity due to
; nutation).
;
; Note that this method is the complete rotation versus the approximate value
; used on B20 of the AE 1992.
;
;WARNING: juldate should actually be reference to UT1 not UTC. But the
;         nutation matrix does not change fast enough to matter.
;
; REFERENCE
; Astronomical Almanac 1992, page B18,B20
; Astronomical Almanac 1984, page S23-S26 for nutation series coefficients.
;-
function nutation_M,juldate,eqOfEq=eqOfEQ
;
        JULDAYS_IN_CENTURY=36525.D  
        JULDATE_J2000     =2451545.D
        C_ASEC_TO_RAD     =4.84813681109535984270D-06
        DTOR=1.745329251994329577D-2
        RADEG=57.29577951308232087720D
; Return the angle from the mean equatorial equator to the ecliptic in radians.

        t=(juldate- JULDATE_J2000)/JULDAYS_IN_CENTURY
;       print,format='("t: ",g22.15)',t
        obliqRd=(23.439291D + t*(-.0130042D + t*(-.00000016D + .000000504D*t)))$
                * DTOR
;*
;*  delPsi is the change in ecliptic longitude from the mean position due to
;*  nutation.
;*  delEps is the change in ecliptic obliquity from the mean oblitquity.
;*
;*  the series for delPsi, delEps is take from page S23 of the 1984 AA.
;*  The series has 106 terms. I used terms down to 100*10-4asecs
;*  See page S23-s26 of AA 1984 for details
;*
;*  period       6798.4 3399.2 182.6 365.3 121.7 13.7 27.6 13.6 9.1...   (days)
;*  series terms:  1      2      9    10    11    31  32   33   34 ...
;/
        omRd   =( 450160.280D - t*(   5.D*1296000.D +  482890.539D + $
                                t*(   7.455D + t*.008D)))*C_ASEC_TO_RAD
 
        dRd    =(1072261.307D + t*(1236.D*1296000.D + 1105601.328D + $
                                t*(  -6.891D + t*.019D)))*C_ASEC_TO_RAD
 
        fRd    =( 335778.877D + t*(1342.D*1296000.D +  295263.137D + $
                                t*( -13.257D + t*.011D)))*C_ASEC_TO_RAD
 
        lprRd  =(1287099.804D + t*(  99.D*1296000.D + 1292581.224D + $
                                t*(   -.577D - t*.012D)))*C_ASEC_TO_RAD 
        lRd    =( 485866.733D + t*(1325.D*1296000.D +  715922.633D + $
                                t*(  31.310D + t*.064D)))*C_ASEC_TO_RAD 
;       print,omRd,cos(omRd),format='("omRd:",D22.15," cos:",D22.15)
        toRad= 1D-4*C_ASEC_TO_RAD;
        delPsiRd=($
              ( -171996.D -174.2D*t)*sin(   omRd)      $;6798.4days  term 1
            + (   2062.D +   .2D*t)*sin(2.D*omRd)        $;3399.1 day  term 2
            + ( -13187.D -  1.6D*t)*sin(2.D*(fRd-dRd+omRd))$;182.6 day term 9
            + (   1426.D -  3.4D*t)*sin(   lprRd)       $;365.3  day  term10
            + (   -517.D +  1.2D*t)*sin(lprRd+2.D*(fRd-dRd+omRd))$;121.7day t11
            + (    217.D -   .5D*t)*sin(-lprRd+2.D*(fRd-dRd+omRd))$;365.2d  t12
            + (    129.D +   .1D*t)*sin(omRd+2.D*(fRd-dRd))       $;177.8d  t13
            + (  -2274.D -   .2D*t)*sin(2.D*(fRd+omRd))  $; 13.7  day  term31
            + (    712.D +   .1D*t)*sin(lRd)            $; 27.6  day  term32
            + (   -386.D -   .4D*t)*sin(2.D*fRd+omRd)    $; 13.6  day  term33
            + (   -301.D        )*sin(lRd+2.D*(fRd+omRd))$;9.1  day  term34
            + (   -158.D        )*sin(lRd-2.D*dRd)       $;31.8 day  term35
            + (    123.D        )*sin(-lRd+2.D*(fRd+omRd))$;27.1day  term36
               )*toRad
 
        delEpsRd=($
             (  92025.D + 8.9D*t)*cos(   omRd)        $;6798.4days term 1
            +(   -895.D +  .5D*t)*cos(2.D*omRd)        $;3399.1 day  term 2
            +(   5736.D - 3.1D*t)*cos(2.*(fRd-dRd+omRd))$;182.6 day  term 9
            +(     54.D -  .1D*t)*cos(   lprRd)       $;365.3  day  term10
            +(    224.D  - .6D*t)*cos(lprRd+2.D*(fRd-dRd+omRd))$;121.7day t11
            +(    -95.D +  .3D*t)*cos(-lprRd+2.D*(fRd-dRd+omRd))$;365.2d  t12
            +(    -70.D      )*cos(omRd+2.D*(fRd-dRd))       $;177.8d  t13
            +(    977.D -  .5D*t)*cos(2.D*(fRd+omRd))  $; 13.7  day  term31
            +(     -7.D       )*cos(lRd)            $; 27.6  day  term32
            +(    200.D       )*cos(2.D*fRd+omRd)    $; 13.6  day  term33
            +(    129.D -  .1D*t)*cos(lRd+2.D*(fRd+omRd))$;9.1  day  term34
                                          $;negligible 31.8 day  term35
            +(    -53.D      )*cos(-lRd+2.D*(fRd+omRd))$;27.1day  term36
             )*toRad
 
;   idl use - angles since they rotate vectors and not coordinate systems.
;        /*
;        *   rotate mean equatorial to mean eclipitic
;        */
;        rotationX_M(obliqRd,TRUE,m1);   /* mean equatorial to mean eclipitic*/
;        /*
;        *  delPsi defined as value to add to mean longitude. This is a
;        *  rotation of a vector. The rotation of the coordinate system is
;        *  minus this value
;        */
;        rotationZ_M(-delPsiRd,TRUE,pm);  /* mean ecliptic to true eclipitic*/
;        MM3D_Mult(pm,m1,pm);            /* concatenate matrices*/
        ptsave=!p.t
        m1=dblarr(4,4)
        t3d,/reset,rotate=[-obliqRd,0., delPsiRd]*RADEG,matrix=m1
;        /*
;        *  looks like delEps is a rotation of the coordinate system and
;        *  not just added to a vector (i tried both ways and coordinate
;        *  system was closer).
;        */
;        rotationX_M(-(obliqRd+delEpsRd),TRUE,m1);/* back to true equatorial*/
;        MM3D_Mult(m1,pm,pm);            /* concatenate matrices*/
        m2=dblarr(4,4)
        t3d,/reset,rotate=[ (obliqRd+delEpsRd),0.,0.]*RADEG,matrix=m2
        rotmat=m2 ## m1
        rotmat=rotmat[0:2,0:2]
        eqOfEq=cos(obliqRd+delEpsRd)*delPsiRd;
        !p.t=ptsave
        return,rotmat
end
