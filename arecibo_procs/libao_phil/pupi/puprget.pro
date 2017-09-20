;+
;NAME:
;puprget - read in a block of puppi raw data
;SYNTAX: blkNum=puprget(desc,d,blkreq=blkreq,nsmp=nsmp,npol=npol,nchan=nchan)
;ARGS:
;    desc: {} returned by pupropen
;KEYWORDS: 
;    blk: int   block number to input, count from 1 
;              -1 , or not present --> input next block
;RETURNS:
;     blkNum: >=1 block number we input. 
;             blkNum-1 is index into desc.hdrI[blkNum-1]
;             0 eof on input (no data)
;          : -1,-2,-3  some type of i/o error or bad data found.
;     nsmp:long   .. number of sample points per channel
;     npol:long   .. number of polsample points per channel
;     nchan:long   .. number of channels
;  d[nsmp,npol,nchan]:complex   data returned
;
;-
function    puprget,desc,d,blkreq=blkreq,nsmp=smpBlk,npol=npol,nchan=nchan 
;
;   optionally position to start of rec
;
    on_ioerror,ioerr
	ateofStart=eof(desc.lun)
    if (n_elements(blkreq) eq 0) then blk=desc.curIblk + 1 ; desc.curIblk counts from 0
	if blk gt desc.totblks then return,0
    if (not ateofStart) then point_lun,-desc.lun,curpos
;
;   position to start of data blk
;
	iblk=blk - 1
    bytepos=desc.hdrI[iblk].posSt + desc.hdrI[iblk].hdrBytes
;   print,'startpos:',bytepos
    point_lun,desc.lun,bytepos
;
;   generate buffer to hold the data
;
	npol=desc.hdrI[iblk].nrcvr
	if (desc.hdrI[iblk].only_i) then npol=1
	nchan=desc.hdrI[iblk].obsnchan
	blocSize=desc.hdrI[iblk].blocsize
	iq=2					; 2 bytes for i,q
	smpBlk=long(blocSize/(1D*nchan * npol*iq) + .5)

	inp=bytarr(2,npol,smpBlk,nchan)
    readu,desc.lun,inp
	desc.curIblk=iblk + 1
;
;	check the neg numbers (bytArr is unsigned)
;
	iiR=where(inp[0,*,*,*] gt 127,cntNegR) 
	iiI=where(inp[1,*,*,*] gt 127,cntNegI) 
;
; 	create the complex float data
;
	d=reform(complex(inp[0,*,*,*],inp[1,*,*,*]))
	if cntNegR gt 0 then begin
		fixR=complex(-256.,0.)
	    d[iiR]+=fixR
	endif
	if cntNegI gt 0 then begin
		fixI=complex(0.,-256.)
	    d[iiI]+=fixI
	endif
	return,blk
ioerr: 
	if (!error_state.name eq 'IDL_M_FILE_NOTOPEN') then begin
		print,!error_state.msg
		return,-1
	endif
    hiteof=eof(desc.lun)
    on_ioerror,NULL
    if (not ateofStart) then point_lun,desc.lun,curpos
    if ( not hiteof ) then begin
            print, !ERR_STRING
            return,-1
    endif else  return,0
end
