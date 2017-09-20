; 
;NAME:
; corinpscan - input a scans worth of data
;SYNTAX: istat=corinpscan(lun,b,braw,sum=sum,scan=scan,maxrecs=maxrecs,sl=sl,
;                         han=han,df=df)
;
; ARGS:
;         lun: int .. assigned to open file
;    b[ngrps]:  {} corget structs.
;brecs[ngrps]:  {} corget structs. optional argument. If
;                 /sum is set and braw is supplied, then the summary
;                 will be returned in b and the individual recs brecs.
;                 ..
; KEYWORDS:
;         sum: int .. if not zero then return avgerage of the scan records
;                     in b[]. The header is from the first record 
;                     (with modifications). If brecs is also supplied then
;                     the individual recs will be returned in brecs;
;     maxrecs: int .. max number of records we can read in when not
;                 computing summary. default is 300. If you have
;                 more records in scan then set this arg.
;        scan: long   position to scan before inputing.
;        sl[]: {sl} returned from getsl(). If provided then direct access
;                   to scan is available.
;         han: if set then hanning smooth the data.
;         df : if set then remove the digital filter bandpass from each record.
;       istat: int .. returns 1 ok, 0 error.
;
;DESCRIPTION:
;   corinpscan will input an entire scan. 
;It will return:
; - all the records in b[]             ( /sum not set )
; - only the average of the scan in b( /sum set, brecs not specified)
; - the average of the scan in b, all recs in brecs[](/sum set, brecs specified)
;
;The user can position to the scan using the keyword scan. Input must 
;start at the first record of the scan (if no positioning is selected).
;
;   The returned data will be a single {corget} structure (if /sum set) or
;and array b[ngrps] (or brecs[ngrsp]  of {corget} structures 
;(one for each integration in the scan.
;
;   When /sum is set then the header returned will be from the first 
;group of the scan with the following modifications:
;
;   h.std.gr,az,chttd will be the average value.
;   h.std.grpnum will be the number of groups input.
;   h.cor.lag0pwrratio  will be the average
;mod history:
;31jun00 updated to new corget format
;04jul00 return average az,gr,ch position and avg lag0pwrratio
;13aug00 added brecs optional arg
;26dec02 fixed bug where last scan of file skipped if 1 record long and
;        we read sequentially with corinpscan().
;     
;
function corinpscan,lun,b,brecs,sum=sum,maxrecs=maxrecs,scan=scan,$
                    sl=sl,dbg=dbg,han=han,df=df
;
;
    forward_function posscan

;    on_error,2  <FIX!!!>
    usewas=wascheck(lun)
    usebrecs=0
    if not keyword_set(han) then han=0
    if n_params() gt 2 then usebrecs=1
    if not keyword_set(maxrecs)  then maxrecs=300
    if maxrecs le 0 then maxrecs=300
    if not keyword_set(dbg) then dbg=0
    dosum=keyword_set(sum)
    if keyword_set(scan) then begin
        if usewas then begin
            istat=waspos(lun,scan,1)
        endif else begin
            if keyword_set(sl) then begin
                istat=posscan(lun,scan,1,sl=sl)
            endif else begin
                istat=posscan(lun,scan,1)
            endelse
        endelse
        if istat ne 1 then begin
            print,"scan",scan," not found"
            goto,errinp;
        endif
    endif else begin
        scan=-1
    endelse
    if dbg then cumread=0.D
    limit=9999
    if ((not dosum) or (usebrecs)) then limit=maxrecs
    hitEof=0
    for grp=0L,limit-1 do begin
;
;     get a record
; 
      if dbg then starttm=systime(1)
      if usewas then begin
          curpos=lun.curpos
          istat=wasget(lun,bl,han=han)
      endif else begin  
          point_lun,-lun,curpos
          istat=corget(lun,bl,han=han)
;;    print,'istatcorget, grp:',istat,grp 
      endelse
      if dbg then cumread=cumread+(systime(1)-starttm)
      if istat eq  0 then begin
        if grp eq 0 then  goto,errinp 
        hitEof=1
        goto,done
      endif
      if istat eq -1 then goto,errinp
;
;       if dig filter removal, get bp, fix first 
;
        if keyword_set(df) and (not usewas) then begin ; <FIX!!!>
            if grp eq 0 then dfbp=cordfbp(bl)
            bl=cormath(bl,dfbp,/div)
        endif
;
;     some checks to see if this is the start of the scan
;
      if (grp eq 0) then begin
        if (bl.(0).h.std.grpNum ne 1) then begin
            print,"not positioned at start of scan:",$
                bl.(0).h.std.scannumber,bl.(0).h.std.grpNum
            goto,errinp
        endif
        nbrds=bl.(0).h.cor.numbrdsused
        if (scan eq -1) then scan=bl.(0).h.std.scannumber
        if ( dosum ) then begin
            b=bl
            if (usebrecs) then brecs=corallocstr(bl,maxrecs)
        endif else begin 
            b=corallocstr(bl,maxrecs)
        endelse
      endif
      if bl.(0).h.std.scannumber ne scan then goto,done
      if dosum then begin
         if grp ne 0 then begin
            for i=0,nbrds-1 do begin
                b.(i).d=b.(i).d + bl.(i).d    
                b.(i).h.std.azttd= b.(i).h.std.azttd + bl.(i).h.std.azttd
                b.(i).h.std.grttd= b.(i).h.std.grttd + bl.(i).h.std.grttd
                b.(i).h.std.chttd= b.(i).h.std.chttd + bl.(i).h.std.chttd
                b.(i).h.cor.lag0pwrratio= b.(i).h.cor.lag0pwrratio + $
                                   bl.(i).h.cor.lag0pwrratio
            endfor
         endif
         if (usebrecs) then corstostr,bl,grp,brecs 
      endif else begin
        corstostr,bl,grp,b 
      endelse
    endfor
done:
    if (grp ne limit) and (not hitEof) then begin
        if usewas then begin
            lun.curpos=curpos
        endif else begin
            point_lun,lun,curpos
        endelse
    endif
    if dosum then begin
        scl=1./grp
        for i=0,nbrds-1 do begin
                b.(i).d=b.(i).d*scl
                b.(i).h.std.azttd      = b.(i).h.std.azttd/grp
                b.(i).h.std.grttd      = b.(i).h.std.grttd/grp
                b.(i).h.std.chttd      = b.(i).h.std.chttd/grp
                b.(i).h.std.grpnum     = grp
                b.(i).h.cor.lag0pwrratio= b.(i).h.cor.lag0pwrratio*scl
        endfor
        if (grp ne maxrecs) and (usebrecs) then begin
            brecs=brecs[0:grp-1]
        endif
    endif else begin
        if grp ne maxrecs then begin
            b=b[0:grp-1]
        endif
    endelse
    if (dbg) then print,'corinpscan: tmcorget:',cumread
    return,1
errinp:
    return,0
end
