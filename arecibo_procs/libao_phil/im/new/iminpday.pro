;+
;NAME:
;iminpday - input one days worth of data
;SYNTAX:	iminpday,yymmdd,d[{iminprec}] ,recsfound=recsfound
;ARGS:
;	yymmdd: long	day to input.
;RETURNS:
;	recsfound: long	 number of records found
;   d:{imday}: structure holding data
;DESCRPITION:
;	Read in a complete days worth of the im data. The date is specifed by
;the argument yymmdd. The d data structure contains:
; help,d,/st
;   YYMMDD LONG   60309			the date used
;   NRECS  LONG   586           the number of records found
;   FRQL   FLOAT  Array[19]     the list of frequencies in use
;   R      struct IMDREC[586]   array of structures holding the ind records.
;   CREC   INT    15            current record we're displaying
;   CFRQ   FLOAT  -1.00000      current frequency we are displaying
;The indidividual record formats are:
; help,d.r,/st
;  H STRUCT  -> IMHDR Array[1] .. the header for this record
;  	 .HDRMARKER  BYTE  Array[4]  the string HDR_
;    .HDRLEN     LONG  44        bytes in this header
;    .RECLEN     LONG  846       record length (hdr,data) in bytes)
;    .VERSION    BYTE  Array[4]  version strin
;    .DATE       LONG  2006068   date yyyyddd year, daynumber
;    .SECMID     LONG   60       seconds from midnite for this record
;    .CFRDATAMHZ FLOAT 165.000   center freq data Mhz
;    .CFRANAMHZ  FLOAT 165.000   center freq specAnalyzer Mhz (dif if mixed).
;    .SPANMHZ    FLOAT  70.0000  span of spectrum analyzer in Mhz
;    .INTEGTIME  LONG   60       peak hold time for this record in secs
;    .SRCAZDEG   LONG   -1       not implemented
;
;  D FLOAT  Array[401]         .. the 401 freq points for this rec (in dbm)
;-
;---------------------------------------------------------------------------
pro iminpday,yymmdd,d,recsfound=recsfound
;
;  d.yymmdd
;  d.nrecs
;  d.frqlist[nfreq]
;  d.r[nrecs]
;  for plottinq
;  d.crec
;  d.cfrq
;
    numrec=0
    recsFound=0
    maxentry=1450
    maxfreq = 20
    frqlist=fltarr(maxfreq)
    frqlistLast=-1;
    lun=imopen(yymmdd)
    if (lun lt 0) then goto,done;
;
    inparr=replicate({imdrec},maxentry)
    inprec={imirec};
;
;   loop till we hit eof
;
    on_ioerror,hiteof
    goodrecs=0L
    for numread=0,maxentry-1 do begin
        readu,lun,inprec
        if swap_endian(inprec.h.hdrlen) eq 44 then inprec=swap_endian(inprec)
        if (string(inprec.h.hdrmarker) eq 'HDR_') and $
           (inprec.h.hdrlen    eq 44)    and $
           (inprec.h.reclen    eq 846)  then begin
            inparr[goodrecs].h=inprec.h
            inparr[goodrecs].d=inprec.d *.01 ; to db
            i=where(frqlist eq inprec.h.cfrDataMhz,count)
            if (count eq 0) then begin
                 frqlistlast=frqlistlast+1
                frqlist[frqlistlast]=inprec.h.cfrDataMhz;
            end
            goodrecs=goodrecs+1L
        endif
    end
hiteof:
    numrec=goodrecs
    if numrec eq 0 then goto,done
    if ( not eof(lun) ) then begin
        print,'rec:',numrec+1,' read err:',!err, !err_string
    end
;
;   sort frqlist,
;
    frqlist=temporary(frqlist[sort(temporary(frqlist[0:frqlistlast]))])
;
;   now build structure to return
;
    if (numrec gt 0) then begin
        d={yymmdd:yymmdd,nrecs:numrec,frql:frqlist, $
                r:temporary(inparr[0:numrec-1]),crec:0 ,cfrq:-1.}
    end
done:if lun ge 0  then free_lun,lun
    recsfound=numrec
    return
end
