;+
;NAME:
;spwrgetday - get a days worth of data
;
;SYNTAX: istat=spwrgetday(yymmdd,p,fname=fname)
;
;ARGS:
;  yymmdd:long     day to get
;KEYWORDS:
;fname   : string  if supplied, ignore yymmdd, read fname
;
;RETURNS:
;     p: structure holding the data input
; istat: > 0 number of records input
;      :-1 i/o error, file doesn't exist
;
;DESCRIPTION:
;
;   Read the site power records for given day.
;-
;
function spwrgetday,yymmdd,p,fname=fname
;
    lprefix='/share/phildat/sitepwr/sitepwr_'
	lsuf   ='.dat'
	useFnm=keyword_set(fname)
	if (useFnm) then begin
		fnameL=fname
	endif else begin
    	yymmddL=(yymmdd lt 1000000L)?yymmdd + 20000000L:yymmdd
        fnameL=lprefix + string(format='(i08)',yymmddL) + lsuf
	endelse
	istat=spwrget(lun,p,fname=fnameL);
	return,istat 
end
