;+
;NAME:
;masgetfile - input an entire file
;SYNTAX: istat=masgetfile(desc,b,avg=avg,median=median,ravg=ravg,$
;               float=float,double=double,filename=filename,fnmI=fnmI,$
;				blankcor=blankcor,$
;; returned...
;				tp=tp,descRet=descRet,azavg=azavg,zaavg=zaavg,hdr=hdr) 
;ARGS:
;    desc: {} returned by masopen.. file to read (unless filename present)
;KEYWORDS: 
;     avg:      if keyword set then return the averaged data
;               It will average over nrows and ndumps per row.
;               the returned data structure will store the averaged
;               spectra as a float. use /double if you want a double
;				see also : median
;  median:      if set then return the median value for the file. This
;               reads the entire file into memory so you need room to
;               hold it.
;  ravg:        if set then average each row
;  float:       the averaged data should be returned as float.
;				if any averaging is done then the default is float.
;  double:      The data should be returned as doubles.
; filename: string if present then ignore desc. openfile,read, then close
;              the descriptor.
;     fnmI: {}  filname Info struct returned from masfilelist. If present
;              then open, read, then close this file.
;blankcor:   if set then do  the correction for blanking. The 
;              blanked spectra will be corrected to have the same number of 
;              spectral accumulations as the unblanked spectra.
;             If /avg,/ravg,or /median then blankcor is also enabled.
;RETURNS:
;  istat: 1 got all the requested records
;       : 0 returned no rows
;       : -1 returned some but not all of the rows
;       : -2 could not open the fie
;   b[n]: {}   array of structs holding the data
; tp[n*m,2]: float array holding the total power for each spectra/sbc
;              m depends on the number of spectra per row
;descRet{}:   if supplied and filename or fnmi is present, then the file descriptor will
;             be left open and returned in descRet
;azavg : float return the average azimuth
;zaavg : float return the average za.
;hdr[] : string  if supplied then return header from fileopen
;-
function masgetfile,desc,b,avg=avg,median=median,ravg=ravg,$
                float=float,double=double,filename=filename,fnmI=fnmI,$
 				blankcor=blankcor,hdr=hdr,$
 				tp=tp,descRet=descRet,azavg=azavg,zaavg=zaavg
;
;   position to start of file
;
	useDesc=0
	medianL=keyword_set(median)?1:0
	avgL   =keyword_set(avg)?1:0
	ravgL  =keyword_set(ravg)?1:0
	if (medianL) then begin
		avgL=0
		ravgL=0
	endif
	if (avgL) then begin
		ravgL=0
	endif
	blankcorL=(keyword_set(blankcor))||avgL || ravgL || medianL
	if (n_elements(fnmI) eq 1) or (n_elements(filename) eq 1) then begin
		if (masopen(filename,desc,fnmI=fnmI,hdr=hdr) lt 0) then begin
			fname=(n_elements(fnmI) eq 1)?fnmI.dir+fnmI.fname:filename
			print,"Could not open:",fname
			return,-2
		endif
		useDesc=1
	endif 
;   do we use double or floats?
	floatL=(keyword_set(float) || keyword_set(avgL) || keyword_set(ravgl) || keyword_set(medianl))
	doubleL=0
	if (keyword_set(double)) then begin
		floatL=0
		doubleL=1
	endif
    nrows=desc.totrows
    row=1
    if arg_present(tp) then begin 
        istat=masgetm(desc,nrows,b,row=row,avg=avgl,ravg=ravgL,tp=tp,_extra=e,$
				blankcor=blankcorL,double=doublel,float=floatL,azavg=azavg,zaavg=zaavg)
		if medianL then b=masmath(b,/median,double=doubleL)
    endif else begin
        istat=masgetm(desc,nrows,b,row=row,avg=avgL,ravg=ravgL,_extra=e,$
			blankcor=blankcorL,double=doubleL,float=floatL,azavg=azavg,zaavg=zaavg)
		if medianL then b=masmath(b,/median,double=doubleL)
    endelse
	if useDesc then begin
		if arg_present(descRet) then begin
			descRet=desc
		endif else begin
			masclose,desc
		endelse
	endif
	return,istat
end
