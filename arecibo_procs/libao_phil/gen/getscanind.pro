;+
;NAME:
;getscanind - get indices for start of each scan
;SYNTAX: getscanind,scanlist,scanind,scanlen
;ARGS  :
;       scanlist[len]: long array of scan numbers
;RETURNS:
;       scanind[len] : long indices into scanlist for start
;                           of each scan.
;       scanlen[len] : long number of entries in each scan.
;DESCRIPTION:
;   The routine corpwr() returns power information for each record in
;a file. This includes the scan number of each record. Typically there
;will be many records in a scan. This routine will search the array of
;scan numbers and return the starting index for the start of each scan
;and the number of records in the scan. It does this by scanning the array
;and looking for where the scan number changes.
;
;EXAMPLE:
;   print,corpwr(lun,9999,p)        ... up to 9999 recs
;   getscanind,p.scan,scanind,scanlen
;;  now loop thru each scan returned
;   nscans=(size(scanind))[1]
;   for i=0,nscans-1 do begin
;;      grab those belonging to 1 scan 
;       p1=p[scanind[i]:scanind[i]+scanlen[i]-1]
;       ...process
;   endfor
;-
pro getscanind,scanlist,scanind,scanlen
    if n_elements(scanlist) eq 1 then begin
        scanind=0
        scanlen=1
    endif else begin
        dif=scanlist-shift(scanlist,1)
        dif[0]=1
        scanind=where(dif ne 0)
        nscans=(size(scanind))[1]
        lenarr=(size(scanlist))[1]
        scanlen=shift(scanind,-1) - scanind
        scanlen[nscans-1]=lenarr-scanind[nscans-1]
    endelse
    return
end
