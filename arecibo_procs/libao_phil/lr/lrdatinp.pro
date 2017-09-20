;
;
;lrdatinp - input laser ranger temp, avgheight
;This inputs the data from the file written by lrMon on vxWorks
; MCN 2006 Nov 28 added year arg
; 
pro lrdatinp,dayNumStart,numDays,lrd,year=year
;
    lrd=replicate({lrdf},numDays*730L)
	if (keyword_set(year)) then begin
		file=strcompress('/share/obs4/lr/' + string(year) + '/lrmon.dat', /remove)
	endif else begin
		file = '/share/obs4/lr/lrmon.dat'
	endelse
    openr,lun,file,/get_lun
;;; if  dayNumStart lt 67L then begin
;;      free_lun,lun
;;      message,"daynumstart 67 year 2000"
;;  endif
    on_ioerror,ioerr

    done=0
    inline=" "
    dayNum=0L
    hr=0L
    min=0L
    sec=0L
    temp=0.
    hght=0.
    stat=0L
    ijunk=0L
    ijunk2=0L
    lastDay=dayNumStart+numDays-1
    i=0L
    ln=0L
    while done eq 0 do begin
        readf,lun,inline 
        ln=ln+1
        reads,inline,dayNum
        if  dayNum gt lastDay then begin
            done=1
        endif else begin 
           if dayNum ge dayNumStart then begin
            reads,inline,format="(I0,I3,1x,I2,1x,I2,I0,9x,2F0,I0,Z0)",$
            dayNum,hr,min,sec,ijunk,temp,hght,ijunk2,stat
            lrd[i].day=dayNum + hr/24. + min/1440.+ sec/86400.
            lrd[i].temp=temp
            lrd[i].hght=hght
            lrd[i].stat=stat
            i=i+1L 
           endif
        endelse
    endwhile
ioerr:
    if  i eq 0 then begin
        lrd=""
    endif else begin
        lrd=temporary(lrd[0:i-1])
    endelse
    if (done eq 0) and (not eof(lun))  then print,'i/o error line:',ln
 
    free_lun,lun
    return
end
