;+
;NAME:
;bdwf_hrsmointerpscan - smooth and interpolate image
;SYNTAX:  istat=bdwf_hrsmointerpscan(savFileInp,freqChanToAvg,
;               tmI,freqI,img_tf,$
;		       median=median,baseline=baseline,zx=zx,zy=zy,$
;		       nsigclip=nsigclip,pol=pol)
;ARGS  : 
;savFileInp: string name of save file holding outputof doitmockhr()
;freqChanToAvg: long number of frequency channels to avg.
;               probably best if divides into total number of
;               channels (8192)
;KEYWORDS:
;	pol: int	polarization to use. 1-4
;               1-stokesI, 2=stokesQ,3=stokesU,4=stokesV
;               default is stokes V.
; median:       if keyword set (/median) then use median rather than
;               mean when averaging freq channels
; baseline:     if set then for each band:
;                  -compute median frequency for band and subtract
;                   it frome each spectra.
;               If not set, then  remove the median of all spectra in 
;               band.
; zx:    int    scale img display in x direction (-2 is 1/2 ,
;               +2 is twice the width"
; zy:    int    scale img display in y direction
; nsigclip: float clip image to Nsig . def=3.
;RETURNS:
;	istat: int  1 ok, -1 error
;     tmI[nt]: float   values for the time axis. unit = secs.
;   freqI[nf]: float   value for the interpolated freq axis. unit=Mhz.
;   img_tf[nt,nf]:float image with x axis=time
;   
;DESCRIPTION:
;	Create an image of the calibrated stokes data. The routine does:
; - input the save file created from doitmockhr(). This contains the
;   calibrated full frequency resolution data of the 7 bands.
; - smooth, decimate each of the 7 bands by freqChanToAvg
; - combine the 7 decimated bands into 1 image
;   - make sure each band is in increasing freq order
;   - interpolate the data to a fixed frequency grid.
; - return the image in img_tf (time is x axis),
;    as well as the tm and freqI keywords.
;
;-
function bdwf_hrsmointerpscan,saveFileInp,freqChanToAvg,$
		tmI,freqI,img_tf,pol=pol,$
		median=median,baseline=baseline
		
;
	    common colph,decomposedph,colph
	
	useMedian=keyword_set(median)
	useBaseline=keyword_set(baseLine)
	ipol=3
  	if n_elements(pol) ne 0 then  ipol=pol-1
	if (ipol lt 0) or (ipol gt 3) then begin
		print,"pol should be 1..4"
		return,-1
	endif
	nchanToAvg=freqChanToAvg
;
;	restore save file
	restore,saveFileInp,/verb
	a=size(boutsave)
	nrows=a[1]
	nbeams=a[2]
	nchan=boutsave[0].nchan
	ndmp=boutsave[0].ndump
	nspc=ndmp*nrows
	nchan1=nchan/nchanToAvg			; after averaging, 1 band
;
;   1--> after averaging
;	hold data after channel average
;
	img1=fltarr(nchan1,nspc,nbeams)
	freq1Ar=fltarr(nchan1,nbeams)
;   original freq
	freq=fltarr(nchan)
	for ibm=0,nbeams-1 do begin &$
		if (useMedian) then begin 
			y=(ndmp eq 1) $
			 ?median(reform(boutsave[*,ibm].d[*,ipol,*],nchanToAvg,nchan1,nspc), dim=1) $
			 :median(reform(boutsave[*,ibm].d[*,ipol,*,*],nchanToAvg,nchan1,nspc), dim=1)
		endif else begin
			y=(ndmp eq 1) $
			  ? total(reform(boutsave[*,ibm].d[*,ipol,*],nchanToAvg,nchan1,nspc),1)/nchanToAvg $
			  : total(reform(boutsave[*,ibm].d[*,ipol,*,*],nchanToAvg,nchan1,nspc),1)/nchanToAvg
		endelse
		freq=masfreq(boutsave[0,ibm].h) 
	    flip=(boutsave[0,ibm].h.cdelt1 lt 0)
		if useBaseline then begin
			baseLineL=median(y,dim=2) &$
			for ispc=0L,nspc-1 do begin 
				y[*,ispc]-=baselineL &$ &$
			endfor &$
		endif else begin
			y-=median(y)
		endelse
		if flip then begin &$
			y=reverse(y,1) &$
			freq=reverse(freq) &$
		endif &$
		img1[*,*,ibm]=y &$
		freq1Ar[*,ibm]=total(reform(freq,nchanToAvg,nchan1),1)/nchanToAvg &$
	endfor
;
; 	get rid of overlapping freq
;
	df=freq1Ar[1,0]-freq1Ar[0,0]
	okAr=intarr(nchan1,nbeams) + 1
	for ibm=0,nbeams-2 do begin &$
		ii=where(freq1Ar[*,ibm+1] le freq1Ar[nchan1-1,ibm],cnt) &$
		cnth=long(cnt/2.) &$
		if cnth gt 0 then begin &$
            nn=nchan1-cnth &$
            okAr[nn:*,ibm]=0 &$
            okAr[0L:cnth-1,ibm+1]=0 &$
;        make sure no overlap (if not even)
            while(freq1Ar[nn,ibm] ge freq1Ar[cnth,ibm+1]) do begin &$
            	okAr[nn,ibm]=0 &$
                nn=nn-1 &$
            endwhile &$
        endif  &$
	endfor
;
; 	interpolate onto a fixed grid
;
	df=freq1Ar[1,0]-freq1Ar[0,0]
	fmin=min(freq1Ar)
	fmax=max(freq1Ar)
    ntot=long((fmax-fmin)/df  + .5) + 1L
    freqI=findgen(ntot)*df + fmin
	ii=where(OkAr eq 1)
;
; 	interpolate onto fixed grid
;   freq (x) by time (t)
	img_ft=fltarr(ntot,nspc)
	fI=freq1Ar[ii]				; freq before interpolation
	for ispc=0,nspc-1 do begin &$
		y=img1[*,ispc,*] &$
		img_ft[*,ispc]=interpol(y[ii],fI,freqI) &$
	endfor
	if ndmp gt 1 then begin
		tmI=findgen(nspc)*boutsave[0].h.cdelt5
	endif else begin
		tmI=findgen(nspc)*boutsave[0].h.cdelt5*abs(boutsave[0].accum)
	endelse

	img_tf=transpose(img_ft)
;
	return,1
;
;   display image outside of this routine
;
;	rangeF=[fmin,fmax]
;	rangeT=[0,max(tmI)]
;	nsig=3
;	invert=1
;	a=meanrob(img_tf,sig=sig,/double)
;	nsigclip=(n_elements(nsigclip) eq 0)?3.:nsigclip
;	clip=[-sig,sig]*nsigclip
;	zx=(n_elements(zx) eq 0)?-2:zx 
;	zy=(n_elements(zy) eq 0)?-2:zy 
;	!p.multi=0
;	imgdisp,img_tf,xr=rangeT,yr=rangeF,invert=invert,clip=clip,$
;		zx=zx,zy=zy
;	return,1
end
