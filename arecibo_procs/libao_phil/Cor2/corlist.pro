;+
;NAME:
;corlist - list contents of correlator data file
;SYNTAX: corlist,lun,recperpage,scan=scan,sl=sl,ast=ast
;ARGS:
;       lun:    int assigned to open file
;recperpage:    lines per page before wait for response. def:30
;KEYWORDS:
;      scan:  long position to scan before listing. def:rewind then list
;      sl[]:  {sl} returned from getsl(). If provided then direct
;                  access is available.
;      ast:        if set then print local time rather than lst for 
;                  start of each scan
;-
;modhistory:
;31jun00 - converted to new corget format
;07jul00 - losing last scan of file
pro corlist,lun,recperlist,scan=scan,sl=sl,ast=ast
;
; list the contents of the file
;    SOURCE       SCAN   GRPS    PROCEDURE     car0   lst   rcv
;                       freq      bwMhz  nchn lagcfg sbc    
;ssssssssssss ddddddddd ddddd xxxxxxxxxxbb xxxxxxxx hh:mm:ss dd
;                       ffff.ffff bb.bbb nnnn   dd    d
;
on_error,1
on_ioerror,done
lineToOutput=0
if (n_elements(recperlist) eq 0) then linemax=30L else linemax=recperlist
if (n_elements(scan) ne 0) then begin
    if keyword_set(sl) then begin
        istat=posscan(lun,scan,1,sl=sl)
    endif else begin
        istat=posscan(lun,scan)
    endelse
    if (istat ne 1) then message,"scan not found"
endif else begin
    rew,lun
endelse

curscan=-1L
currec=-1L
hdr={hdr}
point_lun,-lun,curpos
linecnt=0L
ch=0 
cm=0
cs=0
;  
timeLab=keyword_set(ast)?'AST':'LST' 
while (1 ) do begin
    readu,lun,hdr
    if chkswaprec(hdr.std) then begin
        hdr.std.scannumber=swap_endian(hdr.std.scannumber)
        hdr.pnt.r.lastRd  =swap_endian(hdr.pnt.r.lastRd)
        hdr.std.stscantime =swap_endian(hdr.std.stscantime)
        hdr.std.grpNum    =swap_endian(hdr.std.grpNum)
        hdr.std.reclen    =swap_endian(hdr.std.reclen)
        hdr.iflo.if1.st1  =swap_endian(hdr.iflo.if1.st1)
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
               print,"    SOURCE       SCAN   GRPS    PROCEDURE     STEP  " + $
                  timeLab + "   RCV"  
            endif
            print,format=$
       '(a12," ",i9," ",i5," ",a12,a8," ",i2.2,":",i2.2,":",i2.2," ",i2)', $
                src,curscan,currec,curproc,curstep,ch,cm,cs,currcv
            linecnt=linecnt+1
        endif
        curscan=hdr.std.scannumber
        currcv =iflohrfnum(hdr.iflo)
        src    =string(hdr.proc.srcname)
        curproc=string(hdr.proc.procname)
        curstep=string(hdr.proc.car[*,0]) 
        secMid=(keyword_set(ast))?hdr.std.stscantime  $
                                 :long(86400*hdr.pnt.r.lastRd/(!pi*2.))
        isecmidhms3,secMid,ch,cm,cs
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
            if (linecnt eq 0 ) then begin
               print,"    SOURCE       SCAN   GRPS    PROCEDURE     STEP  " + $
                  timeLab + "   RCV"  
            endif
  print,format=$
    '(a12," ",i9," ",i5," ",a12,a8," ",i2.2,":",i2.2,":",i2.2," ",i2)', $
      src,curscan,currec,curproc,curstep,ch,cm,cs,currcv
    endif

point_lun,lun,curpos
return
end
