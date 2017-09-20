;
; var[2,3]
function anritscreenroom,fbase,ntrace,fiar,npnts=npnts,trplot=trplot,$
		var=var,tit=tit,cs=cs,font=font
;
; display data from screen room test
;
    common colph,decomposedph,colph

	if (n_elements(cs) eq 0) then cs=1.8
	if (n_elements(tit) eq 0 ) then tit=''
	useVar=(n_elements(var) eq 6)
	if n_elements(trplot)  eq 0 then trplot=123
	doTrace=intarr(ntrace)
	ii=trplot
	while (ii gt 0) do begin
		i=ii mod 10
		if (i ge 1) and (i le ntrace) then doTrace[i-1]=1
		ii/=10
	endwhile
	print,"dotrace:",dotrace
	nfiles=anritinpdir(fbase,ntrace,fiar,npnts=npnts)

	ntot=npnts*nfiles
	frqAll=reform(fiar.freq,ntot)
	; dall[npnts,nfiles,ntrace 
	dall  =reform(transpose(fiar.spc,[0,2,1]),ntot,ntrace)

	fmin=min(frqAll)
	fmax=max(frqAll)

	!p.multi=[0,1,3]
	ver,-120,-90
	ltit=tit
	for ifr=0,2 do begin
		f0=ifr*1000.
		f1=(ifr+1)*1000.
		hor,f0,f1
		ii=where((frqAll ge f0 ) and (frqAll le f1),cnt)
		if useVar then ver,var[0,ifr],var[1,ifr]
		if cnt gt 0 then begin
			plot,frqAll[ii],dall[ii,0],chars=cs,font=font,$
				xtitle='freq Mhz',ytit='dbm',$
				tit=ltit,/nodata
			for itrace=0,ntrace-1 do begin
				if (dotrace[itrace]) then $ 
				oplot,frqAll[ii],dall[ii,itrace],col=colph[itrace+1]
			endfor
		endif
		ltit=''
	endfor
	return,1
end
