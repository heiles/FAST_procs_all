;+
;NAME:
;sl_mkarchive - create scan list for a set of files
;
;SYNTAX: nscans=sl_mkarchive(listfile,slAr,slfilear,logfile=logfile)
;
;ARGS:
;   listfile: string. filename holding names of files to scan 
;                     (one per line). semi-colon as the first char is a comment.
;KEYWORDS:
;   logfile: string   name of file to write progress messages. by default just 
;                     goes to stdout.
;
;RETURNS:
;   slAr[nscans] {sl}    One large scanlist array for all the files    
;   slfileAr[m]: {slInd} One entry per file showing where each file starts/
;                        stops in slAr.
;   nscans     : long  number of scans found
;
;KEYWORDS:
;DESCRIPTION:
;   Calls getsl() for every corfile filename in listfile. It creates one large 
;scanlist array for all of the scans. It also creates  an index array telling 
;where each file starts and stops in the slar.
;
;   The slAr[] is an array of structures (1 per scan) containing:
;
;    scan      :         0L, $; scannumber this entry
;    bytepos   :         0L,$; byte pos start of this scan
;    fileindex :         0L, $; lets you point to a filename array
;    stat      :         0B ,$; not used yet..
;    rcvnum    :         0B ,$; receiver number 1-16
;    numfrq    :         0B ,$; number of freq,cor boards used this scan
;    rectype   :         0B ,$;1-calon,2-caloff,3-posOn,4-posOff
;    numrecs   :         0L ,$; number of groups(records in scan)
;    freq      :   fltarr(4),$;topocentric freqMhz center each subband
;    julday    :         0.D,$; julian day start of scan
;    srcname   :         ' ',$;source name (max 12 long)
;    procname  :         ' '};procedure name used.
;
;   The slFileAr is an array of structures (1 per corfile):
;        path    : '' , $; pathname
;        file    : '' , $; filename
;        i1      : 0L , $; first index into slAr array for this file
;        i2      : 0L  } ; last index into  slAr array for this file
;
;EXAMPLE:
;   If the listfile contained:
;
;;  a comment
;/share/olcor/calfile.19mar01.a1400.1
;/share/olcor/calfile.20apr01.a1446.1
;/share/olcor/calfile.20apr01.a1489.1
;/share/olcor/calfile.20mar01.a1389.1
;
;It would process all 4 files and return the data in slAr, and slfilear.
;
;NOTE:
;   This routine is used to generate the save files that hold slar,slFileAr
;by month. arch_gettbl uses these save files.
;
;SEE ALSO:arch_gettbl,arch_getdata
;-
function  sl_mkarchive,listfile,slAr,slfilear,logfile=logfile

;    on_error,1
    useWas=0
    maxscans=30000L
    maxfiles=1000L
    filind=0L
    fileInp=0L
    fnameind=0
    scnInp=0L
    slAr    =replicate({sl}   ,maxscans)
    slFileAr=replicate({slInd},maxfiles)
    scangrow=maxScans/2
    filegrow=maxfiles/2
    cnt=0
    on_ioerror,done
    lun1=-1
    lun =-1
    lunOut=-1
    openr,lun1,listfile,/get_lun
    line=' '
    if n_elements(logfile) gt 0 then begin
        openw,lunout,logfile,/get_lun,/append
        printf,lunout,'starting sl_mkarchive' + systime()
    endif
    while 1 do begin
        readf,lun1,line    
;       print,'inp:'+line
        if strmid(line,0,1) ne ';' then  begin
            fullname=strsplit(line,' ',/extract)
            fullname=fullname[fnameind]
            lab=string(format='("processing file:",a," scans done:",i5)',$
                        fullname,scnInp)
            print,lab
            size=0L
            if lunOut ne -1 then printf,lunOut,lab
            stat=file_exists(fullname,junk,size=size)
            if (stat eq 1) and (size gt 0) then begin
                lun=-1
                error=0
                useWas=wascheck(lun,file=fullname) 
                if useWas then begin
                    istat=wasopen(fullname,lun) 
                    if istat eq 0 then error=1
                endif else begin
                    openr,lun,fullname,error=error,/get_lun
                endelse
                if error ne 0 then begin
                    lab='Err opening ' + fullname
                    print,lab
                    if lunOut ne -1 then printf,lunOut,lab
                    print,!error_stat.msg
                endif else begin
                    sl=getsl(lun)
                    if useWas then begin
                        wasclose,lun
                    endif else begin
                        free_lun,lun
                    endelse
                    lun=-1
                    n=n_elements(sl)
                    if n eq 0 then goto,botloop
;
;    run out of room??
;
                    if scnInp+n gt maxScans then begin
                        slArT=temporary(slAr)
                        slAr =replicate({sl},maxscans+scangrow)
                        slAr[0:maxscans-1]=slArT
                        slArT=''
                        maxScans=maxScans+scangrow
                    endif
                    if fileInp eq maxFiles then begin
                        slfileArT  =temporary(slfileAr)
                        slFileAr =replicate({slInd},maxfiles+filegrow)
                        slFileAr[0:maxfiles-1]=slFileArT
                        slFileArT=''
                        maxFiles=maxFiles+filegrow
                    endif
;
;               split,path and filename
;
                    ind=strpos(fullname,'/',/reverse_search)
                    if ind ne -1 then begin
                        filename=strmid(fullname,ind+1L)
                        pathname=strmid(fullname,0,ind+1L)
                    endif else begin
                        filename=fullname
                        pathname='./'
                    endelse
                    sl.fileindex=lonarr(n) + fileInp
                    slAr[scnInp:scnInp+n-1]=sl
                    slFileAr[fileInp].i1=scnInp
                    slFileAr[fileInp].i2=scnInp + n - 1L
                    slFileAr[fileInp].path=pathname
                    slFileAr[fileInp].file=filename
                    slFileAr[fileInp].size=size
                    scnInp =scnInp+n
                    fileInp=fileInp+1L
                endelse
            endif else begin
                lab='file:'+fullname+ ' has no data'
                print,lab
                if lunOut ne -1 then printf,lunOut,lab
            endelse
        endif       ;  end not comment
botloop: 
    endwhile
done:
    if not useWas then begin
        if lun  ne -1 then free_lun,lun
    endif
    if lun1 ne -1 then free_lun,lun1
    if lunOut ne -1 then begin
        printf,lunOut,'finished running sl_mkarchive'+ systime()
        free_lun,lunOut
        lunOut=-1
    endif
    if fileInp lt maxFiles then begin
        if fileinp eq 0 then begin
            slfilear=''
            slar=''
            scnInp=0L
        endif else begin
            if fileinp ne maxfiles then slFileAr=slFileAr[0:fileinp-1]
            if scnInp lt maxScans then  slAr    =   slAr[0:scnInp-1]
        endelse
    endif
    return,scnInp
end
