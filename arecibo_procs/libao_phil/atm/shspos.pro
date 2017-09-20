;+
;NAME:
;shspos - position to a record in the shs file
;SYNTAX: istat=shspos(desc,rec,currec=currec,nextrec=nextrec)
;ARGS:
;   desc:{}     structure returned by shsopen().
;    rec: long  record to position to (count from 0)
;KEYWORDS:
;   currec:     if set then reposition to start of current rec
;   nextrec:    if set then position to next record.
;RETURNS:
;   istat:  1   - positioned ok.
;           0   - beyond end of file
;          -1   - error positioning
;
;DESCRIPTION:
;   Position to a record in an shs file. This uses the record length
;from the first record of the file.
;-
function shspos,desc,rec,currec=currec,nextrec=nextrec
;
;
; comes out neg if we go over 2^31-1
;
    case 1 of 
    
    keyword_set(currec): begin
                    point_lun,-desc.lun,curpos
                    recl=(curpos-desc.tblSt)/desc.tblLen
                    end
    keyword_set(nextrec): begin
                    point_lun,-desc.lun,curpos
                    recl=(curpos-desc.tblSt)/desc.tblLen + 1L
                    end
    else               : recl=(rec lt 0L)?0L:long(rec)
    endcase
    reqpos=(recL)* desc.tbllen + desc.tblSt
    if (reqpos ge desc.filesize) or (reqpos lt 0L)  then begin
        return,0
    endif
    point_lun,desc.lun,reqpos
    return,1
end
