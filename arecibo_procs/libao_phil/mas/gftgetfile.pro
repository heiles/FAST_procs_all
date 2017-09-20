;+
;NAME:
;gftgetfile - input an entire file
;SYNTAX: istat=gftgetfile.pro(fname,bon,boff,nrows=nrows,hdronly=hdronly)
;ARGS:
;    fname: string   file to open
;KEYWORDS:
;	hdronly:         if set then just return the headers.
;
;RETURNS:
;  istat: 1 got all the requested records
;       : 0 returned no rows
;       : -1 returned some but not all of the rows
;bon[nrows]: {}   array of structs holding the calon data
;boff[nrows]: {}   array of structs holding the caloff data
;   nrows  :   number of rows returned
;-
function gftgetfile,fname,bonAr,boffAr,nrows=nrows,hdronly=hdronly
;
;   position to start of file
;
    nrows=0
    row=1
	irow=0
	istat=gftopen(fname,desc)
	if istat ne 0 then begin
			print,"Error opening file:",fname
			return,0
	endif
	nrows=desc.totrows
	for row=1,nrows do begin
		istat=gftget(desc,bon,boff,row=row,hdronly=hdronly)
		if istat ne 1 then break
		if row eq 1 then begin
			bonAr=replicate(bon,nrows)
			boffAr=replicate(boff,nrows)
		endif
		bonAr[irow]=bon
		boffAr[irow]=boff
		irow++
	endfor
	masclose,desc
	retstat=1
	nrows=irow
	if irow ne nrows then begin
		if irow eq 0 then begin
			bonAr=''
			boffAr=''
			retStat=istat		; 0 or -1
		endif else begin
			bonAr=bonar[0:irow-1]
			boffAr=boffar[0:irow-1]
			retStat=-1
		endelse
	endif
	return,retStat
end
