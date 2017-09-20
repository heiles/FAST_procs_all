;+
;NAME:
;shsfindtm - find file,rec for a given time
;SYNTAX: istat=shsfindtm(yymmdd,hhmmss,fI,indFile,indrec)
;ARGS:
;yymmdd: long date we want
;hhmmss: long time (ast) we want
;fI[n] : {}   array of struct returned from shsscandir()
;RETURNS:
;istat  : int   0 this date does not occur in dir
;               -1 time is before beginning of first file
;               -2 time is after the end of last file
;indFile: long  index into fI[] for file we want.. cnts from 0
;INDREC : long  record we want in file (cnt from 0)
;-
;
function shsfindtm,yymmdd,hhmmss,fI,indFile, indrec
	
	secRec=1
	ii=where(fI.yyyymmdd eq yymmdd,cnt)
	if  cnt eq 0 then return,0
	fIL=fI[ii]
	fileOff=(ii[0] eq 0)?0:ii[0]
	secMidInp=long(hms1_hr(hhmmss)*3600L +.5)
	ii=where(fIL.secMidSt le secMidInp,cnt)
	if cnt eq 0 then return,-1
	indFile=ii[cnt-1] + fileOff
	;
 	; compute rec
	;
	indRec=secMidInp - fI[indFile].secMidSt
	if indRec ge fI[indFile].nrecs then return,-2
	return,1
end
