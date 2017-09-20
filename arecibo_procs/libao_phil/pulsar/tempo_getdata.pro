;+
;NAME:
;tempoget - read a polyco file
;SYNTAX: n=tempoget(polycoName,polyI)
;ARGS:
; polycoName: string  polyco.dat file to read (created by tempo)
;RETURNS:
;n:	int  >=0 number of entries found in file
;        -1 can't open file
;
;polyI[n]: struct   holding info read from file
;-
function tempo_getdata,polyconame,polyI

	lun=-1
	on_ioerror,doneio
	maxCoef=15
	maxEntry=100L
	a={ $ ; line 1
        name: '',$
        date: '',$
        hhmmss:0d ,$ ;utc hhmmss.ss
		mjd :  0d ,$ ; includes fraction
         dm :  0d ,$ ;dispersion measure
		dopgeo:0d ,$ ; *1e-4 
		fitResid:0d ,$ ; fit residual log_10 in periods
;       line 2
        rphase: 0d,$   ; reference phase
        rrotfreq:0d,$  ; ref rotation frequency
        obsnum  :0L,$  ; observatory number
        dspan   :0L,$  ; data span
        ncoef   :0l,$  ; number of coef
        obsFreq :0D,$  ; observing freq in Mhz.
        bphase  :0d,$  ; binary phase
		coef    :dblarr(maxCoef)}
       

	polyI=replicate(a,maxEntry) 
	openr,lun,polyconame,/get_lun,err=ierr
	if ierr ne 0 then begin
		print,"Error opening file:",polyconame
		return,-1
	endif
	icur=0l
	form1='(a10,a10,D12,D20,D21,D6,D7)'
	form2='(D20,D18,I5,I6,I5,D21,D5)'
	nm=''
	date=''
	utc=0d
	tmid=0d
	dm=0d
	dop=0d
	fitres=0d
	rphase=0d
	f0=0d
	obsnum=0L
	dspan=0L
	ncoef=0L
	obsFreq=0D
	bphase=0D
	
	done=0
	while (not done) do begin
;
;   input a set of data
;
	readf,lun,nm,date,utc,tmid,dm,dop,fitres,format=form1
	readf,lun,rphase,F0,obsnum,dspan,ncoef,obsFreq,bphase,format=form2
	coefAr=make_array(ncoef,/double)
	readf,lun,coefar
;
; 	now move the data over
;
	polyI[icur].name=strtrim(nm,2)
	polyI[icur].date=strtrim(date,2)
	polyI[icur].hhmmss=utc
	polyI[icur].mjd   = tmid
	polyI[icur].dm    =dm
	polyI[icur].dopgeo=dop
	polyI[icur].fitresid=fitres
	polyI[icur].rphase=rphase
	polyI[icur].rrotfreq=f0
	polyI[icur].obsnum  = obsnum
	polyI[icur].dspan   =dspan
	polyI[icur].ncoef   =ncoef
	polyI[icur].obsfreq =obsfreq
	polyI[icur].bphase  =bphase
	polyI[icur].coef[0:ncoef-1]=coefAr
	icur++
	endwhile
doneio:
	if icur ne maxEntry then begin
		if icur gt 0 then begin
			polyI=polyI[0:icur-1]
		endif else begin
			polyI=0
		endelse
	endif
	if lun ge 0 then free_lun,lun
	return,icur
end
