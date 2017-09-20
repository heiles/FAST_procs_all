;.............................................................................
pro tsinp,lun,d,npnts
;
; input data from lun int data array..
;
;;  on_error,1
;
;   see how much of file is left
;
    fst=fstat(lun)
    pntsleft=(bytesleftfile(lun))/20L
    if  pntsleft lt npnts then npnts=pntsleft
;
;   allocate array
;
    inp=fltarr(5,npnts)
    readu,lun,inp
    a=size(inp)
    d=replicate({ts},a[2])
    d[*].sec=reform(inp[0,*])
    d[*].p  =reform(inp[1,*])
    d[*].r  =reform(inp[2,*])
    d[*].az =reform(inp[3,*])
    d[*].za =reform(inp[4,*])
    d.aznomod =d.az
	if ((d[0].az gt 740) or (d[0].az lt 0. ) or (d[0].za lt 1.)  or $
	    (d[0].za gt 20.)) then begin
		d=swap_endian(d)
	endif
    return
end
