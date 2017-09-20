;+
;NAME:
;rmsmohr - smooth to one hour resolution
;SYNTAX: nrecs=rmsmohr(dinp,dsmo)
;ARGS:
;   dinp[n] : {rcvmon} data to smooth to hour resolution (unless lastday
;					   keyword is used).
;RETURNS:
;   nrecs      : long    number of smoothed records returned
;   dsmo[nrecs]:{rcvmon} smoothed data
;DESCRIPTION:
;   Smooth the data fields in dinp to one hour resolution.
;Each point is normally sampled every 22 seconds. Fields that are not numeric:
;.stat use the first element of the pnts to smooth.
;
;EXAMPLE:
;-
; 26nov04 - for some reason, lost endfor in rcvloop on 11oct04??
function rmsmohr,dinp,dsmo
;
   	nrecs=n_elements(dinp)
	lday=long(dinp.day)
	uldays=lday[uniq(lday,sort(lday))]	 ;unique idays
	ndays=n_elements(uldays)
	maxrcv=16L
	maxout=ndays*24L*maxrcv
    dsmo=replicate(dinp[0],maxout)

    rcvnumfound=lonarr(16)
    icur=0L
    rcvlist=lonarr(16) - 1
    for i=0l,n_elements(rcvlist)-1 do begin
        if (rmconfig(i) eq 1) then rcvlist[i]=i
	endfor
	ind=where(rcvlist ge 0)
	rcvlist=rcvlist[ind]
;
; 	loop by day
;
	for i=0,ndays-1 do begin
		lcurday=uldays[i]
		iday=where(lday eq lcurday,count)
		if count eq 0 then goto,botloop
		hr=(dinp[iday].day - lcurday) * 24.		; hour of day
		for ii=0L,n_elements(rcvlist)-1 do begin
;;			mm1=icur
			currcv=rcvlist[ii]
            ircv=where((dinp[iday].rcvnum eq currcv),count)
			if count gt 0 then begin
				h=histogram(hr[ircv],binsize=1.,min=0.,max=23.999,$
					reverse_ind=irev)
			    for k=0L,23 do begin
					if irev[k] ne irev[k+1] then begin
						i1=irev[irev[k]]
						i2=irev[irev[k+1]-1L]
						j1=iday[ircv[i1]]		; first index this hour
						npnts=i2-i1+1.
     dsmo[icur].key   =dinp[j1].key
     dsmo[icur].rcvnum=dinp[iday[ircv[i1]]].rcvnum
     dsmo[icur].stat  =dinp[iday[ircv[i1]]].stat
     dsmo[icur].year  =dinp[iday[ircv[i1]]].year
     dsmo[icur].day   =lcurday+(k+.5)/24.
;;				   T16K=total(dinp[iday[ircv[i1:i2]]].T16K)/npnts
;;				   print,currcv,k,T16K
     dsmo[icur].T16k  =total(dinp[iday[ircv[i1:i2]]].T16K)/npnts
     dsmo[icur].T70k  =total(dinp[iday[ircv[i1:i2]]].T70K)/npnts
     dsmo[icur].Tomt  =total(dinp[iday[ircv[i1:i2]]].Tomt)/npnts
     dsmo[icur].pwrP15=total(dinp[iday[ircv[i1:i2]]].PwrP15)/npnts
     dsmo[icur].pwrN15=total(dinp[iday[ircv[i1:i2]]].PwrN15)/npnts
     dsmo[icur].postampP15=total(dinp[iday[ircv[i1:i2]]].postampP15)/npnts
         				for kk=0L,2  do begin
     dsmo[icur].dcur[kk,0]=total(dinp[iday[ircv[i1:i2]]].dcur[kk,0])/npnts
     dsmo[icur].dcur[kk,1]=total(dinp[iday[ircv[i1:i2]]].dcur[kk,1])/npnts
     dsmo[icur].dvolts[kk,0]=total(dinp[iday[ircv[i1:i2]]].dvolts[kk,0])/npnts
     dsmo[icur].dvolts[kk,1]=total(dinp[iday[ircv[i1:i2]]].dvolts[kk,1])/npnts
         				endfor ; kk
         				icur=icur+1
            		endif  ; irev[k] ne irev[k+1]
				endfor	   ; k .. hour loop
			endif		   ; count gt 0 ( at least 1 day entry this rcvr
     endfor  ; ii end rcvlist loop
botloop:
    endfor  ; 			   ; loop i =ndays-1
    nrecs=icur
    if nrecs lt maxout then dsmo=dsmo[0:nrecs-1]
;
;       put back in date order
;
    ind=sort(dsmo.day)
    dsmo=dsmo[ind]
    return,nrecs
end
