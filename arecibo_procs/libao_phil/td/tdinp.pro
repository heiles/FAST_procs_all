;.............................................................................
function tdinp,lun,td,npntsReq
;
; input data from lun int data array..
;
;;  on_error,1
;
;   see how much of file is left
;
    rdblk=10000L
    fst=fstat(lun)
    pntsleft=(fst.size-fst.cur_ptr)/276
    npnts=npntsReq
    if  pntsleft lt npntsReq then npnts=pntsleft
    toLoop=npnts  / rdblk
    atend= npnts mod rdblk
	if npnts le 0 then return ,0
    td =replicate({td},npnts)
;
;   allocate array
;
    if (toLoop gt 0) then tdL=replicate({tdall}, (npnts < rdblk))
    ist=0
    for i=0,toLoop-1 do begin
        readu,lun,tdL
        if tdcheckendian(tdL[0]) then tdL=swap_endian(tdL)
        iend=ist+rdblk-1
        td[ist:iend].secM=tdL.secM
        td[ist:iend].az  =tdL.az*.0001      ; convert to degrees from .0001
        td[ist:iend].gr  =tdL.gr*.0001      ; convert to degrees from .0001
        td[ist:iend].ch  =tdL.ch*.0001      ; convert to degrees from .0001
        td[ist:iend].pos =tdL.slv.tickI.pos/43663.36 ; convert to inches
        td[ist:iend].kips[0,0]=tdL.slv[0].tickI.ldCell1*.02; convert to kips
        td[ist:iend].kips[1,0]=tdL.slv[0].tickI.ldCell2*.02; convert to kips
        td[ist:iend].kips[0,1]=tdL.slv[1].tickI.ldCell1*.02; convert to kips
        td[ist:iend].kips[1,1]=tdL.slv[1].tickI.ldCell2*.02; convert to kips
        td[ist:iend].kips[0,2]=tdL.slv[2].tickI.ldCell1*.02; convert to kips
        td[ist:iend].kips[1,2]=tdL.slv[2].tickI.ldCell2*.02; convert to kips
        ist=ist+rdblk
    endfor
    if  atend gt 0 then begin
        tdL=replicate({tdall}, atend)
        readu,lun,tdL
        if tdcheckendian(tdL[0]) then tdL=swap_endian(tdL)
        iend=ist+atend-1
        td[ist:iend].secM=tdL.secM
        td[ist:iend].az  =tdL.az*.0001      ; convert to degrees from .0001
        td[ist:iend].gr  =tdL.gr*.0001      ; convert to degrees from .0001
        td[ist:iend].ch  =tdL.ch*.0001      ; convert to degrees from .0001
        td[ist:iend].pos =tdL.slv.ticKI.pos/43663.36 ; convert to inches
        td[ist:iend].kips[0,0]=tdL.slv[0].tickI.ldCell1*.02; convert to kips
        td[ist:iend].kips[1,0]=tdL.slv[0].tickI.ldCell2*.02; convert to kips
        td[ist:iend].kips[0,1]=tdL.slv[1].tickI.ldCell1*.02; convert to kips
        td[ist:iend].kips[1,1]=tdL.slv[1].tickI.ldCell2*.02; convert to kips
        td[ist:iend].kips[0,2]=tdL.slv[2].tickI.ldCell1*.02; convert to kips
        td[ist:iend].kips[1,2]=tdL.slv[2].tickI.ldCell2*.02; convert to kips
    endif
    td.kipst=total(total(td.kips,1),1)
    return,npnts
end
