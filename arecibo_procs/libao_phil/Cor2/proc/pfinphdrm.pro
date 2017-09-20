;+
;pfinphdrm - input many  headers from a file
;SYNTAX: istat=pfinphdrm(lun,nrecs,hdrs)
;ARGS:
;		lun    :string filename to process
;		nrecs  :long   number of grps (integrations) to return (max)
;	    hdrs[] : {pfmhdr} return header here
;      istat   : number of headers in hdrs[] returned
;
;DESCRIPTION:
;  Read multiple headers from the current position in the file into the
;array of structures hdrs[]. Each integration or group can have 1 to 4 
;headers corresponding to the 1 to 4 correlator boards that can be used.
;
;The hdrs[] will have 1 board header per entry. An integration
;with 4 boards would then fill 4 locations in hdrs[]. 
;The structure hdrs contains:
; hdrs.h  	   the header
; hdrs.offset  the byte offset in file to position when doing corget.
;			   This is the location of the 1st board of the group.
; hdrs.brd     The board number for this header 0..3
; hdrs.nbrds   The number of boards used this integration
;
;
function pfinphdrm,lun,nrecs,hdrs
;
	maxhdrs=nrecs*4L
	hdrs=replicate({pfmhdr},maxhdrs)
	ih=0L
	for i=0L,nrecs-1 do begin
	    point_lun,-lun,curpos
		if corgethdr(lun,newhdr) lt 1 then goto,done
		nbrds=(size(newhdr))[1]
		for j=0,nbrds-1 do begin
			hdrs[ih].h     =newhdr[j]
			hdrs[ih].offset=curpos
			hdrs[ih].brd   =j
			hdrs[ih].nbrds =nbrds
			ih=ih+1
		endfor
	endfor
done:
	if (ih eq 0)     then hdrs='' else $ 
	if ih ne maxhdrs then hdrs=temporary(hdrs[0:ih-1])
	return,ih
end
