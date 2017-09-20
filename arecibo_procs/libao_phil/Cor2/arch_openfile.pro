;+
;NAME:
;arch_openfile - open a file using archive arrays
;SYNTAX: stat=arch_openfile(slAr,slfileAr,ind,lun)
;ARGS: 
;      slAr[l]   : {sl} or {corsl} {slwas} returned by arch_gettbl
;    slFileAr[m] : {slInd} returned by arch_gettbl
;     ind        : long index into slar for file to open
;
;RETURNS:
;   stat:    int   1 opened ok, 0 could not open
;    lun:    int or {desc} for the open file
;
;DESCRIPTION:
;   arch_openfile() will open a file that contains a given scan.
;The user inputs slar[], slfilear[] that are returned by arch_gettbl()
;and an index into slar[] for the scan that you want. The routine will
;then find the file that this scan is in and open it. It returns the
;lun (or descriptor if this is a was file) that can then be used to
;do i/o on the file. The routine does not read any data from the file.
;   When done be sure and free the lun/desc using free_lun,lun or
;wasclose,lun
;
;EXAMPLES
;
;   For was data..
;
;;get table for data august 20 thru august 31 2004.
;   nscans=arch_gettbl(20040820,20040831,slAr,slFileAr)
;; find scan number=423314477L
;   scan=423314477L
;   ind=where(slar.scan eq scan,count)
;   if count eq 0 then begin
;      print,'scan:',scan,' not found'
;      goto,done
;   endif else begin
;      istat=slar_openfile(slar,slfilear,ind[0],desc)
;      if istat ne 1 then goto,done
;   endelse
;;
;; now input the scan
;;
;   istat=corinpscan(desc,b,scan=scan)
;   
;-
;
function arch_openfile,slAr,slfilear,ind,lun
;
;
    indl=ind[0]             ; make sure not an array
;
;    make sure index into slar is legal
;
    if (indl lt 0) or (indl ge n_elements(slar)) then begin
        print,'arch_openfile:Illegal index for slar'
        goto,errout
    endif
;
;   make sure that slar[ind]. file pointer is legal.
;
    find=slar[ind].fileindex
    if (find lt 0) or (find ge n_elements(slfilear)) then begin
        print,$
'arch_openfile:The slar passed has an illegal slfilear ind'
        goto,errout
    endif
    fname=slfileAr[find].path + slfilear[find].file
    useWas=wascheck(lun,file=fname)
    if not file_exists(fname) then begin
        print,'arch_openfile: file does not exist:',fname
        goto,errout
    endif
    if useWas then begin
        istat=wasopen(fname,lun)
        if istat eq 0 then begin
            print,'arch_openfile:could not open file:',fname
            goto,errout
        endif
    endif else begin
        openr,lun,fname,error=err,/get_lun
        if err ne 0 then begin
            print,'arch_openfile:err opening file:',!error_state.msg 
            goto,errout
        endif
    endelse
    return,1
errout:
    return,0
end
