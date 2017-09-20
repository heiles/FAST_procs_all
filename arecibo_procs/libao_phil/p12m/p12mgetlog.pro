;+
;NAME:
;p12mgetlog - read p12m log data
;SYNTAX: istat=p12mgetlog(lun,dat,nrecs=nrecs,posrec=posrec,dcd=dcd)
;ARGS: 
;     lun       : int   file to read. already opened
;KEYWORDS:
;   nrecs: long   number of records to read. def=1
;   posrec:long   record to position to. def:next record
;                 count from 1
;   dcd   :       if set then return structs with the device, programs words
;                 decoded
;
;RETURNS:
;istat: long	> 0 number of records returned
;                 0 : hit eof
;              <  0 : error
;dat[istat]:{p12mLogI}   array of structs holding log info
;
;		struct format is:
;a={p12mstBlk,$
;    double   mjd,   $ device systime at read
;    ; 32bit status.  not decoded
;    azMSt32:0ul,$
;    azSSt32:0ul,$
;    elSt32 :0ul,$
;    cenSt32:0ul,$
;    azPos_D:0d,$
;    azErr_D:0d,$; deg
;    azFdBackVel_DS:0d,$;deg/sec
;    azMotCur_A:0d,$;
;    azSlMotCur_A:0d,$;
;    elPos_D:0d,$;
;    elErr_D:0d,$;
;    elFdBackVel_DS:0d,$;
;    elMotCur_A:0d$;
; }
;logI={
;   cpuTmAtWaitTick: 0d,$// secs 1970 when wait for tick
;    cpuTmAtTick: 0d,$    // secs 1970 at tick
;    durRdDev: 0d,$       // number secs to rd device
;    durWrLast: 0d,$     // number secs for previous write blk
;    st:{p12mStBlk} $
;
;-
function  p12mgetlog,lun,logI,nrecs=nrecs,posrec=posrec,dcd=dcd
;
;
	on_ioerror,ioErr
	dodcd=keyword_set(dcd)
	if (n_elements(nrecs) eq 0 ) then nrecs=1L
	nrecsL=nrecs*1L
	if (n_elements(posrec) eq 0 ) then posRec=0L
	if posrec gt 0 then begin
		reclen=n_tags({p12mLogIU},/length)
		point_lun,lun,reclen*(posrec-1l)
	endif
	logIU=replicate({p12mLogIU},nrecsL)
	logIU.cpuTmAtWaitTick=-1.
	readu,lun,logIU
ioErr:
	; use 0 with -1 match. last rec still had 0.
	ii=where(logiU.cpuTmAtWaitTick gt 0.,nread)
	if nread ne nrecsL then begin
		if nread gt 0 then begin
			logIU=logIU[ii]
		endif else begin
			logIU=''
		endelse
		nrecsL=nread
	endif
	if not dodcd then begin
		logI=logIU
		return,nrecsL
	endif
	logI=replicate({p12mLogI},nrecsL)
	;// copy and decode
	struct_assign,logIU,logI
	;// now need to decode
	logI.st.stwds=p12mdcdstat(logIU.st.stwds)
	;// decode prState
	logI.prState=p12mdcdprstwd(logIU.prState)
	return,nrecsL
end
