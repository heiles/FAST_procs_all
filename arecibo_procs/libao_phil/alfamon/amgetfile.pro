;+
;NAME:
;amgetfile - find the files for the specified date(s)
;SYNTAX: nfiles=amgetfile(yymmdd1,yymmdd2,filelist,ndays=ndays)
;ARGS:
;   yymmdd1: long  date for first day to read 
;   yymmdd2: long  date for last day of interest
;KEYWORDS:
;   ndays: long find files for ndays starting at yymmdd1. In this case
;               ignore yymmdd2.
;RETURNS:
;   nfiles: number of files found.
;   filelist[nfiles]: list of files.
;   yymmdd2: will return the actual last day used (in case you have
;            requested something in the future.
;DESCRIPTION:
;   Return the list of filenames that contain the data for yymmdd1 through
;yymmdd2 (astdates). If keyword ndays is provided then return the list of
;filenames for the ndays of data starting at yymmdd1 and return yymmdd2.
;   The data is stored by month.
;
;EXAMPLE:
;   Get the files for oct02 through dec02
;   nfiles=amgetfile(021001,021230,filelist)
;   print,nfiles
;   3
;   print,filelist
;-
function amgetfile,yymmdd1,yymmdd2,flist,ndays=ndays
;
; format:
; alfa_logger.log         .. current
; alfa_logger_2004_05.log .. old

    dirPath='/share/cima/Logs/ALFA_logs/'
	filePre='alfa_logger'
	fileSuf=".log"
	archiveList=file_search(dirPath+filePre+"_*.log")
	narchive=n_elements(archiveList)
    maxfiles=narchive + 1
	curFile=dirPath+filePre + fileSuf
;
;	get the dates for the archive
;
	a=stregex(archiveList,"[^_]*_logger_([0-9]*)_([0-9]*)",/extract,/sub)
	yyyymmList=lonarr(narchive)
	yyyymmList=long(a[1,*])*100 + long(a[2,*])	; yyyymm
	maxArch=max(yyyymmList)
;
; 	figure out the range of yyyymmdd  they want..
;
    if keyword_set(ndays) then begin
        julday1=yymmddtojulday(yymmdd1)
        if ndays lt 0 then begin
            julday2=julday1+ndays+1
        endif else begin
            julday2=julday1+ndays-1
        endelse
        caldat,julday2,mon,day,year
        yymmdd2=(year mod 100)*10000L + mon*100 + day
    endif
	yy=yymmdd1/10000L
    yyyymmdd1=(yy lt 2000)?(yymmdd1 mod 10000L) + (2000 + yy)*10000L: yymmdd1
	yy=yymmdd2/10000L
    yyyymmdd2=(yy lt 2000)?(yymmdd2 mod 10000L) + (2000 + yy)*10000L: yymmdd2
    if (yyyymmdd1 gt yyyymmdd2) then begin
        itemp=yyyymmdd1
        yyyymmdd1=yyyymmdd2
        yyyymmdd2=itemp
    endif
    yyyymm1   =yyyymmdd1/100L
    yyyymm2   =yyyymmdd2/100L
	ii=where((yyyymmList ge yyyymm1) and (yyyymmList le yyyymm2),cnt)
	if cnt gt 0 then flist=archiveList[ii]
	if yyyymm2 gt maxArch then begin
		flist=(cnt eq 0)? curFile:[flist,curFile]
		cnt++
	endif 
done:   return,cnt
end
