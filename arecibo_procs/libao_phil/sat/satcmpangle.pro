;+
;NAME:
;satcmpangle - compute angle between ra,dec,jd and satellites
;SYNTAX: satcmpangle,raHr,decDec,jd,passAr,distI
;ARGS:
;raHr[m]:	float	right ascension hours to use
;decDeg[m]: float  declination in degrees
;jd[m]  :   double  julian date
;passAr[n]:{}   array of satellite constellation info returned
;               from satpassplt()
;RETURNS:
;distI[m,n]: float distance from satellite to request position
;DESCRIPTION:
;   Compute the angle in degrees between the requested ra,dec (j2000),jd and the
;location of the satellites in passAr. 
;passAr comes from satpassplt( ...satAr=satAr,/radec). Be sure that the 
;/radec keyword is set in the call to satpassplt so that the ra,dec gets
;computed..
;-
pro satcmpangle,raHr,decD,jd,passAr,distI
;
	forward_function radecdist
;
	maxPnts=150
    npass=n_elements(passAr)
	npnts=n_elements(raHr)
	distI=(npass eq 1)?fltarr(npnts):fltarr(npnts,npass)
	raAr =fltarr(maxPnts) + raHr
	decAr=fltarr(maxPnts) + decD
	for i=0,npass-1 do begin
;
; 	interpolate the satellite to our jd
;
		n=passAr[i].npnts
		raS =interpol(passar[i].p[0:n-1].raHr,passar[i].p[0:n-1].jd,jd)
		decS=interpol(passar[i].p[0:n-1].decD,passar[i].p[0:n-1].jd,jd)
		if npass eq 1 then begin
			distI[*]=radecdist(raHr,decD,raS,decS)
		endif else begin
			distI[*,i]=radecdist(raHr,decD,raS,decS)
		endelse
	endfor
	return
end
