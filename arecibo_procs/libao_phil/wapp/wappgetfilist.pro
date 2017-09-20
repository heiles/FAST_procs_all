;+
;NAME:
;wappgetfilist - get fileinfo structure from file list
;SYNTAX: nentry=wappgetFIlist(filelist,wappI,verbose=verbose,$
;                 missingfiles=missingfiles,nmissing=nmissing)
;ARGS:
; filelist[n]: string   list of wapp datafiles to read.
;KEYWORDS:
;   verbose:        if set then print out some info while running.
;
;RETURNS:
;      nentry   : long  number of file sets found
;    wappI[n]   :{wappfileinfo} 1 entry per file set found.
;missingfiles[m]: string list of files that were not found or could not
;                        be read correctly
;nmissing       : int    number of missing files.
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
;   The user inputs a list of wapp datafile names (including the directory).
;This routine creates a wappI structure for each file set found.
;The structure contains:
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
;   filesize             0d                                 bytes in file
;   HDR             STRUCT    -> HDRWAPP Array[1]           hdr for file
;
;   So the complete dir filename for wapp1 would be:
;   file=wappI[0].wapp[0].dir+wappI[0].wapp[0].fname
;
;   The routine reads in the header so it must be able to locate the
;files on disc using the filenames provided. Any files that can not be
;processed are skipped. They are also recorded in nmissing and 
;missingfiles[].
;
;EXAMPLE:
;   flist=[$
;    '/proj/p1555/P1555.1904+0412.wapp1.52884.0001',$
;    '/proj/p1555/P1555.1904+0412.wapp1.52884.0002']
;   nsets=wappgetFIlist(flist,wappI)
;-
function  wappgetfilist,flistInp,wappfileI,verbose=verbose,$
                nmissing=nmissing,missingfiles=missingfiles  
;
    aa={    fname    : ' '   ,$; filename with path
           bname    : ' '   ,$; base name no path
            hdrOk   :  0     ,$; true if we opened the file ok
            size    : 0D     ,$; size in bytes
           hdr      : {hdrwapp}$ ; wapp hdr
     }
;
;   get the base name, make sure filename format ok
;   must end with .nnnnn.nnnn   to be a pulsar file (mjd.seqnum)
;
    flist=flistInp
    nmissing=0L
    retmissing=arg_present(missingfiles)
    nfiles=n_elements(flist)
    useVerbose=keyword_set(verbose)
    bnameAr=stregex(flist,'.*/(.*[0-9]{5}.[0-9]{4})',/extract,/sub)
    ind=where(bnameAr[1,*] ne '',count)
    if count eq 0 then return,0
    if count ne nfiles then begin
       flist=flist[ind]
       nfiles=n_elements(flist)
    endif
    if retmissing then missingfiles=strarr(nfiles) 
    bnameAr=reform(bnameAr[1,ind])
;
    flistAr=replicate(aa,nfiles)
    flistAr.fname=flist                     ; full name 
    flistAr.bname=bnameAr                   ; base name
;
;   now loop on the filenames
;
    if useVerbose then begin
         lab=string(format='("start ",i5," header reads")',nfiles);
         print,lab
    endif
    for i=0,nfiles-1 do begin
        lun=-1
        err=0
        openr,lun,flistAr[i].fname,/get_lun,error=err
        if err ne 0 then begin
            goto,botloop; file missing
        endif
;
;       deal with duplicate files, maybe in 2 different directories
;
        ind=where((flistAr[0:i].bname eq bnameAr[i]) and $
                  (flistAr[0:i].hdrOk eq 1),count)
        if count gt 0 then begin
           print,'dup:',bnameAr[i]
           goto,botloop ; already processed
        endif
        istat=wappgethdr(lun,hdr)       ; get hdr
        if  istat eq 1 then begin
            flistAr[i].hdr=hdr
            flistAr[i].hdrOk=1
        endif 
        f=fstat(lun)
        flistAr[i].size=f.size
botloop: if lun ne -1 then free_lun,lun
    endfor
;
;   throw out any files that we could not read
;
    wappNumAr=long(stregex(flistar.hdr.hostname,'[1-4]$',/extract))
    ind=where((flistar.hdrOk eq 1) and $
                ((wappNumAr ge 1) and (wappNumAr le 4)),count)
    if count ne nfiles then begin
         if retmissing then begin
            aa=intarr(nfiles)
            aa[ind]=1
            ii=where(aa eq 0,jj)
            missingfiles[nmissing:nmissing+jj-1]=flistar[ii].fname
        endif
        nmissing=nmissing + (nfiles-count)
        nfiles=count
        if nfiles eq 0 then goto,nofiles
        flistar=flistar[ind]
        wappNumAr=wappNumAr[ind]
    endif
;
;   grab the mjd.seqNum and sort it so we can find the files
;   that were taken together.
;
    mjdseq=stregex(flistar.bname,'[^.]+\.[^.]+$',/extract)
    indsort=sort(mjdseq)
;
;   grab some info that will be used to load into wappinfo
;   quicker to do it outside the loop
;
    iwappAr=wappnumAr - 1
    dirAr=stregex(flistar.fname,'^.*/',/extract)
;
    tmp=stregex(flistAr.hdr.start_time,'([0-9]*):([0-9]*):([0-9]*)',$
                    /extract,/sub)
    hrAr =long(tmp[1,*])
    minAr=long(tmp[2,*])
    secAr=long(tmp[3,*])
    astAr=reform((hrAr*3600L + minAr*60L + secAr) - 4L*3600L)
    ind=where(astAr lt 0,count)
    if count gt 0 then astAr[ind]=astAr[ind] + 86400l
;
;
;   now load wappFileInfo.. each entry has all files taken at same time
;
    wappFileI=replicate({wappFileInfo},nfiles)
    inum=0L
    curmjdseq=mjdseq[indsort[0]]
    for i=0,n_elements(indsort)-1 do begin &$
          ii=indsort[i] &$
          if curmjdseq ne mjdseq[ii] then begin &$ ; done this file set 
                inum=inum+1 &$
                curmjdseq=mjdseq[ii] &$
          endif &$
          iwapp=iwappAr[ii] &$
          wappFileI[inum].wapp[iwapp].hdr=flistar[ii].hdr &$
          wappFileI[inum].wapp[iwapp].dir  =dirAr[ii] &$
          wappFileI[inum].wapp[iwapp].fname=flistAr[ii].bname &$
          wappFileI[inum].wapp[iwapp].filesize=flistAr[ii].size &$
          wappFileI[inum].nwapps= wappFileI[inum].nwapps + 1 &$
          wappFileI[inum].wappused[iwapp]= 1 &$
          wappFileI[inum].astSec=astAr[ii] &$
    endfor
;
    
    if retmissing then begin
       if nmissing ne 0 then begin
          missingfiles=missingfiles[0:nmissing-1]
       endif else begin
          missingfiles=''
       endelse
    endif
    ntot=(wappFileI[inum].nwapps gt 0)?inum+1:inum
    if ntot eq 0 then goto,nofiles
    if ntot ne nfiles then wappfileI=wappfileI[0:ntot-1]
    return,ntot
nofiles:
    wappfileI=''
    ntot=0
    return,ntot
end
