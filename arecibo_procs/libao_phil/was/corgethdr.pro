; 
;NAME:
;corgethdr - return the correlator header for the next group 
;
; SYNTAX: istat=corgethdr(lun,rethdr)
; ARGS:
;         lun:  int opened file to read
;   rethdr[nbrds]: {hdr} return array of headers brd 1.. thru brd n
;-
;history:
;31jun00 - updated to new corget format
;03nov01 - updated to work on pc

function corgethdr,lun,rethdr
;
; return the headers for the next group
; if you are not on a group boundary, move for to first group boundary
; before starting.
;
; return 1 - ok
;        0 - eof
;       -1 - aligned on non header boundary or i/o error
;
; on success position to start of next group, on error  remain at current spot
;
    if  wascheck(lun) then begin
        istat=wasftochdr(lun,rethdr,nrows=nrows)
        if istat eq 1 then lun.curpos=lun.curpos+nrows
        return,istat
    endif
    on_error,2
    on_ioerror,ioerr
    rethdr=replicate({hdr},4)
    hdr={hdr}
    point_lun,-lun,startpos
    curpos=startpos
    i=0
    retstat=-1
    while ( retstat ne 1 ) do begin
       readu,lun,hdr
       if ( string(hdr.std.hdrMarker) ne 'hdr_' ) then goto,ioerr
       if chkswaprec(hdr.std) then begin
          hdr=swap_endian(hdr)
        endif
       curpos=curpos+hdr.std.reclen     ; point start of next rec
       point_lun,lun,curpos
       if ((i eq 0 ) and (hdr.std.grpCurRec ne 1)) then begin
       endif else begin
            if i eq 0 then begin
                grpsReq=hdr.std.grptotrecs
                rethdr=replicate({hdr},grpsReq) 
            endif
            rethdr[i]=hdr
            i=i+1
            if (i eq hdr.std.grpTotRecs) then retstat=1
       endelse
    endwhile
    if (i ne grpsReq) and (i gt 0) then rethdr=temporary(rethdr[0:i-1])
    return, 1
;
; on io/errror reposition to current  and return errorcode
;
ioerr: ; seems that we need a null line or the jump screws up
    if ( eof(lun) ) then retstat=0
    on_ioerror,NULL
    point_lun,lun,startpos
    return,retstat
end
