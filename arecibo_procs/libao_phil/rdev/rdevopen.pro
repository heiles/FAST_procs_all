;+
;NAME:
;rdevopen - open a pdev radar data file
;SYNTAX: istat=rdevopen(filename,desc,descprev=descprev,filenum=filenum)
;
;ARGS:
;filename: string file to open
;
;KEYWORDS:
;descprev: {}	descriptor from previous file
;fileNum : long if supplied then this is Nth file of a 
;               multi file sequence.
;               The first file that contains the header should be 0.
;               NOTE - This is not the filenumber in the file. It just
;               counts 0..N-1 . 
;               eq. Suppose you have a multi file sequence with the
;               header file having filenum: 00200.pdev
;               To access the 2nd file (00201) you would set
;               filenum=1 (since we count from 0);
;               filenum of a sequence (count from 0).
;RETURNS:
; istat: int  1 open ok, 0 error
; desc: {}   holds open info
;
;DESCRIPTION:
;   Open a radar file and read the header. After returning from this routine
;you are positioned to read the first data same (with rdevget()).
;
;NOTE: descprev:
;To read an 2..n file of a multi file sequence:
;1. pass descprev=desc where desc is the descriptor for the
;   current file open (do not close it).
;2. The routine will close it and compute the sample offset for the
;   start of the new file.
;3. If the open is successful the previous descriptor will be closed.
;-
function    rdevopen,file,desc,descprev=descPrev,filenum=filenum
;
   common rdevcom,rdevnluns,rdevlunar

;   
	err=0
	BytesSmp=4L
    openr,lun,file,/get_lun,err=err
	if err ne 0 then begin
		printf,-2,!error_state.msg
	    return,0
	endif 
	if n_elements(descPrev) eq 0 then begin
		h={rdev_hdr}
		lenh=n_tags(h,/len)
    	readu,lun,h
		point_lun,lun,1024
		desc={ lun: lun ,$
		   filename: file,$
		    h1:  h.h1,$
			h2:  h.h2,$
		tuner   : 0L, $ for mixing 
	    txSmpIpp: 0L, $ tx Samples/ipp
	     dSmpIpp: 0L, $  data Samples/ipp
	     nSmpIpp: 0L, $  noise Samples/ipp
	     dOffSmp: 0L, $ data  offset samples from start of ipp
     noiseOffSmp: 0L, $ noise  offset samples from start of ipp
	  smpOffStFile: 0D,$; Sample offset start this file. count from 0
	 smpInFile: 0L,$; Sample in this file
  smpIn1stFile: 0L $; Sample in first file
		}
;
;	move unsigned ints to long
;
		desc.tuner   =desc.h2.tunerU*2L^16   + desc.h2.tunerL
		desc.txSmpIpp=desc.h2.d1cntU*2L^16   + desc.h2.d1cntL
		desc.dSmpIpp =desc.h2.d2cntU*2L^16   + desc.h2.d2cntL
		desc.nSmpIpp =desc.h2.d3cntU*2L^16   + desc.h2.d3cntL
; 
;		desc.dOffSmp =desc.h2.s2cntU*(2L^16) + desc.h2.s2cntL + $
;				desc.txSmpIpp
;       // 19oct09 image data offset from the rf pulse
		desc.dOffSmp =desc.h2.s2cntU*(2L^16) + desc.h2.s2cntL 
		desc.noiseOffSmp =desc.h2.s3cntU*(2L^16) + desc.h2.s3cntL
	    fs=fstat(desc.lun)
		desc.smpOffStFile=0L
		desc.smpInFile=(fs.size - 1024)/bytesSmp
		desc.smpIn1stFile=desc.smpInFile
	endif else begin
		rdevclose,descprev
		desc=descPrev
		desc.lun=lun
	    desc.filename=file
	    fs=fstat(desc.lun)
        desc.smpInFile=(fs.size)/bytesSmp
		if (n_elements(filenum) gt 0) then begin
;           assume all files but the first have the same number of files
;           will fail for last file??
;
			desc.smpOffStFile= desc.smpIn1stFile + $
					(desc.smpIn1stFile+1024/bytesSmp)*(fileNum-1D)
		endif else begin
			desc.smpOffStFile= descprev.smpOffStFile + descprev.smpInFile
		endelse
	endelse
;
;	figure out size of this file
;
	if (fs.size mod 2)  ne 0 then begin
		print,"Warning: file size not a multiple of 2. 1/2 sample dropped"
	endif

    ind=where(rdevlunar eq 0,count)
    if count gt 0 then begin
        rdevlunar[ind[0]]=lun
        rdevnluns+=1
    endif
    return,1
end
