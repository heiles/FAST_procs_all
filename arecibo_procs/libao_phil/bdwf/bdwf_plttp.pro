;-
;NAME:
;bdwf_plttp - plot total power info for a day/source
;SYNTAX: bdwf_plttp,saveBase,nscans,pntsScan,lproj,lbase,ldate,$
;                vpol=vpol,fitScanDeg=fitScanDeg,fitDayDeg=fitDayDeg,tosmo=tosmo,$
;		tpall=tpall,tpFall=tpFall,azAll=azAll,zaAll=zaAll,jdAll=jdAll,gainAll=gainAll,$
;		freqAr=freqAr
;ARGS:
;saveBase:string	base name for save files. everything expect nn.sav
;nscans  : int	    number of scans to process
;lproj   : string   project id as a string (for labeling plots) and plot file output
;lbase   : long     base name for plot files.
;                   format is : psname=lproj + "_" + lbase + xx + ".ps"
;					where xx can be "_fitscanNN" or "_fitDayNN" if fitscan or fitday.
;                   NN is the degree of the fit.
;ldate  : string    date to label plots.
;KEYWORDS:
;vpol[2,4]: fltarr  vertical range by pol (min,max),[i,q,u,v] for plots
;fitScanDeg:int     if provided then remove poly_fit of this order to each scan
;fitDayDeg :int     if provided then remove poly_fit of this order for entire day
;tosmo     :int     number of points within 1 scan to smooth. If negative number then
;                   median filter rather than boxcar
;RETURNS:
;tpall[ntotpnts,nbeams,npol] : total power data
;tpFall[ntotpnts,nbeams,npol] : total power data if fit
;azAll[ntotpnts] : az position each point
;zaAll[ntotpnts] : za position each point
;jdAll[ntotpnts] : julian date each point
;gainAll[ntotpnts]: gain correction used each point
;
; also generates the ps file in current directory
;
pro	 bdwf_plttp,savBase,nscans,pntsScan,lproj,lbase,ldate,vpol=vpol,fitscanDeg=fitscanDeg,fitza=fitza,$
		tpall=tpall,tpFall=tpFall,azAll=azAll,zaAll=zaAll,jdAll=jdAll,gainAll=gainAll,freqar=freqar,$
		tosmo=tosmo,hr=hr
    common colph,decomposedph,colph

	hard=1
	npol=4
	if n_elements(fitza) eq 0 then fitza=0
	if n_elements(tosmo) eq  0 then tosmo=1
;
	fitScan=n_elements(fitScanDeg) gt 0
	vpolL=[[-200,3000],[-200,200],[-120,120],[-30,30]]
	if fitScan then $
		vpolL=[[-200,200],[-50,50],[-50,50],[-30,30]]
	if n_elements(vpol) eq 8 then vpolL=vpol

;
	xx=findgen(pntsScan)/pntsScan
	ntot=0L
	for iscan=0,nscans-1 do begin &$
		if keyword_set(hr) then begin
		   restore,string(format='(a,i2.2,".hr.sav")',savbase,iscan),/verb &$
		endif else begin
		   restore,string(format='(a,i2.2,".sav")',savbase,iscan),/verb &$
	    endelse
		n=n_elements(tpar[*,0,0])
		if (n ne pntsScan) and (iscan ne (nscans-1)) then begin
	 		print,"found scan(cnt from 0) with less than normal points. scan/npnts",iscan,n
			stop
		endif
		if iscan eq 0 then begin
			nbands=n_elements(tpar[0,0,*])
			 tpall=fltarr(pntsScan,nscans,nbands,npol)
    		jdAll=dblarr(pntsScan,nscans)
    		azAll=fltarr(pntsScan,nscans)
    		zaAll=fltarr(pntsScan,nscans)
    		gainAll=fltarr(pntsScan,nscans)
			if fitscan then tpFAll=tpall
		endif
		iix=lindgen(n)
		ii=sort(freqAr)
		if fitza then xx=zaAr
		for ipol=0,3 do begin &$
			if abs(tosmo) gt 1 then begin
				if tosmo lt 0 then begin
				  for ib=0,nbands-1 do begin
					tpall[0:n-1,iscan,ib,ipol]=median(reform(tpAr[*,ipol,ii[ib]],n),-tosmo)&$
			      endfor
				endif else begin
				  for ib=0,nbands-1 do begin
					tpall[0:n-1,iscan,ib,ipol]=smooth(reform(tpAr[*,ipol,ii[ib]],n,1,1,1),tosmo)&$
			      endfor
				endelse
		    endif else begin
				tpall[0:n-1,iscan,*,ipol]=reform(tpAr[*,ipol,ii],n,1,nbands,1)&$
			endelse
			if fitscan then begin &$
				for iband=0,nbands-1 do begin &$
					coef=robfit_poly(xx[iix],tpall[iix,iscan,iband,ipol],fitscandeg,$
					yfit=yfit) &$
					tpFall[iix,iscan,iband,ipol]=tpall[iix,iscan,iband,ipol]-yfit &$
				endfor &$
			endif &$
		endfor
		AzAll[iix,iscan]=azAr &$
		zaAll[iix,iscan]=zaAr &$
		jdAll[iix,iscan]=jdAr &$
		gainAll[iix,iscan]=sclGain
		ntot+=n
	endfor
	tpfrq=freqAr[ii]
	tpall=reform(tpall,pntsScan*nscans,nbands,npol)
	if ntot ne nscans*pntsScan then tpall=tpall[0:ntot-1,*,*]
	if fitscan then begin 
		tpFall=reform(tpFall,pntsScan*nscans,nbands,npol)
		if ntot ne nscans*pntsScan then tpFall=tpFall[0:ntot-1,*,*]
	endif
	zaall  =reform(zaall,pntsScan*nscans)
	azall  =reform(azall,pntsScan*nscans)
	jdall  =reform(jdall,pntsScan*nscans)
	gainAll=reform(gainall,pntsScan*nscans)
	if ntot ne nscans*pntsScan then begin
		zaall=zaall[0:ntot-1]
		azall=azall[0:ntot-1]
		jdall=jdall[0:ntot-1]
		gainall=gainall[0:ntot-1]
	endif
	
	x=findgen(ntot)
	xsec=(jdall-jdall[0])*86400D
;
	lpol=['StokesI','StokesQ','StokesU','StokesV']
	if keyword_set(rcvCir) then  $
		lpol=['StokesI','StokesV','StokesU','StokesQ']
	cs=1.6
	n=n_elements(tpall[*,0])
	psname=lproj+ '_' + lbase
	if keyword_set(fitScanDeg) then begin
		ex=(keyword_set(fitza))?"_za":""
		psname=psname + '_fitScan' + string(format='(i02)',fitScandeg) + ex
	endif else begin
		if keyword_set(fitDayDeg) eq 1 then begin
		    ex=(keyword_set(fitza))?"_za":""
			psname=psname + '_fitDay' + string(format='(i02)',fitdaydeg) + ex
		endif
	endelse
	psname=psname + ".ps"
	if hard then pscol,psname,/full
	ver&hor
	ib1=0&ib2=nbands-1
	for ipol=0,3 do begin &$
  		!p.multi=[0,1,4]
		icnt=0
  		for iband=ib1,ib2 do begin  &$
			ver,vpolL[0,ipol],vpolL[1,ipol] &$
			if fitscan then begin
				y=tpFall[*,iband,ipol] *1000. &$   ; to milliJy
			endif else begin &$
				y=tpall[*,iband,ipol] *1000. &$   ; to milliJy
			endelse
			if n_elements(fitDayDeg) eq 1 then begin
				coef=robfit_poly(xsec/86400D,y,fitDayDeg,yfit=yfit,/double)
				yy=y-yfit
 			endif else begin
				yy=y-median(y)
			endelse
			plot,yy,charsize=cs,$
				xtitle='sample points',ytitle='milliJy',$
	 		title=lproj + " " + ldate + " (AST) " + string(format='(a," freq:",f5.0)',$
			lpol[ipol],freqAr[ii[iband]]) &$
			flag,findgen(nscans)*pntsScan,linestyle=3,col=colph[2] &$
			if (icnt mod 4) eq 0 then begin
				ln=7.2
				xp=-.1
			    scl=.6
				lab1=string(format='("tmResSecs:",f7.3)',(xsec[2]-xsec[1])*tosmo)
				lab2=string(format='("scanFitDeg:",i1)',(fitScan)?fitScanDeg:0)
				note,ln,lab1,xp=xp
			    note,ln+1*scl,lab2,xp=xp
			endif
  		endfor &$
	endfor
	if hard then hardcopy
	x
	ldcolph
end
