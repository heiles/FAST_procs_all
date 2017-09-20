;+
; plazswresavg - plot average of the azswing residuals (avg over za)
;
; SYNTAX:
;     plazswresavg,da,azfit,datelabel,roll=roll
;-
pro  plazswresavg,da,azfit,label,roll=roll
;
    if n_elements(roll) eq 0 then roll=0
	a=size(da)
	nza=a[2]
	naz=a[1]
    a=fltarr(naz)
 	labelp= label + ' PITCH residuals avged over za'
 	labelr= label + ' ROLL  residuals avged over za'
    for i=0,nza-1 do begin
            a=a+cmpazswres(da,azfit,i,roll=roll)
    endfor
    a=a/nza
    if  roll eq 0 then begin
       plot,da[*,0].az,a,title=labelp,xstyle=1,ystyle=1,xtitle='az',$ 
			ytitle='pitch residual [deg]'
    endif else begin
       plot,da[*,0].az,a,title=labelr,xstyle=1,ystyle=1,xtitle='az',$
			ytitle='roll residual [deg]'
    endelse
    return
end

