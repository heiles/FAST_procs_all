
;+
;NAME:
;rdevgraptxsmp - grap txSamples from a file
;SYNTAX   nipps=rdevgraptxsmp(desc,txTims,nsamples,txAr)
;                     
;ARGS:
;  desc : {}     returned from rdevopen()
;txTimes[m]:float offsets from start of txipp in usecs for samples to return
;nsamples:  int   number of samples at each tx offset to return
;KEYWORDS:
;txOff:	float	
;
;RETURNS:
;   nipps                 : long number of ipps we found
; txDat[nsamples,nipps,m] : complex    the data
;
;DESCRIPTION:
;   Scan a file extracting individual txsamples from a file. This
;can be used to determine where different observation types start:
;eg. clp has data out to 440 usecs, while topside goes out to 
; For each ipp:
;    for each element of txTims, extract nsamples complex samples.
;
;-
function    rdevgrabtxsmp,desc,txTimes,nsamples,txAr
;
;   value for 4 bit lookups
;
;    real img indices
    indr=1
    indi=0

	ntimes=n_elements(txTimes)
	bytesSmp=2*2L			;  16 bit i,q
	bytesPerRead=nsamples*bytesSmp
;
;	figure out byte offset from start of tx ipp for each txTim
;
	bw=rdevbw(desc)
	txOffSmp  =long(txTimes*bw + .5)
	txOffBytes=txOffSmp*bytesSmp
;
;   position to first ipp
;
	if (rdevposipp(desc,0L) ne 0) then begin &$
		print,"error positioning to first ipp" &$
		return,-1 &$
	endif
	point_lun,-desc.lun,curPosSt
;
; 	position to sample in tx we want.
;
	nsmpIpp=desc.txsmpipp+desc.dsmpipp+desc.nsmpIpp
	ippsInFile=long(desc.smpinfile/nsmpIpp)
	inpDat=intarr(2,nsamples)
	txAr=complexarr(nsamples,ippsInFile,ntimes)
	for ipp=0,ippsInFile-1 do begin &$
		for j=0,ntimes-1 do begin
			point_lun,desc.lun,curPosSt + txOffBytes[j]
			readu,desc.lun,inpDat &$
			txAr[*,ipp,j]=complex(reform(inpDat[indr,*]),reform(inpDat[indI,*])) &$
		endfor 
;
;		compute  start of next  ipp
;
		curPosSt+= bytesSmp*(nsmpipp) &$
	endfor
;
; 	reform 
;
	if (ntimes eq 1) and (nsamples eq 1) then begin
		txar=reform(txar,ippsInFile)
	endif else begin
		if (ntimes eq 1) then begin
			txar=reform(txar,nsamples,ippsInFile)
		endif else begin
		   if (nsamples eq 1) then begin
				txar=reform(txar,ippsInFile,ntimes)
		   endif
		endelse
	endelse
	return,ippsInfile
end
