;
; procedure header info
;
a={hdrproc, id: bytarr( 4,/nozero),$; "proc"
   	       ver: bytarr( 4,/nozero),$; version xx.0 
	  procName: bytarr(12,/nozero),$; procedure name. 
	   procVer: bytarr( 4,/nozero),$; version for procedure
	   srcName: bytarr(16,/nozero),$; source name
	       dar: dblarr(10,/nozero),$
	       iar: lonarr(10,/nozero),$
;							         note car 8,10since 1st ind varies first 
	       car: bytarr(8,10,/nozero)}
