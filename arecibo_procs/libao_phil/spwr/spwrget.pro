;+
;NAME:
;spwrget - get a sitepwr record
;
;SYNTAX: istat=spwrget(lun,p,nrecs=nrecs,fname=fname)
;
;ARGS:
;     lun: logical unit number to read from.
;KEYWORDS:
;nrecs   : long    recs to read. def=1
;fname   : string  if supplied then ignore lun,nrecs,
;                  just read all of fname
;
;RETURNS:
;     p: structure holding the data input
; istat: > 0 number of records input
;      : 0 hiteof
;      :-1 i/o error..
;
;KEYWORDS:
;     nrecs:    number of records to read. def=1
;
;DESCRIPTION:
;
;   Read the site power records. This is ascii data recorded by
;sitepwerlog. The continues from the current position.
;-
;
function spwrget, lun,p,nrec=nrecs,fname=fname
;
	on_ioerror,ioerr
	useFnm=keyword_set(fname)

;    get entire file ?

	if (useFnm) then begin
		recsToGet=readasciifile(fname,inpAr,comment=';')
		if (recsToGet lt 0) then begin
			print,"read error.. nofile? for:",fname
			return,-1
		endif
	endif else begin
		recsToGet=( n_elements(nrecs) eq 0)?1:nrecs
		inp=''
	endelse
	irec=0
	while (irec lt recsToGet) do begin
		if (useFnm) then begin
			inp=inpAr[irec]
		endif else begin
			readf,lun,inp
			if strmid(inp,0,1) eq ';' then continue
		endelse
		if irec eq 0 then begin
			p=replicate({sitepwrI},recsToGet)
	    endif
	    a=strsplit(inp,count=count,/extract)
		p[irec].date=long(a[0]); yyyymmdd
		p[irec].time=hms1_hr(double(a[1]))*3600.; hhmmss.s
		p[irec].time1970=tosecs1970(p[irec].date,p[irec].time)
        for i=0,2 do begin
			p[irec].Imag[i]      =float(a[2+i])
			p[irec].VPhToPh[i]   =float(a[6+i])
			p[irec].VtoGnd[i]    =float(a[9+i])
			p[irec].IdemandCur[i]=float(a[13+i])
			p[irec].IdemandMax[i]=float(a[16+i])
			p[irec].phVtoI[i]    =float(a[19+i])
		endfor
		p[irec].Ires             =float(a[3]) 
		p[irec].Vres             =float(a[6]) 
		p[irec].PFavg            =float(a[22]) 
		p[irec].Pactive          =float(a[23]) 
		p[irec].Preactive        =float(a[24]) 
		p[irec].Papparent        =float(a[25]) 
		p[irec].TempC            =float(a[26]) 
		p[irec].TempRelC         =float(a[27]) 
		for i=0,5 do begin
			reads,a[28+i],val,format='(z)'
			p[irec].ssr[i]=val
		endfor
		irec++
	endwhile

done: if irec ne recsToGet then begin
		p=(irec le 0)?'':p[0:irec-1]
	  endif
	  return,irec
ioerr: 
	hiteof=eof(lun)
	if (not hiteof) then begin
		message,!err_string,/noname
		irec=-1
	endif
	goto,done
end
