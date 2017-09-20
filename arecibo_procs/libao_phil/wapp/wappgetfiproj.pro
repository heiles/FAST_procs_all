;+
;NAME:
;wappgetFIproj - get the list of filenames for a project
;
;SYNTAX: nentry=wappgetFIproj(projid,wappI,badhdr=badhdr,online=online,$
;                             yymmdd=yymmdd)
;
;ARGS:
; projid: string       project id to search for
;
;KEYWORDS:
;   online:     if set then try searching the online discs (if they are
;               mounted.
;yymmdd[2]:long  limit search to this date range [yymmdd1,yymmdd2] (ast)
;
;RETURNS:
;      nentry: long  number of file sets found
;    wappI[n]:{wappfileinfo} 1 entry per file set found.
;     badhdr[m]: string array of filenames that did not have valid headers
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
;   nsets=wappfileFIproj(proj,wappI)
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
function wappgetfiproj,projid,wappFileI,badhdr=badhdr,online=online,$
                 badmjd=badmjd,yymmdd=yymmdd
;
; see if they want the online directories
;
    mjdtojd=2400000.5D
    useMjdLim=(n_elements(yymmdd) gt 0)
    if useMjdLim then begin
        yymmddl=lonarr(2)
        yymmddl[0]=yymmdd[0]
        yymmddl[1]=(n_elements(yymmdd) gt 1)?yymmdd[1]:yymmdd[0]
        yymmddl[1]= yymmddl[1] + 1L ; 
        mjd1=long(yymmddtojulday(yymmddl[0]) + 4D/24. - mjdtojd)
        mjd2=long(yymmddtojulday(yymmddl[1]) + 4D/24. - mjdtojd)
    endif
    if not keyword_set(online) then online=0
    onldir=['/share/wapp11/',$
            '/share/wapp21/',$
            '/share/wapp31/',$
            '/share/wapp41/']

    quote='"'
    projnum=strmid(projid,1)
    nfiles=0
    char1=strmid(projid,0,1)
    charLc=strlowcase(char1)
    charUc=strupcase(char1)
    charLUc=charLc+charUc
    projidlc=charLc + projnum
;
;   see if the projid exists
;
    if projidLc eq 'x107' then begin
        projidl='x107alfa'
    endif else begin
        projidl=projidLc
    endelse
    if (not file_test('/proj/'+projidl)) and (not online) then  return,0
;
;   struct to hold the filenames found in the logfile
;
a={    fname    : ' '   ,$; filename with path
       bname    : ' '   ,$; base name no path 
       filesize : 0d    ,$;
           hdrOk:  0     ,$; true if we opened the file ok
       hdr      : {hdrwapp}$ ; wapp hdr
    }
;
;   see if we search the online directories
;
;   ls  [xX]*.[0-9][0-9][0-9][0-9] 
    if online then begin
        for i=0,n_elements(onldir)-1 do begin   
            cmd=string(format='("ls ",a,"[",a,"]",a,"*.[0-9][0-9][0-9][0-9]")',$
                onldir[i],charLUc,projnum)
            spawn,cmd,files
            count=n_elements(files)
            if count gt 0 then begin
               if files[0] ne '' then begin
                filear=(nfiles eq 0)?files:[filear,files]
                nfiles=nfiles+count
               endif
            endif
        endfor
    endif
;    
        cmd=string(format=$
            '(" find /proj/",a," -name ",a,"[",a,"]",a,"*wapp[1-4]*",a)',$
                    projidl,quote,charLUc,projnum,quote)
        spawn,cmd,files
;
;    find the logfile
;
    n=n_elements(files)
    if keyword_set(files) then begin
            filear=(nfiles eq 0)?files:[filear,files]
            nfiles=nfiles+n
    endif
    if nfiles eq 0 then return,0
;
;    see if the limit to a date range
;
    if useMjdLim then begin
        keepfiles=intarr(nfiles)
        for i=0L,nfiles-1 do begin &$
            fname=filear[i] &$
            ii=strpos(fname,'.',7,/reverse_offset,/reverse_search) &$
            mjdstr=strmid(fname,ii+1,5)
            if (strmatch(mjdstr,'[0-9][0-9][0-9][0-9][0-9]') eq 1 ) then begin
                mjd=long(strmid(fname,ii+1,5)) &$
                keepfiles[i]=(mjd1 le mjd) and (mjd le mjd2) &$
            endif else begin
                print,'Bad mjd in:',fname &$
                keepfiles[i]=0
            endelse
        endfor
        ind=where(keepfiles ne 0,count)
        if count eq 0 then return,0
        if count ne nfiles then begin
            filear=filear[ind]
            nfiles=count
        endif
    endif

    flistAr=replicate(a,nfiles)

    wappFileI=replicate({wappFileInfo},nfiles)
    inpline=''
    inum=0
    nflist=0;                           ; number we have found
    on_ioerror,null
;   print,'nfiles:',nfiles
;
;   loop over the files we found
;
    for i=0L,nfiles-1 do begin
        fname=filear[i]
        lun=-1
;       print,'checking:',fname
        err=0
        openr,lun,fname,/get_lun,error=err
        if err ne 0 then begin
;           print,'missing:',fname
            goto,botloop; file missing
        endif
;       print,'open ok:',fname
        ii=strpos(fname,'/',/reverse_search)
        bname=strmid(fname,ii+1) ; base name , no path
        if nflist ne 0 then begin
             ind=where((flistAr[0:nflist-1].bname eq bname) and $
                       (flistAr[0:nflist-1].hdrOk eq 1),count)
             if count gt 0 then begin
                print,'dup:',fname
                goto,botloop ; already processed
            endif

        endif
        istat=wappgethdr(lun,hdr)       ; get hdr
        flistAr[nflist].fname=fname
        flistAr[nflist].bname=bname
        f=fstat(lun)
        flistAr[nflist].filesize=f.size
        if  istat eq 1 then begin
            flistAr[nflist].hdr=hdr
            flistAr[nflist].hdrOk=1
        endif
        nflist=nflist+1L
botloop: if lun ne -1 then free_lun,lun
    endfor
;
;   throw out any files that we could not read 
;
    if nflist lt nfiles then begin
        if nflist eq 0 then begin
            goto,done
        endif else begin
            flistar=flistar[0:nflist-1]
        endelse
    endif
    if arg_present(badhdr) then begin
        ind=where(flistar.hdrOk eq 0,count)
        if count gt 0 then begin
            badhdr=flistar[ind].fname
;           print,'badhdr',count
        endif else begin
            badhdr=''
        endelse
    endif
    ind=where(flistar.hdrOk eq 1,count)
    nflist=count
    if nflist eq 0 then goto,done
    flistar=flistar[ind]
;
;   grab the mjd.seqNum for sort. any files without this get moved to
;   badmjd keyword array
;
    a=stregex(flistar.fname,'[^.]+\.[^.]+$',/extract)
    ind=where(a eq '',count)
    if count gt 0 then begin
        badmjd=flistar[ind]
;       print,'badmjd:',count
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
    for i=0L,n_elements(ind)-1 do begin
          ii=ind[i]
          if i eq 0 then curmjdseq=a[ii]
          iwapp=long(strmid(flistar[ii].hdr.hostname,4,1))-1
          if iwapp eq -1 then begin
;               print,'iwapp -1:',flistar[ii].hdr.hostname
                goto,botloop1
          endif
          if curmjdseq ne a[ii] then begin
                inum=inum+1
                curmjdseq=a[ii]
          endif
          wappFileI[inum].wapp[iwapp].hdr=flistar[ii].hdr
          fname=flistar[ii].fname
          jj=strpos(fname,'/',/reverse_search)
          wappFileI[inum].wapp[iwapp].dir=strmid(fname,0,jj+1)
          wappFileI[inum].wapp[iwapp].fname=strmid(fname,jj+1)
          wappFileI[inum].wapp[iwapp].filesize=flistAr[ii].filesize
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
        if inum ne nflist then wappfileI=wappfileI[0:inum-1]
    endelse
    return,inum
end
