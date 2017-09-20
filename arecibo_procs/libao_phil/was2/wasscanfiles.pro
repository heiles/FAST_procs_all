;+
;NAME:
;wasscanfiles - get info on each scan of requested files
;
; SYNTAX: istat=wasscanfiles(projId,scanI,yymmdd1=yymmdd1,yymmdd2=yymmdd2,$
;                            minsize=minsize,dir=dir,verb=verb)
;
; ARGS:
;      proj:  string  proj name to search for
;KEYWORDS:
; yymmdd1: long limit files to those starting on or after this date
;                (yymmdd1 included)
; yymmdd2: long limit files to those starting on or before this date
;               (yymmdd2 included)
; minsize: long minimum size in bytes for file to return. default is
;               100000 bytes. file less than this usually have no 
;               data (just a header). 
;dir     : string directory name to search instead of /proj/projid.. 
;                 handy to usr dir=/share/wappdata
;verb    :      if set the print out each scaninfo as it is processed
; RETURNS: 
;     nscans:  number of scans found 
;scanInfo[istat]:   array of scanInfo structures (see below).
;
;
;DESCRIPTION:
;   Search through the wapp fits directories looking for files that
;belong to a particular project. For each file found scan the file
;looking for info on each scan in the file. Use yymmdd1,2 to limit the
;search to a date range. 
;   By default this searches the offline /proj/projid directory.
;If you want to search the online files, set dir='/share/wappdata' in the 
;call.
;
;   For each can found, scanI[] contains:
;  FNAME           STRING    '/share/wappdata/wapp.20081017.a2350.0000.fits'
;   BNAME           STRING    'wapp.20081017.a2350.0000.fits'
;   FSIZE           ULONG        148424896
;   SCAN            LONG         829100053
;   RCVNUM          LONG                 9
;   RECTYPE         LONG                 3
;   NUMRECS         LONG                60
;   NUMFRQ          LONG                 8
;   FREQ            FLOAT     Array[8]
;   JULDAY          DOUBLE    2454756.276 
;   SRCNAME         STRING    'CRL618BP'
;   PROCNAME        STRING    'onoff'
;   OBSNAME         STRING    'ON'
;-
;
function wasscanfiles ,projId,scanI,dir=dir,yymmdd1=yymmdd1,yymmdd2=yymmdd2,$
                        minsize=minsize,verb=verb
;   
;
    mjdttojd=2400000.5D
    maxScans=1000L;
    if n_elements(minsize) eq 0 then minsize=100000L
    defdir='/proj/'+projId
    if not keyword_set(dir) then dir=defdir
    dirl=dir
    if strmid(dirl,strlen(dirl)-1,0) ne '/' then dirl=dirl+'/'
;       
    nfiles=0
    fpat=dirl+'wapp*'+projId+'*'+'.fits'
    flist=file_search(fpat,count=nfiles)
    if nfiles eq 0 then return,0
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
        i1=strpos(flist[0],'/wapp.20') + 6 ; start of date
        datel=long(strmid(flist,i1,8))
        ind=where((datel ge yy1) and (datel le yy2) ,nfiles)
        if nfiles eq 0 then begin
            nfiles=0
            scanI=''
            return,0
        endif
        flist=flist[ind]
    endif
    a={ fname      :''    ,$ ; complete filename
        bname      :''    ,$ ; base name
        fsize      :  0ul ,$
       SCAN        :   0L ,$
       RCVNUM      :   0L ,$
       RECTYPE     :   0L ,$
       NUMRECS     :   0L ,$
       NUMFRQ      :   0L ,$
       FREQ        :   fltarr(8),$
       JULDAY      :   0D,$
       SRCNAME     :   '',$
       PROCNAME    :   '',$
       obsname     :   ''} ; name of this scan within proc

    scanI=replicate(a,maxScans)
    icurScan=0L
tit='     scan  rcv nrecs  srcname     procname obsName  nbrds frq[0]'
    for ifile=0,nfiles-1 do begin
        istat=wasopen(flist[ifile],desc)
        if istat eq 0 then begin
            print,'Could not open: ',+flist[ifile]
            continue
        endif
        a=fstat(desc.lun)
        if a.size lt minsize then begin
			wasclose,desc
			continue
		endif
        if keyword_set(verb) then begin
            print,basename(flist[ifile])
            print,tit
        endif
        sl=getsl(desc)
        if (not keyword_set(sl)) then begin
            wasclose,desc
            continue
        endif
        nscans=n_elements(sl)
        for iscan=0,nscans-1 do begin
            scanI[icurScan].fsize=a.size
            scanI[icurScan].fname=flist[ifile]
            scanI[icurScan].bname=basename(flist[ifile])
            scanI[icurScan].scan  =sl[iscan].scan
            scanI[icurScan].rcvNum=sl[iscan].rcvNum
            scanI[icurScan].numFrq=sl[iscan].numFrq
            scanI[icurScan].recType=sl[iscan].recType
            scanI[icurScan].numRecs=sl[iscan].numRecs
            scanI[icurScan].julDay=sl[iscan].julDay 
            scanI[icurScan].srcName=sl[iscan].srcName
            scanI[icurScan].procName=sl[iscan].procName
            fxbread,desc.lun,obsname,desc.colI.scanType,$
                desc.scanI[iscan].rowstartind+1,errmsg=errmsg
            scanI[icurScan].obsname=obsname
            nf=scanI[icurScan].numFrq;
            if nf le 4 then begin
                scanI[icurScan].freq[0:nf-1]=sl[iscan].freq[0:nf-1]
            endif else begin
                 ilast=(desc.scanI[iscan].nbrds < nf)
                 for j=0,ilast-1 do begin
                   irow=desc.scanI[iscan].rowstartind  + $
                        desc.scanI[iscan].ind[0,j]
                   fxbread,desc.lun,frq,'CRVAL1',irow + 1,errmsg=errmsg
                   scanI[icurScan].freq[j] = frq*1d-6
                 endfor
            endelse
;'     scan  rcv nrecsx srcname     procname obsName  nbrds frq[0]'
; xxdddddddddxnxxdddddxssssssssssssXssssssssxssssssssxddddxfffff.ff
            if keyword_set(verb) then begin
lab=string(format=$
'(2x,i9,1x,i1,2x,i5,1x,a12,1x,a8,1x,a8,1x,i4,1x,f8.2)',$
            scanI[icurScan].scan,$
            scanI[icurScan].rcvnum,$
            scanI[icurScan].numrecs,$
            scanI[icurScan].srcname,$
            scanI[icurScan].procname,$
            scanI[icurScan].obsname,$
            scanI[icurScan].numfrq,$
            scanI[icurScan].freq[0]) 
            print,lab
            endif
            icurScan++
        endfor
        wasclose,desc
    endfor
    nscansTot=icurScan
    if nscansTot ne maxScans then begin
        if  nscansTot eq 0 then begin
            scanI=''
        endif else begin
            scanI=scanI[0:nscansTot-1]
        endelse
    endif
    return,nscansTot
end
