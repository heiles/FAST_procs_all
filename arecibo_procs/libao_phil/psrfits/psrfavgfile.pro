;+ 
;NAME:
;psrfavgfile - avg spectra in a file
;
;SYNTAX: n=psrfavgfile(fname,bavg,brms=brms,desc=desc,fnmI=fnmI,$
;					    maxrows=maxrows,minrows=minrows)
;
;ARGS:
;    fname: string	name of file
;KEYWORDS:
;maxrows: long		max number of rows to input
;minrows: long		if file has less then minrows, then donot process it
;                   (use to skip cals)
;	fnmI:  {}       structure from masfilelist for file to use
;					In this case ignore fname
;RETURNS:
; bavg:  struct    standard struct from psrfget() with data replaced by the averaged data.
;                  the other elements come from the first record of the file
; brms:  struct    if present then return rms for the file.
;                  this is computed on the avg of each row.
;                  The rms is normalized by the number of rows (it is not divided
;                  by the avgspectra).
;
; desc        : struct  from psrfopen(). This contains the various headers.
;						the will have been aleady closed.
; n:   >=0 number of spectra avged
;      < 0  error
;
;DESCRIPTION:
;   average the spectra in a file. Return the averaged spectra in b.
; It will be the standard structure returned from psrfget on the first reccord except
; that the .data element will contain the averaged data.
; Note: currenly blanking is ignored..
; - the rms on u,v is a factor of 2 low.. this is from the mock
;   scaling of the u,v differently then pola,B
;-
;
function psrfavgfile,fname,bavg,brms=brms,desc=desc,fnmI=fnmI,verb=verb,$
			maxrows=maxrows,minrows=minrows
;
;;    on_error,2
	if n_elements(minrows) eq 0 then minrows=0L
	openOk=0
	if (psrfopen(fname,desc,fnmI=fnmI) ne 0) then begin
			print,"Error opening file"
			return,-1
	endif
	openOk=1
;
	if (desc.totrows lt minrows) then goto,errout
	numRows=keyword_set(maxRows)?maxRows<desc.totRows:desc.totRows
	if numRows lt 1 then begin
		print,"No rows in file"
		goto,errout
	endif
;
;   see if we position before start
;
	fftAccumDef=desc.hpdev.phfftacc*1D
	nsblk=desc.hsubint.nsblk
	npol=desc.hsubint.npol
	nchan=desc.hsubint.nchan
	
	dorms=0;
	if arg_present(brms) then begin
		dorms=1
		dsumsq=dblarr(nchan,npol)
		dsum  =dblarr(nchan,npol)
	endif
	scl=0D
	nrow=0L
;
;  note .. last record of file always has same number of 
;          spectra. but the tsubint variable only has the 
;          number that were requested. the averaging is assuming
;          that all the elements of array have valid data.
;
	for irow=0,numrows-1 do begin
		istat=psrfget(desc,bIn,/avg)
		if istat ne 1 then break
		nrow+=1
		if irow eq 0 then begin
			bavg=bIn
		endif else begin
			bavg.data+=bIn.data
	    endelse
		if dorms then begin
			dsum+=bin.data
			dsumsq+=(bin.data*1d)*bin.data
		endif
	 	if keyword_set(verb) then print,irow 
	endfor
	if nrow eq  0 then  begin
			print,"no data found"
			goto,errout
	endif
	if nrow gt 1 then bavg.data/=nrow
	if dorms then begin
		brms=bavg
	    davg=dsum/nrow
	    dtemp=dsumSq/nrow - (davg)^2
		ii=where(dtemp lt 0,cnt)
		if cnt gt 0 then dtemp[ii]=0d
		if (npol ne 4) then begin
			brms.data=sqrt(dtemp)/davg
		endif else begin
		    brms.data[*,0:1]=sqrt(dtemp[*,0:1])/davg[*,0:1]
			dd=sqrt(davg[*,0]^2 + davg[*,1]^2)
			for i=2,3 do brms.data[*,i]=sqrt(dtemp[*,i])/dd
		endelse
	endif
		
	if openOk then psrfclose,desc
	return,nrow*nsblk
errout: 
	if openOk then psrfclose,desc
	return,-1
end
