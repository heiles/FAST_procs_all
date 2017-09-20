;-
;NAME:
;shsclpimg: make image of decoded clp file
;SYNTAX:istat=shsclpimg,file,imgNum,img=img,hdr=hdr,mimgInfo=imgInfo,$
;			bpcind=bpcind,medlen=medlen,cfr=cfr,bw=bw,useimg=useimg,
;			nsig=nsig,zx=zx,zy=zy,title=title,nhghts=nhghts,$
;           wintouse=wintouse,rangeToUse=rangeToUse,fast=fast
;ARGS:
;file: string	    filename holding decoded info (xxx.dcd)
;imgNum:  int        which img to display 1 img1 , 2 img2, 0 no image
;                    12 - both images merged
;
;KEYWORDS:
;bpcInd[2]:long     first last height indices to use for bpc
;                   default last 100 hghts
;medlen:   long     length median filter each spc. default=71 channels
;cfr : float        cfr in Mhz for band. If imgNum=12 then cfr
;                   must be cfr[2] holding the cfr for each img
;bw  : float        bandwidth in Mhz for band
;useimg:            if set then user is passing in img. useit
;nsig[2]: float		for scaling the image. default=[-nsig[0],nsig[1]]*sig
;                   def. 6 sigma.         
;zx  : int   	    scaling for x axis (neg is smaller)
;zy  : int   	    scaling for y axis (neg is smaller)
;nhghts:int         limit to this number of heights (def all)
;title: string      title
;wintouse: int      window number to use for display. Default=1
;rangeToUse[2]:float ranges to use (in km). overrides nghts
;                    [0.,x] will start with first range
;                    [x,999] will end with last range
;fast         :int   if supplied then compute median bandpass to subtract
;                    every fast rows
;
;RETURNS:
;
;istat:  0 ok, -1 error
;img[*,*]:  float selected channel image
;hdr: {}    struct from .hdr file
;MimgInfo:{} if imgNum=+/-12 the this has the freq info for the
;           merged image.. see shsimgmerge()
;
;DESCRIPTION:
;	Make a dynamic spectra image of decoded shs file (.dcd).
;Take info from the .hdr file (it should be in the same directory
;as the .dcd file).
; You select which image you want with imgNum=1,2,12
;12 --> merge the 2 images. If imgNum is -1,-2,-12
;then the image is created, but not displayed
;-
;
function shsclpimg,dcdfile,imgNum,img=img,hdr=hdr,mimgInfo=imgInfo,$
            cfr=cfr,bw=bw,useimg=useimg,$
			bpcind=bpcind,medLen=medlen,$
			nsig=nsig,zx=zx,zy=zy,title=title,border=border,$
			nhghts=nhghts,wintouse=wintouse, rangeToUse=rangeToUse,$
			fast=fast			
;
	forward_function shsimgmerge
	if n_elements(fast) eq 0 then fast=1
	usecToKm=.15
	chkinf=1	; check for infinities
	double=1	; use double for meanrob in imgdisp
	if n_elements(wintouse) eq 0 then wintouse=1
	csn=1.5
	if n_elements(nsig) eq 0 then nsig=6
	if n_elements(title) eq 0 then title='' 
	if n_elements(cfr) eq 0 then cfr=430.
	if n_elements(bw) eq 0 then bw=5.
	if n_elements(border) eq 0 then border=75
	if n_elements(medlen) eq 0 then medlen=71L
	if n_elements(useimg) eq 0 then useimg=0
    basenm=basename(dcdfile)
	len=strlen(dcdfile)
	hdrfile=strmid(dcdfile,0,len-3) + "hdr"
	if (shsclprdhdr(hdrfile,hdr) ne 0) then return,-1
	nchan=hdr.nchan
	fftlen=hdr.fftlen
	nhghtsTot=hdr.nhghts
	if n_elements(nhghts) eq 0 then nhghts=nhghtsTot
	if nhghts le 0 then nhghts=nhghtsTot
	hghtsToUseL=[1,nhghts]
	ih0=hghtsToUseL[0]-1
    ih1=hghtsToUseL[1]-1

;
	if n_elements(rangeToUse) gt 0 then begin
		rangeTot=([0L,nhghts-1]*hdr.hghtresusec  + hdr.hghtdelayusec)$
				 *usecToKm
		rangeToUseL=rangeTot
		if n_elements(rangeToUse) eq 1 then $
			rangeToUseL=[rangeToUse,rangeTot[1]]
		if n_elements(rangeToUse) eq 2 then rangeToUseL=rangeToUse
;       compute indices relative to first height
		aa=(rangeToUseL/usecToKm - hdr.hghtdelayusec)/$
				hdr.hghtresusec
		ih0=(aa[0] > 0L)
		ih1=(aa[1] > 0L) < (nhghtsTot-1)
		hghtsToUseL=[ih0,ih1]+1L
	endif
		
	nhghts=hghtsToUseL[1]-hghtsToUseL[0] + 1L
	if (nhghts lt 0) or (nhghts gt hdr.nhghts) or $
		(hghtsToUseL[0] lt 1) or (hghtsToUseL[1] gt hdr.nhghts)$
		then begin
		if n_elements(rangeToUse) gt 0 then begin
			print,"rangeToUse illegal. Valid vales are:",rangeTot
		endif else begin
			print,"illegal number heights requested. maxval:",$
		        hdr.nhghts
	    endelse
		return,-1
	endif
	if (not useimg) then begin
;
;	bpc should always come from end of array? 
;
		if n_elements(bpcind)  ne 2 then bpcInd=[-100,-1] + hdr.nhghts

		img=fltarr(fftlen,nhghtsTot)
		err=0
		openr,lun,dcdfile,error=err,/get_lun
		if err ne 0 then begin	
			printf,-2,!ERROR_STATE.MSG
			return,-1
		endif
;
;	see which img they want
;   if img2,position before read
;
		if imgNum eq 0 then imgNum=-1
		iimg=abs(imgNum)
		nimg=(iimg eq 12)?2:1
		posFile=0L
		for im=0,nimg-1 do begin
			if (iimg eq 2) then begin
				posFile=4L*fftlen*hdr.nhghts
	   	    	point_lun,lun,posFile
			endif
			readu,lun,img
			img=shift(img,fftlen/2,0)
    		img=reverse(img,1)
;
;	check for infinities.. warn,.
;
			jj=where(finite(img) eq 0,cntInf)
			if cntInf gt 0 then begin
		    	print,"Warning: found ",cntInf," nonFinite numbers in input img"
			endif 

			bpc=total(img[*,bpcind[0]:bpcind[1]],2)/(bpcind[1]-bpcind[0] +1.)
			bpc=reform(bpc,fftlen)
;
;	now extract the heights that actually want to display
;
			ih0=hghtsToUseL[0]-1
			ih1=hghtsToUseL[1]-1
			if nhghts ne nhghtsTot then begin
				img=img[*,ih0:ih1]
			endif
			if (fast gt 1 )then begin
				midval=fast/2
				medbp= median(img[*,midval],medlen)
				for ih=0,nhghts-1 do begin
					img[*,ih]/=bpc[*]
					if (ih mod fast) eq midval then begin
					 	print,midval
						medbp= median(img[*,ih],medlen)
					endif
					img[*,ih]-= medbp
				endfor
			endif else begin
				for ih=0,nhghts-1 do begin
					img[*,ih]/=bpc[*]
					img[*,ih]-= median(img[*,ih],medlen)
				endfor
			endelse
			if (nimg eq 2) and (im eq 0)  then img1=img	; save it
		endfor
		if nimg eq 2 then begin
;        merge images
		 	istat=shsmergeimg(img1,img,cfr,bw,imgM,imgInfo)
			img=imgM
			imgM=''
			img1=''
		endif 
	endif
	free_lun,lun
	if (imgNum lt 0) then return,0
	yr=([ih0,ih1]*hdr.hghtresusec  + hdr.hghtdelayusec)*.15
	if nimg eq 2 then begin
		xr=[-.5,.5]*imgInfo.df*imgInfo.nchan + (imgInfo.f0 + imgInfo.f1)*.5
		tit0=" file:"+basenm+ " chn:" + string(format='(i2)',imgNum)
	endif else begin
		xr=[-.5,.5]*bw + cfr
		tit0=" file:"+basenm+ " chn:" + string(format='(i1)',imgNum)
	endelse
	
	imgdisp,img[*,*],nsigclip=nsig,zx=zx,zy=zy,xr=xr,yr=yr,win=wintouse,$
			border=border,xstyle=9,xtitle='Freq Mhz',ytitle='Range Km',$
			chkinf=chkinf,double=double
	note,1.5,title + tit0,chars=csn
	return,0
end
