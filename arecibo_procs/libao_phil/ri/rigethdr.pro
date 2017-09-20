;+
;NAME:
;rigethdr - input an ri header
;SYNTAX: istat=rigethdr(lun,hdr,scan=scan,pos=pos)
;ARGS:   lun    : unit number for file (already opened)
;        hdr    : {hdr} return data here.
;KEYWORDS:
;       scan    : long . position to start of this scan before reading
;       pos     : int  . 1 - position to start of this header before returning
;RETURNS:
;        istat  : int
;           1 - gotit
;           0 - hit eof
;          -1 - could not position to requested scan
;          -2 -  bad data in hdr
;DESCRIPTION:
;   Read the next ri header and return it. Optionally position to the start
;of this header before returning. This routine is used to peak at the
;header to decide how to process the record before calling riget.
;
;   The caller should have already defined the {hdr} structure  before calling
;this routine (usually done in the xxriinit routine for the particular 
;datataking program). 
;-
function  rigethdr, lun, hdr,scan=scan,pos=pos
;
;   on_error,1
    hdr={hdr}
    on_ioerror,ioerr
    point_lun,-lun,curpos
    retstat=1
    if  keyword_set(scan)  then begin
        istat=posscan(lun,scan,1L)
        case istat of
            0: begin 
                print,$
                'rigethdr:position to:',scan,', but found increasing scannumber'
                retstat=-1
               end 
           -1: begin
                print,'rigethdr:position did not find scan:',scan
                retstat=-1
               end
         else: 
         endcase
    endif
    if retstat ne 1 then goto,done
    readu,lun,hdr
    swapdata= abs(hdr.ri.fifonum) gt 12
    if swapdata then hdr=swap_endian(hdr)
    if ( string(hdr.std.hdrMarker) ne 'hdr_' ) then begin
            print,'rigethdr;bad hdr. no hdrid:hdr_h,'
            retstat=-2
            goto,done
    endif
    if (hdr.ri.smpPairIpp gt 65536) then begin
    print,'riget: smpPairIpp > 65535'
        retstat=-2
        goto,done
    endif
    retstat=1
done:
    if keyword_set(pos) then point_lun,lun,curpos
    return,retstat
ioerr:
    hiteof=eof(lun)
    on_ioerror,NULL
    if (not hiteof) then begin
        message, !ERR_STRING, /NONAME, /IOERROR
     endif 
    retstat=0 
    goto,done
end
