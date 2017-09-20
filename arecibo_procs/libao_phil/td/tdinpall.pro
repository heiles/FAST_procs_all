;.............................................................................
function tdinpall,lun,td,npntsReq
;
; input data from lun int data array..
;
;;  on_error,1
;
;   see how much of file is left
;
    fst=fstat(lun)
    recsize=n_tags({tdall},/len) 
    pntsleft=(fst.size-fst.cur_ptr)/recsize
    npnts=npntsReq
    if  pntsleft lt npntsReq then npnts=pntsleft
;
;   allocate array
;
    td=replicate({tdall},npnts)
    readu,lun,td
    if tdcheckendian(td[0]) then td=swap_endian(td)

    return,npnts
end
