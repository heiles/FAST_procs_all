; 
;NAME:
;posscan - position to a scan/record on disc
; SYNTAX: istat=posscan(lun,scan,rec,retstdhdr=retstdhdr,sl=sl)
; ARGS:
;       lun:    int .. logical unit assigned to open file
;      scan:    long.. scan number 0--> whatever scan fits .. current or next
;                      full scan number --> position to scan, 
;                      no rewinding allowed
;       rec:    long  grp number within scan.
;                     0 or not included--> next record available
;                               number --> record of current scan
; keywords
;   retstdhdr:  if valid variable, return standard header here..
;                (only if we positioned successfully)
;   skip     :  int .. skip this many scans forward. should use with 
;                      scan=0. 
;        sl[]:  {sl} returned from getsl routine. If provided
;               then routine will position directly to the scan requested.
;
; The routine will not backup from the current position. If it finds
; an increasing scan/rec number then it returns -1
;       
; returns: 1 positioned ok
;          0 not found 
;         -1 found increasing scan number
;         -2 scan not in scanloc array
; 
; iook - 1 ok, 0 i/oerror, -1 bad headerid
;-
;history:
; 7jul00 - added skip keyword
;03dec00 - updated to new scanlist structure
;
function posscan ,lun,scan,rec,retstdhdr=retstdhdr,skip=skip,sl=sl
;   you need to have defined the std header...
;
;   if fits data, the lun is a structure..
;
    a=size(lun)
    if  a[n_elements(a)-2] eq 8 then return,waspos(lun,scan,rec)
    scan0=999999999L
    swapLast=0
    on_error,1
    on_ioerror,iolab
    if (n_elements(scan) eq 0 ) then begin
        scan=0
    endif else begin
        if keyword_set(sl) then begin 
            ind=where(scan eq sl.scan,count)
            if count eq 0 then return,-2
            pos=sl[ind].bytepos
            point_lun,lun,pos[0]
        endif
    endelse
    if (n_elements(rec) eq  0 )  then rec=0
    skipl=0
    if keyword_set(skip) then skipl=skip
    hdr={hdrstd}
    hdrstdlen=128
    firsttime=1
    done=0
    irec=0
    stat=0
    rewind=0
    scantomatch=scan
    if scan eq 0 then begin
        scantomatch=scan0
        firsttime=0             ; no rewind allowed on scan 0 searches..
    endif
    point_lun,-lun,startpos
;
;   if beginning of file, make sure 1st 1 char are hdr_
;
    if startpos eq 0 then begin
        point_lun,-lun,poshdrstart
        if searchhdr(lun,maxlen=4) eq 0 then begin
            rew,lun
            if searchhdr(lun) eq 0 then begin
               point_lun,lun,poshdrstart
               on_ioerror,NULL
               message,'bad hdr start of file. no hdrid:hdr_'
            endif
        endif
        point_lun,-lun,poshdrstart
    endif
        
    while ( done eq 0 ) do begin
        iook=0
        point_lun,-lun,poshdrstart
        readu,lun,hdr
        if chkswaprec(hdr) then begin
            hdr.grpnum    =swap_endian(hdr.grpnum)
            hdr.grpCurRec =swap_endian(hdr.grpCurRec)
            hdr.scanNumber=swap_endian(hdr.scanNumber)
            hdr.reclen    =swap_endian(hdr.reclen)
            swapLast=1
        endif
        iook=1
;
iolab:  if iook  and ( string(hdr.hdrMarker) ne 'hdr_' ) then iook=-1
        case iook of 
;
;   bad hdrid
;
            -1 : begin 
                    stat=1
                    if (firsttime eq 1) then begin 
                        rewind=1
                    endif else begin
                        point_lun,lun,poshdrstart
                        on_ioerror,NULL
                        message,'bad hdr. no hdrid:hdr_'
                    endelse
                 end
;
;   i/o error
;
             0 : begin
                    stat=2
                    if (firsttime eq 1) then begin
                        rewind=1
                    endif else begin
                        hiteof=eof(lun)
                        if ( not hiteof) then begin
                            point_lun,lun,poshdrstart
                            on_ioerror,NULL
                            message,!ERR_STRING,/NONAME,/IOERROR
                        endif else  begin
                            done=1
                            retstat=0
                        endelse
                    endelse
                end
;
;   got a record ok
;
            1 : begin
                    if (scantomatch eq scan0) then begin
                        if (skipl eq 0) then  begin
                            if (hdr.grpCurRec eq 1) and $
                               ((hdr.grpnum eq rec) or (rec eq 0)) then begin
                                scantomatch=hdr.scanNumber
                                rec=hdr.grpnum
                            endif
                        endif else begin 
                            skipl=0     ; just need to skip 1 rec..
                        endelse
                    endif
                    case 1 of 
;
;   --found larger scan number
;
                        (hdr.scanNumber gt scantomatch):  begin
                            stat=3
                            if ( firsttime eq 1) then begin
                                rewind=1
                            endif else begin
                                done=1
                                retstat=-1
;   print,"req:",scan,rec,"found increasing scan",hdr.scanNumber,hdr.grpnum
                            endelse
                        end
;
;   --found smaller scan number
;
                        hdr.scanNumber lt scantomatch:  begin
                            stat=4
                        end
;
;   --found  scan number
;
                        (hdr.scanNumber eq scantomatch): begin
;
;      -- found 1st rec of group of interest
;
                            if ( ((hdr.grpnum eq rec) or (rec le 0)) and $
                                (hdr.grpCurRec eq 1)) then begin
                                stat=5
                                retstat=1
                                done=1
;   print,"req:",scan,rec," found match",hdr.scanNumber,hdr.grpnum
;   print,"done, retstat: ",done,retstat
;
;      -- is rec read beyond current rec??
;
                            endif else begin
                                if (hdr.grpnum ge rec) and (rec ne 0) then begin
;
;         -- for scan 0 requests, donot rewind
;
                                    if (firsttime and (scan ne 0)) then begin
                                        rewind=1
                                    endif else begin
;   print,"req:",scan,rec,"found increasing rec",hdr.scanNumber,hdr.grpnum
                                        retstat=0
                                        done=1
                                    endelse
                                endif
                            endelse
                        end
                    endcase
                end
        endcase
        firsttime=0
        irec=irec+1
;       print,stat,hdr.scanNumber,hdr.grpnum,hdr.grpCurRec,hdr.reclen,hdr.hdrlen
        if (done eq 0) then begin
            if (rewind eq 1) then begin
                point_lun,lun,0
                rewind=0
            endif else begin
               point_lun,lun,poshdrstart+hdr.reclen
            endelse
        endif
    endwhile
    on_ioerror,NULL
;
;   if gotit, pos to start of header, else back to initial entry point
;
    if ( retstat eq 1) then begin
        point_lun,lun,poshdrstart
        if n_elements(retstdhdr) gt 0 then begin
            if swapLast then begin
;
;               unswap to original order then swap everything
;
                hdr.grpnum    =swap_endian(hdr.grpnum)
                hdr.grpCurRec =swap_endian(hdr.grpCurRec)
                hdr.scanNumber=swap_endian(hdr.scanNumber)
                hdr.reclen    =swap_endian(hdr.reclen)
                retstdhdr=swap_endian(hdr)
            endif else begin
                retstdhdr=hdr
            endelse
        endif
    endif else begin
        point_lun,lun,startpos
    endelse
    return,retstat
end
