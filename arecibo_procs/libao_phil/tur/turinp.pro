;.............................................................................
pro turinp,lun,tur,npnts
;
; input data from lun int data array..
;;  on_error,1
;
;   see how much of file is left
;
	encToDeg=360./(4096. * 210. / 5.0)
	rdblk=10000L
    fst=fstat(lun)
    pntsleft=(fst.size-fst.cur_ptr)/n_tags({turlogInp},/len)
    if  pntsleft lt npnts then npnts=pntsleft
	toLoop=npnts  / rdblk
	atend= npnts mod rdblk
	tur =replicate({turLog},npnts)
;
;   allocate array
;
	if (toLoop gt 0) then turInp=replicate({turlogInp}, (npnts < rdblk))
	ist=0
	for i=0,toLoop-1 do begin
		readu,lun,turInp
		if turcheckendian(turInp[0]) then turInp=swap_endian(turInp)
		iend=ist+rdblk-1
		tur[ist:iend].statWd    =turInp.statWd
		tur[ist:iend].secM      =turInp.tickMsg.tmMs*.001; convert to secs
		tur[ist:iend].pos       =turInp.tickMsg.pos*encToDeg; 
		tur[ist:iend].devStat   =turInp.tickMsg.devStat; from micro
		tur[ist:iend].lastReqPos=turInp.lastReqPos*encToDeg
		tur[ist:iend].ioTry     =turInp.ioTry
		tur[ist:iend].ioFail    =turInp.ioFail
		tur[ist:iend].dat       =turInp.dat
		tur[ist:iend].datTm     =turInp.tmStmps
		tur[ist:iend].flts      =turInp.flts
		ist=ist+rdblk
	endfor
	if  atend gt 0 then begin
	    turInp=replicate({turloginp}, atend)
		readu,lun,turInp
		if turcheckendian(turInp[0]) then turInp=swap_endian(turInp)
		iend=ist+atend-1
		tur[ist:iend].statWd    =turInp.statWd
		tur[ist:iend].secM      =turInp.tickMsg.tmMs*.001; convert to secs
		tur[ist:iend].pos       =turInp.tickMsg.pos*encToDeg; 
		tur[ist:iend].devStat   =turInp.tickMsg.devStat; from micro
		tur[ist:iend].lastReqPos=turInp.lastReqPos*encToDeg
		tur[ist:iend].ioTry     =turInp.ioTry
		tur[ist:iend].ioFail    =turInp.ioFail
		tur[ist:iend].dat       =turInp.dat
		tur[ist:iend].datTm     =turInp.tmStmps
		tur[ist:iend].flts      =turInp.flts
	endif
	tur.datTm=tur.datTm*.001;	to seconds
    return
end
