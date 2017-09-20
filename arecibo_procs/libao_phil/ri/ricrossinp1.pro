;+
;NAME:
;ricrossinp1 - get 1 strip of a cross pattern
;SYNTAX: istat=ricrossinp1(lun,b)
;ARGS:   lun : long lun to read from
;        b.{ }: structure from the cross pattern (either az or za strip)
;        b.d[npts,2]  - the data polA,b
;DESCRIPTION:
;   This routine is call by ricrossinp to input a single strip of the
;ricross pattern.
;-
function ricrossinp1,lun,b
;
    rec=0
    while (1) do begin
        istat=riget(lun,b1)
        if (istat ne 1) then return,0
        if rec eq 0 then begin
            nrecs=b1.h.proc.iar[7]
            npts =b1.h.proc.iar[3]
            pntsrec=npts/nrecs
            b={h:replicate({hdr},nrecs),d:fltarr(npts,2,/nozero)}
            curp=0
        endif
        b.h[rec]=b1.h
        b.d[curp:curp+pntsrec-1,0]=b1.d1[0,*]
        b.d[curp:curp+pntsrec-1,1]=b1.d1[1,*]
        curp=curp+pntsrec
        rec=rec+1
        if rec ge nrecs then goto,done
    endwhile

done:
    return,1
end
