openr,lun,fname,error=err,/get_lun
if err eq 0 then begin &$
	restore,fname &$ 
	free_lun,lun &$
endif else begin &$
forward_function tsysinp &$
istat=tsysinp(1,r1,year=year) &$
istat=tsysinp(2,r2,year=year) &$
istat=tsysinp(100,r100,year=year) &$
istat=tsysinp(3,r3,year=year) &$
istat=tsysinp(5,r5,year=year) &$
;istat=tsysinp(6,r6,year=year) &$
istat=tsysinp(7,r7,year=year) &$
istat=tsysinp(8,r8,year=year) &$
istat=tsysinp(9,r9,year=year) &$
istat=tsysinp(10,r10,year=year) &$
istat=tsysinp(12,r12,year=year) &$
istat=tsysinp(11,r11,year=year) &$
endelse
