;.............................................................................
pro turinpday,yymmdd,tur,npts=npts,fname=fname
;
; input 1 days worth of tur data
;
;;  on_error,1
;
;   see how much of file is left
;
	if n_elements(fname) eq 0 then $
	fname=string(format='("/share/phildat/turret/tur",i06.6,".dat")',yymmdd)
	openr,lun,fname,error=err,/get_lun
	if err ne 0 then begin
		print,"could not open file " + fname
		tur=''
		npts=0L
		return
	endif
	turinp,lun,tur,86500
	npts=n_elements(tur)
	free_lun,lun
	return
end
