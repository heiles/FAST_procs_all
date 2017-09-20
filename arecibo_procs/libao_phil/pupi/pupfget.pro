;+ 
;NAME:
;pupfget - input next puppi fits row from disc
;
;SYNTAX: istat=pupfget(des,b,row=row,hdronly=hdronly,avg=avg,$
;				   drms=drms)
;
;ARGS:
;    desc:{descpupf}  from pupfopen();
;
;RETURNS:
;     b: structure holding the hdr and data input
; istat: 1 ok
;      : 0 hiteof
;      :-1 i/o error..bad hdr, etc..
;
;KEYWORDS:
;     row     : if set then position to row before reading (count from 1)
;               if row=0 then ignore row keyword
;     hdronly : if set then just return the row header. no status or data.
;       avg   : if set then average the spectra in 1 row before returning.
;               This forces the returned datatype to be float.  
;     drms    : if provided then compute rms by chan and return in 
;               drms[nchan]. do this before any averaging
;               this is only available for search data.
;
;DESCRIPTION:
;
;   Read the next row from a pupf fits datafile pointed to by desc.
;  If keyword row is present, position to row  before reading.
;  For non search data the data on file is  nbins,nchan,npol
;  we want to switch this to nchan,pol,nbin
;-
;
function pupfget, desc,b,row=row,hdronly=hdronly,avg=avg,drms=drms
;
;
;
;;    on_error,2
    on_ioerror,ioerr
	longFiles=!version.FILE_OFFSET_BITS eq 64
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
		rowLen=(longFiles)?long64(desc.bytesRow):desc.bytesRow
	    byteOffset=rowlen*(row-1) + desc.byteoffrec1 	
        point_lun,desc.lun,byteOffset
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
;
;   read the row in up to the data
;
	rowLen=(longFiles)?long64(desc.bytesRow):desc.bytesRow
	byteOffset=rowlen*(desc.currow) + desc.byteoffrec1
    point_lun,desc.lun,byteOffset
	bh=desc.rowstr
    readu,desc.lun,bh
    if desc.needswap then bh=swap_endian(temporary(bh))    
;
; 	now get the data
;
	bd=desc.inpdat
    readu,desc.lun,bd
;
;   for non search data, on disc we want to put nbins last
;   want to arrange to : nchan,npol,nbin
;
	npol=desc.hsubint.npol
	nchan=desc.hsubint.nchan
	if (not desc.searchdata) then begin
        if desc.needswap then bd=swap_endian(temporary(bd))    
		nbin=desc.hsubint.nbin
		bd= transpose(reform(bd,nbin,nchan,npol),[1,2,0])
	endif else begin
;
;	search data is byte we need to convert to float
;   but don't need to swap.
;   Search data is positive...
;	 	    ii=where(bd gt 127,cnt)
 			bd=float(bd)
;			if cnt gt 0L then bd[ii]=bd[ii] - 256.	
	endelse
	b=create_struct(temporary(bh),"data",temporary(bd))
	bd=''
;
;	see if they want to average the spc of 1 row
;
	if (arg_present(drms)) then begin
		if (desc.searchdata) then begin
			if npol eq 1 then begin
			  drms=rmsbychan(b.data)
			endif else begin
			  drms=fltarr(nchan,2)
			  drms[*,0]=rmsbychan(reform(b.data[*,0,*],nchan,nbin)) 
			  drms[*,1]=rmsbychan(reform(b.data[*,1,*],nchan,nbin))
			endelse
		endif else begin
			print,"drms= keyword only available with search data"
		endelse
	endif
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
		scl=1. ; should be number of integrations.
		if npol eq 1 then begin
			bf.data=total(b.data,2)*scl
		endif else begin
			bf.data=total(b.data,3)*scl
		endelse
		b=temporary(bf)
	endif 
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
