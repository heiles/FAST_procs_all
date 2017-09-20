;+
;NAME:
;aminprecs - input alfamon records 
;SYNTAX: nrecs=aminprecs(lun,nrecsReq,d,smo=smo,yyyymmdd1=yyyymmdd1,$
;                        yyyymmdd2=yyyymmdd2)
;ARGS:
;   lun :       int file containing data to read
;   nrecsReq:  long requested number of records to read
;KEYWORDS:
;      smo: int smooth and decimate by this amount.  should be an odd number
;               >= 3. The data will be smoothed and decimated by this amount.
;yyyymmdd1: long      if supplied then start inputting nrecsReq when you hit
;                     this date.
;yyyymmdd2: long      if supplied then stop inputting recs when you go beyond
;                     this date.
;
;RETURNS:
;   nrecs : long    number of records input.
;   d[nrecs]:{alfamon} data input from file
;DESCRIPTION:
;   This routine is normally called via aminpday or ammoninp.
;
;   aminprecs will try to read the requested number of records from the 
;alfa log monitoring file that lun points to (you need to open the file
;before calling this routine). The number of records actually read is
;returned in nrecs. The routine will preallocate an array of nrecsReq
;before reading.
;Note: the dates are ast
;
;EXAMPLE:
;   openr,lun,'/share/cima/Logs/alfa_loggerlog',/get_lun
;   nrecs=aminprecs(lun,9999,d)
;-
function aminprecs,lun,nrecsReq,inpdat,smo=smo,yyyymmdd1=yyyymmdd1,$
			yyyymmdd2=yyyymmdd2
;
    on_ioerror,done

	if n_elements(yyyymmdd1) eq 0 then yyyymmdd1=0L
	if n_elements(yyyymmdd2) eq 0 then yyyymmdd2=99999999L
    dosmo=0 &$
    if keyword_set(smo) then begin
        dosmo=1
        print,'smoothing by:',smo
        if smo gt 2 then dosmo=1
    endif

    inpdat=replicate({alfamon},nrecsReq)
    inpl=''
	irec=0L
	yyyymmdd1S=string(format="(i08)",yyyymmdd1)
	yyyymmdd2S=string(format="(i08)",yyyymmdd2)
	while (irec lt nrecsReq) do begin
		point_lun,-lun,curpos
    	readf,lun,inpl
		if (strmid(inpl,0,1) eq '#') then continue
		if (strmid(inpl,0,8) lt yyyymmdd1s) then continue
		if (strmid(inpl,0,8) gt yyyymmdd2s) then begin
			point_lun,lun,curpos
			break
		end
		inpdat[irec]=amparseinp(inpl)
		irec++
	endwhile
done:
	if irec eq 0 then begin
		inpdat=''
	endif else begin
		if irec ne nrecsReq then begin
			inpdat=inpdat[0:irec-1]
		endif
	endelse
;
    if dosmo then begin
        irec=amsmodat(inpdat,smo,dsmo)
        inpdat=temporary(dsmo)
    endif
    return,irec
end
