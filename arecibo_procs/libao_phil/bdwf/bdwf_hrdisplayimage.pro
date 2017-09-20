;+
;NAME:
;bdwf_hrdisplayimage - display an image
;SYNTAX: bdwf_hrmakeimage,savDirNm,savInpNm,yyymmdd,srcToGet,freqChanToAvg,pol,
;  			baseline=baseline,gifname=gifname,
;           img_tf=img_tf,tmI=tmI,freqI=freqI
;ARGS:
;savDirNmr  : string directory to read the save file, and where to write
;                    the hdr and binary files.
;savInpNm   : string name of input save file (without the directory).
;yyyymmdd   : long   date. becomes part of output filename
;srcToGet   : string srcname. becomes part of output filename
;freqChanToAvg:long  number of frequency channels to avg. eg 64,or 128
;pol        : int    1..4 (stokes i,q,u,v) make,store image of this pol
;KEYWORDS:
;baseline:    int    0--> baseline the  image after combining the 7 bands
;                    1--> baseline each of the 7 bands separately
;                         (this is the default) 
;gifname : string    if provided then write the image to a gif file with
;                    this  name (in the current directory)
;RETURNS:
;img_tm[ntm,nfrq]:float  created image
;tmI[ntm]     :float   time (counting from 0) for each spectra in the image.
;freqI[nfrq]  :float   freq channels for the image (Mhz).
;DESCRIPTION:
;	1.input the save file created by bdwf_hrmakesavefile.
;   2.make a dynamic spectra image for the specified polarization (1..4)
;     - combine all 7 frequency channels
;     - average, decimate in frequency
;     - interpolate to a fixed frequency grid
;     - write the binary image and ascii header to two files
;	 The output file names will be :
;
;		   binfileNm=savDirNm + srcToGet + "_polN_.bin"
;		   hdrfileNm=savDirNm + srcToGet + "_polN_.hdr"
;-
pro bdwf_hrdisplayimage,hrI,img_tf,tmI,freqI,pol,$
           maxFreq=maxFreq,minFreq=minFreq,tmin=tmin,tmax=tmax,$
			zx=zx,zy=zy,invert=invert,nsig=nsig,gifname=gifname, img=img

; -----------------------------------------------------------------
; now display the image
;
; use maxfreq to limit the freq to display
;---> edit to limit the max freq for image to display
	if n_elements(maxFreq) eq 0 then maxFreq=max(freqI)
	if n_elements(minFreq) eq 0 then minFreq=min(freqI)
	if n_elements(tmin)  eq  0 then tmin=min(tmI)
	if n_elements(tmax)  eq  0 then tmax=max(tmI)
	if n_elements(invert)  eq  0 then invert=0
	if n_elements(nsig) eq 0 then nsig=3.
;---> edit to limit the max freq for image to display
	ii=where((freqI ge minfreq) and (freqI le maxFreq),cntFreq)  
	jj=where((tmI ge tmin) and (tmI le tmax),cntTm)
	if (cntTm eq 0) or (cntFreq eq 0) then begin
		print,"no points in minFreq,maxFreq, minTm,maxTm"
		return
	endif
;
; this makes labels for time axis
;
	rangeT=[min(tmI[jj]),max(tmI[jj])]
	rangeF=[min(freqI[ii]),max(freqI[ii])]
;
	xtitle='time [seconds]'
	ytitle='Freq [MHz]'
	ldate=string(format='(i08)',hrI.yyyymmdd)
	lpolAr=['StokesI','StokesQ','StokesU','StokesV']	
	title=hrI.srcToGet + " burst " + ldate + ' ' + lpolAr[pol-1]
; makes characters bigger
	cs=1.5
; space around the edge of the image
	border=85
;
; zoom in x,y  by pixel replication (positive) or averaging (neg)
	Xmax=1400
	Ymax=900 
	nx=cntTm
	ny=cntFreq
	if n_elements(zx) eq 0 then begin
		nx=cntTm
		if nx le Xmax then begin
			zx=Xmax/nx
		endif else begin
		    zx=(nx/Xmax)
			if nx/(zx*1.)  gt Xmax then zx++
			zx=-zx
		endelse
	endif
	if n_elements(zy) eq 0 then begin
		ny=cntFreq
		if ny le Ymax then begin
			zy=Ymax/ny
		endif else begin
		    zy=(ny/Ymax)
			if ny/(zy*1.)  gt Ymax then zy++
			zy=-zy
		endelse
	endif
	if (ny/abs(zy*1.) gt 1000)  then begin
		print,"Warning > 1000 freqBins. You may want to make zy more negative"
	endif

	!p.multi=0
	img=img_tf[*,ii]
	img=img[jj,*]
	imgdisp,img,xr=rangeT,yr=rangeF,invert=invert,nsigclip=nsig,$
        zx=zx,zy=zy,xtitle=xtitle,ytitle=ytitle,title=title,$
        chars=cs,border=border
	if n_elements(gifname) gt 0 then begin
		write_gif,gifname,tvrd()
	endif
	return
end
