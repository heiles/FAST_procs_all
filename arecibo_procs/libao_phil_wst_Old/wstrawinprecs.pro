;+
;NAME: 
;wstrawinprecs - read in records  from ascii file
;
;SYNTAX: n=wstrawinprecs(lun,nrecs,bar)
;ARGS:
;  lun : int     from file open
;  nrecs: long   number of entries to read
;                use this to skip recs with bad dates
;RETURNS:
;      n:  int   number records input
; bar[n]: struct input data
;               
;DESCRIPTION:
;   Routine reads nrecs worth of data from the file pointed to by lun.
;Lun should be assigned to the oriondata.txt ascii file 
;(written by the orion weather station). The routine does no positioning
;before starting to read (so you should do a rewind if you don't know
;where you are positioned in the file.
;	The data is    loaded into the {wststr) array bar. 
;-
function wstrawinprecs,lun,nrecs,bar,verb=verb
	

;   make string mm/dd/yy for comparison
;  L=last
;  F=First
;
; 	allocate enough for  N day
;
	ntoksStd=47
	icur=0L
	on_ioerror,ioerr
	inp=''
	bar=replicate({wststr},nrecs)
	for i=0L,nrecs-1 do begin
		readf,lun,inp	
;
;		check for correct number of tokens
;
		a=strsplit(inp,",")
		ntoks=n_elements(a)
		if (ntoks ne ntoksStd) then begin
			print,i," bad num Toks:",ntoks," expected:",ntoksStd
			continue
		endif
		bar[icur++]=wstldrec(inp)
		if keyword_set(verb) and ((icur mod 1000) eq 0) then begin
			print,format='(i05)',i
		endif
	endfor
ioerr:
	if icur lt nrecs then begin
		if icur eq 0 then begin
			bar=''
		    return,0
		endif
		bar=bar[0L:icur-1]
	endif
	return,icur
end
