;+
;NAME:
;bpmonget - display bufpool monitor data
;SYNTAX: n=bpmonget(inpFile,bpmonSt)
;ARGS:
;inpFile: string file to input
;RETURNS;
;n     : int   number of samples we found
;bpmonAr[n]: {}   array of structs holding the data
;=
function bpmonget,inpfile,bpmonAr
;
    lun=-1
	errv=0
	openr,lun,inpfile,/get_lun,err=errv
	if errv ne 0 then begin
		print,"open error:",!ERROR_STATE.MSG
		return,-1
	endif
	qI={$
		      semMx  :0L,$	; mx sem. 0--> free
		 semEntryCnt :0L,$   ; entries in queue. 0--> empty
         numPuts     :0L,$   ; puts to queue
         numGets     :0L,$   ; gets from queue
         numGetsEmpty:0L,$   ; gets but queue was empty
         maxNum      :0L,$   ; queue has held
         minNum      :0L,$   ; queue has held
         curNum      :0L}    ;  queue hass

	rec={$
		curTm:0D,$  ; secs since 1970
        lgbufs:qI,$ ; large buffers
        smBufs:qI,$ ; small command bufs
        bpInp :qI,$ ; input queue
        bpOut :qI}  ; input queue
	a=size(rec)
	bytesRec=n_tags(rec,/length)

;
; get file size
;
	fs=fstat(lun)
	bytestot=fs.size
	nrecs=bytesTot/bytesRec
	bpMonAr=replicate(rec,nrecs)
	readu,lun,bpMonAr
	free_lun,lun
	return,nrecs
end
