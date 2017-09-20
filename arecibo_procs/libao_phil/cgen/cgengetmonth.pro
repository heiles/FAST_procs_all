;+
;NAME:
;cgengetmonth - input file with 1 month of data
;SYNTAX: n=cgengetmonth(yymm,d,badpnts=bandpnts,nbad=nbad))
;ARGS: 
; yymm: long  month to read  
;KEYWORDS:
; badpnts[m] : {} array of pnts with bad  values read in
; nband      : long  number of bad pnts found.
;RETURNS:
;    n  : long  number of records we read.
;                > 0  number of records returned
;                     a warning message is output if we
;                     don't get all the data
;                0 - no data for this date
;               -1 - read error.  no data   returned
;               -2 - open error
;  d[n]: {}     array of structs holding the info 
;DESCRIPTION:
;   Read in 1 month of cummings generator data.
;ISSUES:
;   When stopping totkw looks like it goes negative?
;   force it positive
;-
function cgengetmonth,yymm,b,badpnts=badpnts,nbad=nbad
	
	nbad=0 
    maxkw=1100		; max allowable value totkw 1 generator.
    minFuel=1   	; min cumulative fuel for 1 gen gallon.. 
    maxFuel=1e6   	; max cumulative fuel for 1 gen gallon.. 
    maxkw=1100		; max allowable value totkw 1 generator.
	yymmL=yymm
	yr=yymm/100L
	if yr lt 50 then yymmL+=200000L
	fname=cgenpath() + "cgen_" + string(format='(i6.6)',yymmL) + ".dat"
	ioerr=0
	lun=-1
	openr,lun,fname,/get_lun,error=ioerr
	if ioerr ne 0 then begin
		if ioerr eq -248 then return,0			; no file 
		print,"err opening " + fname + ":" + !error_state.msg
		retstat=-2
		goto,done
	endif
	f=fstat(lun)
	fsize=f.size
	reclen=n_tags({cgeninfo},/len)
	nrec=fsize/reclen 
	b=replicate({cgeninfo},nrec)
	on_ioerror,ioerr
	rew,lun
	b.recnum=-1
	ok=0
	readu,lun,b
	ok=1
ioerr:
	ii=where(b.recnum ne -1,inprecs)
	if inprecs ne nrec then begin
		b=(inprecs gt 0)?b[ii]:''
	endif
	retstat=inprecs
	on_ioerror,NULL
	; trouble on input
	if ok eq 0 then begin
		hiteof=eof(lun)
		if inprecs eq 0 then begin
			if (hiteof)  then goto,done
			print,"warning:readerr " + fname + ":" + !error_state.msg
			retstat=-1
			goto,done
		endif
	endif
done: if lun gt -1 then free_lun,lun
	if retStat gt 0 then begin
;
;	fix up some of the variables
;
		KtoC=-273.16
		kpaToPsi=0.14503773800721814
		b.geni.oilPres*=kpaToPsi
		b.geni.oiltemp+=KtoC
		b.geni.coolanttemp+=KtoC
		b.geni.misctemp1+=KtoC
		b.geni.misctemp2+=KtoC
		for i=0,3 do begin
			ii=where(b.geni[i].totkw gt 32768,cnt)
	 		if cnt gt 0 then begin
	 			b[ii].geni[i].totkw-=65536L 
	 			b[ii].geni[i].totkw=abs(b[ii].geni[i].totkw)
			endif
		endfor
		; checkfor valid data... power and cumulative fuel
		; let 0 be ok, 1 or more be bad
		ok=intarr(retstat)    
		ii=where(b.geni.totkw gt maxKw,nn)
        if (nn gt 0) then begin
			ok4=intarr(4,retstat)
			ok4[ii]=1
			okL=reform(total(ok4,1))
			ii=where(okL ne 0,nbad)
			if nbad gt 0 then ok[ii]=1
		endif
		ii=where((b.geni.totfuel lt minFuel) or (b.geni.totfuel gt maxFuel),nn)
        if (nn gt 0) then begin
			ok4=intarr(4,retstat) 
			ok4[ii]=1
			okL=reform(total(ok4,1))
			ii=where(okL ne 0,nbad)
			if nbad gt 0 then ok[ii]=1
		endif
		ii=where(ok ne 0,nbad)
		if nbad gt 0 then begin
			badpnts=b[ii]
			ii=where(ok eq 0,retstat)
			b=b[ii]
		endif
	endif
	return,retstat
end
