 pro  cross3_newcal,lun,sl,slPatInd, scndata,  $
	curFitInd,beamin_arr,hb_arr,mmInfo_arr,stkOffsets_chnl_arr,numBrdsProcessed,$
	returnstatus, tcalxx, tcalyy,$
	tcalxx_430ch=tcalxx_430ch, tcalyy_430ch=tcalyy_430ch,$
	board=board,nocal=nocal, cumcorr= cumcorr, totalquiet= totalquiet,$ 
	phaseplot= phaseplot ,byChnl=byChnl,$
	mm_pro_user= mm_pro_user, $
	m_rcvrcorr= m_rcvrcorr, m_skycorr= m_skycorr, m_astro= m_astro
;+
;SL is a scanlist of the entire file. slPatInd is an index into
;sl[slpatInd] that is the scan for the start of the pattern we want to
;process.
;
;Processs a single pattern. Input, phase and ;intensity calibrate. 
;PROCESSES ALL 242 SCANS IN THE PATTERN, CALIBRATING THE LATTER 240 IN
;TERMS OF THE FIRST TWO (WHICH ARE CALON AND CALOFF). THE CAL IS USED FOR
;TWO PURPOSES:

;	1. AMPLITUDE CALIBRATION. This assumes that the gain of each
;spectral channel is proportional to the power in the cal-off spectrum.
;It then determines the temperature scale from the cal deflection and the
;values of tcalxx, tcalyy, which are the cal values as found either from
;phil's file or inputted by the user.

;	If the cal value in the arrays tcalxx_board and tcalyy_board is
;negative, it uses the value from Phil's files. It it is positive, it
;uses that value. 

;	Special case: if the rcvr is 430ch, then it uses tcalxx_430ch
;and tcalyy_430ch.

;	2. PHASE CALIBRATION. If the system has a correlated cal
;(nocal=0 as determined from the routine getrcvr.pro), then it assumes
;the cal phase is zero and corrects all 240 phases to the cal phase. this
;phase calibration includes a linear variation with frequency, using
;carl's patented routine! 

;	If the system does not have a correlated cal, then it fits the
;slope of the phase with frequency and corrects all 240 observations for
;that, but does not fit the zero of phase--it calculates the zero point
;phases of the 240 points from their xy and xy data without subtracting
;any other phase (as opposed to the correlated cal case, for which it
;subtracts the zero point of the cal phase).

;INPUTS:

;	There are several inputs passed through the structure SCNDATA.  
;These are of the nature of which points in the scan to use for on source 
;and for off source values, and which points have the cal on and off. 
;Here are some of the more important:

;Variables contained in the structure SCNDATA:
;	INDXCALON, INDXCALOFF: the index numbers within the pattern for
;calon and caloff, equal to [0,0] and [1,1]. These are arrays because in
;principle there could be more than one index used for calibration; if
;there is only one, avoiding errors requires making them arrays with two
;identical elements.

;	ONSCANS, OFFSCANS: Arrays of index numbers within the pattern
;used for calculating source deflections, onsource - offsource.

;	DPDF, the initial guess for the phase slope in radians per MHz.
;The slope arises primarily in the i.f. and its sign depends on whether
;the final sideband is upper or lower; the program determines this from
;whether the spectrum is flipped. In the unlikely event that the slope
;becomes determined from other causes, this may need to be
;changed--however, the fitting routine is pretty robust and even a guess
;with the wrong sign isn't very serious in most (all?) cases.

;	TCALXX_BOARD, TCALYY_BOARD: See the above discussion of
;AMPLITUDE CALIBRATION.

;	TCALXX_430CH, TCALYY_430CH: See the above discussion of
;AMPLITUDE CALIBRATION.

;	CHNLS, PHASECHNLS, GAINCHNLS: the array of channels over which
;sums are taken to determine continuum power. Normally equals
;indgen(128). I always set these arrays equal to each other; some
;calculations use different ones, which allows different channels to be
;used for phase and intensity sums, but i'm not sure if this is
;consistently defined. If you want to make these arrays different, you
;need to check to see how the program differentiates between them, and
;whether it does so consistently. 

	
;OUTPUTS:

;	beamin_arr[curFitInd:curFitInd+numBrdsProcessed-1]
;         This holds the calibrated data and the calibration info
;	hb_arr[4,curFitInd+numBrdsProcessed-1]:{hdr} 
;		  Holds the header for the first sample of each strip.
;	numBrdsProcessed: long	number of boards processed on this call.
;				  	    You should increment curFitInd by this amount.
;
;	RETURNSTATUS: status of reading the corfile. 1 if normal; 0 if
;				eof; -1 if some other problem
;
;KEYWORDS:

;	set CUMCORR to excise interference from the calon/caloff spectra

;	TOTALQUIET suppresses all printed output for duncan

;HISTORY:
;	scannr0_first = scannr0 inserted in monitor mode 6 jun 01. 
;	comment inserted just above :
;	09nov02 - pjp.. changed to use scanlist processing.
;   03dec04 - pjp001 modified to work with fits data..
;			         throw out extra lags (keep 128).
;					 let it work with just total power data.
;					 fix up the positions for fits file
;   01jan05 - pjp.. passed in tcalxx_430ch, yy_430ch
;   29jan05 = pjp002. don't call washdr. since hdr can change..
;				    only needed the srcname since we were'nt using the
;				    other stuff from fits header
;			         
;-
;
;	Input the requested pattern
;
	on_error,0
	grzaMax=19.68
	chzaMax=19.98
    numBrdsProcessed=0
	returnStat=-1

	scanStart=sl[slPatInd].scan
	recsPerPat=scndata.ptsperstrip*scndata.nrstrips+scndata.ptsforcal
	isfits=wascheck(lun)
	if isFits then begin
;	<pjp002>
;		istat=washdr(lun,hdrFits,scan=scanStart) ; get 1 fits hdr
		istat=corgetm(lun,recsPerPat,bin,scan=scanStart,sl=sl,/noscale)
		brdInd=lindgen(sl[slPatInd].numfrq)
	    if n_elements(board) gt 0 then begin
			if board ne -1 then brdInd=board
		endif
		numbrds=n_tags(bin[0])
		nlags=128
		nostokes=n_elements(bin[0].b1.d[0,*]) eq 2
		nsbc=(nostokes) ? 2 : 4
		nrecs=n_elements(bin)
		case numbrds of
			1  :begin
					 b={b1 : {   h: bin[0].b1.h,$
								hf: bin[0].b1.hf,$
						         p: bin[0].b1.p,$
						     accum: bin[0].b1.accum,$
								 d: fltarr(nlags,4)}$
						 }
				end
			2  :begin
					b={b1 : {    h: bin[0].b1.h,$
								hf: bin[0].b1.hf,$
						         p: bin[0].b1.p,$
						     accum: bin[0].b1.accum,$
								 d: fltarr(nlags,4)}, $
					   b2 : {    h: bin[0].b2.h,$
								hf: bin[0].b2.hf,$
						         p: bin[0].b2.p,$
						     accum: bin[0].b2.accum,$
								 d: fltarr(nlags,4)} $
						 }
				end

			3  :begin
					  b1={b1 : { h: bin[0].b1.h,$
								hf: bin[0].b1.hf,$
						         p: bin[0].b1.p,$
						     accum: bin[0].b1.accum,$
								 d: fltarr(nlags,4)}, $
					      b2 : { h: bin[0].b2.h,$
								hf: bin[0].b2.hf,$
						         p: bin[0].b2.p,$
						     accum: bin[0].b2.accum,$
								 d: fltarr(nlags,4)}, $
					      b3 : { h: bin[0].b3.h,$
								hf: bin[0].b3.hf,$
						         p: bin[0].b3.p,$
						     accum: bin[0].b3.accum,$
								 d: fltarr(nlags,4)} $
						 }
				end
			4  :begin
					   b={b1 : { h: bin[0].b1.h,$
								hf: bin[0].b1.hf,$
						         p: bin[0].b1.p,$
						     accum: bin[0].b1.accum,$
								 d: fltarr(nlags,4)}, $
					      b2 : { h: bin[0].b2.h,$
								hf: bin[0].b2.hf,$
						         p: bin[0].b2.p,$
						     accum: bin[0].b2.accum,$
								 d: fltarr(nlags,4)}, $
					      b3 : { h: bin[0].b3.h,$
								hf: bin[0].b3.hf,$
						         p: bin[0].b3.p,$
						     accum: bin[0].b3.accum,$
								 d: fltarr(nlags,4)}, $
					      b4 : { h: bin[0].b4.h,$
								hf: bin[0].b4.hf,$
						         p: bin[0].b4.p,$
						     accum: bin[0].b4.accum,$
								 d: fltarr(nlags,4)} $
						 }
				end
			8  :begin
                       b={b1 : { h: bin[0].b1.h,$
								hf: bin[0].b1.hf,$
                                 p: bin[0].b1.p,$
                             accum: bin[0].b1.accum,$
                                 d: fltarr(nlags,4)}, $
                          b2 : { h: bin[0].b2.h,$
								hf: bin[0].b2.hf,$
                                 p: bin[0].b2.p,$
                             accum: bin[0].b2.accum,$
                                 d: fltarr(nlags,4)}, $
                          b3 : { h: bin[0].b3.h,$
								hf: bin[0].b3.hf,$
                                 p: bin[0].b3.p,$
                             accum: bin[0].b3.accum,$
                                 d: fltarr(nlags,4)}, $
                          b4 : { h: bin[0].b4.h,$
								hf: bin[0].b4.hf,$
                                 p: bin[0].b4.p,$
                             accum: bin[0].b4.accum,$
                                 d: fltarr(nlags,4)}, $
                          b5 : { h: bin[0].b5.h,$
								hf: bin[0].b5.hf,$
                                 p: bin[0].b5.p,$
                             accum: bin[0].b5.accum,$
                                 d: fltarr(nlags,4)}, $
                          b6 : { h: bin[0].b6.h,$
								hf: bin[0].b6.hf,$
                                 p: bin[0].b6.p,$
                             accum: bin[0].b6.accum,$
                                 d: fltarr(nlags,4)}, $
                          b7 : { h: bin[0].b7.h,$
								hf: bin[0].b7.hf,$
                                 p: bin[0].b7.p,$
                             accum: bin[0].b7.accum,$
                                 d: fltarr(nlags,4)}, $
                          b8 : { h: bin[0].b8.h,$
								hf: bin[0].b8.hf,$
                                 p: bin[0].b8.p,$
                             accum: bin[0].b8.accum,$
                                 d: fltarr(nlags,4)} $
                         }
				end
		endcase
		b=replicate(b,nrecs)		; make array
		ind=[0,60,120,180]+2
	    for ibrd=0,numbrds-1 do begin
			   b.(ibrd).h    =bin.(ibrd).h
			   b.(ibrd).hf   =bin.(ibrd).hf
			   b.(ibrd).p    =bin.(ibrd).p
			   b.(ibrd).accum=bin.(ibrd).accum
			   b.(ibrd).h.cor.lagsbcout=nlags
			   b.(ibrd).h.proc.dar[0]=3.4  ;!! --> FIX <-- !!! FWMH.
;
; 	first rec each scan has wrong start time which screwed up 
;   the rate. <FIX>
;
; azoff,zaoff
;
			   b[ind].(ibrd).h.proc.dar[1]=    b[ind+1].(ibrd).h.proc.dar[1] -$
			 			                         b[ind].(ibrd).h.proc.dar[3]
			   b[ind].(ibrd).h.proc.dar[2]=    b[ind+1].(ibrd).h.proc.dar[2] -$
			 			                         b[ind].(ibrd).h.proc.dar[4]
;
;			if no stokes we have spectra that are probably too long. 
;           truncate to 128 channels using a transform (looks like
;           result is shifted by 1/2 channel??).
;			need to also scale by (1/ (lag0a+lag0b)) to put it in the
;           same form as the other acf data.. might as well do it
;           here.. note we are ending up with spectra here with
;           sbc=1 = I, sbc=2  = Q
;
			if nostokes then begin
			    nlagsin=n_elements(bin[0].(ibrd).d[*,0])	
				fftscl1=2./(2.*nlagsin)
				fftscl2=2.*nlags
				tempBuf1=fltarr(nlagsin*2)
				tempBuf2=fltarr(nlags*2)	
				spc     =fltarr(nlags,2)
				for irec=0,nrecs-1 do begin
				    for isbc=0,1 do begin 		; just do it for pola,polb
						tempbuf1[0:nlagsin-1]=bin[irec].(ibrd).d[*,isbc]*fftscl1
						tempBuf1[0]=tempBuf1[0]*.5
						tempBuf2[0:nlags-1] =$
					(float(fft(tempbuf1,1)))[0:nlags-1]*fftscl2 ; trunc to 128
						tempBuf2[0]=tempBuf2[0]*.5
						spc[*,isbc]=(float(fft(tempBuf2)))[0:nlags-1]
					endfor
					lag0=total(spc,1)/nlags		; recompute lag0, 
					b[irec].(ibrd).h.cor.lag0pwrratio=lag0 ;load header
					pwrNorm=1./total(lag0)
					spc=spc*pwrNorm				;so same form as other data.
					b[irec].(ibrd).d[*,0]=total(spc,2)         ; I= a + b
					b[irec].(ibrd).d[*,1]=spc[*,0]-spc[*,1]    ; Q= a - b
				endfor
;
;			acf's, just truncate..
;
			endif else begin
				   b.(ibrd).d[*,0:nsbc-1] =bin.(ibrd).d[0:nlags-1,*]
			endelse
		endfor
		bIn=''
;
;	   if acf/xcf 		compute spectra
;
		if not nostokes then begin
			ijunk=coracftospcpol(b,b)	; looks like in place is ok 
		endif
	endif else begin
		istat=corgetm(lun,recsPerPat,b,scan=scanStart,sl=sl,/noscale)
	endelse
	if istat ne 1 then begin
		print,'incomplete pattern for scan:',scanStart
		goto,badstat
	endif
;
;	store az,za encoder position for each sample
;
	chkLastInd=242-20			; make sure this za was not out of the beam
	az_encoder=b.b1.h.std.azttd*.0001
	if ( pnthgrmaster(b[0].b1.h.pnt) eq 0) then begin
		za_encoder = b.b1.h.std.chttd*.0001
		if (za_encoder[chkLastInd] ge grzaMax) then goto,outofbeam
	endif else begin
		za_encoder = b.b1.h.std.grttd*.0001
		if (za_encoder[chkLastInd] ge chzaMax) then goto,outofbeam
	endelse
;
;	loop thru each board they want, processing the pattern
;		we increment curFitInd for each board
;
	nchnls= scndata.nchnls
	brdInd=lindgen(sl[slPatInd].numfrq)
	stripStartInd=[2,62,122,182] ; index into 242 recs for start each strip
	if n_elements(board) gt 0 then begin
		if board[0] ne -1 then brdInd=board
	endif
    numBrds=n_elements(brdInd)
	stokes   =fltarr(nchnls,4,recsPerPat,/nozero)
	stokesc1 = fltarr( nchnls, 4,recsPerPat,/nozero)
	getrcvr, b[0], rcvr_name, rcvrnum, nocorrcal, circular
	use430Ch=0
	if (rcvr_name eq '430ch') then use430Ch=1
	sourcename= string( b[0].b1.h.proc.srcname)
	indAllScans = indgen(recsPerPat)
	mm_corr=keyword_set(m_rcvrcorr) or keyword_set(m_skycorr) or $
		    keyword_set(m_astro)
;
; 	we need to do the az,za offsets differently since cima does not
;   load the offsets, rates correctly into the header.
;   1. get the source name and then the source position in ra,decB1950
; 	2. Convert the encoder time samples to JD
;   2. convert to J2000
;   3. get the start time Jd for each strip
;   4. compute the jd sec for each sample of each strip
;   5. compute az,za for the source for each sample of each strip
;      this has the model included.
;	6. Compute model position for each 	az,za of source and remove it
;   7. compute the model correction for each az,za of the samples
;      and remove it.
;   8. offset is azPos - source Position

	for i=0,numBrds-1 do begin
		fitInd=curFitInd + i
		ibrd=brdInd[i]
;
;		scale each value by lag0PwrratiopolA+lag0pwrRatioPolB
;
	    Idat=total(b.(ibrd).h.cor.lag0pwrratio,1)  ;sum I,Q by 242 recs
		stokes[*,*,*]=reform(mav(reform(b.(ibrd).d,nchnls*4,recsPerPat),$
								Idat,/sec),nchnls,4,recsPerPat)
;
;		get the cals to use
;	
		if (use430Ch) then begin
			tcalxx= tcalxx_430ch
			tcalyy= tcalyy_430ch
		endif else begin
			stat=corhcalval( b[0].(ibrd).h, calvals)
			tcalxx=calvals[0]
			tcalyy=calvals[1]
		endelse
		if (scndata.tcalxx_board[ibrd] gt 0) then $
					tcalxx = scndata.tcalxx_board[ibrd]
		if ( scndata.tcalxx_board[ibrd] gt 0) then $
					tcalyy = scndata.tcalyy_board[ ibrd]
		cfr= corhcfrtop(b[0].(ibrd).h)
		freq = corfrq( b[0].(ibrd).h)	; freq array
		frq = freq-cfr
		dpdf_use = scndata.dpdf * (1- 2*(corhflipped(b[0].(ibrd).h.cor) eq 1))

;		NOW FOR CALIBRATIONS------------------------------

;       THE FOLLOWING SECTION DOES PROPER INTENSITY CALIBRATION******
		if (keyword_set( totalquiet) ne 1) then $
			print, 'PROCESSING SCAN NR, FREQ, BOARD, SRC ', $
					scanStart,cfr, ibrd, sourcename, $
					format='(a, i10, f9.1, i3, 3x, a)'

;		DO THE INTENSITY CALIBRAITON...ALL SCANS IDENTICALLY. 
;		do on and off separately (calon,caloff). (srcOn srcOff)

		intensitycal_newcal, scndata, tcalxx, tcalyy, $
			indAllScans, scanStart, stokes, stokesc1, nchnls,cumcorr=cumcorr

;		****THE FOLLOWING SECTION DOES PROPER PHASE CALIBRATION **************
;		    FOR THIS, WE WILL USE THE CHANNEL RANGE SELECTED ABOVE.
;			THE ZERO POINT IN FREQUENCY FOR THIS FIT IS FREQZERO, DEFINED ABOVE.
;
;			IF NOCAL IS ****NOT**** SET (SAME AS NOCORRCAL BEING 0), THEN
;			PHASE-CORRECT ALL DATA TO THE OFF-SOURCE ***CAL*** DEFLECTION...
;			IF NOCAL ***IS*** SET (SAME AS NOCORRCAL BEING 1), THEN
;			DETERMINE THE PHASE SLOPE FROM THE OFF-CAL SOURCE DEFLECTION AND 
;			SET THE PHASE ZERO TO ZERO.
;
		correctoption= 1
		if (not nostokes) then begin
		  if ( nocorrcal eq 1) then correctoption= -1
		  IF (correctoption eq 1) then BEGIN
		    phasecal_newcal, scndata, frq, stokesc1, phasechnls, indAllscans, $
			scndata.indxcalon, scndata.indxcaloff, correctoption, $
			phase_cal_observed, calozerofinal, caloslopefinal,cumcorr=cumcorr
		  ENDIF ELSE BEGIN
			phasecal_newcal, scndata, frq, stokesc1, phasechnls, indAllscans, $
				scndata.onscans, scndata.offscans, correctoption, $
			phase_cal_observed, calozerofinal, caloslopefinal,cumcorr=cumcorr
		  ENDELSE

;		NOW DETERMINE THE PHASE OF THE SOURCE DEFLECTION...

		  phasecal_newcal, scndata, frq, stokesc1, phasechnls, indAllscans, $
				scndata.onscans, scndata.offscans, 0,phase_src_observed,$
				srcozerofinal, srcoslopefinal,cumcorr=cumcorr

		  if ( keyword_set( phaseplot)) then $
			phaseplot, scanStart,frq, phase_cal_observed, phase_src_observed, $
				calozerofinal, caloslopefinal, srcozerofinal, srcoslopefinal
		endif else begin
			print,'No stokes data available, skipping phase fits..'
	    endelse

;
;		Store the info in beamin_arr, beamOut_arr, hb_arr
;
		if isfits then begin
			for j=0,3 do begin
			    ii= stripStartInd[j]	
				hb_arr[j,fitInd]=b[ii].(ibrd).h
;
;				some locations that need to be moved..
;
				hb_arr[j,fitInd].pnt.r.reqposrd[0]=b[ii].(ibrd).hf.CRVAL2*!dtor
				hb_arr[j,fitInd].pnt.r.reqposrd[1]=b[ii].(ibrd).hf.CRVAL3*!dtor
				hb_arr[j,fitInd].pnt.r.lastrd=b[ii].(ibrd).hf.lst*15D*!dtor
			    aa=(b[ii].(ibrd).hf.crval5 - 4D)  * 3600D
				if (aa lt 0.) then aa=aa+86400D
				hb_arr[j,fitInd].std.stscantime=round(aa)

			endfor
		endif else begin
			for j=0,3 do hb_arr[j,fitInd]=b[stripStartInd[j]].(ibrd).h
		endelse
		if (noStokes) then begin
		beamin_arr[fitInd].calphase_zero = 0.
		beamin_arr[fitInd].calphase_slope= 0.
		beamin_arr[fitInd].srcphase_zero = 0.
		beamin_arr[fitInd].srcphase_slope= 0.
		endif else begin

		beamin_arr[fitInd].calphase_zero= calozerofinal
		beamin_arr[fitInd].calphase_slope= caloslopefinal
		beamin_arr[fitInd].srcphase_zero= srcozerofinal
		beamin_arr[fitInd].srcphase_slope= srcoslopefinal
		endelse

		beamin_arr[fitInd].tcalxx= tcalxx
		beamin_arr[fitInd].tcalyy= tcalyy
		beamin_arr[fitInd].rcvrn= rcvrnum
		beamin_arr[fitInd].scannr= hb_arr[0,fitInd].std.scannumber
;
;	put the stokes data for the strips in stkoffsets_chnl redim to
;	be 128,4,60samples,4strips
;	put the cal in stkoffsets_chnl_cal
;
		ptsPerStrip=scndata.ptsPerStrip
		ptsForCal  =scndata.ptsForCal
		nrstrips   =scndata.nrstrips
		beamin_arr[fitInd].azencoders= az_encoder[ 2:*]
		beamin_arr[fitInd].zaencoders= za_encoder[ 2:*]
		beamin_arr[fitInd].hpbw_guess= hb_arr[ 0,fitInd].proc.dar[0]

		mmInfo_arr[fitInd].srcname=sourcename
		mmInfo_arr[fitInd].srcflux=fluxsrc(sourcename,cfr)
		if mmInfo_arr[fitInd].srcflux eq 0 then mmInfo_arr[fitInd].srcflux=-1.
		mmInfo_arr[fitInd].scan   =beamin_arr[fitInd].scannr
		mmInfo_arr[fitInd].brd    =ibrd
		mmInfo_arr[fitInd].rcvnum =rcvrnum
		mmInfo_arr[fitInd].rcvnam =rcvr_name
		mmInfo_arr[fitInd].calTemp=[tcalxx,tcalyy]
		mmInfo_arr[fitInd].fchnl_0  =freq[0]
		mmInfo_arr[fitInd].fchnl_max=freq[127]
		mmInfo_arr[fitInd].cfr      =cfr
		mmInfo_arr[fitInd].nchnls   =nchnls
		mmInfo_arr[fitInd].julday   =b[2].b1.hf.mjd_obs
		mcorr=0
		if (mm_corr) then begin
;
			mm_corr,mm_pro_user,beamin_arr[fitInd].rcvrn,cfr,stokesc1,$
					beamin_arr[fitInd].azencoders,$
					beamin_arr[fitInd].zaencoders,mcorr,$
			    m_rcvrcorr= m_rcvrcorr, m_skycorr= m_skycorr, m_astro= m_astro
		endif
		get_offsets_newcal, scndata,stokesc1,fitInd,hb_arr,b,ibrd,sourcename,$
			beamin_arr,stkOffsets_chnl_arr,byChnl=byChnl
 		mmInfo_arr[fitInd].mmcor=mcorr
	endfor
	numBrdsProcessed=numBrds
;STOP

	returnstat=1
return
badstat:
	returnstat=-1
	return
outofbeam:
	print,string(7b),'Source set. pattern skipped for scan:',scanStart
	return
end
