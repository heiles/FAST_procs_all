;+
;plazswres - overplot azswing residuals
;
; SYNTAX:
;    plazswres,da,azfit,label,roll=roll,step=step
;
; ARGS:
;    da	    [*,nza] {ts} nza azswings to plot
;    azfit	[nza] {azf}  array of azfits (already fit).
;    label  string .. date
; KEYWORDS:
;    roll   0--> pitch, nozero --> roll
;    step   increment to add to each plot for y offset (def:0)
; DESCRIPTION
;    plot the (azswing.p/r - fit) for az  for each of nza azswings. 
;-
pro plazswres ,da,azfit,label,roll=roll,step=step
	    common colph,decomposedph,colph

    labelp= label + ' azswings PITCH residuals vs az'
    labelr= label + ' azswings ROLL  residuals vs az'
	xtitle='az'
    if not keyword_set(roll) then begin
		roll=0
		title=labelp
		ytitle='pitch'
	endif else begin
		roll=1
		title=labelr
		ytitle='roll'
	endelse
    if n_elements(step) eq 0 then step=0.
    a=size(da)
    nza=a[2]
    for i=0,nza-1 do begin
        if  i eq 0 then begin
            plot,da[*,i].az, cmpazswres(da,azfit,i,roll=roll)+step*i,$
				color=colph[i+1],$
                xstyle=1,ystyle=1,$
				xtitle=xtitle,ytitle=ytitle,title=title 
        endif else begin
            oplot,da[*,i].az, cmpazswres(da,azfit,i,roll=roll)+step*i,$
				col=colph[i+1]
        endelse
    endfor
    return
end

