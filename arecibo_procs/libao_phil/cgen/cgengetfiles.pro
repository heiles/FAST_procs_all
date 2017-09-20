;+
;NAME:
;cgengetfiles - find the files for the specified date(s)
;SYNTAX: nfiles=cgengetfiles(yymmdd1,yymmdd2,filelist,ndays=ndays)
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
;yymmdd2. If keyword ndays is provided then return the list of filenames
;for the ndays of data starting at yymmdd1 and return yymmdd2.
;   The data is stored by month.
;
;EXAMPLE:
;   Get the files for oct02 through dec02
;   nfiles=cgengetfiles(021001,021230,filelist)
;   print,nfiles
;   3
;   print,filelist
;-
function cgengetfiles,yymmdd1,yymmdd2,filelist,ndays=ndays
	
;
    fpath=cgenpath()
	startData=20131121
    juldayStartData=yymmddtojulday(startData)
;
;	check for 2 digit years.. switch to 4 digit
;
	yr=yymmdd1 / 10000L
	if (yr lt 100) then begin
		yr=(yr gt 50)?yr+1900: yr:2000;
	endif
	yyyymmdd1L=yr*10000L + (yymmdd1 mod 10000L)

    if keyword_set(ndays) then begin
        julday1=yymmddtojulday(yyyymmdd1L)
        if ndays lt 0 then begin
            julday2=julday1+ndays+1
        endif else begin
            julday2=julday1+ndays-1
        endelse
        caldat,julday2,mon,day,year
        yymmdd2=(year mod 100)*10000L + mon*100 + day
    endif
;
; 	make sure yymmdd2 is 4 dig year
;
	yr=yymmdd2 / 10000L
    if (yr lt 100) then begin
        yr=(yr gt 50)?yr+1900: yr:2000;
    endif
    yyyymmdd2L=yr*10000L + (yymmdd2 mod 10000L)

    if (yyyymmdd1l gt yyyymmdd2l) then begin
        itemp=yyyymmdd1l
        yyyymmdd1l=yyyymmdd2l
        yyyymmdd2l=itemp
    endif
;
;	dont go into the future
;
	a=bin_date()
    yyyymmddcur=(a[0] mod 100) *10000L + a[1]*100 + a[2]
    if yyyymmdd2l gt yyyymmddcur then yyyymmdd2l=yyyymmddcur

;
;	limit to start of data
;
	yyyymmdd1L=(yyyymmdd1L > startData)
	yyyymmdd2L=(yyyymmdd2L > startData)

    julday1=yymmddtojulday(yyyymmdd1L)
    julday2=yymmddtojulday(yyyymmdd2L)


	maxfiles=(long((julay2 - julday1)/30. )  + 1)
	if (maxfiles gt 60) then begin
		print,"Warning. date range limited to 5 years."
		maxfiles=60
	endif
    filelist=strarr(maxfiles)
    yyyymm   =yyyymmdd1l/100L
    yyyymm2 =yyyymmdd2l/100L
    nfiles=0;
    for i=0,maxfiles-1 do begin
        if (yymm gt yymm2)  then goto,done
        lab=string(format='(i6.6)',yymm)
        filelist[nfiles]=fpath + '.' + lab
        nfiles=nfiles+1
        yyyy=yyyymm/100
        mm=(yyyymm mod 100) + 1
        if mm gt 12 then begin
            mm=1
            yyyy=yyyy+1
        endif
        yyyymm=yyyy*100 + mm
    endfor
done:   return,nfiles
end
