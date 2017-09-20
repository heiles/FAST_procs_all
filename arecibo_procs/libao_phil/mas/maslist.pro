;+
;NAME:
;maslist - one line summary listing of file(s)
;SYNTAX maslist,desc,fnmI=fnmI,flist=flist,sumI=sumI
;
;ARGS:
; desc  : {}      descriptor from masopen() for file to list. Ignored if fnmI or flist
;                 keywords present
;KEYWORDS:
;fnmI[n]:{}       structure returned by masfilelist. If this keyword is
;                 present then use this for the files to list
;flist[]:strarr   array of filenames to list. 
;RETURNS:
; sumI[n]: {}      summary info for mas files.
;DESCRIPTION:
;   Make a 1 line summary listing for file. You can specify the files with:
; 1. fnmI=fnmI[]  array fileInfo structures returned from  masfilelist()
; 2. flist=flist[]  strarr of filenames to list
; 3. desc         a descriprtor from the call to masopen().
;
;	If more than one of the above is specified, then the order is
;   1 then 2 then 3.
;
;The 1 line listing contains:
;  SOURCE      SCAN     RA       DEC   C  nSpc POL  Chn    PatNm TopFrq  Bw    RCV
;   Cur-pos 931000143 180506.0   85109 J   3000  2 8192      RUN 1450.0 172.0 alfa
;
;SEE ALSO
;masfilesum()
;-
pro maslist,desc,fnmI=fnmI,flist=flist,sumI=sumI
;
	descl=(keyword_set(fnmI) or keyword_set(flist))?'':desc
	nsum=masfilesum(flist,sumI,desc=descl,fnmI=fnmI,/list)
	return
end
