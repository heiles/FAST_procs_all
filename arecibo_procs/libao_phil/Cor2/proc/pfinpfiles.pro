;+
;pfinpfiles - input headers from a list of files
;SYNTAX: numscans=pfinpfiles(fname,maxscans,hdrscn,fnameAr)
;ARGS:
;	    fname:	string . file containing list of filenames to process
;	 maxscans:	long   . max scans we can return..
;    hdrscn[]:  {pfhdrstr} return data here
;    fnameAr[]: strings.. return array of filenames used.
;    numscans:  number of scans we input
;
;DESCRIPTION:
;	Read filenames to process from the file fname. Format is 1 fileanme per
;line and ; in column 1 is a comment line. For each filename, call pfinpfile
;to input all of the scan headers in the file. For each scan in the file
;The first,last header is recorded as well as the average power.
;
;Return the headers in hdrscn which is an array of {pfhdrstr} structures.
;Also return in fnameAr the array of filenames used (hdrscn has an index
;that points back to this array).
;-
;history:
;13jul00 - alloc hdrs outside of pfinphdrs
;
function pfinpfiles,fname,maxscans,hdrscn,fnameAr,maxscanfile=maxscanfile
 
	if n_elements(maxscanfile) eq 0 then maxscanfile=1000
	maxfnames=1000
	fnameAr=strarr(maxfnames)
	openr,lunin,fname,error=openerr,/get_lun
	if openerr ne 0 then begin
		printf,-2,!err_string
		return,0
	endif
	hdrscn=pfallocstr(maxscans)
	hdrs  =pfallocstr(maxscanfile)		;we pass to pfinphdrs
	cumscns=0L
	finp=" "
	on_ioerror,ioerr
	filesdone=0L
	for i=0L,maxfnames-1 do begin
		readf,lunin,finp
		finp=strtrim(finp,2)
		if strpos(finp,';') ne 0 then begin
			left=(maxscans-cumscns)
			print,'file:',finp,' slots:',left
			nscans=pfinphdrs(finp,filesdone,hdrs)
			fnameAr[filesdone]=finp
			if (nscans gt 0) then begin
				j= left < nscans
				hdrscn[cumscns:cumscns+j-1]=hdrs[0:j-1]
				cumscns=cumscns+nscans
				if cumscns ge maxscans then goto,ioerr
			endif
			filesdone=filesdone+1L
		endif
	endfor
ioerr: 
	free_lun,lunin
	if cumscns ne maxscans then hdrscn=hdrscn[0:cumscns-1]
	if filesdone lt maxfnames then fnameAr=fnameAr[0:filesdone-1]
	return,cumscns
end
