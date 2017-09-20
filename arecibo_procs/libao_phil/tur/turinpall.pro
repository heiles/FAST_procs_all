;.............................................................................
pro turinpall,lun,tur,npnts
;
; input data from lun into data array..
;
;;  on_error,1
;
;   see how much of file is left
;
    fst=fstat(lun)
	recsize=n_tags({turloginp},/len) 
    pntsleft=(fst.size-fst.cur_ptr)/recsize
    if  pntsleft lt npnts then npnts=pntsleft
;
;   allocate array
;
	tur=replicate({turloginp},npnts)
    readu,lun,tur
	if turcheckendian(tur[0]) then tur=swap_endian(tur)

    return
end
