;
;+
;NAME:
;windmkmon - make the month archive
;
;SYNTAX: nrecs=windmkmon(yy,mon,d)
;ARGS:
;	year	: int year to get
;	mon	    : int month of year (1..12)
;RETURNS:
;	d[nrecs]:{windstr} data returned for this month
;   nrecs   : long  number or records found
;			  -1 this months data not available
;DESCRIPTION:
;	Input a months worth of data from the windmeter raw data archive.
;Create the idl structure {windstr} and then write this out to the
;idl save file ('wind_yymm.sav'). The output directory is in 
;/share/megs2_u1/wind/
;-
function	windmkmon,year,mon,wd

	forward_function winddir
;	
    monlist=['jan','feb','mar','apr','may','jun','jul','aug','sep','oct',$
             'nov','dec']
;
	outdir=winddir()

	yymm=(year gt 100)? (year - 2000) : year
	yymm=yymm*100L + mon
	outf=string(format='("wind_",i4.4,".sav")',yymm)

	days=daysinmon(mon,year)

	append=0
	ntot=0L
	for i=1,days do begin
		yymmddL=yymm*100L + i
		nrecs=windinpraw(yymmddL,wd,append=append)
		print,yymmddL,nrecs
		if (nrecs gt 0) and (append eq 0) then append=1
		if nrecs gt 0 then ntot=ntot+nrecs
	endfor
	if ntot le 0 then return,0
;
; 	now check for good data
;
	save,wd,file=outdir+outf
	return,ntot
end
