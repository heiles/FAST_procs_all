; 
;NAME:
;corpwr - return power information for a number of recs
;SYNTAX: nrecs=corpwr(lun,reqrecs,pwra,lasthdr,pwrcnt=pwrcnt)
;ARGS:
;   lun     - file open to
;   reqrecs -requested records to return
;KEYWORDS:
;   pwrcnt  if set the return power counter data (50Mhz) rather than
;           0 lag. This is measured before the digitizer with a
;           vTof converter (it is also not blanked).
;RETURNS:
;   pwra  - returns an array pwra[nrecs]  of {corpwr} struct
;   nrecs - number of recs found, 0 if at eof, -1 if hdr alignment/io error
;DESCRIPTION:
;   Return the total power information for the requested number of
;records. The data is returned in the array pwra. Each element of the
;array contains:
;pwra[i].scan - scan number
;pwra[i].rec  - record number
;pwra[i].time - seconds from midnight end of record.
;pwra[i].nbrds- number of boards in use
;pwra[i].az   - az (deg) end of this record.
;pwra[i].za   - za (deg) end of this record.
;pwra[i].azErr- az (asecs great circle) end of this record.
;pwra[i].zaErr- za (asecs great circle) end of this record.
;pwra[i].pwr[2,4] - total power info. first index in pol1,pol2
;                   2nd index are 4 correlator boards.
;There will only be valid data in the first pwra[i].nbrds entries of
;pwra.
;   In pwra[i].[i,j], i=0,1 will be pola, polb if two polarizations were
;recorded in the board. If only one polarization was recorded on the
;board, then i=0 holds the data (either pola,polB) and i=1 has no data.
;-
;history:
;31jun00 - updated to new form corget
;13sep00 - added time
;13mar03 - added pwrcnt option
;02may03 - lasthdr.. return last complete header we read. if hit eof,
;           do not return 0..
;02feb04 - added was functionality
;
function corpwr,lun,reqrecs,pwra,lasthdr,pwrcnt=pwrcnt
    forward_function corgethdr
    if wascheck(lun) then return,waspwr(lun,reqrecs,pwra,lasthdr)
    on_error,1
    on_ioerror,done
    pwra=replicate({corpwr},reqrecs)
    numinp=0L
    if not (keyword_set(pwrcnt)) then pwrcnt=0
    for i=0L,reqrecs-1  do begin
        istat=corgethdr(lun,lasthdrl)
        if (istat ne 1 ) then goto,done
        lasthdr=lasthdrl
        numinp=numinp+1L 
        pwra[i].scan =lasthdr[0].std.scannumber
        pwra[i].rec  =lasthdr[0].std.grpnum
        pwra[i].time =lasthdr[0].std.time
        pwra[i].nbrds=lasthdr[0].std.grpTotRecs
        pwra[i].az   =lasthdr[0].std.azTTD*.0001
        pwra[i].za   =lasthdr[0].std.grTTD*.0001
        pwra[i].azErr=lasthdr[0].pnt.errAzRd;
        pwra[i].zaErr=lasthdr[0].pnt.errZaRd;
        nbrds=lasthdr[0].std.grpTotRecs
        if pwrcnt then begin
            pwra[i].pwr[*,0:nbrds-1]= lasthdr.cor.pwrcnt
        endif else begin
            pwra[i].pwr[*,0:nbrds-1]= lasthdr.cor.lag0PwrRatio
        endelse
    endfor

done:
    if (numinp gt 0L) then begin
        if (numinp eq reqrecs) then begin
        endif else begin
            pwra=temporary(pwra[0L:numinp-1L])

        endelse
        pwra.azErr=pwra.azErr*!radeg*3600.*sin(pwra.za*!dtor) ;# make great circle
        pwra.zaErr=pwra.zaErr*!radeg*3600.
       return,numinp
    endif

    return,istat
end
