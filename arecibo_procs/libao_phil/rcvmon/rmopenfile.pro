;+
;NAME:
;rmopenfile - open the requested file
;SYNTAX: lun=rmopenfile(filename,dirlist=dirlist)
;ARGS:
;filename: string   file (with or without  directory) to open
;KEYWORDS:
;dirlist[]: strarr  list of directories to search. If not 
;                   present then use the default directories
;                   (/share/obs4/rcvm, /share/phildat/rcvm
;
;RETURNS:
;   lun : int       open lun. -1 --> couldn't open
;DESCRIPTION:
;   Open the requested file. The routine will try openning 
;filename. If not present, then it will search in the
;default directory list: (/share/obs4/rcvm, /share/phildat/rcvm)
;It will open regular or compressed files (compressed files
;end in .gz).
;
;EXAMPLE:
;   openr,lun,'/share/obs4/rcvmon/rcvmN',/get_lun
;   nrecs=rmopenfile(lun,9999,d)
;-
function rmopenfile,file,dirlist=dirlist 
;
	; default directories

	dirlistL=['/share/obs4/rcvm/','/share/phildat/rcvm/']
	if n_elements(dirlist) gt 0 then dirListL=dirList

	ndir=n_elements(dirListL)
	baseNm=basename(file,dirNm=dirNm,nmLen=nmLen)

	; if then included a directory name include it in dirListL
    ; if it is different. nmlen[0] is the length of dir on file

	if (nmLen[0] gt 0 ) then begin
		gotit=0
		for i=0,ndir-1 do begin
			if strcmp(dirlistL[i],dirNm) then begin
			 gotit=1
		     break
			endif
		endfor
	    if not gotit then dirListL=[dirNm,dirListL]
	endif
;
;	see if the file exists
;
	suf=['','.gz']
	fname=''
	for isuf=0,n_elements(suf)-1 do begin
		compress=isuf
		if file_exists(baseNm+suf[isuf],fullname,dir=dirListL) then begin
			fname=fullname
			break
		endif
	endfor
	if fname eq '' then return,-1
	openr,lun,fname,error=err,/get_lun,compress=compress
	if err ne 0 then begin
		message,'cannot open file:' + fname,/info
		return,-1
	endif
	return,lun
end
