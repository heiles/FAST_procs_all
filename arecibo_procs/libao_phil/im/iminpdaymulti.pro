;+
;NAME:
;iminpdaymulti - input 1 freq band, multiple days 
;SYNTAX:n=iminpdaymulti(yymmdd1,freq,dret,yymmdd2=yymmdd2,ndays=ndays
;ARGS:
;yymmdd1: long   first day to input
;freq   : float  freq band to input:
;                The frequecies are: 70 ,165 , 235, 330, 430,$
;                 550, 725, 955,1075,1325,1400,
;                 2200,3600,4500,5500,6500,7500,8500,9500.
;KEYWORDS:
;yymmdd2: long   last day to input. def=1 day
;ndays  : long   number of days to input (overrides yymmdd2)
;maxrec : long   max number of recs we return
;                default = 150*ndays
;RETURNS
;n      : long   number of records found
;dret   : {}     struct holding the data
;DESCRIPTION:
;	Input multiple days of a single frequency band from the
;hilltop monitoring data. The data is returned in the
;standard hilltop monitoring struct: 
;DL>  help,dret,/st
;** Structure length=2325420, data length=2325418, refs=1:
;   YYMMDD          LONG      140701 .. this is the start date
;   NRECS           LONG      1411
;   FRQL            FLOAT     Array[1]
;   R               STRUCT    -> IMDREC Array[1411]
;   CREC            INT              0
;   CFRQ            FLOAT          -1.00000
; The only difference is that the struct will only contain
;a single freq band.
;-
function iminpdaymulti,yymmdd1,freq,dret,yymmdd2=yymmdd2,ndays=ndays,$
		maxrec=maxrec
;
	freql=[70.,165., 235.,330.000,430.,550.,725.,955.,1075.00,$
		1325.,1400.,2200.,3600., 4500., 5500.,6500.,7500.,8500.,$
		9500.]
	ii=where(freq eq freql,cnt)
	if cnt eq 0 then begin
		print,'illegal freq req'
		print,'legal values are:'
		print,freql
		return,-1
	endif
	jd1=yymmddtojulday(yymmdd1*1L)
	jd2=jd1
	if n_elements(yymmdd2) gt 0 then begin
		jd2=yymmddtojulday(yymmdd2*1l)
	endif
	if n_elements(ndays) gt 0 then begin
		jd2=jd1 + ndays - 1l
	endif
	ndaysL=jd2-jd1 + 1l
	maxEntry=(n_elements(maxrec) gt 0)?maxrec:ndaysL*150l
	jd=jd1
	icur=0L
	hitMax=0L
	for i=0l,ndaysl-1 do begin
		caldat,jd,mon,day,yr
		yymmdd=(yr mod 100)*10000L + mon*100L + day
		iminpday,yymmdd,d,recsfound=recsfound
		if recsfound eq 0 then goto,botloop
		ii=where(d.r.h.cfrdatamhz eq freq,cnt)
		if cnt eq 0 then continue
		if icur eq 0 then begin
			rAr=replicate(d.r[0],maxEntry)
			dStart=d
		endif
		if (icur + cnt) ge maxentry then begin
			hitmax=1
			cnt=maxentry - icur - 1
			if cnt le 0 then break
			ii=ii[0:cnt-1]
		endif
		rAr[icur:icur + cnt-1L]=d.r[ii]
		icur+=cnt
		if hitmax then break
botloop:
		jd++
	endfor
	if icur eq 0 then goto,done
;
;	make the struct for all the data
;
	dret={yymmdd: dstart.yymmdd,$
		  nrecs : icur,$
		  frqL  : freq,$
 		  r     : rar[0:icur-1],$
		  crec  : 0,$
		  cfrq  : -1.}
done:
	if hitmax then begin
		print,'hit max number of recs:',maxentry
		print,'Use maxrec keyword to increase max'
	endif
	return,icur
end
