;+
;NAME:
;secs1970tojd - convert  unixsecs(1970,mjd=mjd) to jd
;SYNTAX: jd[n]=secs1970tojd(secs1970)
;ARGS:
;secs1970[n]:double     secs1970 (utc based)
;KEYWORDS:
; mjd: 		            if set then return mjd rather then
;                       jd
;RETURNS:
; jd[n]:  double        jd for above times. if /mjd this will be mjd
;DESCRIPTION:
;	Convert from specified secsfrom 1970 to julian date.
;If /mjd is set, then return mjd rather than jd.
;
;The routine uses the 1970secs, jddate for 2000.0 
; to convert.
;Warning: 2014:nov. this routine was accurate to about
;  .06 seconds.
;
;Note: secs=systime(/sec) returns utc secs from 1970
;      print,systime(0) or print,systime(0,secs) take utc 1970 secs
;      but adjusts to the local time zone (ast) in the output string
;-
function 	secs1970tojd,secs1970,mjd=mjd
;
; compute using mjd for a bit more accuracy
	mjdtojd=2400000.5D
	secsJ2000=946684800D			; secs 1970 for 2000:00:00:00 utc 
	jd2000 =2451544.5D               ; juldate for
	mjd2000=jd2000 - mjdtojd
	difDays=(secs1970*1D - secsJ2000)/86400D
	if keyword_set(mjd) then begin
		return,(mjd2000 + difDays) 
	endif else begin
		return,(mjd2000 + difDays) + mjdtojd
	endelse
end
