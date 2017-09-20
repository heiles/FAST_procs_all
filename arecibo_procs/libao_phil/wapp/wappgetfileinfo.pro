;+
;NAME:
;wappgetfileinfo - get the list of filenames from the log file 
;
;SYNTAX: nentry=wappgetfileinfo(lunLog,wappI,projid=projid,maxentry=maxentry,
;                              logfile=logfile,newdir=newdir,badf=badf,$
;                               limdir=limdir)
;
;ARGS:
; lunLog:    long      logical unit number for logfile
;
;KEYWORDS:
;  projid:  string  if supplied then program will use the logfile in the online
;                   user directory: /share/obs4/usr/pulsar/projid/profid.cimalog
;                   comments below for logfile apply...
;maxentry:  int     maximum number of file sets to hold. 
;                   the default is 500.
; logFile:  string  if present (or projid supplied), then the routine will use 
;                   logfile rather than lunLog for the logfile to search. 
;                   The routine will open,read, and then close the file.
;                   In this case lunLog is ignored
;newdir[4]: string  a set of new directories to search in case the file locactions
;                   in the log file have been changed. include everything
;                   up to the basename: '/dat/wapp/a1840/wapp1/'
;limdir   :  string limit directories to search:
;                   "online" :  online or user supplied newdir 
;                   "proj"   :  only proj directory
;
;RETURNS:
;      nentry: long  number of file sets found
;    wappI[n]:{wappfileinfo} 1 entry per file set found.
;     badf[m]: string array of filenames that did not have mjd.seqnum format
;
;TERMINOLOGY:
;   file set:   the wapp will concurrenlty write 1 to 4 files (depending
;               on the number of wapps selected). These 1 to 4 files
;               are called a set.
;observation:   an observation starts when the user presses the observe
;               button on the gui and stops when the integration ends.
;               It can generate multple file sets if files grow larger than 
;               2.2 gb during the observation.
;
;DESCRIPTION: 
;   The wapp consists of up to 4 cpus (wapp1 thru wapp4). Each cpu writes
;it's data to a separate directory/file. Each observation starts a new file
;set. A single observation can create multiple file sets if more that 
;2.2 gigaBytes of data are taken per observation.
;
;   The gui will write the names of the various output files to the
;current logfile. This file is located in
;/share/obs4/usr/pulsar/"projid"/"projid".cima.log 
;
;   This routine will scan the logfile and create a structure containing
;information for all of the files found. There is 1 entry per file set.
;
;   Each entry contains:
;
;IDL> help,wappI,/st
;** Structure WAPPFILEINFO, 4 tags, length=9168, data length=9166:
;   ASTSEC          LONG             57453  startTm SecFromMidnite AST
;   NWAPPS          INT              4      number of wapps used
;   WAPPUSED        INT       Array[4]      1,0 if wapp used,notused
;   WAPP            STRUCT    -> WAPPFILECPU Array[4] info for each wapp
;
;IDL> help,wappI.wapp,/st
;** Structure WAPPFILECPU, 3 tags, length=2288, data length=2288:
;
;   DIR             STRING    '/share/wapp11/'              dir for file
;   FNAME           STRING    'adleo_calon.wapp.52803.015'  filename
;   filesize            0d       file size in bytes
;   HDR             STRUCT    -> HDRWAPP Array[1]           hdr for file
;
;   So the complete dir filename for wapp1 would be:
;   file=wappI[0].wapp[0].dir+wappI[0].wapp[0].fname
;
;   The routine reads in the header so it must be able to locate the 
;files on disc using the filename in the logfile. Any files that are
;missing are skipped.
;
;EXAMPLE:
;   logfile='/share/obs4/usr/pulsar/a1730/a1730.cimalog'
;   openr,lunlog,file,/get_lun
;   nsets=wappfilegetinfo(lunlog,wappI)
;   free_lun,lunlog
;
;   projid='a1730'
;   nsets=wappfilegetinfo(lunlog,wappI,projid=projid)
;
;NOTES:
;   If the files have been moved to some none standard directory,then 
;used the newdir keyword.
;-
;
function wappgetfileinfo,lunlogU,wappFileI,projid=projid,maxentry=maxentry,$
            logfile=logfile,newdir=newdir,badf=badf,limdir=limdir
;
;   see if they passes in the logfile name
;
    useLog=0
    logfilepath='/share/obs4/usr/pulsar/'
;
;   struct to hold the filenames found in the logfile
;
    badf=''
a={    fname    : ' '   ,$; filename with path
       bname    : ' '   ,$; base name no path 
       filesize :  0d   ,$;
       fileExists: 0     ,$; true if we opened the file ok
       hdr      : {hdrwapp}$ ; wapp hdr
    }
    if not keyword_set(limdir) then limdir=''
    chkonline=limdir ne 'proj'
    chkproj  =limdir ne 'online'
    projidpath=''
;
;    find the logfile
;
    if keyword_set(projid) then begin
        projidl=strlowcase(projid)      ; lower case
        logfile=logfilepath +  projidl + '/' + projidl+ '.cimalog'
        junk=findfile(logfile,count=count)
        if count le 0 then begin
            pp=strupcase(strmid(projidl,0,1)) + strmid(projidl,1)
            logfile=logfilepath+  projidl + '/' + pp + '.cimalog'
            junk=findfile(logfile,count=count)
            if count eq 0 then begin
                print,'could not find logfile for:',projid
                return,0
            endif
        endif
    endif
;
; see if we have a logfile
;
    if n_elements(logfile) gt 0 then begin
        ii=strpos(logfile,'/',/reverse_search)
        blogname=strmid(logfile,ii+1)        ; base name 
        ii=strpos(blogname,'.')
        if ii gt 0 then projidpath='/proj/'+ $
            strlowcase(strmid(blogname,0,ii))+'/'
        on_ioerror,open0
        istat=0
        lunLog=-1
        openr,lunLog,logfile,/get_lun
        istat=1
open0:  on_ioerror,NULL
        if istat eq 0 then begin
            print,'can not open logfile:',logfile
            if lunLog ne -1 then free_lun,lunLog
            return,0
         endif
         useLog=1
    endif else begin
        lunLog=lunLogU
        fstat=fstat(lunlog)
        logfile=fstat.name
        ii=strpos(logfile,'/',/reverse_search)
        blogname=strmid(logfile,ii+1)        ; base name
        ii=strpos(blogname,'.')
        if ii gt 0 then projidpath='/proj/'+ $
                strlowcase(strmid(blogname,0,ii))+ '/'
    endelse
    if n_elements(maxentry) eq 0 then maxentry=500
    maxFlist=maxentry*4l
    flistAr=replicate(a,maxFlist)

    wappFileI=replicate({wappFileInfo},maxentry)
    inpline=''
    inum=0
    nflist=0;                           ; number we have found
    while  not eof(lunlog)  do begin
        lun=-1
        readf,lunLog,inpline
        ind=strsplit(inpline,' ',length=length)
;
;       need 12 tokens, ind 7 is  open
;
        if (n_elements(ind) eq 12) then begin
            if strmid(inpline,ind[7],4) eq 'open' then begin
                iwapp=fix(strmid(inpline,ind[6]+5,1)) - 1
                fname= strmid(inpline,ind[8],length[8]-1)
                ii=strpos(fname,'/',/reverse_search)
                bname=strmid(fname,ii+1)        ; base name , no path
                if keyword_set(newdir) then begin
                    fname=newdir[iwapp] + bname
                endif
;
;   don't bother to check the same file twice
;
                if nflist ne 0 then begin
                    ind=where(flistAr[0:nflist-1].bname eq bname,count)
                    if count gt 0 then goto,botloop ; already processed  
                endif
                nflist=nflist+1
                if nflist gt maxFlist then goto,endFirstLoop
                flistar[nflist-1].fname = fname
                flistar[nflist-1].bname = bname
;
;           try to read file. 
;          1. on line directory or user supplied directory
;          2. /proj/projid/wappn/basename
;          3. /proj/projid/basename
;
                on_ioerror,open1
                istat=0
                lun=-1
                for jj=0,2 do begin
                    if ((jj eq 0) and (chkonline)) or $
                       ((jj gt 0) and (chkproj)) then begin 
;                       print,'checking:',fname
                        openr,lun,fname,/get_lun
;                       print,'open ok:',fname
                        istat=1
open1:          
                        if istat eq 1 then goto,lab1
                    endif
                    case jj of
                        0: fname=string(format='(a,"wapp",i1,"/",a)',projidpath,$
                                        iwapp+1,bname)
                        1: fname=projidpath+bname
                        else:
                    endcase
                endfor
lab1:           on_ioerror,NULL
                if istat ne 1 then goto,botloop; file missing
                flistar[nflist-1].fname = fname ; in case we changed the path
                istat=wappgethdr(lun,hdr)       ; get hdr
                if istat ne 1 then goto,botloop; could not read file
                f=fstat(lun)
                flistar[nflist-1].filesize=f.size
;               print,'got hdr:',fname
                if lun ne -1 then free_lun,lun
                flistAr[nflist-1].hdr=hdr
                flistAr[nflist-1].fileExists=1
            endif
        endif
botloop: if lun ne -1 then free_lun,lun
    endwhile
endfirstLoop:
;
;   throw out any files that we couldnot read 
;
    ind=where(flistar.fileExists eq 1,count)
    nflist=count
    if nflist eq 0 then goto,done
    flistar=flistar[ind]
;
;   grab the mjd.seqNum for sort. any files without this get moved to
;   badf keyword array
;
    a=stregex(flistar.fname,'[^.]+\.[^.]+$',/extract)
    ind=where(a eq '',count)
    if count gt 0 then begin
        badf=flistar[ind]
        ind=where(a ne '',count)
        nflist=count
        if nflist eq 0 then goto,done
        flistar=flistar[ind] 
        a=a[ind]
    endif
;
;   put in mjd.seqnum order
;
    ind=sort(a)             ; order to process files
;
;    now load wappFileInfo.. each entry has all files taken at same time
;
    inum=0
    for i=0,n_elements(ind)-1 do begin
          ii=ind[i]
          if i eq 0 then curmjdseq=a[ii]
          iwapp=long(strmid(flistar[ii].hdr.hostname,4,1))-1
          if iwapp eq -1 then goto,botloop1
          if curmjdseq ne a[ii] then begin
                inum=inum+1
                if inum ge maxentry then goto,done
                curmjdseq=a[ii]
          endif
          wappFileI[inum].wapp[iwapp].filesize=flistar[ii].filesize
          wappFileI[inum].wapp[iwapp].hdr=flistar[ii].hdr
          fname=flistar[ii].fname
          jj=strpos(fname,'/',/reverse_search)
          wappFileI[inum].wapp[iwapp].dir=strmid(fname,0,jj+1)
          wappFileI[inum].wapp[iwapp].fname=strmid(fname,jj+1)
          wappFileI[inum].nwapps= wappFileI[inum].nwapps + 1
          wappFileI[inum].wappused[iwapp]= 1
;
;       use the  gmt start time.. convert to ast
;
          gmtStr=flistar[ii].hdr.start_time ;"hh:mm:ss" gmt
          hr =long(strmid(gmtStr,0,2))
          min=long(strmid(gmtStr,3,2))
          sec=long(strmid(gmtStr,6,2))
          astSecs=(hr*3600L+min*60L+ sec)-4L*3600L           ; go to ast
          if astSecs lt 0 then astSecs=86400L + astSecs
          wappFileI[inum].astSec=astSecs
botloop1:
    endfor
done:  if wappFileI[inum].nwapps gt 0 then inum=inum+1 ; if last one active

    if inum eq 0 then begin
        wappfileI=''
    endif else begin
        if inum ne maxentry then wappfileI=wappfileI[0:inum-1]
    endelse
    if useLog then free_lun,lunLog
    return,inum
end
