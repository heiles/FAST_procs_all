;+
;NAME:
;pdevgettmd - read pdev timedomain data
;SYNTAX: istat=pdevgettmd(desc,smpToRead,b,smpPos=smpPos,posInfo=posinfo)
;ARGS:
;    desc: {} returned by pdevopen
; smpToRead: long samples to read
;KEYWORDS: 
;   smpPos: long sample offset from start of file start read. def: current pos
;               count from 1. <=0 --> current position
;posInfo:{}     The user generates this structure by calling pdevpostmdinfo().
;               This structure will let pdevgettmd() read across files in 
;               multiple file sets. Without this struct, the routine
;               will not read beyond the end of file of the current file.
;RETURNS:
;     n: n  number of samples recovered
;      : 0 hit eof this file
;          if posInfo is supplied,it will read till the end of a multi file set.
;      : -1 some type of i/o error or bad data found.
;b     : complex return data here in struct
;DESCRIPTION:
;	Read pdev time domain data. It returns the number of samples read.
;You can position in the file before reading using smpPos= keyword.
;(Note that positioning will not yet allow you to move to the next file).
;the posinfo= keyword will let you read across files of multiple file sets.
;Warning: for the multi set read to not drop any datasamples, the files 
;must be a multiple of the native datatype..This means that files with 16 bit
;samples must have a file length that is even.).
;
;-
function    pdevgettmd,desc,smpToRead,b,smpPos=smpPos,posInfo=posInfo
;
;   optionally position to start of rec
;
	gotPosInfo=n_elements(posInfo) gt 0 
    on_ioerror,ioerr1
	npol=((desc.hsp.hrlpf and 4) ne 0)?2:1
    bits= 2^(desc.hsp.hrlpf and 3)*2  ; 4,8,16 bits
	bytesSmp=(bits*2L)*npol/8
    type1=(bits eq 16)?2:1   ; 4 bit get read into byte also..
    point_lun,-desc.lun,curpos1 
    if (n_elements(smpPos) eq 0) and (desc.curRecpos lt 1) then smpPos=0
    if keyword_set(smpPos) then begin
        bytepos=(smpPos-1ul)*bytesSmp + desc.hdrOffB
;        print,'startpos:',bytepos
        point_lun,desc.lun,bytepos
        desc.curRecPos=bytePos
        point_lun,-desc.lun,curpos1
    endif
;
;   read the data
;
	itemp=(bits eq 4)?npol:npol*2
    inprec=make_array(itemp,smpToRead,type=type1)
	ndataTypeToRead1=itemp*smpToRead
	readOk=0
   	readu,desc.lun,inprec,transfer_count=readCnt1
	readOk=1
ioerr1: 
    point_lun,-desc.lun,curpos2
	if readCnt1 lt ndataTypeToRead1 then begin
   		on_ioerror,NULL
		; not readok --> 0 bytes read..
		if not readOk  then begin
    		hiteof=eof(desc.lun)
    		if ( not hiteof ) then begin
				; position  back to start of read
    			point_lun,desc.lun,curpos
           	 	print, !ERR_STRING
            	return,-1
        	endif 
		endif
		;if we hit eof in middle of a read, readcnt1 comes back as 0 rather than
		; bytes read. just use disc pos to compute positions
		readCnt1=curPos2 - curPos1	
		; if multiple file scan, try to read the next file to fill the rec

		if (gotposInfo) then begin
			curFileNum=desc.fnmi.num
			lastNum   =posInfo.fnmi1.num + posInfo.nfiles-1
			; try to open read, next file
			if curFileNum lt lastNum then begin
			    ; start of file number.
				fbaseNew=desc.fnmI.fname
			    ii=strpos(fbaseNew,".pdev",/reverse_s) - 5
				strput,fbasenew,string(format='(i05)',curFileNum +1),ii
				istat=pdevopen(desc.fnmi.dir + fbaseNew,desc)
				if istat ne 0 then begin
					print,"Could not open next file in scan set:",fbasenew
					return,-1
				endif
				point_lun,-desc.lun,curpos
			    ; figure out the number of data type we have left to read
			    ; readcnt has units of datatype, not bytes or smples
				; make buffer to hold this. can't read into subarray
				ndataTypeToRead2=ndataTypeToRead1 - readCnt1
				temprec=make_array(ndataTypeToRead2,type=type1)
    			on_ioerror,ioerr2
				readOk=0
   				readu,desc.lun,temprec,transfer_count=readCnt2
			    readOk=1
ioerr2: 
   				on_ioerror,NULL
				; not readok --> 0 bytes read..
				; if we hit eof, just use the bytes from the first read
				if not readOk  then begin
    				hiteof=eof(desc.lun)
    				if ( not hiteof ) then begin
					; position  back to start of read
    						point_lun,desc.lun,curpos
           	 				print, !ERR_STRING
            				return,-1
					endif
				endif
				; now just append to samples to end of the rec
				if readCnt2 gt 0 then begin
					inprec=reform(inprec,ndataTypeToRead1)
					inprec[readCnt1:readCnt1+readCnt2-1L]=tempRec[0L:readCnt2-1L]
					readCnt1=readCnt1+readCnt2
					inprec=reform(inprec,itemp,smpToRead)
				endif
			endif  ; curfilenum ne lastfilenum  
		endif      ; gotposinfo
	endif          ;readcnt1 = ndatatypetoread1
	if readcnt1 eq 0 then return,0
    point_lun,-desc.lun,curpos
    desc.curRecPos=curPos
	smpRead=(bits eq 4)?readCnt1/npol:readCnt1/(npol*2L)
	if smpRead eq 0 then return,0
	if smpToRead gt smpRead then inpRec=inprec[*,0:smpRead-1]
;
;   create struct to return
;
        b={$
        nsbc  : desc.nsbc,$
        nchan : smpRead,$ 
        beam  : 0             ,$ beam 0..6
     subband  : 0             ,$ 0 low,1 high
     chanWidth: 0.            ,$ channel width Mhz
       integTm: 0.            ,$ actual integration, not wall time.
        h     : {pdev_hdrdump},$ this has no data...
        d     : complexarr(smpread,npol)}
     case desc.bits of
            16: begin
                if (npol eq 2) then begin
                    b.d[*,0]=complex(inprec[0,*],inprec[1,*])
                    b.d[*,1]=complex(inprec[2,*],inprec[3,*])
                endif else begin
                    b.d=complex(inprec[0,*],inprec[1,*])
                endelse 
                end
             8: begin
                if (npol eq 2) then begin
                    b.d[*,0]=complex(inprec[0,*],inprec[1,*])
                    b.d[*,1]=complex(inprec[2,*],inprec[3,*])
                endif else begin
                    b.d=complex(inprec[0,*],inprec[1,*])
                endelse 
;
;               8 bit is unsigned, get back the negative numbers
;
                ii=where( float(b.d) gt 127.,cnt)
                if cnt gt 0  then b.d[ii] = complex(float(b.d[ii])-256.,imaginary(b.d[ii]))
                ii=where( imaginary(b.d) gt 127.,cnt)
                if cnt gt 0  then b.d[ii] = complex(float(b.d[ii]),imaginary(b.d[ii])-256)
                b.d+=complex(.5,.5)     ; get rid of .5 offset from 2's compl
                end
; left off here.. need to parse the 4 bits.
; We need to split the 8 bits  into 2 4 bits and then restore the neg numbers.
             4: begin
                if (npol eq 2) then begin
                    b.d[*,0]=complex((ishft(inprec[0,*],-4) and 15B ),$
                                           (inprec[0,*]    and 15B) ) 
                    b.d[*,1]=complex((ishft(inprec[1,*],-4) and 15B ),$
                                           (inprec[1,*]    and 15B  ))
                endif else begin
                    b.d=complex(ishft(inprec,-4) and 15B  ,$
                                      inprec and 15B   )
                endelse
;
;               put back neg numbers
;
                 ii=where( float(b.d) gt 7.,cnt)
                if cnt gt 0  then b.d[ii] = complex(float(b.d[ii])-16.,imaginary(b.d[ii]))
                ii=where( imaginary(b.d) gt 7.,cnt)
                if cnt gt 0  then b.d[ii] = complex(float(b.d[ii]),imaginary(b.d[ii])-16)
;               30oct13.. don't need this
;;                b.d+=complex(.5,.5)     ; get rid of .5 offset from 2's compl
                end
     endcase
;
    b.beam=desc.hdev.beam
    b.subband=desc.hdev.subband
    b.chanWidth= 1.     ; in the time domain
    b.integTm  = (1./(desc.hdev.adcclk)) * desc.hsp.hrdec ; sample rate
    return,smpRead
end
