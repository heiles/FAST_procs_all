;+
;NAME:
;satlisttlefiles - return list of tle files
;SYNTAX: nfiles=satlisttlefiles(tlefiles,tledir=tledir,suf=suf)
;ARGS:
;
;KEYWORDS:
;tledir:  string  if supplied then the directory to  look for tle file
;suf   :  string  suffix for tle files. by default use txt,tle.
;RETURNS:
;nfiles: long    number of files we found
;tlefiles[nfiles]: array of files we founds
;
;DESCRIPTION:
;   get a list of tle files in the requested directory (default is the
;default tle directory). 
;-
function satlisttlefiles,tlefiles,suf=suf,tledir=tledir
;
;   
; 
    suI=satsetup() 
    tlepath=(keyword_set(tledir))?tledir:suI.tledir
	; make sure /  on end of path
	if strpos(tlepath,"/",/reverse_search) ne (strlen(tlepath)-1) then  $
		tlepath+="/"
    tlefiles=file_search(tlepath+"*")
    nfiles=n_elements(tlefiles)
    icnt=0
    sufAr=(keyword_set(suf))?suf:suI.tlesuf
    for ifile=0,nfiles-1 do begin
        for isuf=0,n_elements(suFAr)-1 do begin
            n=strlen(sufAr[isuf])
            if (strpos(tlefiles[ifile],sufAr[isuf],n-1,/reverse_offset) ne -1)$
                 then begin
                tlefiles[icnt]=tlefiles[ifile]
                icnt++
                break;
            endif
        endfor
    endfor
    if icnt ne 0 then begin
        if (icnt lt nfiles) then tlefiles=tlefiles[0:icnt-1]
    endif
    return,icnt
end
