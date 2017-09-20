;+
; plazswdatmcon - overplot multiple azswing data - (c0 + c1*az)
;-
pro plazswdatmcon1,da,azfit,ind,overplot,roll=roll,step=step,_extra=e,$
	color=color,cs=cs

    common colph,decomposedph,colph

    if n_elements(ind)  eq 0 then ind=0
    if n_elements(overplot) eq 0 then overplot=0
    if n_elements(roll) eq 0 then roll=0
    if n_elements(step) eq 0 then step=0
	if n_elements(color) eq 0 then color=1
	if roll eq 0 then begin
      y=da[*,ind].p - (azfit[ind].p.c0+da[*,ind].aznomod * $
            azfit[ind].p.c1)+ind*step
      if  overplot eq 0 then  begin
            plot,da[*,ind].az,y,xstyle=1,ystyle=1,_extra=e,color=colph[color]
				
      endif else begin
            oplot,da[*,ind].az,y,color=colph[color]
      endelse
    endif else begin
        y=da[*,ind].r - (azfit[ind].r.c0+da[*,ind].aznomod* $
                azfit[ind].r.c1)+ind*step
        if  overplot eq 0 then  begin
            plot,da[*,ind].az,y,xstyle=1,ystyle=1,_extra=e,color=colph[color]
        endif else begin
            oplot,da[*,ind].az,y,color=colph[color]
        endelse
    endelse
    return
end
;
pro plazswdatmcon,da,azfit,label,roll=roll,step=step,color=color,$
		cs=cs
;
; 
    if n_elements(roll) eq 0 then roll=0
    if n_elements(step) eq 0 then step=0
    if n_elements(color) eq 0 then color=0
	if n_elements(cs) eq 0 then cs=1.
    overplot=0
	a=size(da)
	nza=(a[0] eq 1)?1:a[2]
	xtitle='az'
	lcol=1
	if roll eq 0 then begin
		ytitle='pitch'
		title=label + ' PITCH - (c0+c1*az from fit)'
	endif else begin
		ytitle='roll'
		title=label + ' Roll  - (c0+c1*az from fit)'
	endelse
    for i=0,nza-1 do  begin
		if i eq 0 then begin
			plazswdatmcon1,da,azfit,i,overplot,roll=roll,step=step,$
				xtitle=xtile,ytitle=ytitle,title=title,color=color,chars=cs
		endif else begin
			plazswdatmcon1,da,azfit,i,overplot,roll=roll,step=step,color=lcol,$
				chars=cs
		endelse
        overplot=1
;		if color ne 0 then lcol=(lcol mod 10) + 1
 		if color ne 0 then lcol=(lcol mod 2) + 1
    endfor
	return
end
;
