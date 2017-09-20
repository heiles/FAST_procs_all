;+
; mx101 - fit turret scans via x101 routine for multiple sources
; SYNTAX: istat=mx101(pminp,srcindStart,fit)
; ARGS:   pminp[]   :{pmsrcinpst} array of srcinp structures..
;     srcIndStart   :long . srcInd for first element of pminp.
;           fit[]   :{x101fitinfo} return data here.
;-
function mx101,pmsrcinp,srcindSt,fito,_extra=e 
;
    numsrc=(size(pmsrcinp))[1]
    srcind=srcindSt
    totpnts=0
    for i=0,numsrc-1 do totpnts=totpnts+pmsrcinp[i].nstrips
    fito=replicate({x101fitval},totpnts)
    npts=0
    curfile=''
    for i=0,numsrc-1 do begin
        if (curfile ne pmsrcinp[i].file) then copen ,pmsrcinp[i].file
        cscan , pmsrcinp[i].scan
        ftpamp,pmsrcinp[i].ftpamp
        ftpsig,pmsrcinp[i].ftpsig
        cstrip,1
        nstrips=pmsrcinp[i].nstrips
        x101,nstrips,fit,_extra=e
		pmsrcinp[i].srcname=fit[0].src			; src name
        fit.srcind=srcind
		if (pmsrcinp[i].nbadstrips gt 0) then begin
			nbad=pmsrcinp[i].nbadstrips
			itemp=intarr(nstrips)		; all zeros
			itemp[pmsrcinp[i].badstrips[0:nbad-1]-1]=1; set bad to 1
			ind=where(itemp eq 0)		; good indices
			fit=fit[ind]
			nstrips=n_elements(fit)
		endif
        fito[npts:npts+nstrips-1] =fit
        npts=npts+nstrips
        srcind=srcind+1
    endfor
	if totpnts ne npts then fito=fito[0:npts-1]
    return,npts
end
