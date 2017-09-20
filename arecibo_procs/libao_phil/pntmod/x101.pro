;+
; x101 - input and fit 2-d gaussian to turret scans
;
; SYNTAX: x101,numstrips,fit,fity,first=first,pol=pol,tccor=tccor,show=show,$
;			   retyfitall=retyfitall,dif=dif
; ARGS:
;		numstrips	  :int  .. number of strips to process
;		fit[numstrips]:{x101fitval} return fit info here.
;		fity[]        :fltarr return yvalue of last fit
; KEYWORDS:
;  	    first	: int first strip to use. count from 1. default 1	
;  	    pol   	: string .. 'a' or 'b' pol to reduce. default:'a'
;  	    tccor 	: int    .. if not zero, correct for time constant smearing
;  	    show  	:        .. if set then plot data and fit for each strip
;  	 retyfitall :        .. if set then return all y fits not just last
;       dif     :        .. if set then data-fit rather than fit
; COMMON BLOCKS
;	     pmccom   : holds input data. loaded by cget,cbase
;	     fitturcom: hold parameters for fit. Set by ftpxxx routines.
; DESCTRIPTION:
;	Input and compute 2-d gauss fits for the requested number of turret
; strips (numstrips) in the current scan (set by cscan,queried by cinfo). 
; The routine uses the common blocks:
;  pmccom    - the data is input here via cget, and the baseline is computed.
;  fitturcom - the initial parameters for the fit are taken from here
;              and the fit values are deposited here.
;
; Before using this routine you should:
; @pminit
; 1. setup the input file with copen
; 2. specify where to start in the file with cscan (see cinfo)
;    the first keyword allows you to start in the middle of a scan.
; 3. set the fit initial parameters (see fitturinfo)
; 4. determine how many strips to fit.
;
; fitturinfo will display the current initial parameters:
;
;amplitude   : 1100.00        :ftpamp  .. in a/d counts
;za Error    :    0.00(asecs) :ftpzae  
;za Width    :  130.00(asecs) :ftpzaw  
;az Error    :    0.00(asecs) :ftpazE  .. great circle
;az Width    :  130.00(asecs) :ftpazW  .. great circle
;turPhase    :  -10.00(turDeg):ftpphase
;sigma       :   15.00        :ftpsig  .. a/d counts
;tmCon       :    0.234(secs ) :ftptmcon .. delay time constant.
;
; The procedures on the right will let you change the initial values.
; 
; The data is input, baselined and fit. The results of the fit are 
; stored in the array fit[{x101fitval}]. {x101fitval} is defined in 
; ~phil/idl/h/pntmod.h. it contains:
;
;Structure FITOUT, 14 tags, length=64:
;   SRC             STRING    srcname
;   srcind          int       index into source array...
;   FREQ            DOUBLE    frequency of observation
;   AZ              FLOAT     azimuth position center of strip
;   ZA              FLOAT     zenith angle center of strip
;   G               FLOAT     gain.. srcStrength/Tsys * 100
;   B               FLOAT     baseline value at peak in a/d counts
;   ZAE             FLOAT     zenith angle error in arc seconds.
;   ZAW             FLOAT     zenith angle width asecs (fwhm)
;   AZE             FLOAT     azimuth error in arc seconds (great circle)
;   AZW             FLOAT     azimuth width in arc seconds (fwhm gc)
;   PH              FLOAT     phase of sign wave (turret degrees)
;   CHI             FLOAT     reduced chisq of fit
;   PNTE            FLOAT     pnterro at start (not loaded yet)
;   OK              FLOAT     fit ok (not used)
;
; The default is to fit polA. Keyword pol='b' will cause pol B to be fit.
;
; There are two time constants used by this routine. The first is 
; tmCon set by ftptmcon. It is used to correct the pointing error
; do to the delays in the system (turret floor, telescope, detector time
; constant). This value is meausured experimentally by fitting a model to
; all the up and downhill za strips and seeing which time constant gives the
; smallest residual errors. 
;
; The second time constant is that of the detector. It delays and 
; smears the pulse. Setting tccor=valueInSeconds will try to deconvolve
; the smearing do to this time constant. After deconvolving, the cuts 
; throught the beam move. The amount they move is a function of their
; width. for a turret swing having 10 counts (fwhm) and a .2 sec 
; time constant, the motion is .69 times valueInSeconds. This is used
; in this routine. For other values, you can adjust tmcon to be the 
; optimal value.
;
; To plot the results use: x101pr,fit
;
; SEE ALSO:
; fitturinfo,cinfo,x101pr
;-
pro x101,numstrips,fit,yfit,first=first,pol=pol,tccor=tccor,cont=cont,$
			show=show,retyfitall=retyfitall,dif=dif

	common pmccom,pmcI,pmc,pmcb
    common fitturcom,ftcI,ftcTurW
    common colph,decomposedph,colph

	if not keyword_set(first) then first=1
	if not keyword_set(cont) then cont=0
	if not keyword_set(show) then show=0
	if n_elements(pol)   eq 0 then pol='a'
	rety=0
	if n_params() ge 3 then rety=1
	retyall=0
	if keyword_set(retyfitall) then retyall=1
	ncomp=0

	corTmcon=1
	if n_elements(tccor) eq 0 then begin
		corTmCon=0
		tccor=0.
	endif
	if (pol eq 'A') then pol='a'
	if (pol ne 'a') then pol='b'
	if corTmCon eq 0 then begin		;If we correct tmCon, then fit uses 0..
		tmcon=ftci.tmCon
	endif else begin
		tmcon=ftci.tmCon-tccor*0.69; we corrected for this much delay
	endelse
;
;	hold the fit output
;
	fit=replicate({x101fitval},numstrips)
	cstrip,first
	linfit=fltarr(2)
	for i=0,numstrips-1 do begin
		cnxt,cont=cont,/noplot
		if  pmci.iostat ne 1 then  begin
			print,"error inputing strip",first+i
			goto,done
		endif
		if i eq 0 then begin
		 fit[*].src =string(pmc.h.proc.srcName)
		 fit[*].freq=pmc.h.iflo.if1.rfFrq*1e-6
		endif
;
; 	optionally correct for time constant smearing
;
		if (corTmCon ne 0 ) then begin
			ctccor,tccor,pol=pol
		endif
		cbase,pol=pol,alinfit=alinfit,blinfit=blinfit
		if pol eq 'a' then linfit=alinfit
		if pol eq 'b' then linfit=blinfit
		if i eq 0 then begin
			ftcI.turAmpDeg  =pmc.pmi.turAmpD
			ftcI.turFrq     =pmc.pmi.turFrqH
			ftcI.turScl     =-45.
			ftcI.sampleRate =pmc.pmi.samplesPerStrip/ $
				float(pmc.pmi.secsPerStrip)
		endif
;
;load parameters for this strip
;
		ftcI.zaOffDeg=pmc.pmi.zaOffStartD
		ftcI.zaVel   =-(ftcI.zaOffDeg*2.)/pmc.pmi.secsPerStrip
		if (pol eq 'a') then begin 
			fittur,pmcb[*,0],yfitl,tmcon=tmcon
		endif else begin
			fittur,pmcb[*,1],yfitl,tmcon=tmcon
		endelse
;
;	 copy params to our storage array
;
		fit[i].az  = pmc.pmi.az  
		fit[i].za  = pmc.pmi.za
;
;		compute the tsys at baseline under the peak.... use the linear fit
;       tmpk= secsperStrip/2 + tmConst + zaErrAsec*zaWidthAsec/time
;       posPk= tmPk*sampleRate
;       if we have 10 samples, the central time will be at sample size
;       since the samples start at the 1sec tick (start of each interval
;       and there
;     tick                           tick
;       |  |  |  |  |  |  |  |  |  |  |
;       1  2  3  4  5  6  7  8  9 10
;        _  _   _  _  _  _  _  _ _  _
;       since we index from   0 the center is numsamples/2..
;
		tm         = pmc.pmi.secsPerStrip/2.+tmcon + $
					 ftcI.p.zaErrA* pmc.pmi.secsPerStrip/ $
					       (-pmc.pmi.zaOffStartD*2.*3600.)
		ind= (tm/pmc.pmi.secsPerStrip) * pmc.pmi.samplesPerStrip
;;		print,"tm:",tm," ind:",ind," linfit:",linfit
		fit[i].b   = linfit[0] + linfit[1]*ind 
		fit[i].g   = (ftcI.p.amp/fit[i].b)* 100.
		fit[i].zaE = ftcI.p.zaErrA
		fit[i].zaW = ftcI.p.zaWdA 
		fit[i].azE = ftcI.p.azErrA
		fit[i].azW = ftcI.p.azWdA
		fit[i].ph  = ftcI.p.phaseD
		fit[i].chi = ftcI.chisq
		fit[i].pntE= 0
		fit[i].ok  = 1
		fit[i].srcind=0		
		ncomp=ncomp+1
		if show then begin
			lin=string(format='(a," scan:",i9," strip:",i3," turPos:",f6.2)',$
				string(pmc.h.proc.srcname),$
				pmci.scaninp,pmci.stripinp,pmc.pmi.turposD)
			if (pol eq 'a') then begin 
				plot,pmcb[*,0],title=lin
			endif else begin
				plot,pmcb[*,1],title=lin
			endelse
			oplot,yfitl,color=colph[2]
		endif
		if rety then begin
			if keyword_set(dif) then begin
				if (pol eq 'a') then begin 
					yfitl=pmcb[*,0]- yfitl
				endif else begin
					yfitl=pmcb[*,1]- yfitl
				endelse
			endif
				
			if retyall then begin
				if i eq 0 then yfit=fltarr(n_elements(yfitl),numstrips)
				yfit[*,i]=yfitl
			endif else begin
				yfit=yfitl
			endelse
		endif

	endfor
done:
	if ncomp ne numstrips then fit=fit[0:ncomp-1]; ;if we had a read error 
	return
end
