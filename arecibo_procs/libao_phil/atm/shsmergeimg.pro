;+
;NAME:
;shsmergeimg - merge two images averging overlap
;SYNTAX: istat=shsmergeimg(img1,img2,cfrAr,bw,imgMerged,imgI,nedgslop=nedgeslop)
;ARGS:
;img1[n,m]: float  one img to merge
;img2[n,m]: float  2nd img to merge
;cfrar[2]: double  freq, Mhz center each band.
;                  if 4096 chan, the freq for chan[2048] cnt from 0
;bw      : double  bw in mhz for each image
;KEYWORDS:
;edgslop: long      number of channels to ignore from each edge of each
;                   img. def is 34. this  area has no data.
;RETURNS:
;istat          :  0 ok
;                  -1 error
;imgMerged[nn,m]: float  merged image
;imgI     : {}     holds info about the new img
;                  - imgI.nchan
;                  - imgI.f0 first freq
;                  - imgI.f1 last freq chan
;                  - imgI.df  channel freq spacing
;DESCRIPION:
;	merge two images together. It will discard edgeslop channels
;from the edges of each input image (def:34).
;It will then averge the overlap region and return the final image.
;	The routine does not reinterpolate the data. If the frequency
;step does not divide into the frequency separation of the two bands
;then there will be a freq error in the overlap region. this will be a
;fraction of the channel width.
;	The freq returned are: 
;    imgI.f0 - is the first frequency kept from the first image
;    imgI.f1 - is the last freq kept from the 2nd image
;    imgI.df - is the original freq freq  step
;-
function shsmergeimg,img1,img2,cfrar,bw,imgM,imgI,nedgslp=nedgslop

;	
	if n_elements(nedgslop) eq 0 then nedgslop=34
	nchan1=n_elements(img1[*,0])
	nhght1=n_elements(img1[0,*])
	nchan2=n_elements(img2[*,0])
	nhght2=n_elements(img2[0,*])
	if (nhght1 ne nhght2) or (nchan1 ne nchan1) then begin
		print,"shsmergeimg. images must have same number of channels, heights"
		return,-1
	endif
	nchan=nchan1
	nhght=nhght1
	freq1=(dindgen(nchan)/nchan - .5d)*bw + cfrar[0]
	freq2=(dindgen(nchan)/nchan - .5d)*bw + cfrar[1]
	df=freq1[1]-freq1[0]
	swapBands= (cfrar[0] gt cfrar[1])
	minF1u=freq1[nedgSlop]	        ; first freq to use
	maxF1u=freq1[nchan-1-nedgSlop]	; last freq to use
	minF2u=freq2[nedgSlop]	        ; first freq to use
	maxF2u=freq2[nchan-1-nedgSlop]	; last freq to use
; 
	; the overlap region
	if swapBands then begin
		iiovr1=where((freq1 ge minf1u) and (freq1 le maxF2u),novrl1)
		iiovr2=where((freq2 ge minf1u) and (freq2 le maxF2u),novrl2)
	endif else begin
		iiovr1=where((freq1 ge minf2u) and (freq1 le maxF1u),novrl1)
		iiovr2=where((freq2 ge minf2u) and (freq2 le maxF1u),novrl2)
	endelse
	if (novrl1 ne novrl2) then begin
		print,"images do not have same number of chan in overlap region:",novrl1,novrl2
		return,-1
	endif
	novr=novrl1
	nchanN=(nchan - 2*nedgSlop)*2 - novr
	imgM=fltarr(nchanN,nhght)
	; i0,i1 are indices into the new array
	i0=0
	i1=nchan-novr-1L - 2*nedgSlop ; end of part from first img.. before overlap
	if swapBands then begin
		imgM[i0:i1,*]=img2[nedgSlop:nchan-novr-nedgslop-1L,*]
    ; overlap region
		i0=i1+1
		i1=i0 + novr - 1L
		imgM[i0:i1,*]=(img1[iiovr1,*]  + img2[iiovr2,*])*.5
	; last part from img1
		i0=i1 + 1
		imgM[i0:*,*]=img1[max(iiovr1)+1:nchan-1L -nedgslop ,*]
	endif else begin
		imgM[i0:i1,*]=img1[nedgSlop:nchan-novr-nedgslop-1L,*]
    ; overlap region
		i0=i1+1
		i1=i0 + novr - 1L
		imgM[i0:i1,*]=(img1[iiovr1,*]  + img2[iiovr2,*])*.5
	; last part from img2
		i0=i1 + 1
		imgM[i0:*,*]=img2[max(iiovr2)+1:nchan-1L -nedgslop ,*]
	endelse
;
;	fill in the freq info
;   cfr is in freq[n/2] count from 0
	imgI={$
			nchan:nchanN,$
			f0   :cfrAr[0] -df*(nchan/2L - nedgslop),$
			f1   :cfrAr[1] +df*(nchan/2l -1 - nedgslop),$
			df   :df}
	return,0  
end 
