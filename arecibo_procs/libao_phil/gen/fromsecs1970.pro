;+
;NAME:
;fromsecs1970 - convert from  unixsecs 1970, to ymd,hms
;SYNTAX: [hhmmss,yyyymmdd]=fromsecs1970(secs1970,utc=utc,daynoyr=daynoyr,str=str)
;ARGS:
;secs1970: long	seconds from 1970
;KEYWORDS:
;utc:           is set then return time as utc. def: local
;DESCRIPTION:
;	Convert from unix seconds 1970 to hhmmss, yyyymmdd.
;If /utc is set then return as utc (the default is local time).
;if the keyword daynoyr= is supplied then also return
; dayno,year in the daynoyr variable
;if the str= keyword is supplied then also return time
;in standard systime string format
;
;RETURNS:
;[hhmmss,yyyymmdd]: lonarr   time
;[dayno,year]     : dblarr   dayno will include the fraction of day.
;str              : string   standard systime string of time
;
;Note:secs1970 are always utc. the idl systime routine will
;convert this to local time.
;-
function 	fromsecs1970,secs1970,daynoYr=daynoYr ,utc=utc,str=str
;
	
	str=systime(0,secs1970,utc=utc)
;                          mon      day       hh      mm      ss     yr
	a=stregex(str,"[^ ]+ +([^ ]+) +([0-9]+) +([^:]+):([^:]+):([^ ]+) +([0-9]+)",$
    		/sub,/extract)
	mon=montonum(a[1])
	day=long(a[2])
	hr =long(a[3])
	min=long(a[4])
	sec=long(a[5])
	yr =long(a[6])
	yymmdd=yr*10000L + mon*100L + day
	hhmmss=hr*10000L + min*100L + sec
	if arg_present(daynoYr) then begin
		daynoyr=[dmtodayno(day,mon,yr) + (hr + min/60d + sec/3600.)/24d,yr]
	endif
	return,[hhmmss,yymmdd]
end
