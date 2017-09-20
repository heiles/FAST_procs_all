;+
;NAME:
;arch_getdata - get cor data using the archive tbl arrays
;SYNTAX: n=arch_getdata(slAr,slfileAr,indAr,b,type=type,incompat=incompat,
;                       han=han,missing=missing,hdronly=hdronly)
;ARGS: 
;      slAr[l]   : {slwas} returned by arch_gettbl
;    slFileAr[m] : {slInd} returned by arch_gettbl
;     indAr[]    : long indices into slar to return
;KEYWORDS:
;       type     :  int  0 first  rec (hdr and data) of each scan1
;                :       1 hdrs from first rec of each scan
;                :       2 all recs each scan  (hdr and data)
;                :       3 average rec (hdr and data) each scan
;                :       4 all hdrs from scan
;hdronly         : if set, then type 0,2,3 will return a data
;                          struct with only b.n.h and b.h.hf no data will
;                          be returned. For was data, types 1,4 don't
;                          work since there are .h and .hf header 
;                          entries.
;RETURNS:
;     n :    int number of elements in b
;     b :    depending on type it can be {corget} or {hdr} 
;slind[n]: long the index into slar for each element returned in b.
;              
;incompat[p]   long indices in indAr that were not returned because the
;                   datatype differs from that of the first record
; missing[m]   long indices in indAr that were not in the file location
;                   that the database had recorded.
;
;DESCRIPTION:
;   After using arch_gettbl() and possibly where(), call this routine
;to read the header and data from disc. What you get back is determined by
;the keyword type and ind. The number of elements in b[] can be greater
;than the number of indices in ind[] (eg you asked for all of the records 
;of the scans, or you are returning just headers). The slind keyword
;array has the same number of elements as b. It contains the index into
;slAr for each elements of b.
;
;EXAMPLES
;
;;get all data for jan02->apr02 cband
;   nscans=arch_gettbl(20040101,20040430,slAr,slFileAr,rcv=9)
;
;;  get note.. corfindpat does not yet work with was data..
;;
;NOTE:
;   When returning just headers, each header of each board is returned
;as a separate entry in b[]. Use slind to figure out which scan each
;belongs to.
;-
; 12aug04. convert to work with was data 
;
function arch_getdata,slAr,slfilear,indar,b,type=type,incompat=incompat,$
                    han=han,maxrecs=maxrecs,slind=slind,missing=missing,$
                    hdronly=hdronly
;
;
    if not keyword_set(type) then type=0
;
;   if they didn't specify the maxrecs, compute it 
;
    if not keyword_set(maxrecs) then begin
       totscans=n_elements(indar)
       totrecs =total(slar[indar].numrecs)
       case type of
        0 : maxrecs=totscans
        1 : maxrecs=totscans*8
        2 : maxrecs=totrecs
        3 : maxrecs=totscans
        4 : maxrecs=totrecs*8
      else: maxrecs=totrecs
      endcase
     endif
    nindar=n_elements(indar)
    if not keyword_set(han)  then  han=0
    useIncompat=arg_present(incompat)
    useMissing =arg_present(missing)
    if useIncompat then begin
        incompat=lonarr(nindar)-1
        nincompat=0
    endif
    if useMissing then begin
        missing=lonarr(nindar)-1
        nmissing=0
    endif
    nb=0L
    maxb=maxrecs
    growb=maxb/2
    dohdr=(type eq 1) or (type eq 4)
    slind=lonarr(maxb)
    curfileInd=-1
    lun=-1
    fileOpen=-1
;    on_error,1
    sum= (type eq 3)
    for i=0L,n_elements(indar)-1 do begin
        indCur=indar[i]
        Find=slAr[indCur].fileindex
        if Find ne curFileInd then begin
            if fileOpen ne -1 then begin
                    wasclose,lun
            endif
            fileOpen=-1
            lun=-1
            fname=slfileAr[find].path + slfilear[find].file
            if file_exists(fname) then begin
                istat=wasopen(fname,lun)
                curfileind=find
                fileOpen=1
            endif else begin
;
;           file missing just skip..
;
               goto,botloop
            endelse
        endif
        istat=posscan(lun,slar[indCur].scan)
;       print,'ind,scan,point:',indCur,slar[indCur].scan,$
;                        slar[indcur].bytepos
        maxrecsLoc=slar[indcur].numrecs
        case type of 
            0 : istat=corget(lun,bloc,han=han,hdronly=hdronly)
            1 : istat=corgethdr(lun,bloc)
            2 : istat=corinpscan(lun,bloc,han=han,maxrecs=maxrecsLoc,$
                        hdronly=hdronly)
            3 : istat=corinpscan(lun,bloc,han=han,/sum,maxrecs=maxrecsLoc,$
                                  hdronly=hdronly)
            4 : begin
                jj=0
                for j=0,maxrecsLoc-1 do begin
                    istat=corgethdr(lun,hloc)
                    if istat eq 0 then break
                    nelmh=n_elements(hloc)
                    if j eq 0 then $
                        bloc=replicate(hloc[0],maxrecsLoc*nelmh)
                    bloc[jj:jj+nelmh-1]=hloc
                    jj=jj+nelmh
                endfor
                if jj ne maxrecsLoc then bloc=bloc[0:jj-1]
                end
         else : message,'Illegal type for arch_getdata.. 0 to 4'
         endcase
         if istat le 0 then begin
            if useMissing then begin
                missing[nmissing]=i
                nmissing=nmissing+1
            endif
            goto,botloop
         endif
         n=n_elements(bloc)
;
;       check that structures are compat .. (unless just headers)
;
         if (nb gt 0) and (not dohdr) then begin
            if corchkstr(b[0],bloc[0]) eq 0 then begin
                if useIncompat then begin
                    incompat[nincompat]=i
                    nincompat=nincompat + 1
                endif
                goto,botloop 
            endif
         endif
         if nb eq 0 then begin
            if (dohdr) then begin
                b=replicate(bloc[0],maxb)
            endif else begin
                b=corallocstr(bloc[0],maxb)
            endelse
        endif
        if (nb + n) gt maxb then begin
            if (nb+n) gt maxrecs then begin
                print,'Hit max records of:',maxrecs
                goto,done
            endif
            btemp=temporary(b)
            if dohdr then begin
                newmax=((maxb+growb) > (maxb + n)) < maxrecs
                b=replicate(b[0],newmax)
            endif else begin
                newmax=((maxb+growb) > (maxb + n)) < maxrecs
                b=corallocstr(btemp[0],newmax)
            endelse
            b[0:maxb-1]=btemp
            btemp=''
            slind=[slind,lonarr(newmax-maxb)]
            maxb=newmax
        endif
        if dohdr  then begin ;   headers..
            b[nb:nb+n-1]=bloc
        endif else begin
            corstostr,bloc,nb,b
        endelse
        slind[nb:nb+n-1]=indCur
        nb=nb+n
botloop:
    endfor
done:
    if fileOpen then begin
            wasclose,lun
    endif
    if nb eq 0 then begin 
        b=''
        slind=''
    endif else begin
        if nb ne maxb then begin
            b    =temporary(b[0:nb-1])
            slInd=temporary(slInd[0:nb-1])
        endif
    endelse
    if useincompat then begin
        if nincompat eq 0 then begin
            incompat=-1
        endif else begin
            incompat=incompat[0:nincompat-1L]
        endelse
    endif
    if useMissing then begin
        if nmissing eq 0 then begin
            missing=-1
        endif else begin
            missing  =missing[0:nmissing-1L]
        endelse
    endif
    return,nb
end
