;
; radec current to azel
;
pro p12m_radeccur_to_azel,mjd,raDeg,decDeg,az,el
;
	mjdToJd=2400000.5D
    ddtor=!dpi/180.d
    dradeg=1.d/ddtor
	p12mposDeg=[18.3483,66.7515]
    p12mlatRd=p12mposDeg[0]*ddtor
    p12mlongRd=p12mposDeg[1]*ddtor      ; west longitude
;
; check for mjd spanning multiple days
;
	jd=mjd+mjdToJd
	ijd=long(jd)
	npts=n_elements(jd)
	if (npts gt 1) then begin
        jdlist=iJD[uniq(ijd,sort(ijd))]
    endif else begin
        jdlist=ijd
    endelse
    az =dblarr(npts)
    el=dblarr(npts)
;
	  for i=0L,n_elements(jdlist)-1L do begin
        indd=where(jdlist[i] eq ijd)
        jdAvg=mean(jd[indd])
;
;   go to 3 vecs
;
        v3=anglesTovec3(raDeg[indd]*ddtor,decDeg[indd]*ddtor);go to 3vecs
;
;   go to current ra,dec
;
;        v3=precNut(v3,jdAvg,eqOfEq=eqOfEq)
;   need eq of equ. use nutation call
		 nutM=nutation_M(jdAvg,eqOfEq=eqOfEq)
;
; get the aberation correction and apply it.
;
        aberV3=aberannual(jd[indd])
        v3=v3+aberV3
        n=n_elements(v3)/3
        vn=reform(sqrt(total(reform(v3*v3,3,n),1)))
        for j=0,2 do v3[j,*]=v3[j,*]/vn
;
; goto  apparent hour angle,dec
;
        lmst=juldaytolmst(jd[indd],obspos=p12mposDeg)
        last=lmst+eqOfEq
        v3=radecvtohav(v3,last)
;
;   ha,dec to az,el
;
        v3=hatoazel(v3,p12mlatRd)
;
;    back to angles
;
        vec3toangles,v3,c1rd,c2rd,/c1pos
        az[indd]=c1rd*dradeg
        el[indd]=c2rd*dradeg
    endfor
;
;	;
;    put el -90 to 90
;    az 0 to 360.
;
	elTmp=el mod 360d
;   limit -180 to 180
    ind=where(el le -180.,cnt)
	if cnt gt 0 then el[ind]+=360d
    ind=where(el gt  180.,cnt)
	if cnt gt 0 then el[ind]-=360d
;
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
	return
end
