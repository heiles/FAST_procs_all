;+
;NAME:
;rfminpday - input a days worth of rf monitor data.
;SYNTAX: npts=rfminpday(yymmdd,d,fname=fname)
;ARGS:
;	yymmdd: long	date to input
;KEYWORDS:
;	fname: string	name of file (with directory to input)
;RETURNS:
;	npts:	long	number of points input
;	d[npts]: {}	    array structures holding the data
;
;DESCRIPTION:
;	input the rf monitor data for the specified day. Until the data
;has been moved to a permanent location, use the fname keyword to
;specify the file to input (yymmdd for now is ignored).
;
;	The returned structure contains:
;	
;	d.year  : long year
;	d.dayno : long day number of year (counts from 1)
;	d.secs  : long sec from midnite
;   d.pwr	: float    power value input
;fileformat:
;
; looks like mjd is in AST units not UTC
; Fri May 13 00:00:12 2011 raddata 55694.0001389 0.976
;-
function rfminpday,yymmdd,d,fname=fname	
;
	fnameLoc=''
	defDir='/share/radmon/'
	if n_elements(yymmdd) ne 0 then fnameLoc= defDir + $
				string(format='("RadMon",i02,"_",i02,"_",i02,".log")',$
			(yymmdd/10000L mod 100),yymmdd/100L mod 100L,yymmdd mod 100L)
	if n_elements(fname) ne  0 then fnameLoc=fname
;
	if fnameLoc eq '' then begin
		print,'Need to specify yymmdd or fname= keyword for date to use'
		return,0
	endif
	nlines=readasciifile(fnameLoc,inplines)
	if nlines le 0 then return,0
;
;                     year      mon        day        hr        min        sec  
;
;
; jjjj is mjd
;
; a[0] = dayS monthS dayMonN hh:mm:ss yyyy raddata jjjjj.sssssss  p.pp
;      day string skip
; a[1] = mjd
; a[2] = pwr
	a=stregex(inplines,'^.+ raddata ([0-9.]+) +([0-9.-]+)',/extract,/subexpr)
	ii=where(a[0,*] ne '',cnt)
	if cnt ne nlines then begin
		if cnt eq 0 then return,0
		a=a[*,ii]
		nlines=cnt
	endif
;
 	astr={Jd : 0D,$
 	  dayno : 0L,$
 	  sec   : 0L,$
       pwr	: 0.}
	mjdToJd=2400000.5D
	astToUTC=4D/24D
	d      =replicate(astr,nlines)
;    jorge left mjd relative to ast..
	d.jd   =reform(double(a[1,*])) + mjdtojd + astToUtc
	d.pwr  = reform(float(a[2,*]))
	caldat,d.jd - astToUTC,mon,day,yr,hr,min,sec
	d.sec=long(hr*3600 + min*60 + sec + .5)
	d.dayno=dmtodayno(day,mon,yr)
	return,nlines
end
