pro plzastrips,dz,roll=roll,lab=lab,remza=remza
;
;   plot za swings vs za
;
	common colph,decomposedph,colph

	subza=0
    if n_elements(lab) eq 0 then lab=" "
    if n_elements(roll) eq 0 then roll=0
	if keyword_set(remza) then subza=1
    a=size(dz)
    if a[0] eq 1 then begin
        nza=1
    endif else begin
        nza=(size(dz))[2]
    endelse
    for i=0,nza-1 do begin
        if roll ne 0 then begin
            if nza eq 1 then begin
                y=dz.r
				za=dz.za
            endif else begin
                y=dz[*,i].r
				za=dz[*,i].za
            endelse
        endif else begin
            if nza eq 1 then begin
                y=dz.p
				za=dz.za
            endif else begin
                y=dz[*,i].p
				za=dz[*,i].za
            endelse
        endelse
		if subza then y=y-za + 9.8
        if  i eq 0 then begin
            plot,dz[*,i].za,y,xstyle=1,ystyle=1,xtitle='za',$
                ytitle='[deg]',title=lab
        endif else begin
            oplot,dz[*,i].za,y,color=colph[i+1]
        endelse
    endfor
    return
end
