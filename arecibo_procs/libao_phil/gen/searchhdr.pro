;+
;NAME:
;searchhdr - position to the next available hdr in the file.
;SYNTAX: istat=searchhdr(lun,maxlen=maxlen)
;ARGS:
;       lun: int   lun of file to search
;KEYWORDS:
;   maxlen: long    maximum number of bytes to read. default is
;                   1megabyte
;RETURNS:
;      istat: int 1 --> positioned to header, 0 no header found
;DESCRIPTION
;   Position to the next available hdr in an AO data file. Search up to
;maxlen bytes before quitting. If the header is not found, return positioned
;at the input position.
;-
;
function searchhdr,lun,maxlen=maxlen

    point_lun,-lun,startPos
    len=65536L
    if n_elements(maxlen) eq 0  then maxlen=len*16L
    maxread=maxlen/len
    if maxread eq 0 then begin
        maxread=1
        len=maxlen
    endif
    bmatch=byte('hdr_')
    inbuf=bytarr(len)
    offset=-1L
    on_ioerror,readerr
    firsttime=1
    for i=0,maxread-1 do begin
        inbuf=inbuf xor inbuf
        point_lun,-lun,curpos
;
;   overlap
;
        if startpos ne curpos then begin
            curpos=curpos-3
            point_lun,lun,curpos
        endif
        ioOk=0
        readu,lun,inbuf
        iook=1
;
;   in case partial rec
;
readerr:
        ind1=where(inbuf eq bmatch[0],count1)
        if count1 gt 0 then begin
            ind2=where(inbuf[ind1 +1]  eq bmatch[1],count2) 
            if count2 gt 0 then begin
                ind3=where(inbuf[ind1[ind2] + 2] eq bmatch[2],count3)
                if count3 gt 0 then begin
                   ind4=where(inbuf[ind1[ind2[ind3]] + 3] eq bmatch[3],count4) 
                   if count4 gt 0 then begin
                      offset=ind1[ind2[ind3[ind4[0]]]]
                      goto,botloop
                   endif
                endif
            endif
        endif
        if iook eq 0 then goto,botloop
    endfor
botloop:
    if offset gt -1 then begin
        point_lun,lun,curpos+offset
        return,1
    endif else begin
        point_lun,lun,startpos
        return,0
    endelse
end
