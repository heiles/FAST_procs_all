;+
; prfit2dio - input or output the coeff's  from prfit2d
; 
; SYNTAX: 
;    prfit2dio,prfit2d,filename,io=io 
;
;  ARGS: 
;       prfit2dio    {prfit2d} structure to input or output
; 	    filename  string   name of file to use for i/o    
;					 if filename not supplied, then read in the default
;				     file
; 
;  KEYWORDS:
;       io    required keyword. 'read' or 'write'
;
;		
pro prfit2dio,prfit2d,filename,io=io
;
;	on_error,1					; all the way back
	on_ioerror,labioerr

	if n_params() eq 1 then begin
		filename=aodefdir() + 'data/prAug01ReflOrig.coef'
		io='read'
	endif else begin
	if (n_elements(io) eq 0) or $
		 (io ne 'read') and (io ne 'write') then  begin
			message,'prfit2dio requires keyword io= "read" , or "write"'
	 endif
	 if  n_elements(filename) eq 0 then begin
			message,'usage:prfit2dio {prfit2d} filname io="read" or "write"'
	 endif
	endelse
 
	lun=-1
	if io eq 'read' then begin
		iotype='read'
		openr,lun,filename,/get_lun,error=ioerr
		if ioerr ne 0 then begin
			lin=string(format='("prfit2dio: openR err ",d," file:",a)',$
					ioerr,filename)
			if lun ne -1 then free_lun,lun
			message,lin
		endif
		prfit2d={prfit2d}
		readu,lun,prfit2d
		if abs(prfit2d.zapolydeg) gt 50 then prfit2d=swap_endian(prfit2d)
		free_lun,lun
		lun=-1 
		return
	endif else begin
;
;		write
;
		iotype='write'
		openw,lun,filename,/get_lun,error=ioerr
		if ioerr ne 0 then begin
			lin=string(format='("prfit2dio: openW err ",d," file:",a)',$
					ioerr,filename)
			if lun ne -1 then free_lun,lun
			message,lin
		endif
		writeu,lun,prfit2d
		free_lun,lun
		lun=-1
		return
	endelse
labioerr:  ;
	lin=string(format='(a,"ioerror filename:",a)',iotype,filename)
	if lun ne -1 then free_lun,lun
	message,lin
end
