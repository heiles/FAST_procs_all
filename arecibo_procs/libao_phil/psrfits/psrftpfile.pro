;+ 
;NAME:
;psrftpfile - compute total power for file
;
;SYNTAX: n=psrftpfile(fname,tp,fnmI=fnmI,hdr=hdr,maxrows=maxrows,blankcor=blankcor)
;
;ARGS:
;    fname: string	name of file
;    fname: string	name of file
;KEYWORDS:
;maxrows: long		max number of rows to input
;	fnmI:  {}       structure from masfilelist for file to use
;					In this case ignore fname
;blankcor:          If set the correct for adc blanking
;RETURNS:
;  tp[n,npols]: float total power
; hdr         : struct primary and extension headers
;
; n:   >=0 number of sample points returned
;      < 0  error
;
;DESCRIPTION:
;   Read in a file and compute the total power
;-
;
function psrftpfile,fname,tp,hdr=hdr,fnmI=fnmI,verb=verb,maxrows=maxrows,blankcor=blankcor
;
;;    on_error,2
	openOk=0
	if (psrfopen(fname,desc,fnmI=fnmI) ne 0) then begin
			print,"Error opening file"
			return,-1
	endif
	blankcorL=keyword_set(blankcor)?1:0
	openOk=1
;
	numRows=keyword_set(maxRows)?maxRows<desc.totRows:desc.totRows
	if numRows lt 1 then begin
		print,"No rows in file"
		goto,errout
	endif
;
;   see if we position before start
;
	nsblk=desc.hsubint.nsblk
	npol=desc.hsubint.npol
	tp=fltarr(nsblk*numrows,npol)
	icur=0L
	for irow=0,numrows-1 do begin
		istat=psrfget(desc,b,blankcor=blankcor)
	 	if keyword_set(verb) then print,irow 
		if istat ne 1 then break
		if (icur eq 0 ) and (arg_present(hdr)) then begin
			hdr={hpri: desc.hpri,$
				 azSt: b.tel_az,$
				 zaSt: b.tel_zen}
		endif
		if npol eq 1 then begin
			tp[icur:icur+nsblk-1]=total(b.data,1)
		endif else begin
			for ipol=0,npol-1 do $
				tp[icur:icur+nsblk-1,ipol]=reform(total(b.data[*,ipol,*],1),nsblk)
		endelse
		icur+=nsblk
	endfor
	if icur ne (numrows*nsblk) then begin
		if icur eq 0 then begin
			print,"no data found"
			goto,errout
		endif
		tp=(npol eq 1)?reform(tp[0l:icur-1]):reform(tp[0L:icur-1],icur,npol)
	endif
	if openOk then psrfclose,desc
	return,icur
errout: 
	if openOk then psrfclose,desc
	return,-1
end
