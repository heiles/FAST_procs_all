;+
;NAME:
;scanlist - list contents of  data file
;SYNTAX: scanlist,lun,recperpage,scan=scan,search=search,std=std,verb=verb
;ARGS:
;       lun:    int assigned to open file
;recperpage:    lines per page before wait for response. def:30
;KEYWORDS:
;    scan:  long position to scan before listing. def:rewind then list
;  search:       if set, then search for header rec if not found at current
;                position
;  std   :      if set then assume std data
;  verb  :      if set then print info each record read
;DESCRPIPTION:
;   list a summary of all of the scans in a file to  stdout. This works for
;correlator or ri datafiles.
;   The output data is:
;
;    SOURCE       SCAN   GRPS    PROCEDURE     car0   lst
;
; Where grps is the number of recs in the file, procedure is the procedure
;name that was used to take the data, car0 is the first entry in the
;carr[] of the header (typically it has the step in the pattern like
; on or off), and lst is the local sidereal time.
;SEE ALSO:
;   corlist
;-
;modhistory:
;31jun00 - converted to new corget format
;07jul00 - losing last scan of file
pro scanlist,lun,recperlist,scan=scan,search=search,std=std,verb=verb
;
; list the contents of the file
;    SOURCE       SCAN   GRPS    PROCEDURE     car0   lst
;ssssssssssss ddddddddd ddddd xxxxxxxxxxxx xxxxxxxx hh:mm:ss
;
;on_error,1
on_ioerror,done
lineToOutput=0
useStd=keyword_set(std)
if (n_elements(recperlist) eq 0) then linemax=30L else linemax=recperlist
if (n_elements(scan) ne 0) then begin
    istat=posscan(lun,scan)
    if (istat ne 1) then message,"scan not found"
endif else begin
    rew,lun
endelse
if n_elements(search) eq 0 then search=0

curscan=-1L
currec=-1L
if useStd then begin
    hdr={ std: {hdrStd}}
endif else begin
    hdr={hdr}
endelse
point_lun,-lun,curpos
linecnt=0L
ch=0 
cm=0
cs=0
firsttime=1
recNum=0L
while (1 ) do begin
        if (firsttime and  keyword_set(search)) then begin
            istat=searchhdr(lun)
            point_lun,-lun,curpos
        endif
        firsttime=0
        readu,lun,hdr
        recNum=recNum+1
;
;   check if this is a header
;
        if string(hdr.std.hdrmarker) ne 'hdr_' then begin
            print,'bad hdrid:',string(hdr.std.hdrmarker),' rec:',recNum,' byte:',curpos
            point_lun,lun,curpos
            return
        endif
            
        if chkswaprec(hdr.std) then hdr=swap_endian(hdr)
        if keyword_set(verb) then begin
            lab=string(format=$
'("rec:",i5," scn:",i9," grp:",i5," Id:",a8," pos:",I9," h,dlen:",i6,i7)',$
    recnum,hdr.std.scannumber,hdr.std.grpnum,string(hdr.std.id),curpos,$
            hdr.std.hdrlen, hdr.std.reclen-hdr.std.hdrlen)
            print,lab
            linecnt=linecnt+1
            if (linecnt ge linemax) then begin
                ans=' '
                read,"Enter return to continue, q to quit",ans
                if (ans eq 'q') then goto,done
                linecnt=0
            endif
        endif
;
;   if new scan,output old summary
;

    if (hdr.std.scannumber ne curscan) then begin
        if (lineToOutput ) then begin
            if (linecnt ge linemax) then begin
                ans=' '
                read,"Enter return to continue, q to quit",ans
                if (ans eq 'q') then goto,done
                linecnt=0
            endif
            if (linecnt eq 0 ) then begin
        print,"    SOURCE       SCAN   GRPS    PROCEDURE     STEP  LST"    
            endif
    print,format='(a12," ",i9," ",i5," ",a12,a8," ",i2.2,":",i2.2,":",i2.2)', $
                src,curscan,currec,curproc,curstep,ch,cm,cs
            linecnt=linecnt+1
        endif
        curscan=hdr.std.scannumber
        if (hdr.std.sec.misc ne 0) and (not keyword_set(std)) then  begin
            src    =string(hdr.proc.srcname)
            curproc=string(hdr.proc.procname)
            curstep=string(hdr.proc.car[*,0])
        endif else begin
            src='nosrc'
            curproc='noproc'
            curstep='nostep'
        endelse
        if (hdr.std.sec.pnt ne 0) and (not keyword_set(std)) then  begin
            lastSec=long(86400*hdr.pnt.r.lastRd/(!pi*2.))
            isecmidhms3,lastSec,ch,cm,cs
        endif else begin
            ch=0
            cm=0 
            cs=0
        endelse
;       print,lastSec,ch,ch,cs
    endif
    lineToOutput=1
;
;   position to next rec
;
    currec =hdr.std.grpNum
    curpos=curpos + hdr.std.reclen
    point_lun,lun,curpos
end
done:
    if lineToOutput then begin
  print,format='(a12," ",i9," ",i5," ",a12,a8," ",i2.2,":",i2.2,":",i2.2)', $
      src,curscan,currec,curproc,curstep,ch,cm,cs
    endif

point_lun,lun,curpos
return
end
