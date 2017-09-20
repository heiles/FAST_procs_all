;+
;NAME:
;wapptpfile - get total power from file (opt dedisp)
;SYNTAX: npts=wapptpfile(filename,tp,dm=dm,maxsmp=maxsmp,hdr=hdr)
;
;ARGS:
;filename:  string  filename to process
;KEYWORDS:
;      DM:   float  if supplied then dedisperse the data with this dm.
;  maxsmp:   long   number of time samples to return. Default is the
;                   entire file.
;RETURNS:
;   npts:    long    number of time points returned
; tp[npts,nspc] float The total power series. There will be npts time samples.
;                    nspc will depend on how many spectra (acfs) were taken
;                    per time sample (1 2, or 4)
;  hdr{}:            wapp header structure for this file
;
;DESCRIPTION:
;   Input the total power time series for a file. If the dm keyword is 
;supplied then dedisperse the time series first. There will be one
;set of time samples for each acf/spectra type in the file: 1,2pol, 4 2polsalfa
;
;SEE ALSO sp_dedisperse
;-
function wapptpfile,file,tp,dm=dm,maxsmp=maxsmp,hdr=hdr
;
    npntsDone=0L                        ; total point read
    bufSzInp=long(100e6)
    dedisp=(n_elements(dm) gt 0)
    npntsTot=(n_elements(maxsmp) eq 0)?2e9:maxsmp ; make big value 
    lun=-1
    openr,lun,file,/get_lun
    istat=wappgethdr(lun,hdr)
    if (wappfilesizei(lun,hdr,fszI) ne 1) then goto,done
    npntsTot= (npntsTot < fszi.nrecs)
;   
    if dedisp then begin
        npntsDone=sp_dedisp(file,dm,tp,maxsmp=npntsTot)
    endif else begin
        istat=wappget(lun,hdr,a,posrec=1,nrec=1,/retpwr)
        pntSmp=n_elements(a)                ; spc in 1 read
        tp=fltarr(npntsTot,pntSmp)
        recsPerRead=bufSzInp/fszI.bytesRec
        nreads=(npntsTot/recsPerRead)
        recsLastRead=recsPerRead
        if (nreads*recsPerRead lt npntsTot) then begin
            recsLastRead=(npntsTot-nreads*recsPerRead)
            nreads=nreads+1
        endif
        posrec=1L
        done=0
        iread=0L
        while (not done ) do begin
            nrecs=((iread+1) eq nreads)?recsLastRead:recsPerRead
            recRead=wappget(lun,hdr,d,nrec=nrecs,posrec=posrec,/retpwr)
            posrec=0
            if recRead le 0 then begin
                done=1
            endif else begin
                if pntSmp gt 1 then begin
                    tp[npntsDone:npntsDone+recRead-1,*]=transpose(d)
                endif else begin
                    tp[npntsDone:npntsDone+recRead-1]=d
                endelse
                npntsDone+=recRead
                iread+=1L
                done=iread ge nreads
            endelse
        endwhile
    endelse
done:
    if npntsDone eq 0 then begin
        tp=''
    endif else begin
        if (npntsDone lt npntsTot) then begin
            tp=(pntSmp eq 1)?tp[0L:npntsDone-1]:tp[0L:npntsDone-1L,*]
        endif
    endelse
    if lun ne -1 then free_lun,lun
    return,npntsDone
end
