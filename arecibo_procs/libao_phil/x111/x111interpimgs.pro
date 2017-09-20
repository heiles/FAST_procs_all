;+
;x111interpimgs: interpolate multiple x111 bands to 1 image
;istat=x111interpimgs(pdat,img,xfrq,setsToUse)
;
;ARGS:
;pdat[n]: array of pointers to bret structs.
;         each ptr should be loaded by x11inp.
;         should have the same number of entries in each.
;         should also be contiguous in freq coverage.
;
function x111interpimgs,pdat ,img,xfrq,setsToUse
;
;create freq arrays for each band,
;
	nbands=n_elements(pdat)
	nsets=setsToUse
	rowsSet=60
	nrows=nsets*rowsSet
	nchan=(*pdat[0]).bdat[0].b1.h.cor.lagsbcout
; 25 mhz each band
	bw=25.
; 23 mhz spacing between bands
	stp=23.
	dfInp=bw/nchan
;  how many chans to keep each 1/2 band so no overlap
;  interpolate gets confused when overlap in x direction
	nchnside=long(stp/2./dfInp)
	ok=fltarr(nchan,4) + 1
; dif is number to drop each edge  each band
	dif=nchan/2 - nchnside
	ok[0:dif-1,*]=0
	ok[nchan-dif:*,*]=0
; but first band keep left edge, last band keep right edge
	ok[0:dif-1,0]=1
	ok[nchan-dif:*,nbands-1]=1
	ii=where(ok eq 1,cntsel)
; create freq array  frqInp,frqSel,frqIntp
	frqInp=fltarr(1024,nbands)
	frqSel=fltarr(cntsel)
	for i=0,nbands-1 do $
		frqInp[*,i]=corfrq((*pdat[i]).bdat[0].b1.h)
	fmax=max(frqInp)
	fmin=min(frqInp)
;
	frqSel=frqInp[ii]
	dfIntp=(fmax-fmin)/cntsel
	frqIntp=findgen(cntsel)*dfintp + fmin
	yy=fltarr(nchan,nbands,nrows)
	for iband=0,nbands-1 do begin
		yy[*,iband,*]=reform(((*pdat[iband]).bdat[*,0:nsets-1].b1.d[*,0] +  $
	            		  (*pdat[iband]).bdat[*,0:nsets-1].b1.d[*,1])/2.,nchan,1,nrows)
	endfor
	yy=reform(yy,nchan*nbands,nrows)
	img=fltarr(cntsel,nrows)
	for irow=0,nrows-1 do begin &$
		img[*,irow]=interpol(yy[ii,irow],frqSel,frqIntp) &$
	endfor
	xfrq=frqIntp
	return,1
end
