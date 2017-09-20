;+
;NAME:
;pdevpostmd - position a tmd file
;SYNTAX: curPos=pdevpostmd(desc,smpPos)
;ARGS:
;    desc: {}   returned by pdevopen
; smpPos: long  sample to position to
;               count from 1. if < 1 then return
;               the current sample position
;               count from 1. <=0 --> current position
;RETURNS:
;  curPos: long current sample postion (after positioning)
;DESCRIPTION:
;	Position timedomain file so the next read will read
;sample number smpPos (counting from 1).
;If the position is beyond the end of the file, position at the
;end. If smpPos=0 then return the sample we are about to read
;(count from 1).
;-
function    pdevpostmd,desc,smpPos
;
;   optionally position to start of rec
;
	npol=((desc.hsp.hrlpf and 4) ne 0)?2:1
    bits= 2^(desc.hsp.hrlpf and 3)*2  ; 4,8,16 bits
	bytesSmp=(bits*2L)*npol/8
	; current bytepos
    point_lun,-desc.lun,curpos
	; just return smppos we are about to read
	if (smpPos eq 0) then begin 
		return,(curpos-desc.hdrOffB)/bytesSmp  + 1l
	endif
    bytepos=(smpPos-1ul)*bytesSmp + desc.hdrOffB
    point_lun,desc.lun,bytepos
    desc.curRecPos=bytePos
	return,smpPos
end
