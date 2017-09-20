;+
;NAME:
;rminpday - input 1 or more days of rcvmon info
;SYNTAX: nrecs=rminpday(yymmdd1,d,lastday=yymmdd2,ndays=ndays,rcvnum=rcvnum,$
;                       smo=smo,curfile=curfile,dayno=dayno,year=year)
;ARGS:
;   long :   yymmdd1 day to input (unless dayno specified)
;KEYWORDS:
;   lastday:long return data from days yymmdd1 through yymmdd2
;				 (unless keyword set dayno)
;   ndays  :long return ndays starting at yymmdd1
;   smo    :long smooth and decimate the data by this many sample points.
;                the datapoints are normally spaces by 22 seconds.
;   curfile:     if set, use current file, (used for maintenance purposes)
;				 not normally needed even to access current data.
;   dayno  :long if supplied, then set yymmdd1 to dayno,year
;
;RETURNS:
;   nrecs: number of entries in d
;   d[nrecs]: {rcvmon} the rcvmon data. 1 entry per receiver measurement.
;
;DESCRIPTION:
;   Input the receiver monitor data for the date yymmdd1. If the
;keyword lastday is provided then input data from yymmdd1 through yymmdd2.
;If the keyword ndays is provided then input ndays of data starting at
;yymmdd1 (ndays overrides lastday). If no keywords are provided just input
;the one day. If the rcvnum keyword is supplied then only data for this
;receiver will be returned.
;   
;   The entire dataset of all receivers is typically sampled once every
;22 seconds. The data is returned as an array of structures d[nrecs]. Each 
;entry contains:
;
;IDL> help,a,/st 
;** Structure RCVMON, 13 tags, length=88:
;   KEY             BYTE      Array[4] The string 'rcv'
;   RCVNUM          BYTE               The receiver number
;   STAT            BYTE               bitfield
;                                      B0 - lakeshore disp is on
;                                      B1 - hemtLed polA on
;                                      B2 - hemtLed polB on
;   YEAR            INT                4 digit year
;   DAY             DOUBLE             daynumber of year with fraction of day.
;   T16K            FLOAT              16K stage temperature in deg K
;   T70K            FLOAT              70K stage temperature in deg K
;   TOMT            FLOAT              omt temperature in deg K
;   PWRP15          FLOAT              dewar +15 volt supply voltage
;   PWRN15          FLOAT              dewar -15 volt supply voltage
;   POSTAMPP15      FLOAT              postamp +15 volt supply voltage
;   DCUR            FLOAT  Array[3, 2] bias current [Amps123 , polAB]
;   DVOLTS          FLOAT  Array[3, 2] bias voltage [amps123 , polAB]
;
;-
function rminpday,yymmdd1,d,lastday=yymmdd2,ndays=ndays,rcvnum=rcvnum,smo=smo,$
				  curfile=curfile,dayno=dayno,year=year
;
    reclen=n_tags({rcvmon},/length)
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
		flist='/share/obs4/rcvm/rcvmN'
;		need to setup yymmdd2
		yymmdd2l=yymmdd1
		if n_elements(yymmdd2) gt 0 then begin
			yymmdd2l=yymmdd2
		endif else begin
			if n_elements(ndays) gt 0 then begin
				if ndays ne 0 then begin
					julday1=yymmddtojulday(yymmdd1)
        			if ndays lt 0 then begin
            			julday2=julday1+ndays+1
        			endif else begin
            		    julday2=julday1+ndays-1
        			endelse
        			caldat,julday2,mon,day,yearl
        			yymmdd2l=(yearl mod 100)*10000L + mon*100 + day
				endif
			endif
		endelse
		yymmdd2=yymmdd2l
	endif else begin
    	case  1 of 
      keyword_set(ndays)  :nfiles=rmgetfile(yymmdd1,yymmdd2,flist,ndays=ndays)
      keyword_set(yymmdd2):nfiles=rmgetfile(yymmdd1,yymmdd2,flist)
      else                :nfiles=rmgetfile(yymmdd1,yymmdd2,flist,ndays=1)
    	endcase
	endelse
    yymmdd1l=yymmdd1
    yymmdd2l=yymmdd2
    if yymmdd1 gt yymmdd2 then begin
        itemp=yymmdd1l
        yymmdd1l=yymmdd2l
        yymmdd2l=itemp
    endif
    year1=yymmdd1l/10000L + 2000
    day1=dmtodayno(yymmdd1l mod 100L,yymmdd1l/100L mod 100L,year1)
    year2=yymmdd2l/10000L + 2000
    day2=dmtodayno(yymmdd2l mod 100,yymmdd2l/100 mod 100,year2)
    ntot=0L
    for i=0,nfiles-1 do begin
		if ((lun=rmopenfile(flist[i])) lt 0) then goto,botloop
        fstat=fstat(lun)
        nrecs=fstat.size/reclen + 10
		if nrecs eq 0 then continue
        nrecs=rminprecs(lun,nrecs,dmon,rcvnum=rcvnum,smo=smo);get a monthsdata
        free_lun,lun
        yearl=dmon[0].year
        case 1 of
        (year1 eq year2):ind=where((dmon.day ge day1) and $
                         (dmon.day lt (day2+1.)) and (dmon.year eq year1),count)
        (yearl  eq year1):ind=where((dmon.day ge day1) and $
                                   (dmon.year eq year1),count)
        (yearl  eq year2):ind=where((dmon.day lt (day2+1)) and $
                                   (dmon.year eq year2),count)
        else            :ind=where((dmon.day gt -1) and $
                                   (dmon.year eq yearl),count)
        endcase
        if ntot eq 0L then begin
            if count gt 0 then d=dmon[ind]
        endif else begin
            if count gt 0 then d=[temporary(d),dmon[ind]]
        endelse
        ntot=ntot+count
botloop:
    endfor
    return,ntot
end
