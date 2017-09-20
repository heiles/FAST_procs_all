;+
;NAME:
;pdevrmstmd - compute rms,spectra for timedomain file
;SYNTAX: istat=pdevrmstmd(fname,retI,fnmI=fnmI,desc=desc,smpToRead=smpToRead,$
;				fftlen=fftlen,verb=verb,var=var,cs=cs,font=font,tit=tit,$
;               normspc=normspc)
;ARGS:
;    fname: string file to process 
;KEYWORDS: 
;   fnmI: {}    if supplied then use this for the file name
;               (see masfilelist).
;   desc: {}    if supplied then user has already openned the file
;               read from the current position.
;               Leave desc open at last read position on exit
; smpToRead:long number of samples to process. def=2^20l
; fftlen   : long length of xform to do, default=16384
;            if fftlen=-1 then do not do xforms
; verb     :    if set then print mean,rms and plot avg spectra
; var[2]   : if supplied then vertical scale for plot
; normspc  : if set the normalize spectra to median value
;RETURNS:
; istat: 0   ok
;      : -1 trouble.. error message also printed
; retI : {} structure holding info
;           retI.npol  = number of pols
;           retI.fftlen= length of fft
;           retI.freq[fftlen] freq for fft
;           retI.spc[fftlen,npol] averaged spectra
;           retI.mean[npol] mean (complex i,q)
;           retI.rms[npol]  rms  (complex i,q)
;           retI.histx[2^nbits]  x axis for histogram
;		    reti.histy[2^nbits,npol] histogram
;
;DESCRIPTION:
;	Compute mean, rms, and average spectra for part of a
;.pdev time domain file. 
;	The specified file will be:
;   -  openned.
;      - if keyword desc provided then use desc passed in.
;   - input the requested number of samples
;   - compute mean,rms
;   - compute average spectra of fftlen
;     - if fftlen < 0 then skip this
;     - if verb  is set then plot the average spectra
;   - compute histogram of the bits
;     for 16 bits, use 12bit hist (divide num / 16)
;     if verb set then plot this
;   - on exit, close the desc (if we opened it). 
;     if the user supplied the desc, then leave it open.
;-
function  pdevrmstmd,fname,retI,fnmI=fnmI,desc=desc,smpToRead=smpToRead,$
 				fftlen=fftlen,verb=verb ,var=var,cs=cs,font=font,tit=tit,$
				normspc=normspc
    common colph,decomposedph,colph
;
;   optionally position to start of rec
;
	if n_elements(cs) eq 0 then cs=1.
	csn=1.5
	if n_elements(font) eq 0 then font=0
	if n_elements(tit) eq 0 then tit=''
	retstat=0
	prgNm="pdevrmstmd:"
	openfile=0L
	verbose=(n_elements(verbose) eq 0)?0:verbose
	if n_elements(smptoread) eq 0 then smpToRead=2L^20
	if n_elements(fftlen) eq 0 then fftlen=16384L
	dofft=(fftlen gt 0)
	
	if (fftlen gt smpToRead) and (dofft) then begin
		print,prgNm+ " fftlen > samplesToRead"
		goto,errout
	endif
	if (n_elements(desc) eq 0 ) then begin
		istat=pdevopen(fname,desc,fnmI=fnmI)
		if istat ne 0 then begin
			print,prgNm+ " Error openning file:",istat
			goto, errout
		endif
		openfile=1
	endif
	if (n_elements(normspc) eq 0 ) then normspc=0
		
;
;	get the data
;
	npol=desc.nsbc
	n=pdevgettmd(desc,smpToRead,b)
	if (n ne smpToRead) then begin
		print,prgNm + " warning.. only " + string(n) +$
			 " samples read."
		stop
	endif
	meanAr=complexarr(2)
	rmsAr=complexarr(2)
	for i=0,npol-1 do begin
		a=rms(b.d[*,i],/quiet)
		meanAr[i]=a[0]
		rmsAr[i] =a[1]
	endfor
	if (n lt fftlen) and (dofft) then begin
		print,prgNm+ " fftlen > actual samples read"
		goto,errout
	endif
	if (dofft) then begin
	  nfft=smpToRead/fftlen
	  if (nfft*fftlen) ne smptoRead then begin
		i1=nfft*fftlen-1
		if npol eq 1 then begin
	 		spc=reform($
 	            total(abs(fft(reform(b.d[0:i1],fftlen,nfft),dim=1))^2,2)/nfft,$
			fftlen)
		endif else begin
	 		spc=reform($
 	            total(abs(fft(reform(b.d[0:i1,*],fftlen,nfft,npol),dim=1)$
			      )^2,2)/nfft,fftlen,npol)
		endelse
	  endif else begin
        if npol eq 1 then begin
            spc=reform($
               total(abs(fft(reform(b.d,fftlen,nfft),dim=1))^2,2)/nfft, fftlen)
        endif else begin
            spc=reform($
            total(abs(fft(reform(b.d,fftlen,nfft,npol),dim=1))^2,2)/nfft,$
			fftlen,npol)
		endelse
	  endelse
	  spc=(npol eq 1)?shift(spc,fftlen/2):shift(spc,fftlen/2,0)
	  if normspc then begin
		for ipol=0,npol-1 do spc[*,ipol]/=median(spc[*,ipol])
	  endif
      freq=pdevfreq(desc,lenfft=fftlen)
	endif else begin
		spc=0.
		freq=0.
	endelse
;
; 	compute the histogram
;
	nbits = desc.bits
	scl=(nbits gt 8)?1./16.:1.
	nh=long(2L^nbits*scl + .5)
	for ipol=0,npol-1 do begin	
		if ipol eq 0 then begin
			h=histogram(float(b.d[*,ipol]*scl),binsize=1.,$
			 max=nh/2.-1,min=-nh/2.,locations=histx)
			nn=n_elements(h)
		    histy=lonarr(nn,2,npol)
			histy[*,0,ipol]=h
		endif else begin
			histy[*,0,ipol]=$
			histogram(float(b.d[*,ipol]*scl),binsize=1,$
			 max=nh/2.-1.,min=-nh/2.,locations=histx)
		endelse
		histy[*,1,ipol]=$
		histogram(imaginary(b.d[*,ipol]*scl),binsize=1,$
		 max=nh/2.-1,min=-nh/2.,locations=histx)
	endfor
		
;
	retI={$
         npol  : npol,$
         fftlen: fftlen*1L,$
         freq  : freq,$
         mean  : meanAr,$
         rms   : rmsAr,$
		 histx : histx,$
		 histy : histy,$
         spc   : spc $
	}
	if (verb) then begin
		hor
		ver
		icol=1
		ln=3
		scl=.8
		xp=.04
		lpol=[' PolA',' PolB']
		!p.multi=[0,1,2]
		ver,0,max(reti.histy)
		hor,min(reti.histx),max(reti.histx)
		plot,[0,1],[0,1],/nodata,$
			chars=cs,font=font,$
			xtitle='a/d levels',ytitle='counts',$
			tit=tit + ' ' + 'Histogram of voltages'
		for ipol=0,npol-1 do begin
			for j=0,1 do begin ; over i,q
			  oplot,reti.histx,reti.histy[*,j,ipol],col=colph[icol]
			  icol++
			endfor
		endfor
		icur=0
		for ipol=0,1 do begin
			note,ln+icur*scl,"I-dig " +lpol[ipol],xp=xp,$
				chars=csn,font=font,col=colph[icur+1] 
			icur++
			note,ln+icur*scl,"Q-dig " +lpol[ipol],xp=xp,$
				chars=csn,font=font,col=colph[icur+1] 
			icur++
		endfor
		tm=(dofft)?nfft*fftlen*b.integtm:smpToRead*b.integtm
		tit="average spectra. Average " + string(format='(f8.3)',$
			  tm) + " secs"
		labAr=strarr(npol)
		for ipol=0,npol-1 do begin
			labAr[ipol]=string(format=$
	'("mean (i,q):(",f6.3,1x,f6.3,") rms:(",f8.3,1x,f8.3,")")',$
				retI.mean[ipol],retI.rms[ipol] ) + $
			lpol[ipol]
			print,labAr[ipol]
;			if not dofft then print,labAr[ipol] 
		endfor
		if (dofft) then begin
		  ver
		  hor
		  ln=18
		  if n_elements(var) eq 2 then ver,var[0],var[1]
		  if npol eq 1 then begin
			plot,reti.freq,reti.spc,$
			chars=cs,font=font,$ &$
				xtitle='Freq [Mhz]',ytitle='spectral density',$
			   title=tit
	      endif else begin
			plot,reti.freq,reti.spc[*,0],$
			chars=cs,font=font,$ &$
				xtitle='Freq [Mhz]',ytitle='spectral density',$
			   title=tit
			oplot,reti.freq,reti.spc[*,1],col=colph[2]
	     endelse
		 for ipol=0,npol-1 do begin
		   note,ln +ipol*scl,labAr[ipol],xp=xp,col=colph[ipol+1],$
				chars=csn,font=font
		 endfor
		endif
    endif
	retstat=0
endit: if openfile then pdevclose,desc
	return,retstat
errout: retstat=-1
	goto,endit
end
