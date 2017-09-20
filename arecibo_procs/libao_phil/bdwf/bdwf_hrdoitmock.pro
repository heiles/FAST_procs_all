;+
;NAME:
;bdwf_hrdoitmock - input mock files,create savefile
;SYNTAX:istat=bdwf_hrdoitmock(hrI,scanIar,savBase,iscanRange=iscanRange,$
;             wait=wait)
;ARGS:
;hrI : {}   struct loaded by bdwf_hrinit()
;scanIar[]:{} returned by getscaninfo(). contain info on data scans
;             for the flare. normally it will have 1 entry.
;             If the flare spans multiple scans,then all the scans 
;             should be included here.
;             we want to process
;savBase  : string base name for save file. It will be 
;             used by this routine to generate hrI.savFileNm
;             contains: "srcToGet_yyyymmdd_scanInStrip"
;             this routine then adds _0,_1 if more than one
;             scan.(i think it is always 1 scan).
;KEYWORDS:
;iscanRange[2]:long If scanIar[] has more than one entry, then 
;                   this you can use this to limit the entries
;                  of scanIar[] to use . holds, first,last index
;                  to use (count form 0). Or you could just
;                  limit scanIar[] to the files you want.
;wait         : int  if not zero then wait after displaying image
;
;RETURNS:
;hrI.savFileNm: string is loaded with the name of the save file.
;               the following data is saved in hrI.savFileNm:
; 		  save,tpAr,freqAr,rmsMask,jdAr,azAr,zaAr,scanI,sclGain,boutSave
;DESCRIPTION:
;	Read in the mock fits files for the filenum of interest (all 7 bands).
;If hrI.avgrow =1 then average all the spectra in each row (usually)
;ends up giving .9 sec resolution). If hrI.avgrow=0 then keep the 
;.1 sec time resolution.
;	calibrate all of the spectra using masstokes (bpc,cal,gain)
;	Use masrms to compute an rms by channel. This will later be
;used to exclude frequency channels when averaging over freq.
;	Then display an image of stokes V
;   Also display the rms by channel that was computed
;	Compute the total power for each 170 Mhz band (using
;the rms computed above to exclude rfi.)
;  save the computed info in the save file
;
;-
function  bdwf_hrdoitmock,hrI,scanIAr,savBase,iscanRange=iscanRange,$
		   wait=wait,pntseachscan=pntseachscan
    common colph,decomposedph,colph


	tpedgeFract=.05			; ignore 5% each edge when computing total power
	rmsfitdeg=1			    ; when computing mask fit linear across rms
	rmsrembase=1			; 1--> fit along channel before rms when computing mask
                            ; for total power
	mjdToJd=2400000.5D
	winimg=1
	nscans=n_elements(scanIAr)
	iscan1=0
	iscan2=nscans - 1
	if n_elements(wait) eq 0 then wait=0
	if n_elements(iscanrange) eq 2 then begin
		iscan1=iscanrange[0]
		iscan2=iscanrange[1]
	    if ((iscan1 lt 0) or (iscan1 ge nscans) or $
	        (iscan2 lt 0) or (iscan2 ge nscans)) then begin
			print,"Illegal scan range. should be :",0,nscans-1
			return,-1
		endif
		if iscan1 gt iscan2 then  begin
			itmp=iscan1
			iscan1=iscan2
			iscan2=itmp
		endif
	endif
	nscans=iscan2-iscan1 + 1
	hrI.nsavFiles=nscans
	nbeams=n_elements(scaniar[0].fnmicalon)
;
;	 for cal
;
	npol=4
;   for rms fit
	symbad=2
; 
;
	bpc=1
	cmpmask=1
	phase=1
	start=1
	pntsEachScan=lindgen(nscans)
	iiscan=0L
	
	for iscan=iscan1,iscan2 do begin
;		if spcToAvg gt 1 then totSpc/=spcToAvg
		spcToAvg=(hrI.avgRow)?scanIar[iscan].ndumpD:1
		totRows=scanIar[iscan].nrowsD
		totSpc =scanIar[iscan].ndumpD*totRows/spctoavg
;		zaAr=fltarr(totRows)
;		azAr=fltarr(totRows)
;		jdAr=dblarr(totspc)
		freqAr=fltarr(nbeams)
;
;	
;
		tpAr=fltarr(totspc,npol,nbeams)
        print,"Looping over beams"
	    for ibm=0,nbeams-1 do begin
			; average the cals
			istat=masgetfile(desc,bcalon,/avg,fnmi=scanIar[iscan].fnmicalon[ibm])
			istat=masgetfile(descCal,bcaloff,/avg,fnmi=scanIar[iscan].fnmicaloff[ibm],/descret)
			bcalIn=[bcalon,bcaloff]
			if ibm eq 0 then begin
				nchan=bcalon[0].nchan
				iiedge1tp=indgen(nchan*tpEdgeFract)
				iiedge2tp=nchan - 1 - iiedge1tp
				x=findgen(nchan)
			    rmsMask=intarr(nchan,nbeams)
			endif
;
;			input the datafile, smooth to requested spectra
;
			cmpmaskL=cmpmask
			dind=0L
			startDat=1
			irowTot=0L
			for idat=0,scanIar[iscan].nfilesd -1 do begin
				fname=scanIAr[iscan].fnmiDat[ibm,idat].fname
				ltime=systime(0)
				print,"Start ",fname + ' : ' + ltime
				ltit0=fname
				istat=masopen(file,descDat,fnmi=scanIar[iscan].fnmiDat[ibm,idat])
				rowPos=1
				rowsToProcessFile=descDat.totrows

; 			if no averaging.. then slip last row if number of dumps is different
				for irow=0,rowsToProcessFile-1 do begin &$
					istat=masgetm(descDat,1,b,avg=hrI.avgRow,row=rowPos) &$
					rowPos=0 &$
					if startDat then begin &$
						 bar=replicate(b,totRows) &$
						 startDat=0 &$
					endif &$
					if (b.ndump ne bar[0].ndump) then begin
						print,"row:",irow+1," only has:",b.ndump," spectra..skip"
						continue
					endif
					bar[irowTot]=b &$
					irowTot++ &$
				endfor
				masclose,/all
			endfor
			if irowTot lt totRows then begin
			    totRows=irowTot
				bar=bar[0:totRows-1]
			endif
;			
			istat=masstokes(bar,bcalIn,descDat,descCal,bdatOut,bcalOut,/phase,bpc=bpc,$
						mask=mask,cmpmask=cmpmask)
			bar=''
			nrows=n_elements(bdatOut)
			ndmps=bdatOut[0].ndump
			nspc=nrows*ndmps
			wuse,0,xsize=500,ysize=600
			hor&ver
			bcaldif=masmath(bcalOut[0],bcalout[1],/sub)
			masplot,bcaldif,title=ltit0 + ' Caldif'
		    freqAr[ibm]=bdatOut[0].h.crval1*1e-6
;
;	gain correct for az,za. Data was in Kelvins, divide by K/Jy gives Jy.
;
;			if we didn't average row, need to interpolate the 9 samples/row
;           the averaged Jd  is at the start of each row. We interpolate
;           to the center of each 1/9 of a row
;
			istat=masgainget(bdatOut.h,KperJ) &$
   	 		sclGainL=1./kperJ &$
			for i=0,nrows-1 do bdatout[i].d*=sclGainL[i]
			if (hrI.avgrow eq 0) then begin
				x=dindgen(nrows)
				xi=(dindgen(ndmps,nrows)+.5)/ndmps 
				jdar=interpol(bdatOut.h.mjdxxobs,x,xi) + mjdToJd 
				jdAr=reform(jdar,nrows*ndmps)
				azAr=interpol(bdatOut.h.azimuth,x,xi) 
				azAr=reform(azar,nrows*ndmps)
				zaAr=90. - interpol(bdatOut.h.elevatio,x,xi) 
				zaAr=reform(zaar,nrows*ndmps)
				sclGain=reform(interpol(sclGainL,x,xi),nrows*ndmps)
			endif else begin
				jdAr=bdatOut.h.mjdxxobs + mjdToJd
				azAr=bdatOut.h.azimuth
				zaAr=90. - bdatOut.h.elevatio
				sclGain=sclGainL
			endelse
;
;			display image of  stokes V 
;
			pol=4
			nobpc=0
			nsigclip=10
			!p.multi=0
			ltit=ltit0 + " stokes i"
			zx=-(nchan/1024)
			zy=-fix(nspc/800. + .9)
			if zx ge -1 then zx=1
			if zy ge -1 then zy=1
			samewin=start ne 1
			wuse,1
			img=masimgdisp(bdatOut,pol=pol,nobpc=nobpc,nsigclip=nsigclip,zx=zx,zy=zy,samewin=samewin,win=winimg)
			start=0
			ln=1.5
			xp=.6
			cs=1.6
			note,ln,scanIAr[iscan].fnmiDat[ibm,0].fname,xp=xp,charsize=cs
;
;   compute rms by along each frequency channel for stokes I. Find the channels with no rfi.
;   These are the ones we'll use when computing the total power. Value returned in 
;   in mask. use the same mask for all samples
;
	 		brms=masrms(bdatOut,rembase=rmsrembase)
			coef=robfit_poly(x,brms.d[*,0],rmsfitdeg,nsig=nsig,gindx=gindx,ngood=ngood,$
					yfit=yfit)
 			rmsMask[gindx,ibm]=1
;				don't use the edges for total power
			rmsMask[iiedge1tp,ibm]=0
			rmsMask[iiedge2tp,ibm]=0
			gindx=where(rmsMask[*,ibm] ne 0,ngood)
			bindx=where(rmsMask[*,ibm] eq 0,nbad)
			wuse,2
			ver,0,median(brms.d[*,0])*3
			freq=masfreq(brms.h)
			plot,freq,brms.d[*,0],title="rms/mean for:"+fname
			oplot,freq,yfit,col=colph[5]
			if nbad gt 1 then oplot,freq[bindx],brms.d[bindx,0],psym=symbad,col=colph[2]
			ver
				

; 	compute the total power
			tpAr[0:nspc-1,*,ibm]=transpose($
					reform(total(bdatOut.d[gindx,*,*],1)/ngood,npol,nspc))
			if wait then begin
				print,scanIar[iscan].fnmiDat[0].fname,' enter to continue. s to stop'
				key=checkkey(/wait)
				if key eq 's' then stop
				print,'continuing'
			endif
			xx=findgen(n_elements(tpar[*,0,0]))
			wuse,3
			ver,-.200,.200
			stripsxy,xx,reform(tpar[*,3,*],totspc,nbeams),0,0,/step,xtitle='bm=' + string(ibm),$
			title='stokes V vs time iscan. bands by color:'+string(iscan)
			ver
;
; 			save all the beams , complete freq resolution
;
			if ibm eq 0 then begin
				BoutSave=replicate(bdatOut[0],n_elements(bdatout),nbeams)
			endif
		    BoutSave[*,ibm]=bdatOut
		endfor  ; for loop ibm
;
;   save to idl save file
;
		if nspc ne totspc then tpar=tpar[0:nspc-1,*,*]
		scanI=scanIar[iscan]
		hrI.savFileNms[iiscan]=savbase + string(format='("_",i2.2,".hr.sav")',iscan)
		hrI.pntsEachScan[iiscan]=nspc
		save,tpAr,freqAr,rmsMask,jdAr,azAr,zaAr,scanI,sclGain,boutSave,$
			iiscan,hrI,file=hrI.savFileNms[iiscan]
		if (iiscan eq 0) then begin
			hrI.hdrI.object=boutsave[0].h.object
			tmp=boutsave[0].h.datexxobs
   			yyyy=long(strmid(tmp,0,4))
			mm  =long(strmid(tmp,5,2))
		 	dd  =long(strmid(tmp,8,2))
			hrI.hdrI.yyyymmddUtc=yyyy*10000L + mm*100L + dd
			hrI.hdrI.secMidUtc=boutsave[0].h.crval5
			tmRow=boutsave[1].h.crval5 - boutsave[0].h.crval5
	    	hrI.hdrI.tmStp =(hrI.avgRow)?tmRow:boutsave[0].h.cdelt5
		    hrI.hdrI.nrows = n_elements(boutsave[*,0])
			hrI.hdrI.ndumps= boutsave[0].ndump
		endif else begin
			; in case multiple scans
			hrI.hdrI.nrows+= n_elements(boutsave)
		endelse
		iiscan++
	endfor	 ; for loop iscan
	return,0
end
