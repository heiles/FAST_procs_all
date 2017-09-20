;+
;NAME:
;shsscandir - can all files in an shs directory
;SYNTAX: n=shsscandir(path,fI)
;ARGS:
; path: string  directory path, filename (with wildcards) to search
;               this string is passed to file_search()
;RETURNS:
; n   : long    number of files found
;fI[n]: {}      holds info for each file
;
; The fI struct contains:
;IDL> help,fi,/st
;** Structure <8c5cd8>, 5 tags, length=48, data length=44, refs=1:
;   YYYYMMDD        LONG          20150619
;   FNAME           STRING    '/net/daeron/data/t1193_20150619b/t1193'...
;   LTIME           STRING    '23:51:24'
;   SECMIDST        LONG             85884
;   NRECS           LONG               109
;-
function shsscandir,path,fI 
	flist=file_search(path)
	nfiles=n_elements(flist)
	if nfiles eq 0 then return,0
	a={ yyyymmdd: 0L,$; need to fill this in separately
    fname:'',$ ; complete name with path
    ltime:'',$ ; start of file .. hh:mm:ss
    secMidSt:0L,$ 
    nrecs:0L}
	fI=replicate(a,nfiles)
	astToUtc=4d/24d
    basenm=basename(flist[0])
    a=stregex(basenm,'^[^_]*_([0-9]*)',/extract,/sub)
    yyyymmddCur=long(a[1])
	jdCur=yymmddtojulday(yyyymmddCur) ; note we are using ast times

	for i=0,nfiles-1 do begin &$
    	istat=shsopen(flist[i],desc) &$
    	fI[i].fname=flist[i] &$
        fI[i].ltime=desc.dhdr1.systime &$
        a=strsplit(fI[i].ltime,":",/extract) &$
        fI[i].secmidSt=long(a[0])*3600L + long(a[1])*60L + long(a[2])  &$
		if (i eq 0 ) then secMidLast=fI[i].secMidSt
        fI[i].nrecs =desc.numrec &$
        shsclose,desc &$
		if (fI[i].secMidSt lt secMidLast) then begin
			jdCur+=1d
			caldat,jdCur,yr,mon,day,hr,min,sec
			yyyymmddCur=yr*10000L + mon*100l + day
		endif
		fI[i].yyyymmdd=yyyymmddCur
		secMidLast=fI[i].secMidSt
	endfor
	return,nfiles
end
