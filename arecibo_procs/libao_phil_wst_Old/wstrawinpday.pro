;+
;NAME: 
;wstrawinpday - read in 1 days worth of data from ascii file
;
;SYNTAX: n=wstrawinpday(lun,yymmdd,bar,inp1=inp1,ndays=ndays)
;ARGS:
;  lun : int     from file open
;  yymmdd: int   yymmdd of date to start on       from file open
;  ndays : int   number of days to input. def=1
; search :       if set, then continue looking if you find a 
;                date gt the requested (in case bad record..)
; verb   :       is set then plot date/time of each rec
; recOff :long   start search at this recnum in file (cnt from 0)
;                use this to skip recs with bad dates
;RETURNS:
;      n:  int   number records input
; bar[n]: struct input data
;  inp1: string  string data for first row input
;               
;DESCRIPTION:
;   Routine reads ndays worth of data from the file pointed to by lun.
;Lun should be assigned to the oriondata.txt ascii file 
;(written by the orion weather station). The routine does no positioning
;before starting to read (so you should do a rewind if you don't know
;where you are positioned in the file.
;	The routine reads until it finds a record with the data yymmdd. It will
;continue reading for ndays (default=1) days worth of records.
;	The data is    loaded into the {wststr) array bar. 
;	If the keyword inp1= is supplied then the first ascii record returned
;will be returned in inp1 (for debugging).
;Notes:
; 1. the routine leaves you postioned after the first non-matching record
;    is found. If you read day N, and then read day N+1 without rewinding
;    the lun, then you will miss the first record of day N+1.
;-
function wstrawinpday,lun,yymmdd,bar,ndays=ndays,$
			inp1=inp1,search=search,verb=verb ,recoff=recoff
	
	on_ioerror,nodata
	if n_elements(ndays) eq 0 then ndays=1
	if n_elements(recOff) eq 0 then recOff=0L
	yymmddF=yymmdd
	if yymmddF gt 999999L then yymmddF-=20000000L

;   make string mm/dd/yy for comparison
;  L=last
;  F=First

	yy=yymmddF/10000L
	mm=yymmddF/100L mod 100L 
	dd=yymmddF mod 100L
	yymmddL=yymmddF
	if ndays gt 1 then begin
		jd=julday(mm,dd,yy+2000D,0,0,0)
		jd+=(ndays-1)
	    eps=.01
		caldat,jd+eps,mon,day,year
		yymmddL=(year-2000L)*10000L + mon*100L + day
	endif
	bar=''
	inp=''
	irec=0L
	print,yymmddF,yymmddL
	while 1 do begin
		readf,lun,inp
		irec++
		if (irec -1 ) lt recOff then continue
		yymmddC=long(strmid(inp,6,2))*10000L + long(strmid(inp,0,2))*100L + $
						long(strmid(inp,3,2))
		if (yymmddC ge yymmddF) then begin
			if (yymmddC le yymmddL) then break
		endif
		if (yymmddC gt yymmddL) and (not keyword_set(search)) then goto,nodata
		if keyword_set(verb) then print,format='(i5,":",a)',irec,strmid(inp,0,17)
	endwhile
;
; 	allocate enough for  N day
;
	on_ioerror,ioerr2
	slop=100
	maxrecs=(84000L/15 + slop)*ndays
	inpar=strarr(maxrecs)
	readf,lun,inpar
ioerr2:
	ii=where(inpar ne '',cnt)
	bar=replicate({wststr},cnt+1)
	inp1=inp
	bar[0]=wstldrec(inp)
	ntot=1L
	if cnt eq 0 then goto,done
;
	for i=0L,cnt - 1L do begin
		yymmddC=long(strmid(inpAr[i],6,2))*10000L + $
				long(strmid(inpAr[i],0,2))*100L + $
						long(strmid(inpAr[i],3,2))
		if (yymmddC gt yymmddL) then break
		if (inpar[i] eq '') then continue
		bar[ntot++]=wstldrec(inpar[i])
	endfor
	if (ntot) lt cnt+1 then goto,done
;
;   keep reading
;
	inp=''
	on_ioerror,done
	while (1) do begin
		readf,lun,inp
		yymmddC=long(strmid(inp,6,2))*10000L + $
				long(strmid(inp,0,2))*100L + $
						long(strmid(inp,3,2))
		if (yymmddC gt yymmddL) then break
		bar=[bar,wstldrec(inp)]
		ntot++
	endwhile
done: 
	if ntot lt n_elements(bar) then bar=bar[0:ntot-1]
	return,ntot
nodata: 
	bar=''
	return,0
end
