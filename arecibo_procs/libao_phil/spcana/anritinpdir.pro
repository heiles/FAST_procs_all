;+
;NAME:
;anritinpdir - input set of files from a directory matching pattern
;SYNTAX: nfiles=inpdir(bdir,ntrace,fiAR,npnts=npnts)
;ARGS:
;bdir: string  base directory and file base to match
;              this string is passed to file_search()
;ntrace: int   number of traces stored
;KEYWORDS:
;npnts : int   number of points/file def=551
;RETURNS:
; FIAr[NFILES]:{}  holds info from files
;
;Notes:
; 	all files must have same npnts, ntraces
;-
function  anritinpdir,bdir,ntrace,fiAr,npnts=npnts
	if (n_elements(npnts) eq 0) then npnts=551
;    numbers order is:  freq, trace 1,2,3
	inpAr=fltarr(ntrace+1,npnts)
	fI={ fname:' ',$ 
	   cfr   : 0.,$
       df    : 0.,$
	   mtime :0LL,$ ;secs 1970. last file modification
	   freq  : dblarr(npnts),$
	   spc   : dblarr(npnts,ntrace)}
;
;   get filelisting of this directory
;
	fnmAr=file_search(bdir,count=nfiles)
	if (nfiles eq 0) then begin
		print,"no files found for " + bdir
		return,0
	endif
	fIAr=replicate(fI,nfiles)
	inp=''
	for ifile=0,nfiles-1 do begin
		openr,lun,fnmAr[ifile],/get_lun
		fs=fstat(lun)
		readu,lun,inpar 
		free_lun,lun
		fiAr[ifile].fname=fnmAr[ifile]
		fiAr[ifile].freq=inpar[0,*]
		fiAr[ifile].spc=transpose(inpar[1:*,*])
		fiAr[ifile].df=(fiAr[ifile].freq[1]- fiAr[ifile].freq[0])
		fiAr[ifile].cfr=fiAr[ifile].freq[npnts/2]
		fiar[ifile].mtime=fs.mtime
	endfor		
	return,nfiles
end
