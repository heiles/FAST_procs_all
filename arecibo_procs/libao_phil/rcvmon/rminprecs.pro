;+
;NAME:
;rminprecs - input rcvmonitor records 
;SYNTAX: nrecs=rminprecs(lun,nrecsReq,d,rcvnum=rcvnum,smo=smo)
;ARGS:
;   lun :       int file containing data to read
;   nrecsReq:  long requested number of records to read
;KEYWORDS:
;   rcvnum: int only return data for this receiver.. 1..12
;      smo: int smooth and decimate by this amount.  should be an odd number
;               >= 3. The data will be smoothed and decimated by this amount.
;RETURNS:
;   nrecs : long    number of records input.
;   d[nrecs]:{rcvmon} data input from file
;DESCRIPTION:
;   This routine is normally called via rminpday or rmmoninp.
;
;   rminprecs will try to read the requested number of records from the 
;receiver monitoring file that lun points to (you need to open the file
;before calling this routine). The number of records actually read is
;returned in nrecs. The routine will preallocate an array of nrecsReq
;before reading.
;
;EXAMPLE:
;   openr,lun,'/share/obs4/rcvmon/rcvmN',/get_lun
;   nrecs=rminprecs(lun,9999,d)
;-
function rminprecs,lun,nrecreq,inpdat,rcvnum=rcvnum,smo=smo
;
    on_ioerror,done

    dosmo=0
    if keyword_set(smo) then begin
        dosmo=1
        print,'smoothing by:',smo
        if smo gt 2 then dosmo=1
    endif

    inpdat=replicate({rcvmon},nrecreq)
    inpdat.year=-1 
    readu,lun,inpdat
done:
    ind=where(inpdat.year eq -1,count)
    if count gt 0 then begin
		if count eq n_elements(inpdat) then return,0
		inpdat=temporary(inpdat[0:ind[0]-1])
	endif
;
; swap if little endian machine
;
    a=1234L
;   byteorder,a,/swap_if_little_endian
    byteorder,a,/htonL
    if a ne 1234L then inpdat=temporary(swap_endian(inpdat))
    if n_elements(rcvnum) gt 0 then begin
        ind=where(inpdat.rcvnum eq rcvnum,nrecs)
        if nrecs gt 0 then begin
            inpdat=inpdat[ind]
        endif else begin
            inpdat=''
        endelse
    endif else begin
        nrecs=n_elements(inpdat)
    endelse
;
    if dosmo then begin
        nrecs=rmsmodat(inpdat,smo,dsmo)
        inpdat=temporary(dsmo)
    endif
    return,nrecs
end
