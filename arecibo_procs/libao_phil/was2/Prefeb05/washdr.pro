;+
;NAME:
;washdr - read a was fits header
;
;SYNTAX: istat=washdr(desc,h,scan=scan,rec=rec,numhdr=numhdr,inc=inc)
;
;ARGS: 
;   desc:{wasdesc} was descriptor returned from wasopen()
;   scan: long     scan number default is current position in file
;    rec: long     record number of scan, default is current record
;    inc:          if set then increment position in file after reading
;                  the default is to do do no increment.
;    numhdr:       number of headers to read. default is 1
;
;RETURNS:
;   istat: int  1 ok, 0 eof,-1 bad (could not find scan or rec)
;       h: {wasfhdr}  was fits header
;
;DESCRIPTION:
;   This routine will read the fits headers on disc into a data structure.
;By default the header from the current row position is input. Multiple
;rows can be read with the numhdr keyword. You can position in the file
;before reading by using the scan, rec keywords. After the i/o the file
;is left positioned at the original position (on entry to this routine). The
;inc keyword will position the file after the last header read (be careful
;since  integrations or records may contain multiple rows in the file).
;
;WARNING:
;   This routine reads the memory in the fits header directly into a
;structure. If / when the header changes, this routine will fail (
;I need to make it more robust).
;-
function washdr,desc,rethdr,scan=scan,rec=rec,inc=inc,numhdr=numhdr
;
;   
;
    errmsg=''
    scanL=keyword_set(scan) ?scan:0L
    recL =keyword_set(rec)  ?rec :0L
    if scanL ne 0 then recL=1       
    if (scanL ne 0) or (recl ne 0) then begin
        if waspos(desc,scan,rec) ne 1 then begin
            print,"error positioning to scan,rec:",scanL,recL
            return,-1
        endif
    endif
    if not keyword_set(numhdr) then numhdr=1
    startPos=desc.curpos
    rethdr=replicate({wasfhdr},numhdr)
    rethdrb={wasfhdrb}
;;;;;;;;    on_ioerror,ioerr
    for i=0L,numhdr-1 do begin
;
;   read 2nd col
;
        curRow=desc.curpos+1L
        fxbread,desc.lun,junk,2,curRow,errmsg=errmsg
;
;   backup to start of 2nd col
;
        point_lun,-desc.lun,bytpos
        bytpos=bytpos-16L;          back up..
        point_lun,desc.lun,bytpos
;
        readu,desc.lun,rethdrb

        if (rethdrb.lags_in and 'ffff0000'XL) ne 0 then $
                rethdrb=swap_endian(rethdrb)
        numtags=n_tags(rethdrb)
        n=n_tags(rethdrb)
        for j=0,n-1 do begin &$
            sz=size(rethdrb.(j)) &$
;			print,'j:',j
            if ((sz[0] gt 0) and (sz[1] ge 8)) then begin &$
                rethdr[i].(j)=string(rethdrb.(j)) &$
            endif else begin &$
                 rethdr[i].(j)=rethdrb.(j) &$
            endelse &$
        endfor
        desc.curpos=desc.curpos+1
    endfor
    if not keyword_set(inc) then desc.curpos=startPos
    
    on_ioerror, NULL
    return,1

ioerr:
    on_ioerror, NULL
    if not keyword_set(inc) then desc.curpos=startPos
    rethdr=''
    if (eof(desc.lun)) then begin
        return,0
    endif
    print,'washdr ioerror:',!ERROR_STATE.MSG
    return,-1
end
