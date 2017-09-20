;+
;NAME:
;p12m_radecjtoazea - convert j2000 to p12m az,el.
;SYNTAX: p12m_radecjtoazel,rcv,raHr,decDeg,julDat,az,el,nomodel=nomodel
;ARGS:
;       rcv: int    receiver number 1 - 2200, 2 - 8000.. ignored..
;   raHr[n]: float/double   J2000 ra in hours
; decDeg[n]: float/double   J2000 dec in Deg
; julDat[n]: double julian date for each point (utc based). 
;KEYWORDS:
;   nomodel: if set then do not include model correction in az,za.
; julDat[n]: double julian date for each point (utc based). 
;
;RETURNS:
;     az[n]: float/double   azimuth in degrees
;     el[n]: float/double el in degrees
;DESCRIPTION:
;   Convert from J2000 ra, dec to actual azimuth, elevation angle
; encoder values. These are the values that would be read off
;of the encoder in actual operation (the model corrections 
;have been included). The juliandate should be utc based.
; If you use julday() function remember to
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
;   p12m_radecJtoazel,rcv,raH,decD,julday,az,el
;   print,az,el
;-
pro p12m_radecjtoazel,rcv,raHr,decDeg,julDat,az,el,corForAst=corForAst,$
                   nomodel=nomodel
;
;
    ddtor=!dpi/180.d
    dradeg=1.d/ddtor

	p12mLatD=dms1_deg(182053.87d)
	p12mlonD=hms1_hr(042700.36D)*15D
	obsPos_deg=[p12mLatD,p12mLonD]
	p12mLatRd=p12mLatD*ddtor
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
    el=dblarr(npts)
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
        lmst=juldaytolmst(juldat[indd],obspos_deg=obspos_deg)
        last=lmst+eqOfEq
        v3=radecvtohav(v3,last)
;
;   ha,dec to az,el
;
        v3=hatoazel(v3,p12mLatRd)
;
;    back to angles
;
        vec3toangles,v3,c1rd,c2rd,/c1pos
        az[indd]=c1rd*dradeg
        el[indd]=c2rd*dradeg
    endfor
;   ;
;    put el -90 to 90
;    az 0 to 360.
;
    elTmp=el mod 360d
;   limit -180 to 180
    ind=where(el le -180.,cnt)
    if cnt gt 0 then el[ind]+=360d
    ind=where(el gt  180.,cnt)
    if cnt gt 0 then el[ind]-=360d
;   now -90 to 90
    ind=where(el gt 90.,cnt)
    if cnt gt 0 then begin
        el[ind]=180. -el[ind]
        az[ind]+=180.
    endif
    ind=where(el lt -90.,cnt)
    if cnt gt 0 then begin
        el[ind]=-(180. + el[ind])
        az[ind]+=180.
    endif
    az=az mod 360.D
    ind=where(az lt 0.d,cnt)
    if cnt gt 0 then begin
        az[ind]=360.+az[ind]
    endif
;
; compute the model correction
;
    if not keyword_set(nomodel) then begin
        p12mmodinp,mI,rcv=rcv
        p12mmodeval,az,el,mI,azErrAsecs,elErrAsecs
        az= az + (azErrAsecs/3600D)/cos(el*ddtor)
        el= el + elErrAsecs/3600D
    endif
  return
end
