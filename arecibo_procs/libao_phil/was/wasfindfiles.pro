;+
;NAME:
;wasfindfiles - find the files for an observation
;
; SYNTAX: istat=wasfindfiles(file1,flist)
;
; ARGS:
;      file1:  string  the name of one of the files
;                               number --> record of current scan
; RETURNS: 
;      istat: -1 illegal fname passed in
;              0..nthe number of files found on disc 
;      flist[istat] the filenames for each file
;
;DESCRIPTION:
;   This routine will take than name of a single was fits file and find
;all of the other files that were taken at the same time. You enter
;the complete pathname to the file. The list of all files (including
;the name you passed in) will be returned in flist)
;-
;
function wasfindfiles ,fname,flist
;   
;   split at the /
;
    wappsubdir=['wapp11','wapp21','wapp31','wapp41']
    maxwappnum=4
;       
    af=strsplit(fname,'/',len=lenf)
    nsectf=n_elements(af)
    basename=strmid(fname,af[nsectf-1],lenf[nsectf-1])
    ab=strsplit(basename,'.',len=lenb)
    bnamAll=strmid(basename,lenb[0])
    pathAll=strmid(fname,0,af[nsectf-2])
    flist=strarr(maxwappnum)
    j=0
    for i=1,maxwappnum do begin &$
        subdir=wappsubdir[i-1] &$
        file=string(format='(a,a,"/","wapp",i1,a)',pathAll,subdir,i,bnamAll) &$
        a=findfile(file,count=istat) &$
        if istat eq 1 then begin &$
            flist[j]=file &$
            j=j+1 &$
        endif &$
    endfor
    if j eq 0 then begin
        flist=''
    endif else begin
        if j ne n_elements(flist) then flist=flist[0:j-1]
    endelse
    return,j
end
