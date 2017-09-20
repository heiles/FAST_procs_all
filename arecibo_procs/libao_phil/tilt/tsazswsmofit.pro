;.............................................................................
pro tsAzSwSmoFit,da,azfit,decimate=decimate
;
; smooth and the do the fits, sort to 0,360
;
	if n_elements(decimate) eq 0 then decimate=0
    a=size(da)
    if a[0] eq 1 then nelm=1 else nelm=a[2]
    azfit =replicate({azf},nelm)
    azfloc={azf}
    for i=0,nelm-1 do begin
        print,"smooth,fitting,mod360 for za:",da[0,i].za
        d0=da[*,i]
        tssmo,d0,decimate=decimate
        tsAzSwFit,d0.aznomod,d0[0].za,d0.p,d0.r,azfloc
        azfit[i]=azfloc
        d0.az=(d0.az mod 360.)
        ind=sort(d0.az)
	    if keyword_set(decimate) then begin
			if (i eq 0) then begin
				daout=replicate(d0[0],n_elements(d0),nelm)
			endif
			daout[*,i]=d0[ind]
		endif else begin
        	da[*,i]=d0[ind]
		endelse
    endfor
	if keyword_set(decimate) then da=daout
    return
end
