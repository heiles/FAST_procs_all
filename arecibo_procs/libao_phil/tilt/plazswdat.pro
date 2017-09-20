; plazswdat - plot azswing data vs 
;
pro plazswdat,da,roll=roll,step=step,label=label
;
    common colph,decomposedph,colph

	if n_elements(roll) eq 0 then roll=0
	if n_elements(step) eq 0 then step=0.
	if n_elements(label) eq 0 then label=' '
	a=size(da)
	if a[0] eq 1 then begin
		len=1
	endif else begin
		len=a[2]
	endelse
	for i=0,len-1 do begin
		if roll ne 0 then begin
			yy=da[*,i].r + i*step
			labely='roll [deg]'
			title= label + ' azswing roll'
		endif else begin
			yy=da[*,i].p +i*step
			title=label + 'azswing pitch'
			labely='pitch [deg]'
		endelse
		if i eq 0 then begin
			plot,da[*,i].az,yy,title=title,xtitle='az',ytitle=labely,$
					color=colph[i+1]
		endif else begin
			oplot,da[*,i].az,yy, color=colph[i+1]
		endelse
	endfor
	return
end
