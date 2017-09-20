;+
;NAME:
;sblogget - read sband log file
;SYNTAX: nrecs=sblogget(logfile,d,draw=draw)
;ARGS:
;logfile: string  filename to open and read
;RETURNS:
;nrec   : long  > 0 number of log records found
;               -1 error opening or reading reading file 
;d[n]   : {}    struct holding info scaled to engineering units
;draw[n]: {}    strcut holding info before scaling to eng units.
;
;DESCRIPTION:
;	read all of the log records from the specified sband logfile.
;The  data is returned in an array of structures (d). The meter data has
;been scaled to engineering units (normally mulitply by 10^y (y=1,.1,.01).
;If the draw keyword is supplied then a copy of the raw input data
;(before meter scaling.. ints) is also returned.
;	The data structure returned is:
; help,d,/st
;** Structure <84a188c>, 4 tags, length=192, data length=191, refs=2:
;   TM              BYTE      Array[8]
;   DATE            BYTE      Array[8]
;   STAT            BYTE      Array[47]
;   MET             STRUCT    -> <Anonymous> Array[1]
;
; The meter data has been scaled to the same units as the online
;723 program. The d.met structure contains:
;
;IDL> help,d.met,/st
;** Structure <84b8a14>, 32 tags, length=128, data length=128, refs=3:
;   MAGVK1          FLOAT           167.000
;   MAGVK2          FLOAT           148.000
;   BEAMV           FLOAT           0.00000
;   MAGIK1          FLOAT           13.0000
;   MAGIK2          FLOAT           12.6000
;   BODYI           FLOAT           0.00000
;   FILVK1          FLOAT           10.6000
;   FILVK2          FLOAT           10.2000
;   FILIK1          FLOAT           18.9000
;   FILIK2          FLOAT           18.4000
;   COLIK1          FLOAT           0.00000
;   COLIK2          FLOAT           0.00000
;   VACIIK1         FLOAT          0.114815
;   VACIIK2         FLOAT         0.0223872
;   SP1             FLOAT           0.00000
;   SP2             LONG                 0
;   WASTFWDP        FLOAT           10.0000
;   FWDPK1          FLOAT           0.00000
;   REFLPK1         FLOAT           0.00000
;   FWDPK2          FLOAT           3.00000
;   REFLPK2         FLOAT         0.0200000
;   WASTREFLP       FLOAT           0.00000
;   TURNDLP         FLOAT           2.00000
;   ANTFWDP         FLOAT           5.00000
;   ANTREFLP        FLOAT           0.00000
;   RFDRVPK1        FLOAT           3.00000
;   RFDRVPK2        LONG                24
;   WASTFLWRATE     FLOAT           287.000
;   DELTATEMP       FLOAT          0.130000
;   COLFLOWK2       FLOAT           310.000
;   EXCITERINPP     FLOAT           3.00000
;   SP3             FLOAT           0.00000
;
; abbreviations used are:
;  K1 - klystron 1
;  K2 - klystron 2
;  I=current
;  V=voltabe
;  P=power
;  Fwd=forward
;  Refl=reflected
;  mag=magnet
;  fil=filament
;  col=collector
;  wast= wasterload
;  turn: turnstile
;  dl  : dummy load
;  P   : proof
;  spN : spare bit
;
;Notes: you need to do @sbandinit before using this routine
;-
function sblogget,logfile,d,draw=inp
;
;
;    int short met def
;
imet={sbl_imet}; 
;   float met def

fmet={sbl_fmet};
;
; scale the int to float engineering units
;
	sclDat=[$
		1.  ,$; magVK1
		1.  ,$; magVK2
		 .1 ,$; beamV
		 .1 ,$; magIK1
		 .1 ,$; magIK2
		 .1 ,$; bodyI
		 .1 ,$; filVK1
		 .1 ,$; filVK2
		 .1 ,$; filIK1
		 .1 ,$; filIK2
		 .1 ,$; colIK1   i10
		 .1 ,$; colIK2
		1.  ,$; vaciIK1 .. 10^(x/100.)
		1.  ,$; vaciIK2 .. 10^(x/100.)
		1.  ,$; sp1
		1.  ,$; sp2
		1.  ,$; wastFwdP
		1.  ,$; fwdPK1   i17
		 .01,$; reflPK1
		1.  ,$; fwdPK2
		 .01,$; reflPK2
		 .1 ,$; wastReflP
		1.  ,$; turnDlP
		1.  ,$; antFwdP  
		 .1 ,$; antReflP  
		.01 ,$; rfDrvPK1
		.01 ,$; rfDrvPK2
		1.  ,$; wastFlwRate
		 .01,$; deltaTemp
		1.  ,$; colFlowK2
		1.  ,$; exciterInpP
		1.  ] ; sp3
;
; 
; 	rec length:

	inprec={sbl_inprec};
	reclenB=n_elements(inprec.tm) + n_elements(inprec.date) + $
			n_elements(inprec.stat) + n_tags(inprec.met)*2

	err=0
	openr,lun,logfile,/get_lun,err=err
	if err ne 0 then begin
		print,!error_state.msg + " opening file:" + logfile 
		return,-1
	endif
;
; 	fstat to get file size
;
	f=fstat(lun)
	nrecs=f.size/recLenB
	if nrecs eq 0 then  return,0
;
; !! note: !! this shouldn't work all the time??
;  inprec has datalength 127, struct length 128
;  the inpdata is length 127 bytes
;  If idl does a single read into inp[] then it should
;  fail. If it does a single read for each element then it
;  should not corrupt adjacent struct array elements of inp[].
;  But.. inprec.met is a struct and falls on an odd byte
;  so some machines may put an extra pad byte beforee it.
;  It works on linux pc. If it eventually fails,
;  use a short read then move the data, 1 struct element at a time.
;
	inp=replicate(inprec,nrecs)
	d  =replicate({sbl_usrrec},nrecs)
	rew,lun
	readu,lun,inp
	free_lun,lun
;
; scale to engineering units
;
	for i=0,n_tags(inp[0].met)  - 1 do d.met.(i)=inp.met.(i)*sclDat[i]
	;
	; fix vacion (y=10^(x/100.)*.01 where x is input
	;
	d.met.vaciIK1=10^(inp.met.vaciIK1/100.) * .01
	d.met.vaciIK2=10^(inp.met.vaciIK2/100.) * .01
	;
	; convert byte to string for ldate,ltime
	;
	d.ltm  =string(inp.tm)
	d.ldate=string(inp.date)
	;
	; convert hh:mm:ss  
	;         mm/dd/yy  to dayno and year
	;
	atm=stregex(inp.tm,"(..):(..):(..)",/sub,/ext)
	ada=stregex(inp.date,"(..)/(..)/(..)",/sub,/ext)
	d.year= fix(reform(ada[3,*])) + 2000 
	; 	check for < 2000
	ii=where(d.year gt 2050,cnt)
	if (cnt gt 0) then d[ii].year-=100L
;
	fracDay=reform($
		(long(atm[3,*]) + 60L*(long(atm[2,*]) + 60L*long(atm[1,*])))/86400D)
	mon=reform(long(ada[1,*]))
	day=reform(long(ada[2,*]))
	d.dayno=dmtodayno(day,mon,d.year) + fracDay
;
; 	the status
;
	d.stat=inp.stat
	return,nrecs
end
