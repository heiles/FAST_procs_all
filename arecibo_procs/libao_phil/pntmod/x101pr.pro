;+
;x101pr - print out value from turret fits (from x101).
;SYNTAX: x101pr,fit
;ARGS:
;		fit[]	:{x101fitval} array returned by x101 cal
;DESCRIPTION:
; az    za      g       b    zaE   zaW    azE   azW    ph    chi
;aaa.aa zz.zz ggg.gg bbbb.b eeee.e www.w eeee.e www.w ppp.pp ccc.cc
;-
pro x101pr,fit,filename=filename
;
    len=n_elements(fit)
	if keyword_set(filename) then begin
		openw,lun,filename,/get_lun
	endif else begin
		lun=-1
	endelse
    for i=0,len-1 do begin
        if i eq 0 then begin
            printf,lun,$
            " az    za      g       b    zaE   zaW    azE   azW  ph      chi"
        endif
        printf,lun,format=$
'(f6.2," ",f5.2," ",f6.2," ",f6.1," ",f6.1," ",f5.1," ",f6.1," ",f5.1," ",f6.2," ",f6.2)',$
    fit[i].az,fit[i].za,fit[i].g,fit[i].b,fit[i].zaE,fit[i].zaW,fit[i].azE,$
    fit[i].azW,fit[i].ph,fit[i].chi
    endfor
	if lun gt 99 then free_lun,lun
    return
end

