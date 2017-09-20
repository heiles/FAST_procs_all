;+
;NAME:
;masgetfile - input an entire file
;SYNTAX: istat=masgetfile(desc,b,avg=avg,tp=tp)
;ARGS:
;    desc: {} returned by masopen
;KEYWORDS: 
;     avg:      if keyword set then return the averaged data
;               It will average over nrows and ndumps per row.
;               the returned data structure will store the averaged
;               spectra as a double.
;RETURNS:
;  istat: 1 got all the requested records
;       : 0 returned no rows
;       : -1 returned some but not all of the rows
;   b[n]: {}   array of structs holding the data
; tp[n*m,2]: float array holding the total power for each spectra/sbc
;              m depends on the number of spectra per row
;-
function masgetfile,desc,b,avg=avg,tp=tp,_extra=e
;
;   position to start of file
;
    nrows=desc.totrows
    row=1
	if arg_present(tp) then begin 
    	return,(masgetm(desc,nrows,b,row=row,avg=avg,tp=tp,_extra=e))
	endif else begin
    	return,(masgetm(desc,nrows,b,row=row,avg=avg,_extra=e))
	endelse
end
