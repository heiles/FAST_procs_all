;+
;NAME:
;mascmppwrrms - compute total power exluding rfi via rms.
;SYNTAX: istat=mascmppwrrms(bar,tpI,fixblank=fixblank,norm=norm,maskar=maskar)
;ARGS:
;	bar[N]:{}	array of data from masgetm
;KEYWORDS:
;fixblank: 	if set the correct for any blanked spectra so they
;           all have the standard integration time.
;norm    :  if set then normalize tp to median value
;RETURNS:
;istat:	int 	0 ok, -1 error 
;tpi:{}		structure hold total power info
;maskAr[nchan,npol]: float mask used 
;-
;
function mascmppwrrms,bar,tpI,fixblank=fixblank,maskAr=maskAr,norm=norm

    nrows=n_elements(bar)
    ndumps=bar[0].ndump
    nspc=nrows*ndumps
    nchan=bar[0].nchan
	mjdtojd=2400000.5D
	deg=1
;
;   figure out number scans in file and where the cal and
;   data is
;
    brms=masrms(bar)
    x=findgen(nchan)/nchan
	npol=(brms[0].npol < 2)
;
    tpI={  hdr      : bar[0].h   ,$
           nspc     : nspc      ,$  ; number of spectra (600) 
           maskFract: fltarr(npol),$ ; fraction used for mask 
			rms     : fltarr(npol),$ ; median value of rms
               tp   : fltarr(nspc,npol)} ;tpSpc/median(tpSpc all spc)
	nblank=0L
	retMask=arg_present(maskAr)
	if retMask then begin
		maskar=fltarr(nchan,npol)
	endif
	if keyword_set(fixblank) and (not bar[0].blankCorDone) then begin
		fftaccumStd=max(bar.st.fftaccum)
		iiblnk=where(fftaccumstd ne bar.st.fftaccum,nblank)
		if nblank ne 0 then begin
			blankCor=fftaccumStd*1./((reform(bar.st.fftaccum,nspc))[iiblnk])
		endif
	endif
 	for ipol=0,npol-1 do begin
		coef=robfit_poly(x,brms.d[*,ipol],deg,gindx=gindx,ngood=ngood,$
				fpnts=fpnts)
		if retMask then maskAr[gindx,ipol]=1.
		tpI.maskFract[ipol]=fpnts
		if ndumps gt 1 then begin
			tpi.tp[*,ipol]= reform(total(bar.d[gindx,ipol,*],1)/ngood,nspc)
		endif else begin
			tpi.tp[*,ipol]= reform(total(bar.d[gindx,ipol],1)/ngood,nspc)
		endelse
;	
		if nblank gt 0 then tpI.tp[iiblnk,ipol]*=blankCor
		if keyword_set(norm) then $
			tpI.tp[*,ipol]=tpI.tp[*,ipol]/median(tpI.tp[*,ipol])
		tpi.rms[ipol] =median(brms.d[gindx,ipol])
		
	endfor
	tpI.hdr=bar[0].h
	return,0
end
