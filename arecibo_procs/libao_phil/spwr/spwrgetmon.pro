;+
;NAME:
;spwrgetmon - get a months worth of data
;
;SYNTAX: istat=spwrgetday(yymm,p,idir=idir)
;
;ARGS:
;  yymm:long     yy,mon to get
;KEYWORDS:
;idir   : string  if supplied, then input directory.
;                 else use default
;
;RETURNS:
;     p: structure holding the data input
; istat: > 0 number of records input
;      :-1 i/o error, file doesn't exist
;
;DESCRIPTION:
;
;   Read the site power records for the specified month.
;-
;
function spwrgetmon,yymm,par,idir=idir
;
	minDay=1440
	sloprec=100
	lpref='sitepwr_'
	lsuf   ='.dat'
    idirL='/share/phildat/sitepwr/'
	if n_elements(idir) ne 0 then idirL=idir
	if (strmid(idirL,0,1,/reverse_offset) ne "/") then idirL=idirL + "/"
    lprefix='/share/phildat/sitepwr/sitepwr_'
	mon=yymm mod 100L
	yr =yymm / 100L
	if yr lt 100 then yr +=2000L
	srcpat=idirL + lpref + string(format='(i04,i02,"[0-9][0-9]")',yr,mon) + lsuf
	flist=file_search(srcpat)
	nfiles=n_elements(flist)
	maxRec=(minDay + sloprec)*nfiles
	firstTime=1
	icur=0L
	for ifile=0,nfiles-1 do begin
		nrecs=spwrgetday(yymmdd,p,fname=flist[ifile])
		if (nrecs le 0 ) then continue
		if (firstTime) then begin
			par=replicate(p[0],(maxrec))
			firsttime=0
		endif
		par[icur:icur+nrecs-1]=p
		icur+=nrecs
	endfor
	if icur eq 0 then  return,0
	if icur ne maxrec then par=par[0:icur-1]
	return,icur
end
