;+
;NAME:
;aminpday - input 1 or more days of alfamon info
;SYNTAX: nrecs=aminpday(yymmdd1,d,lastday=yymmdd2,ndays=ndays,$
;                       smo=smo,curfile=curfile,dayno=dayno,year=year)
;ARGS:
;   long :   yymmdd1 day to input (unless dayno specified)
;KEYWORDS:
;   lastday:long return data from days yymmdd1 through yymmdd2
;				 (unless keyword set dayno)
;   ndays  :long return ndays starting at yymmdd1
;   smo    :long smooth and decimate the data by this many sample points.
;                the datapoints are normally spaces by 300 seconds.
;   curfile:     if set, use current file, (used for maintenance purposes)
;   dayno  :long if supplied, then set yymmdd1 to dayno,year
;
;RETURNS:
;   nrecs: number of entries in d
;   d[nrecs]: {alfamon} the alfamon data. 1 entry per measurement.
;
;DESCRIPTION:
;   Input the alfar monitor data for the date yymmdd1. If the
;keyword lastday is provided then input data from yymmdd1 through yymmdd2.
;If the keyword ndays is provided then input ndays of data starting at
;yymmdd1 (ndays overrides lastday). If no keywords are provided just input
;the one day. 
;   
;The  data is sampled once every 300 seconds. The data is returned as an array
;of structures d[nrecs]. Each ;entry contains:
;
;IDL> help,a,/st
;** Structure ALFAMON, 21 tags, length=664, data length=662:
;   TMA       STRING ''                  yyyymmddhhmmss in ascii
;   JD        DOUBLE 0.0000000
;   BIAS_CTL  INT    0				0 local, 1 remote
;   BIAS_STAT INT    Array[2, 7]    [pol,beam] 0 off, 1 amps on ; 
;   VD        FLOAT  Array[2, 7, 3] [pol,beam,stage1,2,3] drain Voltage
;   ID        FLOAT  Array[2, 7, 3] [pol,beam,stage1,2,3] drain Current
;   VG        FLOAT  Array[2, 7, 3] [pol,beam,stage1,2,3] gate Voltage
;   T20       FLOAT  Array[4]       20K temp K1..K4
;   T70       FLOAT  Array[4]		70K temp K1..K4
;   V32P      FLOAT  0.00000        Plus 32Volt power supply
;   V20P      FLOAT  0.00000        Plus 20 Volt power supply
;   V20N      FLOAT  0.00000        negative 20 Volt power supply
;   V9P       FLOAT  0.00000        Plus 9 Volt power supply
;   V15P      FLOAT  Array[6]       Plus 15 Volt power supply R1..R6
;   V15N      FLOAT  Array[4]       Neg  15 Volt power supply R1..R4
;   V5P       FLOAT  Array[2]       Plus 5 Volt power supply R1..R2
;   CALCTL    INT    0
;   NSELEV    INT    0
;   NSEDIODET INT    0
;   VACSTAT   INT    0
;   VACLEV    FLOAT  0.00000
;-
function aminpday,yymmdd1,d,lastday=yymmdd2,ndays=ndays,smo=smo,$
				  curfile=curfile,dayno=dayno,year=year
;
	hdrLen=3935.
	minRecLen=1173.		; some are 1174,1175..
;    10jan13 ..we now sometimes disable some of the monitoring, this can leave
;              use with lots of short recs.. so increase the slop
	nrecSlop=1000L		; some are 1174,1175..
	if keyword_set(dayno) then begin
		if not keyword_set(year) then begin
			a=bin_date()
			year=a[0]
		endif
		dm=daynotodm(dayno,year)
		yymmdd1=(year mod 100)*10000L + dm[1]*100L + dm[0]
	endif

	if keyword_set(curfile) then begin
		nfiles=1
		flist='/share/cima/Logs/ALFA_logs/alfa_logger.log'
	endif else begin
    	case  1 of 
      keyword_set(ndays)  :nfiles=amgetfile(yymmdd1,yymmdd2,flist,ndays=ndays)
      keyword_set(yymmdd2):nfiles=amgetfile(yymmdd1,yymmdd2,flist)
      else                :nfiles=amgetfile(yymmdd1,yymmdd2,flist,ndays=1)
    	endcase
	endelse
	if n_elements(yymmdd2) eq 0 then yymmdd2=yymmdd1
    yyyymmdd1l=yymmdd1
    yyyymmdd2l=yymmdd2
	if (yyyymmdd1l / 10000L) lt 2000 then yyyymmdd1L+= 2000L * 10000L
	if (yyyymmdd2l / 10000L) lt 2000 then yyyymmdd2L+= 2000L * 10000L
    if yyyymmdd1l gt yyyymmdd2l then begin
        itemp=yyyymmdd1l
        yyyymmdd1l=yyyymmdd2l
        yyyymmdd2l=itemp
    endif
    ntot=0L
    for i=0,nfiles-1 do begin
        openr,lun,flist[i],error=err,/get_lun,compress=compress
        if (err ne 0 ) then begin
            message,'cannot open file:' + flist[i],/info
            goto,botloop
        endif
        fstat=fstat(lun)
        nrecsReq=(fstat.size-hdrLen)/minRecLen + nrecSlop
;
        nrecs=aminprecs(lun,nrecsReq,dmon,smo=smo,yyyymmdd1=yyyymmdd1l,$
						yyyymmdd2=yyyymmdd2l);get then data
        free_lun,lun
        if ntot eq 0L then begin
            if nrecs gt 0 then d=dmon
        endif else begin
            if nrecs gt 0 then d=[temporary(d),dmon]
        endelse
        ntot=ntot+nrecs
botloop:
    endfor
    return,ntot
end
