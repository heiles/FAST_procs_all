;+
;NAME:
;byuinpfile : input a file of byu voltage data
;SYNTAX: istat=byuinpfile(file,dipD,ichantoDip=ichantoDip,hdrAr=hdrAr)
;ARGS:
;file:	string	filename to read from
;KEYWORDS:
;useIchan:   if true then use ichantodip, if not, return default
;            mapping here.
;RETURNS:
; istat:	1 ok -1 error
;dipD[nsmp,nchan] float input data
;hdrAr:strarr(2,nkeys) holds keyorde followed by name.
;ichantodip: pass back can also pass it in if /useIchan is set.

;-
function byuinpfile,file,dipD,ichantodip=ichantodip,hdrAr=hdrAr,$
		useIchan=useIchan ,verb=verb
;
;
	lun=-1
	maxkeys=20
	atod1card=4
	bytesSmp=2L

	if not keyword_set(useIchan) then  begin
		chanToDipA=[17,18,19,20,5,6,7,8, 9,10,11,12, 13,14,15,16,1,2,3,4]
		chanToDipB=lindgen(20)+21
		ichanToDip=reform([chanTodipA,chantodipB],4,10)-1
	endif

    istat=file_exists(file,size=filesizeBytes) &$
    if istat eq 0 then begin
		print,"file:",file, " not accessible"
		return,-1
	endif
	openr,lun,file,/get_lun
;
; get the header
;
	inpline=''
	done=0
	hdrAr=strarr(2,maxkeys)
	i=0
;
	use40chan=0
	totChan=20
	numBlocks=0L
	blockSize=0L
	smps1AtoDBlk=0L
	smpRate=0.
	while (not done) do begin &$
    	readf,lun,inpline &$
    	a=strsplit(inpline,"=",/extract) &$
    	hdrAr[0,i]=a[0] &$
    	hdrAr[1,i]=a[1] &$
    	done=(strcmp(a[0],'Begin') eq 1)&$
   		 i+=1 &$
    	if a[0] eq 'FortyChannelSystem' then use40Chan=a[1] eq '1' &$
    	if a[0] eq 'num_blocks' then numBlocks=long(a[1]) &$
    	if a[0] eq 'ReadBlockSize' then smps1AtoDBlk=long(a[1]) &$
    	if a[0] eq 'sample_rate' then smpsRate=float(a[1]) &$
    endwhile
	nkeys=i
	hdrAr=hdrAr[*,0:nkeys-1]
	point_lun,-lun,curpos
	free_lun,lun
;
;	now get the binary data
;
	if use40Chan then begin &$
   		 numblocks*=2 &$     ; bug in header
    	numchan=40 &$
	endif
;
	openu,lun,file,/get_lun
	point_lun,lun,curpos
	chanD=fltarr(smps1atodblk,numblocks/(numChan/4),4,numChan/4)
	inpD =intarr(atod1card,smps1atodblk)
	for i=0,numblocks-1 do begin
    	readu,lun,inpD,transfer_count=shortsRead
    	if ( shortsRead ne (smps1AtoDBlk*4)) then begin
        	 print,"block:",i," readreq:",smps1AtoDblk*4," read:",shortsRead
			 goto,errout
    	endif
    	k=i mod (numChan/4) 
    	l=i/(numChan/4)  
		if keyword_set(verb) then begin
			print,"blkNum:",i," k,l:",k,l
		endif
    	chanD[*,l,*,k]=transpose(inpD) &$
	endfor
	free_lun,lun
	smps1dip=smps1atodblk*numblocks/(numchan/4)
	chanD=reform(chanD,smps1dip,40)
	return,smps1dip
errout:
	free_lun,lun
	return,-1
end
