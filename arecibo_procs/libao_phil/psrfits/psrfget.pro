;+ 
;NAME:
;psrfget - input next psrfits row from disc
;
;SYNTAX: istat=psrfget(des,b,row=row,hdronly=hdronly,blankcor=blankcor,avg=avg,$
;                          tp=tp)
;
;ARGS:
;    desc:{descpsrf}  from psrfopen();
;
;RETURNS:
;     b: structure holding the hdr and data input
;  tp[ndump,npol]: float  if tp provided (and averge set) then also
;                 return the total power for each time sample
; istat: 1 ok
;      : 0 hiteof
;      :-1 i/o error..bad hdr, etc..
;
;
;KEYWORDS:
;     row     : if set then position to row before reading (count from 1)
;               if row=0 then ignore row keyword
;     hdronly : if set then just return the row header. no status or data.
;    blankcor : if set then correct for any blanking.. the forces the
;               returned dataset to be floats
;       avg   : if set then average the spectra in 1 row before returning.
;               This forces the returned datatype to be float.  
;               this will automatically do the blankcor (since it normalizes
;               the sum to the total number of ffts accumulated * the 
;               integration period std value.
;
;DESCRIPTION:
;
;   Read the next row from a psrf fits datafile pointed to by desc.
;  If keyword row is present, position to row  before reading.
;-
;
function psrfget, desc,b,row=row,hdronly=hdronly,blankcor=blankcor ,avg=avg,$
				tp=tp
;
;
;
;;    on_error,2
    on_ioerror,ioerr
	useTp=(arg_present(tp) and (keyword_set(avg)))
;
;   see if we position before start
;
    curRowStart=desc.currow
    if keyword_set(row) then begin
        if (row gt desc.totrows) or (row lt 1) then begin
            lab=string(format=$
            '("illegal row requested:",i," valid is 1 to",i)',row,desc.totrows);
            print,lab
            return,-1
        endif
        point_lun,desc.lun,desc.bytesRow*(row-1LL) + desc.byteoffrec1
        desc.currow=row-1
    endif 
    if (desc.currow ge desc.totrows) then begin
            lab=string(format=$
            '("hit last row of fits file:",i)',desc.totrows);
;            print,lab
            return,-1
    endif
;
;   debug.. get the two descriptors
;
;;    point_lun,desc.lun,desc.currow*desc.bytesRow + $
;;              desc.byteoffrec1 
;;  ll=lonarr(4)
;;  readu,desc.lun,ll
;;  ll=swap_endian(ll)
;;  print,"descriptors:",ll
;
;   read the row in 1 shot
;
	data4bit=(desc.hsubint.nbits eq 4)?1:0
    point_lun,desc.lun,desc.currow*(desc.bytesRow*1LL) + $
                desc.byteoffrec1 
	b=desc.rowstr
    readu,desc.lun,b

;	4bit data is byte so it isn't swapped.

   	if desc.needswap then b=swap_endian(temporary(b))    
		
;
;	see if they want to average the spc of 1 row
;
	if keyword_set(avg) then begin
;
;		get the number of tags
;		
		tagNmAr=tag_names(b)
        ntags  =n_elements(tagNmAr)
		npol   =desc.hsubint.npol
		for i=0,ntags-1 do begin
			if i eq 0 then begin
				bf=create_struct(tagNmAr[i],b.(i))
			endif else begin
				if tagNmAr[i] ne "DATA" then begin
				   bf=create_struct(temporary(bf),tagNmAr[i],b.(i))
				endif else begin
					nchan=n_elements(b.dat_freq)
					if npol eq 1 then begin
				    	bf=create_struct(temporary(bf),tagNmAr[i],fltarr(nchan))
					endif else begin
				    	bf=create_struct(temporary(bf),tagNmAr[i],fltarr(nchan,npol))
				    endelse
				endelse
			endelse
		endfor
;
; 		now average
;	
		defAccum=uint(desc.hpdev.phfftacc)
		scl=defAccum/total(b.stat.fftaccum)
		ntmSmp=desc.hsubint.nsblk
       	npol=desc.hsubint.npol
		if useTp then begin
			tp=fltarr(ntmsmp,npol)
			sclN=1./ntmsmp
		    if (keyword_set(blankcor) or (data4bit)) then sclN=defAccum*sclN/b.stat.fftaccum
		endif
			
		if  data4bit then begin 
; 
			nsmpTot=n_elements(b.data)*2L
         	nchan=desc.hsubint.nchan
         	ntmSmp=desc.hsubint.nsblk
         	fbuf=fltarr(2L,nsmpTot/2)              ; unpack everyother sample
         	fbuf[0,*]=ishft(b.data,-4)
         	fbuf[1,*]=b.data and 'f'x
         	fbuf=reform(temporary(fbuf),nchan,npol*ntmSmp)
         	asize=size(fbuf)
         	vsize=size(bf.dat_offs)
;        dat= pack*scl + offset
            fbuf=mav(fbuf,b.dat_scl) + $
                 (b.dat_offs # make_array(asize[2],type=vsize[2],value=1))
			if npol eq 1 then begin
				bf.data=total(fbuf,2)*scl
				if useTp then tp=reform(total(fbuf,1)*sclN)
			endif else begin
				bf.data=total(fbuf,3)*scl
				if useTp then tp=transpose(reform((total(fbuf,1)*sclN)))
			endelse
		endif else begin
			if npol eq 1 then begin
				bf.data=total(b.data,2)*scl
				if useTp then tp=reform(total(b.data,1)*sclN)
			endif else begin
				bf.data=total(b.data,3)*scl
				if useTp then begin
					tp=transpose(reform(total(b.data,1)))
					tp[*,0]*=sclN
					tp[*,1]*=sclN
				endif
			endelse
		endelse
		b=temporary(bf)
	endif else begin 
;
;     if 4bit data, unpack,scale it
;
	  if (data4bit) then begin 
		 bf=desc.rowstrf
		 nsmpTot=n_elements(bf.data)
		 nchan=desc.hsubint.nchan
		 npol=desc.hsubint.npol
         ntmSmp=desc.hsubint.nsblk
		 fbuf=fltarr(2L,nsmpTot/2)				; unpack everyother sample
		 fbuf[0,*]=ishft(b.data,-4)
		 fbuf[1,*]=b.data and 'f'x
		 fbuf=reform(temporary(fbuf),nchan,npol*ntmSmp)
		 asize=size(fbuf)
		 vsize=size(bf.dat_offs)
;		 dat= pack*scl + offset
		 fbuf=mav(fbuf,b.dat_scl) + $
  		         (b.dat_offs # make_array(asize[2],type=vsize[2],value=1))
		
;  they are positive numbers..
;
;		move to float struct
;
		 tagNmAr=tag_names(b)
         ntags  =n_elements(tagNmAr)
		 for i=0,ntags-1 do begin
			if (tagNmAr[i] ne 'DATA') then begin
				bf.(i)=b.(i)
			endif else begin
				if npol eq 1 then begin
					bf.data=reform(temporary(fbuf),nchan,npol,ntmSmp)
				endif else begin
					bf.data=reform(temporary(fbuf),nchan,ntmSmp)
				endelse
			endelse
		endfor
	    b=temporary(bf)
	  endif
;
;	if they want to correct for blanking do it here
;
		
	  if (keyword_set(blankcor) and (desc.hpdev.phadcthr eq 1) )then begin
		if (not data4bit) then begin
			bf=desc.rowstrf
			struct_assign,b,bf
			b=temporary(bf)
		endif
		defAccum=uint(desc.hpdev.phfftacc)
		ii=where(b.stat.fftaccum ne defAccum,cnt)
		if cnt gt 0 then begin
			for i=0L,cnt-1 do $
			  if (b.stat[ii[i]].fftaccum eq 0) then begin
			  	b.data[*,ii[i]] *= 0.
			  endif else begin
			  	b.data[*,ii[i]] *= (defAccum*1./b.stat[ii[i]].fftaccum)
			  endelse
		endif
	  endif
	endelse
;
;   fix up the strings
;
    desc.currow++;
    return,1
;
; testing..
ioerr: ; seems that we need a null line or the jump screws up
    on_ioerror,NULL
    hiteof=eof(desc.lun)
    desc.currow=curRowStart;
    if ( not hiteof ) then begin
            print, !ERROR_STATE.MSG
            return,-1
    endif else  return,0
end
