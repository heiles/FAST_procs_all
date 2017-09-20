;+
;NAME:
;pupropen - open puppi raw file for reading
;SYNTAX: istat=pupropen(filename,desc,verb=verb)
;ARGS:
;   filename: string    filename to open
;KEYWORDS:
;   verb:     if set then print out header numbers we read them
;RETURNS:
;   istat: 1 ok
;           0 hit eof reading ascii header
;          -1 could not open file.
;          -2 no header info in file
;          -3 no END header card after 1000 cards
;   desc : {}  file descriptor to pass to the i/o routines.
;DESCRIPTION:
; 	open  an ao puppi raw file. It will scan the file to find
;the start of each block (with it's headers).
;
;-
function pupropen,filename,desc,hdr=hdr,verb=verb
;
;
   common puprcom,puprnluns,puprlunar

    errmsg=''
    lun=-1
    fileLoc=filename
	retStat=0 
	if n_elements(verb) eq 0 then verb=0

;;  open file. 

	err=0
    openr,lun,fileLoc,/get_lun,err=err
	if err ne 0 then begin
		print,"Error:",!ERROR_STATE.msg," opening:",fileLoc
		return,-1
	endif
;
;	get the filesize
;
	fst=fstat(lun)
	fileSize=fst.size	
;
; 	get the first header
;
	retStat=puprgethdr(lun,hdrI)
	if (retStat ne 1) then goto,errout
;
;	figure out how many blocks the file has
;
	totblklen=(hdrI.hdrBytes + hdrI.blocsize)
	nblocks=long(fileSize/(1D*totBlkLen) + .5)

;   add one more to grab partial blocks
	nblocks++
;
; 	 grab the rest of the blocks
;
	hdrAr=replicate(hdrI,nblocks)
	hdrAr[0]=hdrI
	icur=1L
	for iblk=1,nblocks-1 do begin
;
; 		position to start of this hdr
;
		curPos=hdrAr[iblk-1].posSt + hdrAr[iblk-1].hdrBytes + $
			   hdrAr[iblk-1].blocsize
		point_lun,lun,curPos
		retStat=puprgethdr(lun,hdrI)
		if verb then print,"hdrBlk:",iblk," puprgethdr stat:",retstat
		if (retStat ne 1) then begin
			if not verb then print,"hdrBlk:",iblk," puprgethdr stat:",retstat
		    break
		endif
		hdrAr[icur]=hdrI
;
;		see if file contains entire block.
;
		endBlk= hdrAr[icur].posSt + hdrAr[icur].hdrBytes + $
				hdrAr[icur].blocsize
		hdrAr[icur].partialDataBlk=(endBlk gt fileSize) 
		if (hdrAr[icur].partialDataBlk) then begin
			print,"data block:",iblk," only partially full"
		    icur++
			break;	
		endif
		icur++
	endfor
	nblocks=icur
	desc= { $
			lun:lun,$
			curpos:0LL,$
			curIblk:0L, $   	 ;blkIndex to read next. count from 0
			totBlks:nblocks,$
			fileSize:fileSize,$
			hdrI  : hdrAr[0:nblocks-1] }
;	
;    remember lun in case puprclose,/all
;
    ind=where(puprlunar eq 0,count)
    if count gt 0 then begin
        puprlunar[ind[0]]=lun
        puprnluns=puprnluns+1
    endif
	rew,desc.lun
	return,1
errout:
	if lun gt -1 then free_lun,lun
	return,retstat
end
