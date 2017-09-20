;+
;NAME:
;pdevget - read in a pdev record
;SYNTAX: istat=pdevget(desc,d,rec=rec)
;ARGS:
;    desc: {} returned by pdevopen
;KEYWORDS: 
;     rec: long record to position to before reading.
;RETURNS:
;     istat: 1 got entire record
;          : 0 hit eof this file
;          : -1 some type of i/o error or bad data found.
;
;-
function    pdevget,desc,b,rec=rec ,inprec=inprec
;
;   optionally position to start of rec
;
    on_ioerror,ioerr
	ateofStart=eof(desc.lun)
    dobrev=desc.nobitrev eq 0
    if (n_elements(rec) eq 0) and (desc.curRecpos lt 1) then rec=1
    if (not ateofStart) then point_lun,-desc.lun,curpos
    if keyword_set(rec) then begin
        bytepos=(rec-1UL)*desc.recLenB + desc.hdrOffB
;        print,'startpos:',bytepos
        point_lun,desc.lun,bytepos
        desc.curRecPos=rec
        point_lun,-desc.lun,curpos
    endif
;
;   read the data
;
    inprec=desc.inprec
    readu,desc.lun,inprec
    desc.curRecPos++
;
;   create struct to return
;
    if (not desc.tmd) then begin
        b={$
        nsbc  : desc.nsbc,$
        nchan : desc.nchan,$ 
        beam  : 0             ,$ beam 0..6
     subband  : 0             ,$ 0 low,1 high
     chanWidth: 0.            ,$ channel width Mhz
       integTm: 0.            ,$ actual integration, not wall time.
        h     : {pdev_hdrdump},$
        d     : fltarr(desc.nchan,desc.nsbc)}    
;
;  move input data to float array.
;
        if (dobrev) then ii=desc.bitRevTbl
    case b.nsbc of
      1 : b.d=(dobrev)?inprec.datU[ii]:inprec.datU
      2 : begin
          b.d[*,0]=(dobrev)?inprec.datU[0,ii]: inprec.datU[0,*]
          b.d[*,1]=(dobrev)?inprec.datU[1,ii]: inprec.datU[1,*]
          end
      4 : case desc.hsp.fmtwidth of 
             0: begin 
                b.d[*,0]=(dobrev)?inprec.dat[ii].s0s1[0]:inprec.dat.s0s1[0]
                b.d[*,1]=(dobrev)?inprec.dat[ii].s0s1[1]:inprec.dat.s0s1[1]
; 
;  -->ERROR .. FIX<--  next 2 need to be converted from 
;                      unsigned to signed char before conversion
;                    (idl does not have unsigned char.. use bit
;                     manipulations).
                b.d[*,2]=(dobrev)?inprec.dat[ii].s2s3[0]:inprec.dat.s2s3[0]
                b.d[*,3]=(dobrev)?inprec.dat[ii].s2s3[1]:inprec.dat.s2s3[1]
               end
             1: begin 
                b.d[*,0]=(dobrev)?inprec.dat[ii].s0s1[0]:inprec.dat.s0s1[0]
                b.d[*,1]=(dobrev)?inprec.dat[ii].s0s1[1]:inprec.dat.s0s1[1]
                b.d[*,2]=(dobrev)?inprec.dat[ii].s2s3[0]:inprec.dat.s2s3[0]
                b.d[*,3]=(dobrev)?inprec.dat[ii].s2s2[1]:inprec.dat.s2s3[1]
               end
           else: begin
                b.d[*,0]=(dobrev)?inprec.datU[0,ii]:inprec.datU[0,*]
                b.d[*,1]=(dobrev)?inprec.datU[1,ii]:inprec.datU[1,*]
                b.d[*,2]=(dobrev)?inprec.datS[0,ii]:inprec.datS[0,*]
                b.d[*,3]=(dobrev)?inprec.datS[1,ii]:inprec.datS[1,*]
               end
           endcase
       endcase

;
;   fix up the record header if it is the old pdev without bit  rev.
;   or time domain..
;
    	h=inprec.h
    	if (desc.psrvphil eq 0) then begin

   			if (desc.hdev.byteswapcode and 1) eq 0 then begin
        		t = h[0] & h[0] = h[1]& h[1] = t;
        		t = h[2] & h[2] = h[3]& h[3] = t;
        		t = h[4] & h[4] = h[5]& h[5] = t;
        		t = h[6] & h[6] = h[7]& h[7] = t;
   		 	endif
    	if  (desc.hdev.byteswapcode and 2) eq 0 then begin
        	t = h[0] & h[0] = h[2]& h[2] = t;
        	t = h[1] & h[1] = h[3]& h[3] = t;
        	t = h[4] & h[4] = h[6]& h[6] = t;
        	t = h[5] & h[5] = h[7]& h[7] = t;
    	endif
    	if  (desc.hdev.byteswapcode and 4) eq 0 then begin
        	t = h[0]& h[0] = h[4]& h[4] = t
        	t = h[1]& h[1] = h[5]& h[5] = t
        	t = h[2]& h[2] = h[6]& h[6] = t
        	t = h[3]& h[3] = h[7]& h[7] = t
    	endif
    	endif
;
;   now move the record header bits into the structure.
;
;    print,'h after',h,format='(a,8z3)'
    	b.h.seqnum  =(ishft(h[1]*1,8)) or (h[0]*1)
    	b.h.fftaccum=(ishft(h[3]*1,8)) or (h[2]*1)
    	b.h.calOn   =h[4] and 1
    	b.h.adcOverflow = ishft(h[4],-4) and 15
    	b.h.pfbOverflow   = h[5] and 15
    	b.h.satCntVShift  = ishft(h[5],-4) and 15
    	b.h.satCntAccS2S3 = h[6] and 15
    	b.h.satCntAccS0S1 = ishft(h[6],-4) and 15
    	b.h.satCntAshftS2S3 = h[7] and 15
    	b.h.satCntAshftS0S1 = ishft(h[7],-4) and 15
    endif else begin
;
; time domain
;
        b={$
        nsbc  : desc.nsbc,$
        nchan : desc.nchan,$ 
        beam  : 0             ,$ beam 0..6
     subband  : 0             ,$ 0 low,1 high
     chanWidth: 0.            ,$ channel width Mhz
       integTm: 0.            ,$ actual integration, not wall time.
        h     : {pdev_hdrdump},$ this has no data...
        d     : complexarr(desc.nchan,desc.nsbc)}
		byteSwapCode=desc.hdev.byteswapcode
        case desc.bits of
            16: begin
                if (desc.nsbc eq 2) then begin
					; bug prior to 20sep11 should be byteswap 1
				    if byteswapcode eq 3 then begin
                   	 	b.d[*,0]=complex(inprec.datU[1,*],inprec.datU[0,*])
                    	b.d[*,1]=complex(inprec.datU[3,*],inprec.datU[2,*])
					endif else begin
                    	b.d[*,0]=complex(inprec.datU[0,*],inprec.datU[1,*])
                    	b.d[*,1]=complex(inprec.datU[2,*],inprec.datU[3,*])
					endelse
                endif else begin
				    if byteswapcode eq 3 then begin
                    	b.d=complex(inprec.datU[1,*],inprec.datU[0,*])
					endif else begin
                    	b.d=complex(inprec.datU[0,*],inprec.datU[1,*])
					endelse
                endelse 
                end
             8: begin
                if (desc.nsbc eq 2) then begin
				    if byteswapcode eq 3 then begin
                    	b.d[*,1]=complex(inprec.datU[1,*],inprec.datU[0,*])
                   	    b.d[*,0]=complex(inprec.datU[3,*],inprec.datU[2,*])
					endif else begin
                    	b.d[*,0]=complex(inprec.datU[0,*],inprec.datU[1,*])
                   	    b.d[*,1]=complex(inprec.datU[2,*],inprec.datU[3,*])
					endelse
                endif else begin
				    if byteswapcode eq 3 then begin
                    	b.d=complex(inprec.datU[1,*],inprec.datU[0,*])
                    	ii=lindgen(descc.nchan/2)*2
						temp=b.d[ii]
						b.d[ii]=b.d[ii+1]
						b.d[ii+1]=temp
					endif else begin
                    	b.d=complex(inprec.datU[0,*],inprec.datU[1,*])
					endelse
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
                if (desc.nsbc eq 2) then begin
                    b.d[*,0]=complex((ishft(inprec.datU[0,*],-4) and 15B ),$
                                           (inprec.datU[0,*]    and 15B) ) 
                    b.d[*,1]=complex((ishft(inprec.datU[1,*],-4) and 15B ),$
                                           (inprec.datU[1,*]    and 15B  ))
                endif else begin
                    b.d=complex(ishft(inprec.datU,-4) and 15B  ,$
                                      inprec.datU and 15B   )
                endelse
;
;               put back neg numbers
;
                 ii=where( float(b.d) gt 7.,cnt)
                if cnt gt 0  then b.d[ii] = complex(float(b.d[ii])-16.,imaginary(b.d[ii]))
                ii=where( imaginary(b.d) gt 7.,cnt)
                if cnt gt 0  then b.d[ii] = complex(float(b.d[ii]),imaginary(b.d[ii])-16)
                b.d+=complex(.5,.5)     ; get rid of .5 offset from 2's compl
                end
             endcase

    endelse
;
    b.beam=desc.hdev.beam
    b.subband=desc.hdev.subband
    if (desc.tmd eq 0) then begin  ; spectra  
        scale=(desc.hsp.hrmode)?1.*desc.hsp.hrdec:1.
        b.chanWidth= (1.*desc.hdev.adcclk)/(desc.hsp.fftlen*scale)
        b.integTm = 1./(desc.hdev.adcclk) *desc.hsp.fftlen * b.h.fftAccum*scale
    endif else begin
        b.chanWidth= 1.     ; in the time domain
        b.integTm  = (1./(desc.hdev.adcclk)) * desc.hsp.hrdec ; sample rate
    endelse
    return,1
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
