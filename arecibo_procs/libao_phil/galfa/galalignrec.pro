; +NODOCUMENT
;NAME:
;galalignrec - align the row to the start of a record
;
;SYNTAX: istat=galalignrec(desc,aligndown=aligndown,recInd=recInd)
;
;ARGS: 
;   desc:{galdesc} gal descriptor returned from galopen()
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
function galalignrec,desc,aligndown=aligndown,recInd=recInd
;
;   map the curpos row ptr (0 based) in the scan, rec we are about to read
;
    curPosStart=desc.curpos
;
; find out which scan we are on.
;
    if  curPosStart ge desc.totrows then return,0   ; eof..
;
    irecAr=where(curPosStart  ge desc.recStartrow,count)
    if count eq 0 then return,-1
    recInd=irecAr[count-1]
    if desc.recstartRow[recInd] eq curPosStart then return,1
;
;    not  aligned, fix it..
;
     recInd=(keyword_set(aligndown))? recInd $
                                       :(recInd+1)
         
     desc.curpos=desc.recStartRow[recInd]
     return,1
end
