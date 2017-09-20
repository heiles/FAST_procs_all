;+
;NAME:
;rdevspc - compute the spectrum of the data
;SYNTAX: naccum=rdevspc(desc,fftlen,spc,spcTx=spcTx,freq=freq,toavg=toavg,plot=plot,$
;                       _extra=e,pos=pos
;ARGS:
;  desc: {}        from rdevopen()
;  fftlen:long    length of fft to perform
;   d[npol,n]: int The data read in via rdevget()
;Keywords:
;	toavg: long		number of spectra to avg. default is 1
;  plot  :          if set the plot spectra
;    _e  :          pass to plot routine.. ytitle=ytitle, etc..
;    pos :  long    Ipp in file to position to before starting.
;                   (count from 0). null or -1 --> read next ipp available
;RETURNS:
; naccum: long     number of power spectra we averaged.
; spc[fftlen]: float The frequency array for the spectrum (in Mhz). 
; spctx[fftlen]: float if supplied then also return the tx spectra
;     freq[fftlen]: float  freq array Mhz

;DESCRIPTION:
;   Input and compute spectra for rdev data. toavg keyword allows you to average 
;multiple spectra. The spectra is returned. it will also return via keywords the number
;of pols (npol), the frequency array (freq).
;	The /plot keyword will plot the spectra before returning.
;EXAMPLE:
;
; file='/share/pdata/pdev/sasdr_2010.20100123.b0a.00100.pdev'
; istat=rdevopen(file,desc)
;; set each plot in a separate window
; naccum= rdevspc(desc,spc,freq=freq,/plot)
;
;history:
; 25jan10 .. updated to new rdev format
; 04mar08 .. switched to new decF coding
;
;-
function rdevspc,desc,fftlenD,spcD,spcTx=spcTx,freq=freq,txFreq=txFreq,toavg=toavg,$
				   plot=plot,_extra=e,pos=pos
            
;
	posL=(n_elements(pos) eq 0)?-1L:pos
	if n_elements(toavg) eq 0 then toavg=1
    bw   = rdevbw(desc)
	naccumD=0L
	useTx=arg_present(spcTx)
	if useTx then begin
		naccumTx=0L
		fftLenTx=(fftlenD le desc.txsmpipp)?fftlenD:2L^fix(alog10(desc.txsmpIpp)/alog10(2.))
	endif
	spcD=fltarr(fftlenD)
	if useTx then spcTx=fltarr(fftlenTx)
	done=0
	fftDInIpp=desc.dsmpipp/fftlenD
	if (fftDInIpp lt 1 ) then begin
		print,"fftlen must be < than the samples in the data win:",desc.dsmpipp
		return,-1
	endif
	if useTx then fftTxInIpp=desc.txsmpipp/fftLenTx
	while (~ done) do begin
		if ((nsmp=rdevgetipp(desc,d,tx,posipp=polL,/cmplx)) ne 1) then begin
			print,"Error reading in ipp: istat:",nsmp
			return,-1
		endif
		i0=0L
		for i=0,fftDInipp-1 do begin
			spcD+=(abs(fft(reform(d[i0:i0+fftLenD-1])))^2)
			i0+=fftlenD
	    	posL=-1
			naccumD++
			if naccumD ge toavg then begin
				done=1
				break
			endif
		endfor
		if useTx then begin
			i0=0L
;    note that this could have different number of accumulations than the data.
			for i=0,fftTxInipp-1 do begin
				spcTx+=(abs(fft(reform(tx[i0:i0+fftLenTx-1])))^2)
			    i0+=fftlenTx
				naccumTx++
			endfor
		endif
	endwhile
	if naccumD eq 0 then return,0
	if naccumD gt 1 then spcD/=naccumD
	if useTx then begin
		if  naccumTx gt 1 then spcTx/=naccumTx
	endif
	spcD=shift(spcD,fftlenD/2)
	if (useTx) then spcTx=shift(spcTx,fftlenTx/2)
	if (arg_present(freq) ||  keyword_set(plot)) then begin
			freq=(findgen(fftlenD)/fftlenD - .5)*bw
	endif
	if (arg_present(Txfreq) ||  keyword_set(plot)) then begin
			txFreq=(findgen(fftlenTx)/fftlenTx - .5)*bw
	endif
	if keyword_set(plot) then begin
			if useTx then begin
				!p.multi=[0,1,2]
	    		plot,freq,spcD[*],_extra=e
	    		plot,freq,spcTx[*],_extra=e
			endif else begin
	    		plot,freq,spcD[*],_extra=e
			endelse
	endif
	return,naccumD
end
