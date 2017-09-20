
pro rew,lun
    on_error,2
;
;   check if this is a was,mock data descriptro rather than
;   an lun
;
    a=size(lun)
    if (a[n_elements(a)-2] eq 8  ) then begin      
        ii=where(tag_names(lun) eq 'CURRECPOS',cnt)
		if cnt gt 0 then begin
		   lun.currecpos=0
		endif else begin
           ii=where(tag_names(lun) eq 'CURROW',cnt)
	       if cnt gt 0 then begin
		       lun.currow=0
		   endif else begin
              ii=where(tag_names(lun) eq 'CURPOS',cnt)
	          if cnt gt 0 then begin
			    lun.curpos=0
		      endif else begin
				 message,"unknown desc type for rew."
			  endelse
		   endelse
		endelse
    endif else begin
        point_lun,lun,0
    endelse
    return
end
