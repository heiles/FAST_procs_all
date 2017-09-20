;+
;NAME:
;pdevpostmdinfo - figure out position info for multi file run
;SYNTAX: istat=pdevpostmdinfo(firstFile,nfiles,posI,fnmI=fnmI)
;ARGS:
; firstFile: string name of first file of run
;                   if fnmI supplied then ignore this
; nfiles:    long   number of files in scan (one beam)
;KEYWORDS:
;  fnmI: {}     fnmi struct from masfilelist. If supplied then
;               name filename form here.
;RETURNS:
;istat: int     0 ok
;              -1 : error .. message printed
; posI: {]      struct holding positioning info
;
;DESCRIPTION:
;	compute positioning info for multi file scans
;This can then be used to figure out where in the
;multi file scan to position to.
;
;-
function pdevpostmdinfo,firstfile,nfiles,posI,fnmI=fnmI
;
;   open the first file
;
	desc1Open=0
	lun2=-1
	lunl=-1
	if (n_elements(fnmI) eq 0) then begin
		istat=pdevparsfnm(firstfile,fnmIL)
		if istat ne 1 then begin
			print,"Could not parse filename:",firstfile
		    goto,errout
		endif
	endif else begin
		fnmIL=fnmI
	endelse
    fname=fnmIL.dir + fnmIL.fname
    fname=strmid(fname,0,strlen(fname)-10) + $
           string(format='(i05)',fnmIL.num +1) + ".pdev"
    ioerr=0

	istat=pdevopen('',desc1,fnmI=fnmIL)
	if istat ne 0 then begin
		print,"pdevopen returns error opening first file:",istat
	 	goto,errout
	endif
	desc1Open=1
	if (desc1.tmd ne 1) then begin
		print,"requested file is not timedomain"
		goto, errout
	endif

	posI={ $
		fnmI1:fnmIL , $; info on first file of scan
		stTm1970:0LL, $; start time scan. secs1970
		nfiles: 0L  , $; number of files in scan
		smpTmSec:0d , $; sample time in seconds
	    bytesSmp:0  , $; bytes 1 sample
		bytes1stF:0LL,$; data bytes first file
	    bytesMF  :0LL,$; bytes data middle files
	    bytesLF  :0LL,$; bytes data last file
		bytesTotScan:0LL$; total data bytes in scan
	}
	posI.stTm1970= desc1.hdev.time
	posI.nfiles=nfiles
	posI.smpTmSec=1D/desc1.hao.bandwdHz
	npol=((desc1.hsp.hrlpf and 4) ne 0)?2:1
    bits= 2^(desc1.hsp.hrlpf and 3)*2  ; 4,8,16 bits
	posI.bytesSmp=(bits*2L)*npol/8
	posI.bytes1stF=desc1.bytesFile - desc1.hdrlenb
;
;	now get sizes for other files
;
	if nfiles gt 1 then begin
    	fname=fnmIL.dir + fnmIL.fname
		fname=strmid(fname,0,strlen(fname)-10) + $
        	  string(format='(i05)',fnmIL.num +1) + ".pdev"
		ioerr=0
		openr,lun2,fname,/get_lun,err=ioerr
		if ioerr ne 0 then begin
	 		print,"Error opening 2nd file:",!error_state.msg
			goto,errout
		endif
		fs=fstat(lun2)
		posI.bytesMF=fs.size
	endif
	if nfiles gt 2 then begin
    	fname=fnmIL.dir + fnmIL.fname
        fname=strmid(fname,0,strlen(fname)-10) + $
              string(format='(i05)',fnmIL.num + nfiles - 1) + ".pdev"
        ioerr=0
        openr,lunl,fname,/get_lun,err=ioerr
        if ioerr ne 0 then begin
            print,"Error opening last file:",!error_state.msg
            goto,errout
        endif
        fs=fstat(lunl)
        posI.bytesLF=fs.size
	endif else begin	; middle and end file the same
        posI.bytesLF=posI.bytesMF
	endelse
		
	; these are data bytes... 
	posI.bytesTotScan=posI.bytes1stF
	if nfiles eq 2 then begin
		posI.bytesTotScan += posI.bytesLF 
	endif
	if nfiles gt 2 then begin
	    posI.bytesTotScan += (posI.bytesMF*(nfiles-2)  + posI.bytesLF)
	endif
	istat=0
done:
	if  desc1Open then pdevclose,desc1
	if  lun2 gt -1 then free_lun,lun2
	if  lunl gt -1 then free_lun,lunl
	return,istat
errout:
	istat=-1
	goto,done
end
