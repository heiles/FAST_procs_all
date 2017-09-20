;+
;NAME:
;wasalignrec - align the row to the start of a record
;
;SYNTAX: istat=wasalignrec(desc,aligndown=aligndown,scanInd=scanInd,$
;                           recInd=recInd)
;
;ARGS: 
;   desc:{wasdesc} was descriptor returned from wasopen()
;
;KEYWORDS: 
;aligndown:  If the current pointer is in the middle of a 
;            record, the routine will round up to the next record. If the
;            aligndown keyword is set, then the routine will round down
;            to the closest record.
;
;RETURNS:
;   istat: int   1 ok, 0 eof, -1 error.
; scanInd: long  index into desc.scanI[] for the current position (0 based)
; recInd:  long  the record number within the current scan (0 based)
;
;DESCRIPTION:
;   The fits data is stored in a fits binary table by row. There are
;multiple rows for a single integration (rec). This routine will 
;guarantee that the next read position will be positioned at the
;start of a record.
;-
function wasalignrec,desc,aligndown=aligndown,scanInd=scanInd,recInd=recInd
;
;   map the curpos row ptr (0 based) in the scan, rec we are about to read
;
    if desc.totscans eq 0 then begin
        desc.curpos=0L
        scanInd=0L
        recInd=0L
        return,0
    endif
    curPosStart=desc.curpos
;
; find out which scan we are on.
;
    ii=desc.totscans-1
    while (1) do begin
        if  curPosStart ge desc.totrows then return,0   ; eof..
;
        iscan=where(curPosStart  ge desc.scanI[0:ii].rowStartInd,count)
        if count eq 0 then return,-1
        scanInd=iscan[count-1]
;
;   make sure we are lined up with a group
;
        rowsInRec=desc.scanI[scanInd].rowsinrec
        rowInScanInd=curPosStart-desc.scanI[scanInd].rowStartInd; count from 0
        recInd=rowInscanInd/rowsInRec
        if (recInd*rowsInRec eq rowInScanInd) then begin
            desc.curpos=curPosStart
            return,1
        endif
;
;    not  aligned, fix it..
;
        recInd=(keyword_set(aligndown))? recInd $
                                       :(recInd+1)
         
        curPosStart=desc.scanI[scanInd].rowStartInd + rowsInRec*recInd
        if curPosStart lt (desc.scanI[scanInd].rowStartInd + $ 
                           desc.scanI[scanInd].rowsInScan) then begin
            desc.curpos=curPosStart                 
            return,1
        endif
    endwhile
        
end
