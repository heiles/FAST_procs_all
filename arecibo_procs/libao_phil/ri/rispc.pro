;+
;NAME:
;rispc - input and compute spectra from ri data
;SYNTAX: istat=rispc(lun,freqRes,spc,dc=dc,pwrof2=pwrof2,hdr=hdr,chan=chan,
;                    rawd=rawd,freq=freq)
;
;ARGS:   lun    : unit number for file (already opened)
;     freqRes   : float freq resolution Hz we want in the spectra
;KEYWORDS:
;     pwrOf2    :       if set then force the output spectra to be the closest
;                       power of 2
;       hdr     : {hdr} pass in a header for this file so we don't have
;                       to read the first record to get 1.
;       dc      : complex remove this before computing spectra 
;      chan     : int   Which channel to use
;      dec      : int   decimate input data by this amount. 0=1 is no
;                       decimation
;
;RETURNS:
;  istat        :      1 got spectra
;                      0 hit eof
;                      -1 error
;   spc[n]      : float spectra
;rawd[]         : {ri}  return input records here.
; freq[n]       : float freq array for the spectra
;
;DESCRIPTION:
;   Read in ri data and compute the power spectra.  The routine will optionally
;remove dc and smooth/decimate before computing the spectra. The computed
;power spectra will be returned. The routine can also return a copy of the
; input raw data (keyword rawd=) and a freq array (freq=) that corresponds 
;to the computed spectra.
;   The routine assumes that the data is taken as complex data. If more
;that 1 channel was taken, then the chan= keyword can select between
;chan 1 and chan 2 (chan 1 is the default).  
;   By default the routine will read the first record to get the header
;info. To save time, you can pass in a header for this file using the
;hdr=  keyword.
;   The dec= keyword allows averaging/decimation in time before
;computing the spectra. 
;
;   The processing is:
; 1. grab a header from the file if hdr= keyword not used..
; 2. compute the spectral length: 
;       1./(freqRes*smpTm*dec)
;    make this the closest power of 2 if pwrof2 is set.
; 3. compute the number of input recs needed for this data.
; 4. input the data, smooth and decimate by dec if requested.
; 5. remove dc if supplied
; 6. compute the spectra: spc=abs(fft(d))^2
; 7. rotate the spectra to put dc in the middle: spc=shift(spc,smpSpc/2)
;
;Example:
;   openr,lun,file,/get_lun
;
;; compute dc first over the 1st 100 recs
;
;   istat=riget(lun,d,numrecs=100)
;   dc=total(d.d1)
;   rew,lun             ; rewind file
;
;;  use the header read in to pass to routine 
;   
;   hdr=d[0].h
;
;;  decimate by 128, force spectra to be a power of 2
;;  return the freq array on the first call
;;  compute 100 spectra
;
;   freqRes=1.              ; 1 hz resolution
;   toSmo  =128L            ; decimate by 128..
;   numSpc = 100
;   for i=0,numSpc-1 do begin
;      if i eq 0 then begin
;         istat=rispc(lun,freqRes,spc,dec=toSmo,freq=freq,hdr=hdr,dc=dc)
;         spcAr=fltarr(n_elements(spc),numSpc)  ; be sure you have mem for this.
;      endif else begin
;         istat=rispc(lun,freqRes,spc,dec=toSmo,hdr=hdr,dc=dc)
;      endelse
;     spcAr[*,i]=spc
;   endfor
;
;-
;
;
function  rispc, lun, freqRes,spc,dc=dc,pwrof2=pwrof2,hdr=hdr,chan=chan,$
            rawd=rawd,dec=dec,freq=freq
;
    decF=1L
    if n_elements(chan) eq 0 then chan=1
    if n_elements(dec) ne 0 then  decF=dec
    if decF eq 0 then decF=1L
    makePwrOf2=keyword_set(pwrof2)
    needHdr=n_elements(hdr) eq 0
    gotDc  =n_elements(dc) gt 0 
;
    point_lun,-lun,curpos
    if needHdr then begin
       istat=riget(lun,d)
       if istat ne 1 then return,istat
       hdr=d.h
       point_lun,lun,curpos
    endif
    if (chan eq 2) and (hdr.ri.fifonum eq 1) then begin
        print,'Data only has channel 1. chan 2 not available...'
        return,-1
    endif 
;
;   index for chan 
; 
    ichn=(chan eq 1)? 0:(hdr.ri.fifonum eq 2)?0:1
;
;
;
    gw=hdr.ri.gw
    smprec=hdr.ri.smppairipp*hdr.ri.ippsperbuf
    smpSpc=long(1./(freqRes*gw*1e-6))/decF
    if makePwrOf2 then begin
        a=alog(smpSpc*1.)/alog(2.)
        if (a mod 1.) gt 0.584962 then a+=1.
        a=long(a)
        smpSpc=2L^a
    endif
    smpRead=smpSpc*decF
;
;    see if they want the freq returned
;
    if arg_present(freq) then begin
        bw=(1./(gw*1e-6))/decF
        freq=(findgen(smpSpc)/smpSpc - .5)*bw
    endif
;
;   compute how many recs we need
;
    nrecs=smpRead/smprec
    if (nrecs*smpRec) lt smpSpc then nrecs++
    istat=riget(lun,rawd,/complex,numrecs=nrecs)
    if istat le 0 then return,istat
    if istat ne nrecs then return,0
	smpInp   =nrecs*smprec
	i2=smpRead - 1L
	needSubSet= ( smpInp gt smpRead)
;
;   compute spectra
;
	if (needSubset) then begin
    	if decF gt 1 then begin
    		if (gotdc) then begin
       			spc=shift($
      			abs(fft(reform(total(reform((rawd.(ichn+1))[0:i2],decF,smpSpc),1)$
					/decF) - dc))^2.,smpSpc/2L)
      		endif else begin
       			spc=shift($
      			abs(fft(reform(total(reform((rawd.(ichn+1))[0:i2],decF,smpSpc),1)$
					/decF)))^2.,smpSpc/2L)
      		endelse
    	endif else begin
       		if (gotdc) then begin
         		spc=shift(abs(fft(reform((rawd.(ichn+1))[0:i2],smpSpc)-dc))^2.,$
					smpSpc/2L)
       		endif else begin
         			spc=shift(abs(fft(reform((rawd.(ichn+1))[0:i2],smpSpc)))^2.,$
						smpSpc/2L)
       		endelse
    	endelse
	endif else begin
    	if decF gt 1 then begin
    		if (gotdc) then begin
       			spc=shift($
      			abs(fft(reform(total(reform(rawd.(ichn+1),decF,smpSpc),1)/decF)$
					 - dc))^2.,smpSpc/2L)
      		endif else begin
       			spc=shift($
      			abs(fft(reform(total(reform(rawd.(ichn+1),decF,smpSpc),1)/decF)$
					))^2.,smpSpc/2L)
      		endelse
    	endif else begin
       		if (gotdc) then begin
         		spc=shift(abs(fft(reform(rawd.(ichn+1),smpSpc)-dc))^2.,smpSpc/2L)
       		endif else begin
         		spc=shift(abs(fft(reform(rawd.(ichn+1),smpSpc)))^2.,smpSpc/2L)
       		endelse
    	endelse
	endelse
    return,1
end
