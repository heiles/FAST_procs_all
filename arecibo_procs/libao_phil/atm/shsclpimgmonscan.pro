;+
;NAME:
;shsclpimgmonscan - scan for processed clp files
;SYNTAX: nfiles=shsclpimgmonscan(dir,fbase,fiar,firsttime=firsttime,
;		            allhdrs=allhdrs
;ARGS:
;dir     : string   to search for .hdr files. Include the 
;                   '/' at the end of the dir name
;fbase   : string   for filename to look for. Include up to the
;                   _ before the filenumber digits (see below)
;KEYWORDS:
;    nrec:  long    number of records to process (default is 1000).
;                   warning.. this is the number of records, not ipps
;                   unless ipps/buf = 1.
;firstTime:         if set then this is the first time the routine
;                   is called with this dir,fbase. If not set then
;                   fiar will have the info from the previous call.
;                   the routine will add new info to this array.
;allhdrs:           if set then return all header for each file.
;                   Each .shs  file will have multiple 10 sec
;                   images generated from it. By default only the
;                   first hdr of the .shs file is returned in fiar[i]
;                   With allhdrs set, all the headers are returned
;                   in fiar[i].hdrs[20]. Leaving this off speeds up
;                   the scanning. If you need the az,za,time exactly
;                   for each img then turn this on. It only works
;                   with firsttime=1
;RETURNS:
;nfiles:  long   number of raw input files found
;fiar[nfiles]:{}  stuct holding info on all the image files found:
;
;DESCRIPTION:
;	Scan for .shs processed image files. The routine looks for
;the .hdr files in the provided dir, fbase. It returns the number
;of  input files found (note that there are multipled 10sec img files
;for each raw input file.
;EXAMPLES:
;	dir='/raid/radar/phil/t1193_20120120/'
;   fbase='t1193_20jan2012_'
;   n=shsclpimgmonscan(dir,fbase,fiar,first=1)
; Structure <170f688>, 4 tags, length=196, data length=196, refs=1:
;  FNUM            LONG                 0
;   NIMG            LONG                10
;   HDR             STRUCT    -> <Anonymous> Array[1]
;   IMGNUMAR        LONG      Array[20]
;
;   n=shsclpimgmonscan(dir,fbase,fiar,first=1,/allhdrs) 
;   help,fiar,/st
; Structure <19c57b8>, 4 tags, length=2248, data length=2248, refs=1:
;p   FNUM            LONG                 0
;   NIMG            LONG                10
;   HDR             STRUCT    -> <Anonymous> Array[20]
;   IMGNUMAR        LONG      Array[20]
;
;Note that without /allhdrs, you only get the header from the
;first 10 sec block of the file.
;- 
function shsclpimgmonscan,dir,fbase,fiar,firsttime=firsttime,$
		 allhdrs=allhdrs
;
; 	scan dir,fbase looking for .hdr files.
;   return in fiar one entry per filenum (multiple
;   imgfiles/fnum
;
	firstTimeL=keyword_set(firsttime)
	allHdrs=keyword_set(allhdrs)
	if (allhdrs and (not firstTimeL)) then begin
		print,$
"shsclpimgmonscan: allhdrs key only valid with firstTime=1"
		return,0
	endif
	print,"Scanning for files..."
	far=file_search(dir + "*.hdr")
	if (n_elements(far) eq 1) and (far[0] eq '') then return,0
		
	a=stregex(far,'.*_([0-9][0-9][0-9]*).([0-9][0-9][0-9]).hdr',/subex,/extr)
	fnumAr=long(reform(a[1,*]))
	inumAr=long(reform(a[2,*]))
;
; create struct array one for each file (multiple images each file
;
    istat=shsclprdhdr(far[0],hdr) &$
	nn=n_elements(fnumAr)
; 	maximgFile=41 <21jul14> ran with tx samples too small . got lots of imgs/file
;   upped to 110 .. for 1 sec images with heater
 	maximgFile=120
; 	maximgFile=20 
	maxfiles=20000L
	if (allHdrs) then begin
		a={   fnum: 0L,$              ; 0 based
      		nimg: 0l,$
      		hdr:  replicate(hdr,maximgFile),$
      		imgNumAr:lonarr(maximgFile)} ; 1 based
	endif else begin
			a={   fnum: 0L,$              ; 0 based
      		nimg: 0l,$
      		hdr:  hdr,$
      		imgNumAr:lonarr(maximgFile)} ; 1 based
	endelse

	if (not firsttimeL) then fiarOld=fiar
	fIAr=replicate(a,maxfiles)
	icurFNum=-1
	start=1L
	ifile=0L
	imgCnt=0L
	for i=0L,nn-1 do begin &$
    	if (fnumAr[i] ne icurFNum) then begin &$
        	if not start then begin &$
           		ifile++ &$
        	endif else begin &$
            	start=0 &$
            	ifile=0 &$
        	endelse &$
        	icurFNum=fnumAr[i] &$
        	fiAr[ifile].fnum=fnumAr[i] &$
			gotHdr=0
			if (not firsttimeL) then begin
				ii=where(icurFnum eq fiarOld.fnum,cnt)
				if cnt gt 0 then hdr=fiarOld[ii[0]].hdr
				gotHdr=1
			endif
			if (not allhdrs)then begin
        		if (not gotHdr) then istat=shsclprdhdr(far[i],hdr) &$
        		fiar[ifile].hdr  =hdr &$
			endif
        	iimgCnt=0 &$
    	endif &$
    	fiar[ifile].imgNumAr[iimgCnt]=inumAr[i] &$
		if (allHdrs) then begin
        	 istat=shsclprdhdr(far[i],hdr) &$
        	fiar[ifile].hdr[iimgCnt]  =hdr &$
		endif
    	iimgCnt++ &$
    	fiar[ifile].nimg=iimgCnt &$
	endfor
	fiar=fiar[0:ifile]
	nfiles=ifile+1
;
;	put in numerical order. the file scan comes back in
;   ascii order
;
	ii=sort(fiar.fnum)
	fiar=fiar[ii]
	return,nfiles
end
