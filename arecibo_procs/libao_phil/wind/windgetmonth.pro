;+
;NAME:
;windgetmonth - input a months worth of data
;
;SYNTAX: nrecs=windgetmonth(year,month,wd,smo=smo)
;ARGS:
;	year	: int 4 digit year
;   month   : 1 through 12 month of year
;KEYWORDS
;		smo : int smooth and decimate the data to this many seconds
;			      the default is 1 second resolution
;RETURNS:
;	wd[nrecs]:{windstr} data returned
;   nrecs   : long  number or records found
;			  -1 this months data not available
;DESCRIPTION:
;	Input a months worth of wind data. It is return in the array of
;wind structures d. Each element of d contains:
;** Structure WINDSTR, 3 tags, length=16:
;   JULDAY DOUBLE   Julian day of measurement.AST noon rather than utc noon
;					starts the day.
;   VEL    FLOAT    wind velocity in mph
;   DIR    FLOAT    direction in degree from where the wind is blowing.
;-
function	windgetmonth,year,mon,wd,smo=smo
;	
;
	forward_function winddir
	dir=winddir()
	yymm= (year mod 100L )*100 + mon
	file=string(format='(a,"wind_",i4.4,".sav")',dir,yymm)
;
;	see if file exists
;
	a=findfile(file,count=count)
	if count eq 0 then return,-1
	restore,file
	if keyword_set(smo) then begin
		if smo eq 1 then goto,done 
		nold=n_elements(wd)
		nnew=nold/smo
		if nnew*smo eq nold then begin
			wd=reform(wd,smo,nnew,/overwrite)
		endif else begin
			wd=reform(wd[0:nnew*smo-1L],smo,nnew)
		endelse
		wdn=wd[0:nnew-1]
		wdn.jd =median(wd.jd,dim=1)
		wdn.dir=median(wd.dir,dim=1)
		wdn.vel=total(wd.vel,1)/smo
		wd=wdn
	endif

done: return,n_elements(wd)
end
