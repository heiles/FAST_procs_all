;+
;NAME:
;hdrget - input headers
;SYNTAX: nhdrs=hdrget(lun,numhdrs,hdrs,scan=scan,std=std)
;ARGS:
;       lun: int  assigned to open file
;   numhdrs: long number of headers to read
;KEYWORDS:
;      scan: long position to scan before listing. 
;       std: if set then just return the standard header
;RETURNS:
;   hdrsd[]:{hdr} return headers here (or hdrStd)
;   nhdrs  :long  number of headers found
;
;DESCRPIPTION:
;   Input numhdrs headers from the current position in the file.
;If the scan keyword is used, then position to start of scan before inputting.
;If an integration requires more than 1 record (eg 4 correlator boards) then
;each record will count as a header.
;SEE ALSO:
;   posscan,scanlist
;-
;modhistory:
;
function hdrget,lun,numhdrs,hdrs,scan=scan,std=std
;
on_error,1
on_ioerror,done
lineToOutput=0
if (n_elements(scan) ne 0) then begin
    istat=posscan(lun,scan,1)
    if (istat ne 1) then message,"scan not found"
endif 

useStdHdr=keyword_set(std)
curscan=-1L
currec=-1L
if  useStdHdr then begin
    hdr={hdrstd}
    hdrs=replicate(hdr,numhdrs)
endif else begin
    hdrs=replicate({hdr},numhdrs)
    hdr ={hdr}
endelse

point_lun,-lun,curpos
linecnt=0L
ch=0 
cm=0
cs=0
inp=0L
for i=0,numhdrs-1 do begin
    readu,lun,hdr
    needSwap =(useStdHdr)?chkswaprec(hdr): chkswaprec(hdr.std)
    if needSwap then hdr=swap_endian(hdr)
    hdrs[inp]=hdr
    inp=inp+1L
;
;   position to next rec
;
    curpos=(useStdHdr)?curpos + hdr.reclen : hdr.std.reclen
    point_lun,lun,curpos
end
done:
if (inp ne numhdrs) then begin
    if inp eq 0 then begin
        hdrs=''
    endif else begin
        hdrs=hdrs[0:inp-1]
    endelse
endif
point_lun,lun,curpos
return,inp
end
