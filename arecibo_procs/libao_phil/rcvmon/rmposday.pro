;+
;NAME:
;rmposday - position to start of day
;SYNTAX: istat=rmposday(lun,yymmdd)
;ARGS:
;   lun :       int file containing data to read
; yymmdd:  long requested number of records to read
;RETURNS:
;   istat : int  0 - positioned at start (yymmdd <= first rec)
;                1 - positioned in file
;                2 - positioned at end (yymmdd > last rec of file)
;DESCRIPTION:
;   rmposday will position to the start of a day within the file.
;This routine is normally called from rminpday().
;
;EXAMPLE:
;   openr,lun,'/share/obs4/rcvm/rcvmN',/get_lun
;   yymmdd=021105
;   istat=rmposday(lun,yymmdd)
;
;-
function rmposday,lun,yymmdd
;
    on_ioerror,done

    returnStat=1L
    year=yymmdd/10000L
    if year gt 50 then begin
        year=year+1900
    endif else begin
        year=year+2000
    endelse
    day=yymmdd mod 100L
    mon=(yymmdd / 100L) mod 100L
    dayno=dmtodayno(day,mon,year)
;
    blkRecs=10000L
    recSize=n_tags({rcvmon},/len)
    blkBytes=recSize*blkRecs
    inpblk=replicate({rcvmon},blkRecs)
    onerec={rcvmon}
    fstatd=fstat(lun)
    bytesPerDayApprox=recSize*86400L/2L ; assume 2 secs per sample
    a=1234L
     byteorder,a,/htonl
;    byteorder,a,/swap_if_little_endian
    needSwap= a ne 1234L
;   print,'need swap:',needswap
;
;   if we have a large, file, check if they want to position to the
;   day at the end (rmmon etc). If so, position to the end -1 day worth of
;   data then start searching forward
;
    blksRead=0L
    rew,lun
    gotit=0L
    if (fstatd.size gt bytesPerDayApprox*2L) then begin
;
;       read the last rec of the file
;        
        recsInFile=fstatd.size/recSize
        point_lun,lun,(recsInFile-1L)*recSize
        readu,lun,onerec
        if needSwap then onerec=swap_endian(onerec)     
;
;       want the last day, position to one day earlier. Need to position
;       in units of blkRead
;
        if (onerec.year gt year) or $
             ((onerec.year eq year) and (long(onerec.day) le dayno)) then begin
             blksRead=(recsInFile*recSize - $
                    ((bytesPerDayApprox/blkBytes) + 1 )*blkBytes)/blkBytes
             point_lun,lun,blksRead*blkBytes
        endif else begin
            rew,lun
        endelse
    endif
;
    gotit=0
    while not gotit do begin
        inpblk.year=-1L
        readu,lun,inpblk
        blksRead=blksRead+1L
        if needSwap then begin
            yearl =swap_endian(inpblk.year)
            daynol=swap_endian(inpblk.day)
        endif else begin
            yearl =inpblk.year
            daynol=inpblk.day
        endelse
        ind=where( (yearl ge year) and (daynol ge dayno),count)
        if count gt 0 then gotIt=1
    endwhile
done:
;
; hit eof or eof on first read
;
    if (not gotIt) then begin 
        if needSwap then begin
            yearl =swap_endian(inpblk.year)
            daynol=swap_endian(inpblk.day)
        endif else begin
            yearl =inpblk.year
            daynol=inpblk.day
        endelse
        ind=where( ((yearl ge year) and (daynol ge dayno)) or $
                   (yearl eq (-1L)),count)
        if count gt 0 then begin
            blksRead=blksRead+1L
        endif else begin        ; position end of last block read
            blksRead=blksRead + 2L
            ind[0]=0
        endelse
    endif 
    curPos=(blksRead-1L)*recSize*blkRecs + ind[0]*recSize
    if (curPos eq 0)           then returnStat=0L
    if (curpos eq fstatd.size) then returnStat=2L
    point_lun,lun,curPos 
    return,returnStat
end
