;+
;NAME:
;tempread - read receiver room temperature data
;SYNTAX: dat=tempread(yymmdd,lun=lun,nrec=nrec)
;ARGS:
;   yymmdd: long    day of year to input.
;KEYWORDS: 
;   lun     : int  if provided then this is open to the file to read from.
;                  The default is to read from the temperature data file of
;                  the current year.
;   nrec    : long . if present, read this many records starting at yymmdd.
;                    the default is to read 1 days worth of data.
;RETURNS:
;   dat[n]: {tempdat} temp data structure returned. 
;                     dat.time : float daynumber of sample
;                     dat.temp : float temp in degree F.
;-  
function tempread,yymmdd,lun=lun,nrec=nrec
 
    inplen=100000L
    if (not keyword_set(nrec)) then begin
            daylen=10000L
            nrec=0
    endif else begin    
            daylen=nrec
    endelse
    if  keyword_set(lun) then begin
        loclun=lun
    endif else begin
        openr,loclun,'/share/obs4/temp/temp.dat',/get_lun
    endelse
    a={tempraw, time:   0L, temp:   0.}
    a={tempdat, time:   0., temp:   0.}
;
;   figure out daynumber
;
    day=yymmdd mod 100L
    mon=(yymmdd/100L)  mod 100L
    yr =(yymmdd/10000L) + 2000
    if (yr gt 2050) then yr=yr - 100L
    daynum=dmtodayno(day,mon,yr)
    timest =daynum*100000L
    timeend=(daynum+1L)*100000L
;
;   find the start day
;
    inpraw=replicate({tempraw},inplen)
    on_ioerror,gotit
    count=-1
    val=1234L
    byteorder,val,/htonl
    needswap=1234L ne val
    foundDate=0
    for i=0L,9999999L do begin
        didswap=0
        point_lun,-loclun,curpos
        inpraw.time=0L
        readu,loclun,inpraw
        if needswap then begin
            inpraw=swap_endian(inpraw)
        endif
        ind=where((inpraw.time ge timest) and (inpraw.time ne 0),count)
        if count ne 0 then begin
            foundDate=1
            goto,gotit
        endif
    endfor
;
gotit: 
    if not foundDate then begin
        if needswap then inpraw=swap_endian(inpraw)
        ind=where((inpraw.time ge timest) and (inpraw.time ne 0),count)
    endif
    if count eq 0L then goto,nodata
    if (inpraw[inplen-1].time eq timest) or (nrec ne 0)  then begin
            curpos=curpos + ind[0]*8L
            point_lun,loclun,curpos
            inpraw=replicate({tempraw},daylen)
            on_ioerror,gotit2
            readu,loclun,inpraw
    endif
;
;   find end of this day
;
gotit2:
    if nrec eq 0 then begin
        ind=where((inpraw.time / 100000L) eq daynum,count)
    endif else begin 
        if needswap then inpraw=swap_endian(inpraw)
        ind=where(inpraw.time ne 0.,count)
    endelse
    if (count eq 0) then begin
        goto,nodata
    endif
    inpday=replicate({tempdat},count)
    inpday.time=  floor((inpraw[ind].time/100000.)) + $
        (inpraw[ind].time mod 100000)/86400.
    inpday.temp=inpraw[ind].temp*1.8 + 32.
    goto,done
    
nodata: print,'no data found for date:',yymmdd
    inpday=''
done: if (n_elements(lun) eq 0 ) then free_lun,loclun
    return,inpday
end
