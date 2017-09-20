;+
;inpanzfit - input data from turret scan (already analyzed by analyz)
;
;SYNTAX:
;        inpanzfit,filename,pntdat
;
; ARGS: 
; 	  filename: string.. to read... format is az,za...12 cols/line
;				# col 1 is a comment
;
;     pntdat  : {anzfitval} defined in h/pntmod.h return info here
;
; 
pro inpanzfit,filename,pntdat
	lun=-1
	openr,lun,filename,error=err,/get_lun
    if err ne 0 then begin
	  message,'error ' + !err_string
    endif
	maxinp=2000
	pntdat=replicate({anzfitval},maxinp)
	pntdat1={anzfitval}
	inpline=""
	on_ioerror,done
	ind=0L
	while 1 do begin
		readf,lun,inpline
		if strmid(inpline,0,1) ne "#" then begin
			if  ind lt maxinp then begin
				reads,inpline,pntdat1
				pntdat[ind]=pntdat1
				ind=ind+1
			endif else begin
		        message,"input array:2000 elements overflowed"
			endelse
		endif
	endwhile
done:
	if lun ne -1 then free_lun,lun
	if ind gt 0 then begin 
	 	pntdat=pntdat[0:ind-1]
	endif else begin
		pntdata=""
	endelse
	return
end
