;+
;NAME:
;pdevpostmdcmp - compute file,position in file for time offset
;SYNTAX: istat=pdevpostmdcmp(posITmd,secs,retI,secs1970=secs1970,ymdhms=ymdhms)
;ARGS:
; posITmd: {}   timedomain position info returned by pdevpostmdinfo();
;   secs :long  second from start of file to position to
;KEYWORDS:
;secs1970:long  secs 1970 for position.
;ymdhms[2]:long yymmdd, hhmmss fofor time to position to.
;Note: all times are utc. Arecibo time is UTC-4HOURS
;
;RETURNS:
;  istat : int   0 ok, -1 error with errmsg printed
; retI   : {}    struct holding return position info
;DESCRIPTION:
;	Compute the position in a multi scan file for a given 
;time offset from the beginning of the file. The user
;inputs the integer seconds from start of file to move to.
;
;	The keyword secs1970 lets you input the absolute secs from
;1970 (utc) for the time of interest. 
;
;   The keyword ymdhms[2] lets you input hour,minutes secs (utc).
;
;	The routine returns in retI: the filename, byte offet in file, and the
;samples left. 
; retI.filename
; retI.byteOffset
; retI.bytesLeftToRead .. in file from this position
;
; 	No file opening or positioning  is done by this routine.
;-
function    pdevpostmdcmp,posI,secs,retI,secs1970=secs1970,hms=hms
;
;   optionally position to start of rec
;
	fnum=-1
	eps=1d-9
	tmPos=posI.STTM1970 + LONG64(secs + eps)
	if n_elements(secs1970) gt 0 then begin
		tmPos=long64(secs1970 + eps)
	endif
	if n_elements(ymdhms) eq 2  then begin
	 	tmPos=long64(tosecs1970(ymdhms[0],ymdhms[1])+eps)
	endif
	secOffset=long(tmPos - posI.stTm1970 )
	dataByteOffset=((secOffset*1D)/posI.smpTmSec) *posI.bytesSmp
	if (dataByteOffset ge posI.bytesTotScan) then begin
		print,"requested position beyond end of scan" 
	    return,-1
	endif
	; check if in the first file
	if (dataByteOffSet lt posI.bytes1stF) then begin
		fnum=0
		byteOffsetD=dataByteOffset
		bytesLeftFile=posI.bytes1stF - byteOffsetD
		hdrOffset=1024L
		goto,done
	endif 
	; see if it is in the last file
	if dataByteOffset ge (posI.bytesTotScan-posI.bytesLF) then begin
		fnum=posI.nfiles - 1
		byteLeftFile=(posI.bytesTotScan - databyteOffset)
		byteOffsetD=posI.bytesLF - bytesLeftFile
		hdrOffset=0L
		goto,done
	endif
	; must be a middle file
	deltM= (dataByteoffset - posI.bytes1stF)
	fnum=deltM / posI.bytesMF + 1	; plus 1 because of 1st file
	byteOffsetD=deltM mod  posI.bytesMF
	hdrOffset=0L 
done:
	fname=posI.fnmI1.dir + posI.fnmI1.fname
	fname=strmid(fname,0,strlen(fname)-1) + $
		 string(format='(i05)',posI.fnmI1.num +fnum)  + ".pdev"
	retI={$
		fname:fname,$
		byteOffset:byteOffsetD + hdrOffset,$
		bytesLeftToRead:bytesLeftFile $
	}
	return,0
end
