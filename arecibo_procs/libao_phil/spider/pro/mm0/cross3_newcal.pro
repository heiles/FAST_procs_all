 pro  cross3_newcal,lun,sl,slPatInd, scndata,  $
    curFitInd,beamin_arr,hb_arr,mmInfo_arr,stkOffsets_chnl_arr,numBrdsProcessed,$
    returnstatus, tcalxx, tcalyy,han=han,polBad=polBad,missingcal=missingcal,$
	tcalxx_430ch=tcalxx_430ch, tcalyy_430ch=tcalyy_430ch,$
    board=board,nocal=nocal, cumcorr= cumcorr, totalquiet= totalquiet,$ 
    phaseplot= phaseplot ,byChnl=byChnl,$
    mm_pro_user= mm_pro_user, $
    m_rcvrcorr= m_rcvrcorr, m_skycorr= m_skycorr, m_astro= m_astro
;+
;NAME:
;cross3_newcal - input, calibrate, and 1d proces a pattern
;SL is a scanlist of the entire file. slPatInd is and index into
;sl[slpatInd] that is the scan for the start of the pattern we want to
;process.
;
;Processs a single pattern. Input, phase and ;intensity calibrate. 
;PROCESSES ALL 242 SCANS IN THE PATTERN, CALIBRATING THE LATTER 240 IN
;TERMS OF THE FIRST TWO (WHICH ARE CALON AND CALOFF). THE CAL IS USED FOR
;TWO PURPOSES:

;   1. AMPLITUDE CALIBRATION. This assumes that the gain of each
;spectral channel is proportional to the power in the cal-off spectrum.
;It then determines the temperature scale from the cal deflection and the
;values of tcalxx, tcalyy, which are the cal values as found either from
;phil's file or inputted by the user.

;   If the cal value in the arrays tcalxx_board and tcalyy_board is
;negative, it uses the value from Phil's files. It it is positive, it
;uses that value. 

;   Special case: if the rcvr is 430ch, then it uses tcalxx_430ch
;and tcalyy_430ch.

;   2. PHASE CALIBRATION. If the system has a correlated cal
;(nocal=0 as determined from the routine getrcvr.pro), then it assumes
;the cal phase is zero and corrects all 240 phases to the cal phase. this
;phase calibration includes a linear variation with frequency, using
;carl's patented routine! 

;   If the system does not have a correlated cal, then it fits the
;slope of the phase with frequency and corrects all 240 observations for
;that, but does not fit the zero of phase--it calculates the zero point
;phases of the 240 points from their xy and xy data without subtracting
;any other phase (as opposed to the correlated cal case, for which it
;subtracts the zero point of the cal phase).

;INPUTS:

;   There are several inputs passed through the structure SCNDATA.  
;These are of the nature of which points in the scan to use for on source 
;and for off source values, and which points have the cal on and off. 
;Here are some of the more important:

;Variables contained in the structure SCNDATA:
;   INDXCALON, INDXCALOFF: the index numbers within the pattern for
;calon and caloff, equal to [0,0] and [1,1]. These are arrays because in
;principle there could be more than one index used for calibration; if
;there is only one, avoiding errors requires making them arrays with two
;identical elements.

;   ONSCANS, OFFSCANS: Arrays of index numbers within the pattern
;used for calculating source deflections, onsource - offsource.

;   DPDF, the initial guess for the phase slope in radians per MHz.
;The slope arises primarily in the i.f. and its sign depends on whether
;the final sideband is upper or lower; the program determines this from
;whether the spectrum is flipped. In the unlikely event that the slope
;becomes determined from other causes, this may need to be
;changed--however, the fitting routine is pretty robust and even a guess
;with the wrong sign isn't very serious in most (all?) cases.

;   TCALXX_BOARD, TCALYY_BOARD: See the above discussion of
;AMPLITUDE CALIBRATION.

;   TCALXX_430CH, TCALYY_430CH: See the above discussion of
;AMPLITUDE CALIBRATION.

;   CHNLS, PHASECHNLS, GAINCHNLS: the array of channels over which
;sums are taken to determine continuum power. Normally equals
;indgen(128). I always set these arrays equal to each other; some
;calculations use different ones, which allows different channels to be
;used for phase and intensity sums, but i'm not sure if this is
;consistently defined. If you want to make these arrays different, you
;need to check to see how the program differentiates between them, and
;whether it does so consistently. 
;
; POLBAD: int   ==0 --> polA bad, ==1 --> polB bad. If bad then copy other
;                  other pol to this pol. This makes Q 0 and u,v junk
; missingcal: int  if set then this receiver has no cal. normalize to
;                  Tsys.. you can still get pointing and sefd
;
    
;OUTPUTS:

;   beamin_arr[curFitInd:curFitInd+numBrdsProcessed-1]
;         This holds the calibrated data and the calibration info
;   hb_arr[4,curFitInd+numBrdsProcessed-1]:{hdr} 
;         Holds the header for the first sample of each strip.
;   numBrdsProcessed: long  number of boards processed on this call.
;                       You should increment curFitInd by this amount.
;
;   RETURNSTATUS: status of reading the corfile. 1 if normal; 0 if
;               eof; -1 if some other problem
;
;KEYWORDS:

;   set CUMCORR to excise interference from the calon/caloff spectra

;   TOTALQUIET suppresses all printed output for duncan

;HISTORY:
;   scannr0_first = scannr0 inserted in monitor mode 6 jun 01. 
;   comment inserted just above :
;   09nov02 - pjp.. changed to use scanlist processing.
;   01jan05 - pjp.. passed in tcalxx_430ch, yy_430ch
;   13aug06 - pjp.. added han keyword in case strong rfi.
;-
;
;   Input the requested pattern
;
    grzaMax=19.68
    chzaMax=19.98
    numBrdsProcessed=0
    returnStat=-1

    scanStart=sl[slPatInd].scan
    recsPerPat=scndata.ptsperstrip*scndata.nrstrips+scndata.ptsforcal
    istat=corgetm(lun,recsPerPat,b,scan=scanStart,sl=sl,/noscale,han=han)
    if istat ne 1 then begin
        print,'incomplete pattern for scan:',scanStart
        goto,badstat
    endif
	if (b[0].b1.h.cor.lagsbcout ne scndata.nchnls) then begin
		print,'illegal number lags for scan:',scanStart
		goto,badstat
	endif
;
;   store az,za encoder position for each sample
;
    chkLastInd=242-20           ; make sure this za was not out of the beam
    az_encoder=b.b1.h.std.azttd*.0001
    if ( pnthgrmaster(b[0].b1.h.pnt) eq 0) then begin
        za_encoder = b.b1.h.std.chttd*.0001
        if (za_encoder[chkLastInd] ge grzaMax) then goto,outofbeam
    endif else begin
        za_encoder = b.b1.h.std.grttd*.0001
        if (za_encoder[chkLastInd] ge chzaMax) then goto,outofbeam
    endelse
;
;   loop thru each board they want, processing the pattern
;       we increment curFitInd for each board
;
    nchnls= scndata.nchnls
    brdInd=lindgen(sl[slPatInd].numfrq)
    stripStartInd=[2,62,122,182] ; index into 242 recs for start each strip
    if n_elements(board) gt 0 then brdInd=board
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

    for i=0,numBrds-1 do begin
        fitInd=curFitInd + i
        ibrd=brdInd[i]
;
;       scale each value by lag0PwrratiopolA+lag0pwrRatioPolB
;
        Idat=total(b.(ibrd).h.cor.lag0pwrratio,1)  ;sum I,Q by 242 recs
        stokes[*,*,*]=reform(mav(reform(b.(ibrd).d,nchnls*4,recsPerPat),$
                                Idat,/sec),nchnls,4,recsPerPat)
;
;       get the cals to use
;   
        if (use430Ch) then begin
            tcalxx= tcalxx_430ch
            tcalyy= tcalyy_430ch
        endif else begin
		    if (keyword_set(missingcal)) then begin
				calvals=[1.,1.]
			endif else begin
            	stat=corhcalval( b[0].(ibrd).h, calvals)
			endelse
            tcalxx=calvals[0]
            tcalyy=calvals[1]
        endelse
        if (scndata.tcalxx_board[ibrd] gt 0) then $
                    tcalxx = scndata.tcalxx_board[ibrd]
        if ( scndata.tcalxx_board[ibrd] gt 0) then $
                    tcalyy = scndata.tcalyy_board[ ibrd]
        cfr= corhcfrtop(b[0].(ibrd).h)
        freq = corfrq( b[0].(ibrd).h)   ; freq array
        frq = freq-cfr
        dpdf_use = scndata.dpdf * (1- 2*(corhflipped(b[0].(ibrd).h.cor) eq 1))

;       NOW FOR CALIBRATIONS------------------------------

;       THE FOLLOWING SECTION DOES PROPER INTENSITY CALIBRATION******
        if (keyword_set( totalquiet) ne 1) then $
            print, 'PROCESSING SCAN NR, FREQ, BOARD, SRC ', $
                    scanStart,cfr, ibrd, sourcename, $
                    format='(a, i10, f9.1, i3, 3x, a)'

;       DO THE INTENSITY CALIBRAITON...ALL SCANS IDENTICALLY. 
;       do on and off separately (calon,caloff). (srcOn srcOff)

        intensitycal_newcal, scndata, tcalxx, tcalyy, $
            indAllScans, scanStart, stokes, stokesc1, nchnls,cumcorr=cumcorr,$
			polBad=polBad,missingcal=missingcal

;       ****THE FOLLOWING SECTION DOES PROPER PHASE CALIBRATION **************
;           FOR THIS, WE WILL USE THE CHANNEL RANGE SELECTED ABOVE.
;           THE ZERO POINT IN FREQUENCY FOR THIS FIT IS FREQZERO, DEFINED ABOVE.
;
;           IF NOCAL IS ****NOT**** SET (SAME AS NOCORRCAL BEING 0), THEN
;           PHASE-CORRECT ALL DATA TO THE OFF-SOURCE ***CAL*** DEFLECTION...
;           IF NOCAL ***IS*** SET (SAME AS NOCORRCAL BEING 1), THEN
;           DETERMINE THE PHASE SLOPE FROM THE OFF-CAL SOURCE DEFLECTION AND 
;           SET THE PHASE ZERO TO ZERO.
;
        correctoption= 1
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

;       NOW DETERMINE THE PHASE OF THE SOURCE DEFLECTION...

        phasecal_newcal, scndata, frq, stokesc1, phasechnls, indAllscans, $
                scndata.onscans, scndata.offscans, 0,phase_src_observed,$
                srcozerofinal, srcoslopefinal,cumcorr=cumcorr

        if ( keyword_set( phaseplot)) then $
            phaseplot, scanStart,frq, phase_cal_observed, phase_src_observed, $
                calozerofinal, caloslopefinal, srcozerofinal, srcoslopefinal
;
;       Store the info in beamin_arr, beamOut_arr, hb_arr
;
        for j=0,3 do hb_arr[j,fitInd]=b[stripStartInd[j]].(ibrd).h
        beamin_arr[fitInd].calphase_zero= calozerofinal
        beamin_arr[fitInd].calphase_slope= caloslopefinal
        beamin_arr[fitInd].srcphase_zero= srcozerofinal
        beamin_arr[fitInd].srcphase_slope= srcoslopefinal

        beamin_arr[fitInd].tcalxx= tcalxx
        beamin_arr[fitInd].tcalyy= tcalyy
        beamin_arr[fitInd].rcvrn= rcvrnum
        beamin_arr[fitInd].scannr= hb_arr[0,fitInd].std.scannumber
;   put the stokes data for the strips in stkoffsets_chnl redim to
;   be 128,4,60samples,4strips
;   put the cal in stkoffsets_chnl_cal
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
        mmInfo_arr[fitInd].julday   =hb_arr[0,fitInd].pnt.r.mjd +$
                                    hb_arr[0,fitInd].pnt.r.ut1Frac
        mcorr=0
        if (mm_corr) then begin
;
            mm_corr,mm_pro_user,beamin_arr[fitInd].rcvrn,cfr,stokesc1,$
                    beamin_arr[fitInd].azencoders,$
                    beamin_arr[fitInd].zaencoders,mcorr,$
                m_rcvrcorr= m_rcvrcorr, m_skycorr= m_skycorr, m_astro= m_astro
        endif
        get_offsets_newcal, scndata,stokesc1,fitInd, hb_arr,beamin_arr,$
            stkOffsets_chnl_arr,byChnl=byChnl
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
