
;+
;NAME:
;wasprojfiles - find the files belonging to a project id
;
; SYNTAX: istat=wasprojfiles(proj,fileInfo)
;
; ARGS:
;      proj:  string  proj name to search for
; RETURNS: 
;     istat:  number of files found 
;fileinfo[istat]:   array of file info structures containing the name 
;                   and size of the file
;
;DESCRIPTION:
;   Search through the wapp fits directories looking for files that
;belong to a particular project. Return an array of stuctures containing
;the filename and file size.
;
;-
;
function wasprojfiles ,proj,fileI,dir=dir
;   
;
    defdir='/share'
    if not keyword_set(dir) then dir='/share'
    dirl=dir
    if strmid(dirl,strlen(dirl)-1,0) ne '/' then dirl=dirl+'/'
    wappsubdir=['wapp11','wapp21','wapp31','wapp41']
    maxwappnum=4
;       
    ntot=0
    for i=0,maxwappnum-1 do begin
        fpat=dirl+wappsubdir[i]+'/'+'wapp*'+proj+'*'+'.fits'
        a=findfile(fpat,count=nfiles)
        if nfiles gt 0 then begin
            flist=(ntot eq 0)?a:[flist,a]
        endif
        ntot=ntot+nfiles
    endfor
    if ntot eq 0 then return,0
    a={ fname:''    ,$
        size:  0ul  }
    fileI=replicate(a,ntot)
    fileI.fname=flist
    lun=-1
    for i=0,ntot-1 do begin
        openr,lun,flist[i],/get_lun
        a=fstat(lun)
        free_lun,lun
        lun=-1
        fileI[i].size=a.size
    endfor
    return,ntot
end
