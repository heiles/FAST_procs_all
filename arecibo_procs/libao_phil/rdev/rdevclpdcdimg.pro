;-
;NAME:
;rdevclpdcdimg: make image of decoded clp file
;SYNTAX:rdevclpdcdimg,file,nhghts,fftlen,bw,img,frange=frange,freq=freq,$
;             tosmo=tosmo,dec=dec,nsig=nsig,zx=zx,zy=zy,dbg=dbg,sub=sub,$
;			  origimg=origimg,yr=yr,median=median,title=title
;ARGS:
;KEYWORDS:
;DESCRIPTION:
;	Make a dynamic spectra image of decode clp rdev file (.dcd).
;-
;
pro	rdevclpdcdimg,file,nhghts,fftlen,bw,b,frange=frange,freq=freq,tosmo=tosmo,dec=dec,$
			nsig=nsig,zx=zx,zy=zy,dbg=dbg,sub=sub,origimg=origimg,yr=yr,median=median,title=title
;
	
	len=fftlen
	border=75
	if n_elements(tosmo) eq 0  then tosmo=64
	if n_elements(nsig) eq 0 then nsig=3.
	if n_elements(dbg) eq 0 then dbg=0
	if n_elements(dec) eq 0 then dec=1
	subrange=1
	if n_elements(frange) ne 2 then begin
		frange=[-bw/2.,bw/2]+430.
		subrange=0
	endif
;
	openr,lun,file,/get_lun
	rew,lun
	b=fltarr(len,nhghts)
	readu,lun,b
	free_lun,lun
	b=shift(b,len/2,0)
;
	freq=(findgen(len)/len - .5)*bw + 430.
	f1=(425>frange[0])
	f2=(435<frange[1])
	ii=where((freq gt f1) and (freq lt f2),n)
	a=median(b[ii,*])
	b=b/a  
;
	if keyword_set(sub) then begin
		if keyword_set(median) then begin 
			for i=0,nhghts-1 do b[*,i]=b[*,i]-median(b[*,i],tosmo)
		endif else begin
			for i=0,nhghts-1 do b[*,i]=b[*,i]-smooth(b[*,i],tosmo)
		endelse
	endif else begin
		if keyword_set(median) then begin 
			for i=0,nhghts-1 do b[*,i]=b[*,i]/median(b[*,i],tosmo) - 1.
		endif else begin
			for i=0,nhghts-1 do b[*,i]=b[*,i]/smooth(b[*,i],tosmo) - 1.
		endelse
	endelse
	if subrange then  begin
		ii=where((freq ge frange[0]) and (freq le frange[1]),len)
		if dec gt 1 then begin
			len1=(len/long(dec))*long(dec)
			if len1 ne len then begin
				len=len1
			    ii=[ii[0:len1-1]]
			endif
		endif
		b=b[ii,*]
		freq=freq[ii]
	endif
	if (dec) gt 1 then begin
		 b=total(reform(b,dec,len/dec,nhghts),1)/dec
		 freq=total(reform(freq,dec,len/dec),1)/dec
	     len=len/dec
	endif
	ii=where((freq ge ((frange[0]>422))) and (freq le (438 < frange[1])),n)
	a=meanrob(b[ii,*],sig=sig)
	clip=[-sig,sig]*nsig
	imgdisp,b,clip=clip,zx=zx,zy=zy,xr=[freq[0],freq[len-1]],$
		border=border,xstyle=9,xtitle='Freq [Mhz]',ytitle='range',yr=yr
	cs=1.8
	ln=1.5
	if n_elements(title) gt 0 then note,ln,title,charsize=cs
	if dbg then stop
	return
end
