;
; 0. - list records in a scan
; 0. - list summary of scans..
; 1. - input 1 strip
;    - input 1 scan  - pmload...
; 2. baseline,plot..
; 3. fit
; 4. plot,data,fit,params
; 5. contour.
; 6. accumulate fit data.
; copen,filename,
; cscan,scannum     .. set scannumber
; cstrip,stripnum   .. set stripnum
; cstrip,stripnum   .. set stripnum
; cget              .. get next strip .. load in common pmc
; cmon              .. monitor file
; cbase             .. baseline last input data.. pmc.d[*,2] -> pmcb[*,2]
; cplt              .. plot last baslined data.
; cpltr             .. plot last raw data
; cnxt              .. input,baseline,plot next strip..
; cpos  			.. position to current scan,strip.. for contouring..
; ctccor			.. correct for time constant..
; fitturinfo
; ftpamp,ftpaze,ftpzae,ftpazw,ftpzaw,ftpphase,ftpsig,ftptmcon
; px101sb8
; history:
; 10jun00 - added smooth option to cbase...
; 31aug00 - moved x101,x101pr,etc to separate files.
;
;------------------------------------------------------------------------------
pro cbase,pol=pol,smo=smo,alinfit=alinfit,blinfit=blinfit
	common pmccom,pmcI,pmc,pmcb 

	pmcb=fltarr(pmc.pmi.samplesperstrip,2)
	if (n_elements(pol) eq 0) then pol=' '
	linfit=fltarr(2)
	if (n_elements(smo) eq 0) then smo=0
	if smo gt 1 then begin
		if (pol eq 'a') or (pol eq ' ') then begin
			pmcb[*,0]=pmbase(pmc.pmi,smooth(pmc.d[*,0],smo),linfit=linfit)
			alinfit=linfit
		endif
		if (pol eq 'b') or (pol eq ' ') then begin
			pmcb[*,1]=pmbase(pmc.pmi,smooth(pmc.d[*,1],smo),linfit=linfit)
			blinfit=linfit
		endif
	endif else begin
		if (pol eq 'a') or (pol eq ' ') then begin
			pmcb[*,0]=pmbase(pmc.pmi,pmc.d[*,0],linfit=linfit)
			alinfit=linfit
		endif
		if (pol eq 'b') or (pol eq ' ') then begin
			pmcb[*,1]=pmbase(pmc.pmi,pmc.d[*,1],linfit=linfit)
			blinfit=linfit
		endif
	endelse
	return
end
;------------------------------------------------------------------------------
pro cget,quiet=quiet
;
;	where we started
;
	common pmccom,pmcI,pmc,pmcb 
;
; 	see if we need to search for the start of the scan
;
	if not keyword_set(quiet) then quiet=0
	pmci.iostat=-3
	cpos,inpok,quiet=quiet
	if inpok eq 0 then goto,done
;
;	input the strip..
;
	istat=pmget(pmci.lun,pmc,quiet=quiet)
	if (istat ne 1) then begin
		pmci.iostat=istat
		goto,done
	endif
	pmci.scanInp =pmc.h.std.scannumber
	pmci.stripInp=pmc.pmi.stripNum
;
;	 make sure it is the strip we want..
;
	if ((pmci.scanReq ne 0) and (pmci.scanReq ne pmci.scanInp)) or $
		(pmci.stripReq ne pmci.stripInp) then begin
		pmci.iostat=-1
		goto,done
	endif

	pmci.stripReq= pmci.stripReq+1
	pmci.iostat=1
done:
	return
end
;------------------------------------------------------------------------------
pro cpos,iook,quiet=quiet
	common pmccom,pmcI,pmc,pmcb 
	iook=0
	if n_elements(quiet) eq 0 then quiet=0
	if  ((pmcI.scanInp ne pmcI.scanReq) and (pmcI.scanReq gt 0)) or $
           (pmcI.scanStB lt 0 ) then begin
        pmcI.scanStB  =-1
        pmcI.stripLenB=-1
        istat=posscan(pmci.lun,pmci.scanReq,1)
; 		print,'cstripreq',pmci.iostat
        if istat ne 1 then  begin
 			if quiet eq 0 then print,"cpos:didn't find scan:",pmcI.scanReq
             goto,done
        endif
        point_lun,-pmci.lun,itemp
        pmci.scanStB=itemp
    endif
;
;   do we now how to position directly to the strip
;
    if (pmci.stripLenB le 0) then  begin
        istat=pmget(pmcI.lun,b)
		if (istat ne 1) then begin
			pmci.iostat=istat
			goto,done
		endif
        pmci.stripLenB=b.pmi.recsPerStrip*b.h.std.reclen
    endif
;
;	 now position to rec
;
	point_lun,pmci.lun,pmcI.scanStB + (pmcI.stripReq-1)*pmcI.stripLenB
	iook=1
done:
	return
end
;------------------------------------------------------------------------------
pro cinfo
	common pmccom,pmcI,pmc,pmcb 
	print,format='("lun          :",i3)' ,pmcI.lun
	print,format='("filename     :",a)'  ,pmcI.filename
	print,format='("scanReq      :",i9)' ,pmcI.scanReq
	print,format='("scanInp      :",i9)' ,pmcI.scanInp
	print,format='("nextStrip    :",i9)' ,pmcI.stripReq
	print,format='("lastStrip    :",i9)' ,pmcI.stripInp
	print,format='("scanStBytes  :",i9)' ,pmcI.scanStB
	print,format='("stripLenBytex:",i9)' ,pmcI.stripLenB
	print,format='("last io stat :",i9," 1:ok,0:eof,-1:scan?,-2:hdr?,-3:posErr")',pmcI.iostat
	return
end
;------------------------------------------------------------------------------
pro cmon,norew=norew,online=online
;
; monitor data as it comes in..
;
	common pmccom,pmcI,pmc,pmcb
	forward_function waitnxtgrp


    on_error,1
	if keyword_set(online) and (pmci.lun eq 0) then begin
		openstat=1
		firsttime=1
	    while openstat eq 1 do begin
			copen,'/share/olda/datafile',openstat
			if openstat ne 0 then begin
				if firsttime then begin
					print,"waiting for file to be created.."
					firsttime=0
				endif
				wait,5
			endif
		endwhile
	endif
	if not keyword_set(norew) then begin
		cscan,0
		cstrip,1
	endif
;
; 	make sure file is not empty
;
	fsize=0
	f=fstat(pmcI.lun)
	msgcnt=0
	while  f.size eq 0 do begin
		if (msgcnt mod 12 eq 0) then begin
			print,"waiting for ",f.name," to be not empty"
		endif
		wait,5
		msgcnt=msgcnt+1
		f=fstat(pmcI.lun)
	endwhile
;
    for i=0L,99999  do begin
	    cnxt,/cont,/quiet
		 case pmcI.iostat of
            1: ok=1
;
;           new scan or strip req smaller than we want
;
            0: wait,2
		   -3: wait,2
         else: begin
			   print,'iostat:',pmci.iostat 
			   return
			   end
        endcase
	endfor
end
;------------------------------------------------------------------------------
pro cnxta
	common pmccom,pmcI,pmc,pmcb 
	cget
	if pmci.iostat ne 1 then return
	cbase
	cplta 
	return
end
;------------------------------------------------------------------------------
pro cnxt,cont=cont,quiet=quiet,noplot=noplot,alinfit=alinfit,blinfit=blinfit
;
; if cont set then automatically move to next scan
;
	common pmccom,pmcI,pmc,pmcb 


	if not keyword_set(quiet) then quiet=0
	if not keyword_set(noplot) then noplot=0
    cget,quiet=quiet
	if (pmci.iostat ne 1) then begin
	   	if not keyword_set(cont) or (pmci.iostat ne -1) then return
;
;		see if we had a partial record on last scan
;
		if (pmci.scanreq  eq pmci.scaninp) then begin
			cpos,inpok,quiet=quiet
			if inpok ne 1 then returnn
			hdr=1
			istat=posscan(pmci.lun,0,skip=1,retstdhdr=hdr)
			if (istat ne 1) or (hdr.scannumber eq pmci.scanreq) then return
			cscan,hdr.scannumber
		endif else begin
			cscan,pmci.scaninp
		endelse
		cstrip,1
    	cget,quiet=quiet
		if (pmci.iostat ne 1) then return
	endif
	if string(pmc.h.proc.procname) eq 'pntmod' then begin
		cbase,alinfit=alinfit,blinfit=blinfit
	    if noplot then return
		cplt,alinfit=alinfit,blinfit=blinfit
	endif else begin
	    if noplot then return
		cpltr
	endelse
	return
end
;------------------------------------------------------------------------------
pro copenobs
	copen,'/share/olda/datafile'
	return
end
;------------------------------------------------------------------------------
pro copen,filename,openstat
	common pmccom,pmcI,pmc,pmcb 

	on_error,1
	nparms=n_params() 
	if pmcI.lun gt 0 then begin
		free_lun,pmcI.lun
		pmcI.lun=-1
	endif
	openr,lun,filename,error=openstat,/get_lun
	if openstat ne 0 then begin
		if nparms eq 2 then return
		message,!err_string
	endif
	pmci.filename=filename
	pmcI.lun=lun
	pmcI.scanInp =-1
	pmcI.stripInp=-1
	return
end
;------------------------------------------------------------------------------
pro cplta
	cplt0,0,1
	return
end
;------------------------------------------------------------------------------
pro cpltb
	cplt0,0,2
	return
end
;------------------------------------------------------------------------------
pro cplt,alinfit=alinfit,blinfit=blinfit
	cplt0,0,0,alinfit=alinfit,blinfit=blinfit
	return
end
;------------------------------------------------------------------------------
pro cpltra
	cplt0,1,1
	return
end
;------------------------------------------------------------------------------
pro cpltrb
	cplt0,1,2
	return
end
;------------------------------------------------------------------------------
pro cpltr
	cplt0,1,0
	return
end
;------------------------------------------------------------------------------
pro  cplt0,raw,pol,alinfit=alinfit,blinfit=blinfit
	common pmccom,pmcI,pmc,pmcb 
    common colph,decomposedph,colph

    lab=string(format=$
		'("scan:",i9," strip:",i3," src:",A," az:",f7.3," za:",f7.3)',$
		pmc.h.std.scannumber,pmc.pmi.stripNum,string(pmc.h.proc.srcname),$
		pmc.pmi.az,pmc.pmi.za)
	if raw ne 0 then begin
		case 1 of 
		pol eq 0 : begin
				plot,pmc.d[*,0],xtitle='sample',title=lab,xstyle=1,ystyle=1
	 			oplot,pmc.d[*,1],color=colph[2]
				end
		pol eq 1 : begin
				plot,pmc.d[*,0],xtitle='sample',title=lab,xstyle=1,ystyle=1
				end
		pol eq 2 : begin
				plot,pmc.d[*,1],xtitle='sample',title=lab,xstyle=1,ystyle=1
				end
	   endcase
	endif else begin
		case 1  of 
		pol eq 0 : begin
				plot,pmcb[*,0],xtitle='sample',title=lab,xstyle=1,ystyle=1
	 			oplot,pmcb[*,1],color=colph[2]
				end
		pol eq 1 : begin
				plot,pmcb[*,0],xtitle='sample',title=lab,xstyle=1,ystyle=1
				end
		pol eq 2 : begin
				plot,pmcb[*,1],xtitle='sample',title=lab,xstyle=1,ystyle=1
				end
	   endcase
	   xp=.05
	   ln=3
	   if n_elements(alinfit) eq 2 then begin
		lab=string(format='("BaselineFitA:",f7.1)',alinfit[0])
		note,ln,lab,xp=xp
	   endif
	   if n_elements(blinfit) eq 2 then begin
		lab=string(format='("BaselineFitB:",f7.1)',blinfit[0])
		note,ln+1,lab,xp=xp
	   endif
	endelse
	return
end
;------------------------------------------------------------------------------
pro cscan,scan
;
	common pmccom,pmci,pmc,pmcb 
	if scan ne 0 then begin
;
;		new scan
;
		if scan ne pmci.scanReq then begin
			pmci.scanReq  =scan
			pmci.scanstB  =-1		; no longer now the byte start location
			pmci.stripLenB=-1
		endif
    endif else begin
		pmci.scanReq=0
		if pmci.scanInp lt 0 then begin
			pmci.scanStB  =-1
			pmci.stripLenB=-1
		endif
	endelse
	return
end
;------------------------------------------------------------------------------
pro cstrip,strip
	common pmccom,pmcI,pmc,pmcb 
	pmcI.stripReq=strip
	return
end
;------------------------------------------------------------------------------
pro ctccor,tc,pol=pol
	common pmccom,pmcI,pmc,pmcb 
;
; model out to 10 time constants
;
	if n_elements(pol) eq 0 then pol=' '
	npts=pmc.pmi.samplesPerstrip 		; of data we have 
	secPerSample=pmc.pmi.secsPerStrip/float(npts)
	x0=tc/secPerSample			; samples per 1 tc
	tcpts=x0*10		        	; compute out to 10 time constants
	a=exp(-1./x0*findgen(tcpts))
	a=a/total(a)
	cexp=fltarr(npts)
	cexp[0:tcpts-1]=a
;
; let cexp be exponential convolved into data d
; x is convolution, * is multiply
;
; then  d'= d x cexp   is what we measured
;
; let Capials be fft of function
; fft(d x (cexp)) = D * Cexp
; so compute
;   fft(D*Cexp * CexpInv) = fft(D * 1) = d * N
;
	FcexpInv=1./fft(cexp)
	i=1
	if pol eq ' ' then i=2
	d=fltarr(npts,i)
	if pol ne 'b' then begin
		pmc.d[*,0]=fft( fft(temporary(pmc.d[*,0]))*FcexpInv/float(npts),1.)
		tmp=fft( fft(temporary(pmc.d[*,0]))*FcexpInv/float(npts),1.)
	endif
	if pol ne 'a' then begin
		pmc.d[*,1]=fft( fft(temporary(pmc.d[*,1]))*FcexpInv/float(npts),1.)
	endif
	return
end
;------------------------------------------------------------------------------
; fitur routines..
;
pro fitturinfo 
	common fitturcom,ftcI,ftcTurW

	print,         " input parameters"
	print,format='("amplitude   :",f8.2, "        :ftpamp")',ftcI.pinp.amp
	print,format='("za Error    :",f8.2, "(asecs) :ftpzae")',ftcI.pinp.zaErrA
	print,format='("za Width    :",f8.2, "(asecs) :ftpzaw")',ftcI.pinp.zaWdA
	print,format='("az Error    :",f8.2, "(asecs) :ftpazE")',ftcI.pinp.azErrA
	print,format='("az Width    :",f8.2, "(asecs) :ftpazW")',ftcI.pinp.azWdA
	print,format='("turPhase    :",f8.2, "(turDeg):ftpphase")',ftcI.pinp.PhaseD
	print,format='("sigma       :",f8.2, "        :ftpsig")',ftcI.sigma
	print,format='("tmCon       :",f8.2, "(secs ) :ftptmcon")',ftcI.tmCon
	return
end
;------------------------------------------------------------------------------
pro ftpamp, amp
    common fitturcom,ftcI,ftcTurW
	ftcI.pinp.amp=amp
	return
end
;------------------------------------------------------------------------------
pro ftpzae, zae
    common fitturcom,ftcI,ftcTurW
	ftcI.pinp.zaErrA=zae
	return
end
;------------------------------------------------------------------------------
pro ftpzaw, zaw
    common fitturcom,ftcI,ftcTurW
	ftcI.pinp.zaWdA=zaw
	return
end
;------------------------------------------------------------------------------
pro ftpaze, aze
    common fitturcom,ftcI,ftcTurW
	ftcI.pinp.azErrA=aze
	return
end
;------------------------------------------------------------------------------
pro ftpazw, azw
    common fitturcom,ftcI,ftcTurW
	ftcI.pinp.azWdA=azw
	return
end
;------------------------------------------------------------------------------
pro ftpphase, phase
    common fitturcom,ftcI,ftcTurW
	ftcI.pinp.phaseD=phase
	return
end
;------------------------------------------------------------------------------
pro ftpsig, sig
    common fitturcom,ftcI,ftcTurW
	ftcI.sigma=sig
	return
end
;------------------------------------------------------------------------------
pro ftptmcon,tmc
    common fitturcom,ftcI,ftcTurW
	ftcI.tmCon=tmc
	return
end
;------------------------------------------------------------------------------
pro pntx101sb8
	common pmccom,pmcI,pmc,pmcb
    common fitturcom,ftcI,ftcTurW

	ftcI.turScl=-45.
	ftcI.tmCon =.02
	ftcI.sigma =10.
	ftcI.pinp.amp=200.
	ftcI.pinp.zaErrA=0.
	ftcI.pinp.zaWdA=130.
	ftcI.pinp.azErrA=0.
	ftcI.pinp.azWdA=130.
	ftcI.pinp.phaseD=-10.
	return	
end
;------------------------------------------------------------------------------
pro pntx101sbh
	common pmccom,pmcI,pmc,pmcb
    common fitturcom,ftcI,ftcTurW
;
; 3 deg amp move.
;
	ftcI.turScl=-45.
	ftcI.tmCon =.02
	ftcI.sigma =10.
	ftcI.pinp.amp=85.
	ftcI.pinp.zaErrA=0.
	ftcI.pinp.zaWdA=85.
	ftcI.pinp.azErrA=0.
	ftcI.pinp.azWdA=100.
	ftcI.pinp.phaseD=-13.
	return	
end
;------------------------------------------------------------------------------
pro pntx101cb 
	common pmccom,pmcI,pmc,pmcb
    common fitturcom,ftcI,ftcTurW

	ftcI.turScl=-45.
	ftcI.tmCon =.02
	ftcI.sigma =10.
	ftcI.pinp.amp=200.
	ftcI.pinp.zaErrA=0.
	ftcI.pinp.zaWdA=60.
	ftcI.pinp.azErrA=0.
	ftcI.pinp.azWdA=80.
	ftcI.pinp.phaseD=-10.
	return	
end
;------------------------------------------------------------------------------
pro pntx101xb
    common pmccom,pmcI,pmc,pmcb
    common fitturcom,ftcI,ftcTurW

    ftcI.turScl=-45.
    ftcI.tmCon =.02
    ftcI.sigma =10.
    ftcI.pinp.amp=200.
    ftcI.pinp.zaErrA=0.
    ftcI.pinp.zaWdA=38.
    ftcI.pinp.azErrA=0.
    ftcI.pinp.azWdA=40.
    ftcI.pinp.phaseD=-10.
    return
end
;------------------------------------------------------------------------------
pro pntx101lb
    common pmccom,pmcI,pmc,pmcb
    common fitturcom,ftcI,ftcTurW

    ftcI.turScl=-45.
    ftcI.tmCon =.02
    ftcI.sigma =10.
    ftcI.pinp.amp=200.
    ftcI.pinp.zaErrA=0.
    ftcI.pinp.zaWdA=200.
    ftcI.pinp.azErrA=0.
    ftcI.pinp.azWdA=200.
    ftcI.pinp.phaseD=-10.
    return
end

