;+
;NAME:
;radeccurtoazza - convert from raDecCurrent to azza
;
;SYNTAX: radeccurtoazza,raC,decC,lstRd,az,za 
;
;ARGS:
;   raC[n] :  float current right ascension degrees
;  decC[n] :  float current declination degrees
;  lstRd[n]:  float local siderial time in radians..
;
;KEYWORDS:
;
;RETURNS:
;   az[n]    : encoder azimuth angle in degrees. 
;   za[npts]    : encoder zenith  angle in degrees. 
;
;DESCRIPTION:
;   Convert from current ra,dec to az,el. this is done for the
; ao dish: (latitude 18:21:14.2).
;-
;modhistory:
;
pro radeccurtoazza,raC,decC,lstRd,az,za
;
    n=n_elements(raC)
    latObsRd= (18. + 21./60. + 14.2/3600.)/360. * 2.*!pi
    th=latObsRd - !pi/2.
    costh=cos(th)
    sinth=sin(th)
;
; generate ha vector once a step +/- 2 hours
;
    haRd=(lstRd - raC*!dtor)
    igt=where(haRd gt !pi,cntgt)
    ilt=where(haRd lt (-!pi),cntlt)
    if cntgt gt 0 then haRd[igt]-=2*!pi
    if cntlt gt 0 then haRd[ilt]+=2*!pi
    azElV=fltarr(3,n)
;
;   convert ha,dec to 3 vector
;
    decRd=decC*!dtor
    haDec=fltarr(3,n)
    cosDec=cos(decRd)
    haDec[0,*]= cos(haRd)*cosDec
    haDec[1,*]= sin(haRd)*cosDec
    haDec[2,*]= fltarr(n) + sin(decRd)
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
    ind=where( az gt 360.,count)
    if count gt 0 then begin
        az[ind]=az[ind] - 360.
    endif
    za=90. - !radeg*asin(azElV[2,*]) ;
    return
end
