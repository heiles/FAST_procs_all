;+
;NAME:
;pdevfilelist - get list of pdev files 
;SYNTAX: nfiles=pdevfilelist(nmAr,fnmIAr,recur=recur)
;ARGS:
;   nmAr[]: strarr   An array of names to search. Each name can be 
;                    a pdev filename, or a directory name
;KEYWORDS:
;   recur:          if set then recurse down through any directories supplied.
;RETURNS:
;   ntot    : long  number of .pdev files found
;fnmIArNtot[]:{}    an array of structures holding info on the
;                   pdev files fou nd:w
;DESCRIPTION:
;   The returned structure contains:
; nmAr='/share/pdata/pdev/agc110443/x107.20070123.agc110443.b0a.00000.pdev'
; istat=pdevfilelist(nmAr,fnmI)
; help,fnmI,/st
;* Structure PDEVFNMPARS, 8 tags, length=60, data length=60:
;   DIR             STRING    '/share/pdata/pdev/agc110443/'
;   FNAME           STRING    'x107.20070123.agc110443.b0a.00000.pdev'
;   PROJ            STRING    'x107'
;   DATE            LONG          20070123
;   src             STRING    'agc110443'
;   bm              INT           0
;   BAND            INT           0
;   grp             INT           0
;   num             INT           0
;-
function pdevfilelist,fnameAr,fnmIAr,recur=recur
;
    maxfiles=500L
    srchlist=file_search(fnamear,/mark_dir,count=nelm)
    if nelm eq 0 then return,0L
    fnmIAr=replicate({pdevfnmpars},maxfiles)
    itot=0L
    for ielm=0,nelm-1 do begin
        fnm=srchlist[ielm]
        if strmid(fnm,0,1,/reverse_offset) eq '/' then begin
           if keyword_set(recur) then begin
               flist=file_search(fnm,"?*.pdev",count=nfiles)    
           endif else begin 
               flist=file_search(fnm+"?*.pdev",count=nfiles)    
           endelse
        endif else begin
           flist=fnm
           fniles=1L
        endelse
        for ifile=0,nfiles-1 do begin
            istat=pdevparsfnm(flist[ifile],fnmI)
            if istat then begin
                fnmIAr[itot]=fnmI
                itot++
                if itot ge maxfiles then begin
                    fnmiArTmp=fnmIAr
                    maxFiles=maxFiles + maxFiles/2
                    fnmIar   =replicate({pdevfnmpars},maxFiles)
                    fnmIar[0:itot-1]=fnmIarTmp
                    fnmIarTmp=''
                endif
            endif
        endfor
    endfor
    if itot ne maxfiles then begin
        if itot eq 0 then begin
            fnmIAr=''
        endif else begin
            fnmIAr=fnmIAr[0L:itot-1]
        endelse
    endif
    return,itot
end
