;+
;NAME: 
;wstrawinpday - read in 1 days worth of data from ascii file
;
;SYNTAX: n=wstrawinpday(yymmdd,bar,inpdir=inpdir)
;ARGS:
;  yymmdd: int   yymmdd of date for file (ast)
; inpdir : string input dir to read file. def: '/share/orion/'
;RETURNS:
;      n:  int   number records input
; bar[n]: struct input data
;               
;DESCRIPTION:
;   Input a days worth of wst data from the daily raw:
;wst_yymmdd.txt. 
;	The data is loaded into the {wststr) array bar. 
;The file can have 1 or more minutes from the next ast day
;Since the file rename occurs 1 minute after midnite
;-
function wstrawinpday,yymmdd,bar,inpdir=inpdir
	
	if n_elements(inpdir) eq 0 then inpdir='/share/orion/'
	yymmddF=yymmdd
	bar=''
	ntot=0L
	lun=-1
;
; 	make filename
;
	fname=inpdir + string(format='("wst_",i06,".txt")',yymmdd)
	ierr=0
	openr,lun,fname,/get_lun,error=ierr
	if ierr ne 0 then begin
		print,"file:",fname," open error:",!ERROR_STATE.MSG
		goto,errout
	endif

;	count the records in the file
;
	cmd="wc " + fname   
	spawn,cmd,reply
	a=strsplit(reply,/extract)
	nrecs=long(a[0])
	if nrecs le 0 then begin
		print,"No lines found in file:",fname
		goto,done
	endif
	on_ioerror,ioerr2
	inpar=strarr(nrecs)
	readf,lun,inpar
ioerr2:
	ii=where(inpar ne '',cnt)
	if cnt ne nrecs then begin
		inpar=inpar[ii]
		nrecs=cnt
	endif
	bar=replicate({wststr},nrecs)
	ntot=0L
	for i=0L,nrecs - 1L do begin
		bar[ntot++]=wstldrec(inpar[i])
	endfor
	if (ntot) lt nrecs then begin
		bar=bar[0:ntot-1]
		nrecs=ntot
	endif
done:
	if lun ge 0 then free_lun,lun
	return,ntot
errout:
	ntot=-1
	goto,done
end
