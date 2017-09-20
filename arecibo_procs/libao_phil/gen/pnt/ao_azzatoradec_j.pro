;+
;NAME:
;ao_azzatoradec_j - convert AO az,za to J2000
;SYNTAX: ao_azzatoradec_j,rcv,az,za,julDat,raHrs,decDeg,last=last
;                         ofdate=ofdate
;ARGS:
;    rcvnum: int    receiver number 1..16,17 for alfa,  100 for ch
;                   use 0 to bypass model corrections.
;
;     az[n]: float/double   azimuth in degrees
;     za[n]: float/double za in degrees
; julDat[n]: double julian date for each point.
;
;KEYWORDS:
;   last[n]: double local apparent siderial time (in radians). If supplied
;                   then this will be used rather then computing it from 
;                   the julday (you could take it from the pointing header
;                    b.b1.h.pnt.r.lastRd
;   ofdate :        If set then return current ra,dec (ofdate) rather than
;                   J2000        
;
;RETURNS:
;  raHrs[n]: double j2000 right ascension (hours) ..see (ofdate)
; decDeg[n]: double j2000 declination (degrees)   ..see (ofdate)
;DESCRIPTION:
;   Convert az,za encoder readings for ao to ra,dec epoch J2000. These are the
;values read from the encoders after all corrections are made (model, etc).
;The azimuth encoder is always the encoder on the dome side of the
;azimuth arm. The routine will recompute the precession, nutation
;every julian day.  
;   
;EXAMPLE:
;   Find the ra/dec position of telescope using the az/za
;positions from the .std portion of an AO header (either ri or correlator
;data). 
;
;   1. correlator spectral data. 
;       suppose you have an array of correlator recs b[n]:
;       az=b.b1.h.std.azttd*.0001D
;       za=b.b1.h.std.grttd*.0001D
;       tm=b.b1.h.std.postmms*.001D
;       dayno=b.b1.h.std.date mod 1000 + tm/86400D
;       year =b.b1.h.std.date / 1000
;   2. corpwr() data.. p[n]
;       az=p.az*1D
;       za=p.za*1D
;       tm=p.time*1D
;       dayno=(p.scan/100000L) mod 1000 + tm/86400D
;       year =(p.scan/100000000L) + 2000L
;       -- warning p.scan has the last digit of the year only
;          after 2009 the above line doesn't work..
;       ..The time here is the end of the integration. The az,za position
;         is probably from 1 sec before the end of the integration. If 
;         you are doing 1 sec dumps then you are probably going to be
;         of by 1 sec of time..
;   3. ridata. suppose you have a long scan of ri data   d[n].
;      The header data is sampled once per ri record. Your accuracy will
;      then be the ri record spacing.
;       az=d.h.std.azttd*.0001D
;       za=d.h.std.grttd*.0001D
;       tm=d.h.std.postmms*.001D
;       dayno=d.h.std.date mod 1000 + tm/86400D
;       year =d.h.std.date / 1000
;
;   juldayAr=daynotojul(dayno,year) + 4.D/24.D ; +4 is ao gmt offset
;  ao_azzatoradec_j,rcvnum,az,za,juldayAr,raHrs,decDeg  
;
;   The above example will have trouble with a scan that crosses midnight.
;The time will go from 86399 to 0 while the day number will increment
;on the next scan.
;   The az,za data is stored once a second. If the header records (correlator
;or ri) are sampled faster than this, then you will get the value at
;each second (there will be duplicates in the ra,dec array).
;
;NOTE:
;   Be sure and define the juldat as a double so you have enough
;precision.
;
;SEE ALSO:
;   agcazzadif
;-
pro ao_azzatoradec_j,rcv,az,za,julDat,raHr,decDeg,last=last,ofdate=ofdate
;
;
    ddtor=!dpi/180.d
    dradeg=1.D/ddtor
    aolatRd=dms1_rad(182114.2)
;   get model correction. use current model
    if rcv ne 0 then modinp,modeldata,rcv=rcv
    iJulDat=long(julDat)
;
;   loop by julian day so we can do prec, nutation by day
;
    npts=n_elements(juldat)
    if (npts gt 1) then begin
        juldaylist=ijulDat[uniq(ijulDat,sort(iJuldat))]
    endif else begin
        juldaylist=long(julDat)
    endelse
    raHr =dblarr(npts)
    decDeg=dblarr(npts)
    for i=0L,n_elements(juldaylist)-1 do begin
        indd=where(juldaylist[i] eq iJulDat)
        julDatAvg=mean(julDat[indd])

;   need equation of equinox to go lmst to last use average juldate
;
        nutM=nutation_M(julDatAvg,eqOfEq=eqOfEq)

;
;   we don't have the inverse of the model so evaluate the model at the
;   provided positions, remove this from the az,za then recompute the 
;   model. Take the average of the two model offsets and add this to the
;   intial points.
;  sounds good.. for now i'll just cheat...
;
        if rcv ne 0 then begin
            modeval,az[indd],za[indd],modeldata,azErrAsecs1,zaErrAsecs1,/enc
            zacorRd=(za[indd] - zaErrAsecs1/3600.)*ddtor
            azcorRd=(az[indd] - (azErrAsecs1/3600.)/sin(zaCorRd))*ddtor
        endif else begin
            zacorRd=(za[indd])*ddtor
            azcorRd=(az[indd])*ddtor
        endelse
;
;   go to source coordinates
;
        if (rcv ne 100) then azCorRd=azCorRd - !dpi    
;
;   make sure za > 0.
;
        ind=where(zaCorRd lt 0.,count)
        if count gt 0 then begin
            zaCorRd[ind]=-zaCorRd[ind]
            azCorRd[ind]=azCorRd[ind]+ !dpi
        endif
;
;   az 0 to 2pi positive.
;
        azCorRd=azCorRd mod (2.d*!dpi)
        ind=where(azCorRd lt 0.d,count)
        if count gt 0 then  azCorRd[ind]=azCorRd[ind]+ (2.d*!dpi)
        elCorRd=!dpi/2.D - zaCorRd    ; za to elevation
        azElV3=anglesTovec3(azCorRd,elCorRd) ; go to 3 vectors
;
;   az,el to ha,dec .. haToAzEl goes either way.
;
         haDecV3=haToAzEl(azelv3,aoLatRd)
;
;   hour angle/dec to raDec current
;
        if n_elements(last) ne npts then begin
            lmst=juldaytolmst(juldat[indD])
            last=lmst+eqOfEq
        endif
        v3=hatoradec(haDecV3,last)
        v3=v3 mod (!dpi*2d)
        if not keyword_set(ofdate) then begin
;
; get the aberation correction
;
          aberV3=aberannual(julDat[indd])
          v3=v3-aberV3
          n=n_elements(v3)/3
          vn=reform(sqrt(total(reform(v3*v3,3,n),1)))
          for j=0,2 do v3[j,*]=v3[j,*]/vn
;
; now apply inverse nutation,prec to go to j2000
;
          v3=precNut(v3,juldatAvg,/toj2000)
        endif
;
;   * convert vectors back to angles
;
        vec3ToAngles,v3,c1Rd,c2Rd
        raHr[indd]  =c1Rd * dradeg/360.*24.
        decDeg[indd]=c2Rd * dradeg
    endfor
    ind=where(raHr lt 0.,count)
    if count gt 0 then raHr[ind]=raHr[ind] + 24.D
    ind=where(raHr ge 24.,count)
    if count gt 0 then raHr[ind]=raHr[ind] - 24.D
  return
end
