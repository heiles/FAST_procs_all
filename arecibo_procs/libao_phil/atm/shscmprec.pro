;+
;NAME:
;shscmprec - compute current record position
;SYNTAX: currec=shscmprec(desc)
;RETURNS:
;   currentrec: long  current record we are about to read. 
;                     count from 0
;
;DESCRIPTION:
;   Compute the record we are about to read. count from
;0. If we are in the middle of a record, return the current record
;(removing the fractional part
;from the first record of the file.
;-
function shscmprec,desc
;
;
; comes out neg if we go over 2^31-1
;
    point_lun,-desc.lun,curpos
    return,(curpos-desc.tblSt)/desc.tblLen
end
