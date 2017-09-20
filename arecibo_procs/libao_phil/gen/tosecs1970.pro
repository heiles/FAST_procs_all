;+
;NAME:
;tosecs1970 - convert to unixsecs(from 1970)
;SYNTAX: secs1970=tosecs1970(yymmdd,hhmmss,mjd=mdd,jd=jd,daynoyr=daynoyr)
;ARGS:
;yymmdd: long	year,mon,day for time (utc based)
;hhmmss: double hour,min,sec for time (utc based)
;KEYWORDS:
;jd	: double	if provided then ignore yymmdd,hhmmss and use jd
;               as the date to convert to secs since 1970
;mjd: double	if provided then ignore yymmdd,hhmmss and use mjd
;               as the date to convert to secs since 1970
;daynoYr[2]:double  [dayno,year] if provided then ignore yymmdd,hhmmss
;               and use dayno and year (utc based) to convert to secs1970.
;DESCRIPTION:
;	Convert from specified date, time to secs from 1970 (unix time).
;If jd,mjd, or daynoyr are provided then used them instead of yymmdd,hhmmss.
;All times/dates provided are assumed to be utc based. If you want have
;secs1970 using ast as the base:
;	secs1970Ast=tosecs1970(080916,142022) - 4D * 3600D
;
;Note: secs=systime(/sec) returns utc secs from 1970
;      print,systime(0) or print,systime(0,secs) take utc 1970 secs
;      but adjusts to the local time zone (ast) in the output string
;-
function 	tosecs1970,yymmdd,hhmmss,mjd=mjd,jd=jd,daynoYr=daynoYr 
;
	jdl=-1D
	secsJ2000=946684800D			; secs 1970 for 2000:00:00:00 utc 
	jd2000=2451544.5D               ; juldate for
	mjdtojd=2400000.5D
	mjd2000=jd2000 - mjdtojd        ; will give a bit more resolution
	useJd=0
	if keyword_set(jd) then begin
		useJd=1
		jdL=jd
	endif 
	useMjd=keyword_set(mjd)
	if keyword_set(daynoYr) then begin
		dayno=dayno[0]*1D
		year =dayno[1]*1D
	    if year lt 100 then begin
			year=(year lt 50 )?year+2000D:year+1900D
		endif
		jdL=daynotojul(dayno,year)
		useJd=1
	endif
	if useMjd then return, secsJ2000 + (mjd - mjd2000)*86400D
	if not useJd then jdl=yymmddtojulday(yymmdd) + hms1_hr(hhmmss)/24D
	dif=(jdL-jd2000)*86400D
	return, secsJ2000 + dif
end
