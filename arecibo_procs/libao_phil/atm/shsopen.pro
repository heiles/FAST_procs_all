;+
;NAME:
;shsopen - open an atm shs file
;SYNTAX: istat=shsopen(filename,desc)
;ARGS:
;filename:  string filename of file to open
;RETURNS:
;  istat: int   1 open ok
;               0 couldn't open file
;   desc: {}    descriptor holding file info. pass this to the shs io routines.
;
;
;DESCRIPTION:
;   Open an atm shs file. Return a file descriptor that you will pass
;to the shsxxx i/o routines. The file is left positioned at the start hdr
;of the first table.
;-
function shsopen,filename,desc
;
;
    common shscom,shsnluns,shslunar

    tblslop=96*2L       ; bytes at end of each table ..
    openr,lun,filename,/get_lun,error=ioerr
    if ioerr ne 0 then begin
        print,'Open error:',!error_state.msg
        return,0
    endif
;
;   get the file size
;
    f=fstat(lun)
;
; read the primary header
;
    istat=shshdr_pri(lun,phdr)
    if istat ne 1 then begin
        free_lun,lun
        return,0
    endif
;
;   kludge... read blank line after primary, before data..
;   
    a=''
    readf,lun,a
    point_lun,-lun,pos_dhdrSt
;
;   read the first data header so we have a guess at how long the
;   tables are..
;
    istat=shshdr_dat(lun,dhdr)
    if istat ne 1 then begin
        print,'error reading first data header. status:',istat
        free_lun,lun
        return,0
    endif
    point_lun,-lun,pos_dhdrEnd  ; to get length of header
    point_lun,lun,pos_dhdrst    ; back to start of header
;
;   figure out bytes in 1st table.. include the 2*96 bytes at the
;
    dhdrlen=(pos_dhdrEnd - pos_dhdrSt) ; data hdr len
    tblLen=(dhdr.numdims eq 1)?dhdr.dim0:dhdr.dim0*dhdr.dim1
    tbllen=tbllen*dhdr.datawidth + dhdrlen +tblslop
;
; now put together the descriptor
;
    maxrec=((f.size)-pos_dhdrSt)/tbllen 
    desc={$
           lun  : lun ,$
           fname: filename,$
        filesize: f.size,$
          numrec: maxrec  ,$ number of recs in file
           phdr : phdr,$
          dhdr1 : dhdr,$
          tblst : pos_dhdrSt,$ byte position 1st table 
          tbllen: tbllen $; number of bytes in a table. hdr, data, slop
    }
    ind=where(shslunar eq 0,count)
    if count gt 0 then begin
        shslunar[ind[0]]=lun
        shsnluns=shsnluns+1
    endif


    return,1
end
