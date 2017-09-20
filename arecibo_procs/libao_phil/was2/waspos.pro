;+
;NAME:
;waspos - position to a scan/record in a was fits file
;
; SYNTAX: istat=waspos(desc,scan,rec)
;
; ARGS:
;      desc:   {wasdesc} .. was descriptor
;      scan:    long.. scan number 0--> current scan or whateverr scan fits
;                      full scan number --> position to scan
;       rec:    long  grp number within scan.
;                     0 or not included--> next record available
;                               number --> record of current scan
; RETURNS: 1 positioned ok
;         -2 requested scan/rec not found
;
;DESCRIPTION:
;   Position to a scan/record in a was fits file. The algorithm is:
;
;1. position to start of scannumber. If scannumber is zero then remain
;   in current scan.
;2. if record is provided then position to record within current scan. If
;   record is not provided then position to next record in file.
;-
;history:
; 7jul00 - added skip keyword
;03dec00 - updated to new scanlist structure
;
function waspos ,desc,scan,rec
;   
    scan0=999999999L
    iscan=-1
;   on_error,1
;   on_ioerror,iolab
    if n_elements(scan) eq 0 then scan=0
    if n_elements(rec)  eq 0 then rec=1
    if (scan eq 0) then begin
        curPos=desc.curpos
        iscan=where(curPos  ge desc.scanI.rowStartInd,count)
        iscan=iscan[count-1]
        scan=desc.scanI[iscan].scan
    endif
    if iscan eq -1 then begin
        iscan=where(scan  eq desc.scanI.scan,count)
        if count eq 0 then return,-2
        iscan=iscan[0]
    endif
    inc=(rec-1)*desc.scanI[iscan].rowsInRec
    if inc ge desc.scanI[iscan].rowsInScan then begin
        print,'Scan,rec not found:',scan,rec
        return,-2
    endif
    desc.curpos=desc.scanI[iscan].rowStartInd+inc
    desc.scanind=iscan
    return,1
end
