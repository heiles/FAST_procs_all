;+
;NAME:
;ao_radecjtoazza - convert j2000 to AO az,za.
;SYNTAX: radecjtoazza,rcv,raHr,decDeg,julDat,az,za,nomodel=nomodel
;ARGS:
;       rcv: int    receiver number 1..12, 100 for ch
;   raHr[n]: float/double   J2000 ra in hours
; decDeg[n]: float/double   J2000 dec in Deg
; julDat[n]: double julian date for each point (utc based). 
;KEYWORDS:
;   nomodel: if set then do not include model correction in az,za.
; julDat[n]: double julian date for each point (utc based). 
;
;RETURNS:
;     az[n]: float/double   azimuth in degrees
;     za[n]: float/double za in degrees
;DESCRIPTION:
;   Convert from J2000 ra, dec to actual azimuth, zenith angle encoder
;values. These are the values that would be read off of the encoder
;in actual operation (the model corrections have been included). The
;juliandate should be utc based. If you use julday() function remember to
;added 4./24D if you use ast hour,min,seconds. The precession nutation
;is computed for each julian day of the input data.
;
;NOTE:
;   Be sure and define the juldat as a double so you have enough
;precision.

;
;EXAMPLE:
;   using the daynotojuldat routine.. you could also use juldat()
;   convert from hhmmss, ddmmss to hr.h deg.d
;   ra=205716.4D
;   dec=025846.1D
;   raH=hms1_rad(ra)*!radeg/360.D*24D
;   decD=dms1_rad(dec)*!radeg
;
;   convert date to dayno with fraction
;
;   mon=11
;   day=19
;   year=2002
;   astHHMMSS=174258L
;   daynoF=dmtodayno(day,mon,year) + hms1_rad(asthhmss)/(2.D*!dpi)
;   compute julianday 
;   julday=daynotojul(daynoF,year) + 4./24.D
;   
;   you could also have done this with:
;
;   julday=julday(11.D,19.D,2002.D,17.D,42.D,58.D) + 4./24.D
;   rcv=5               ; lbw
;
;   ao_radecJtoazza,rcv,raH,decD,julday,az,za
;   print,az,za
;-
pro ao_radecjtoazza,rcv,raHr,decDeg,julDat,az,za,corForAst=corForAst,$
                   nomodel=nomodel
;
;
    ddtor=!dpi/180.d
    dradeg=1.d/ddtor
    aolatRd=dms1_rad(182114.2)
;
    iJulDat=long(julDat)
;
;   loop by julian day so we can do prec, nutation by day
;
    npts=n_elements(juldat)
    if (npts gt 1) then begin
        juldaylist=iJulDat[uniq(iJulDat,sort(iJuldat))]
    endif else begin
        juldaylist=iJulDat
    endelse
    az =dblarr(npts)
    za=dblarr(npts)
    for i=0L,n_elements(juldaylist)-1L do begin
        indd=where(juldaylist[i] eq iJulDat)
        julDatAvg=mean(julDat[indd])
;
;   go to 3 vecs
;
        v3=anglesTovec3(raHr[indd]/24.D*2.D*!dpi,decDeg[indd]*ddtor);go to 3vecs
;
;   go to current ra,dec
;
        v3=precNut(v3,julDatAvg,eqOfEq=eqOfEq)
;
; get the aberation correction and apply it.
;
        aberV3=aberannual(julDat[indd])
        v3=v3+aberV3
        n=n_elements(v3)/3
        vn=reform(sqrt(total(reform(v3*v3,3,n),1)))
        for j=0,2 do v3[j,*]=v3[j,*]/vn
;
; goto  apparent hour angle,dec
;
        lmst=juldaytolmst(juldat[indd])
        last=lmst+eqOfEq
        v3=radecvtohav(v3,last)
;
;   ha,dec to az,el
;
        v3=hatoazel(v3,aoLatRd)
;
;    back to angles
;
        vec3toangles,v3,c1rd,c2rd,/c1pos
        az[indd]=c1rd*dradeg
        za[indd]= 90.D - c2rd*dradeg
    endfor
;
;   these are source coordinates. compute greg side encoder
;   position
;   
    if rcv ne 100 then az=az+180.D
;
;    put za positive
;    az 0 to 360.
;
    ind=where(za lt 0.,count)
    if count gt 0 then begin
        za[ind]=za[ind]* (-1.D)
        az[ind]=az[ind]+180.D
    endif
    az=az mod 360.D
    ind=where(az lt 0.d,count)
    if count gt 0 then begin
        az[ind]=360.+az[ind]
    endif
;
; compute the model correction
;
    if not keyword_set(nomodel) then begin
        modinp,modeldata,rcv=rcv
        modeval,az,za,modeldata,azErrAsecs,zaErrAsecs,/enc
        az= az + (azErrAsecs/3600.D)/sin(za*ddtor)
        za= za + zaErrAsecs/3600.D
    endif
  return
end
