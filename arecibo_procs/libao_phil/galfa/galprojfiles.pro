;+
;NAME:
;galprojfiles - find the files belonging to a project id
;
; SYNTAX: istat=galprojfiles(proj,fileInfo,yymmdd1=yymmdd1,yymmdd2=yymmdd2,$
;                            minsize=minsize,dir=dir)
;
; ARGS:
;      proj:  string  proj name to search for
;KEYWORDS:
; yymmdd1: long limit files to those starting on this date (yymmdd1 included)
; yymmdd2: long limit files to those starting on or before this date
;               (yymmdd2 included)
; minsize: long minimum size in bytes for file to return. default is
;               100000 bytes. file less than this usually have no 
;               data (just a header). 
;dir    : string directory to search thru. def: /share/galfa
; RETURNS: 
;     istat:  number of files found 
;fileinfo[istat]:   array of file info structures containing the name 
;                   and size of the file
;
;DESCRIPTION:
;   Search through the galfa fits directories looking for files that
;belong to a particular project. Return an array of stuctures containing
;the filename and file size.
;
;-
;
function galprojfiles ,proj,fileI,dir=dir,yymmdd1=yymmdd1,yymmdd2=yymmdd2,$
                        minsize=minsize
;   
;
    if n_elements(minsize) eq 0 then minsize=100000L
    defdir='/share/galfa/'
    if not keyword_set(dir) then dir=defdir
    dirl=dir
    if strmid(dirl,strlen(dirl)-1) ne '/' then dirl=dirl+'/'
;       
    ntot=0
    fpat=dirl+'galfa*'+proj+'*'+'.fits'
;    flist=file_search(fpat,count=ntot,/fold_case); fold case screws up??
    flist=file_search(fpat,count=ntot)
    if ntot eq 0 then return,0
;
;   see if they put a date limit ...
;
    use1=keyword_set(yymmdd1)
    use2=keyword_set(yymmdd2)
    if use1 or use2 then begin
        if not use1 then yymmdd1=0L
        if not use2 then yymmdd2=21000101
        yy1=(yymmdd1 lt 20000101L)?yymmdd1+20000000L: yymmdd1; if yy two digits
        yy2=(yymmdd2 lt 20000101L)?yymmdd2+20000000L: yymmdd2; ditto
;
;   grab the date from the file names..
;
        i1=strpos(flist[0],'/galfa.20') + 7 ; start of date
        datel=long(strmid(flist,i1,8))
        ind=where((datel ge yy1) and (datel le yy2) ,ntot)
        if ntot eq 0 then begin
            ntot=0
            fileinfo=''
            return,ntot
        endif
        flist=flist[ind]
    endif
    a={ fname:''    ,$
        size:  0ul  }
    fileI=replicate(a,ntot)
    fileI.fname=flist
    lun=-1
    for i=0,ntot-1 do begin &$
        openr,lun,flist[i],/get_lun &$
        a=fstat(lun) &$
        free_lun,lun &$
        lun=-1 &$
        fileI[i].size=a.size &$
    endfor
    ind=where(fileI.size gt minsize,count)
    if count ne ntot then begin
       ntot=count
       fileI=(ntot eq 0)? '' : fileI[ind]
    endif
    return,ntot
end
