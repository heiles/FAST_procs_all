;+
;NAME:
;shsclp - coded long pulse (ri)
;SYNTAX: istat=shsclp(desc,spcBuf1,spcBuf2,ippToAvg=ippToAvg,baudLen=baudLen,
;                          spclen=spclen,txSmpSkip=txSmpSkip,nheights=nheights,$
;                          dinfo=dinfo,hdr=hdr,dotm=dotm,tmi=tmi,verbose=verbose,$
;                          clipRfi=clipRfi,,minipp=minipp,usenoise=usenoise,$
;						   dinp=dinp,firstheight=firstheight)
;ARGS:
;  desc:    struct     desc that points at data file
;KEYWORDS:
;  ippToAvg:  long    number of ipps toavg. there are  100 ipps/rec so
;                    should be a multiple of 100 ipps
; minipp :  long    minimum number contiguous ipps to avg, if not found
;                   continue through the file for the next block.
; baudlen:  float   This is actaully the step in the height processing.
;                   It defaults to 1 usec
;                   lets you override it. The units are usecs.
;spclen  : long     The length of the spectra to do. By default it is
;                   rounded up to the next power of 2.
;txSmpSkip:float    The number of usecs to skip before taking the first
;                   tx sample. This takes in account the filter delay for the
;                   tx samples. The default is 5 usecs.
;nheights: long     limit to 1..nheights.. default is all
;dotm     :         if set then do detailed tming.. if not, just do
;                   total times.
;verbose  :         if set then output start of each rec and start of
;                   each ipp modulo 10
;cliprfi  : float   if supplied, then clip the spectra of each rfi to 
;                   nsig=cliprfi, 0 these voltage points and back xform
;                   (unless usenoise is set)
;usenoise : int     if true then replace large rms with noise rather
;                   than 0 it.
;dinp[m]: int       use this at data to process. ippToAvg will be 
;                   set to the min of ipptoAvg m*dinp.nipps
;firsthght: long    if provided then first height to process. count from 0.
;                  default is 0
;navgipp  : long   number of navgipp to return. default is 1.
;                  use this to return unaveraged ipp
;                  set ipptoavg=1 set navgipp=100.. this will return 1 rec
;RETURNS:
;spcbuf1[spclen,nhghts]: float   the averaged spectra vs heights for the
;                                first channel (normally ch1 for dual beam).
;spcbuf2[spclen,nhghts]: float   the averaged spectra vs height if two
;                                channels were used (normally gr for dual beam).
; dinfo  :  {}      Structure holding info that was used in the computation
;                   (see below)
; dhdr   :  {}      header from the first record averaged. 
; tmI    :  {}      Timing info  (see timing info below for a description). If 
;                   dotm=1 then you get detailed info. If not, then just the totals.
;
;DESCRIPTION:
;   Input and process coded long pulse data taken in raw data mode with 
;ryans machine. It will read ippToAvg/100 records (default 10) starting
;from the current location on disc (pointed to by desc). It
;requested number of records into a buffer (so don't make it too large). It currently
;does not check if this is a clp record or not (to be added).
;
;   For each ipp the processing step is:
;   1. extract the tx samples using txSmpSkip to determine which
;      tx Sample to start on.
;   2. compute the complex conjugate of these samples.
;   3. for each height:
;       - multiply the data by the code.
;       - zero extend to spclen
;       - fft the data
;       - compute power and accumulate
;       - compute how many samples to skip to get to the next starting
;         height (usually baudlen/sampLen).
;   4. After accumulating divide by the number of accumulations;
;   5. Shift each spectra so that dc is in the center (for a 4096 length
;      xform, shift right by 2048)
;
;   6. fill in the dinfo structure with the info that was used for the
;      computation. Dinfo contaings:
;dinfo={ $
;        gwUsec     : gwUsec,$
;        baudLenUsec: baudLenUsec,$
;        codeLenGw  : codeLenGw,$
;        nhghts     : nhghts,$
;        hghtStepGw : hghtStep,$
;        ippAvged   : ippAvgd,$
;        spcLen     : spclen,$
;        txSmpSkip  : txSmpSkipL,$
;        numChn     : numChn ,$
;          bwMhz   : bw,$
;		nsigclip  : nsigclip,$
;		ippI      : ippI[ipptoAVg] } ; info on each ipp
; ippI hold info on each ipp:
;	clipI={$
;		   mean:0.,$; spectral mean
;		   rms :0.,$; spectum rms
;		   ndel:0. $, ;nchan removed
;          rmsLoop:0$; 1 or 2 .. how many times we looped rms
;		   }
;	a={ rec: 0L,$    in file count from 0
;	    ippRec:0L,$; ipp within rec count from 0
;		ippCum:0L, ; from start of file  count from 0
;		; following computes on spc.. if nsigdel 0.
;		clipI   : replicate(clipI,2) $; the 2 chan
;		}
;
;   7. also return the header from the first ipp used in the variable hdr.
;      Interesting info is in the sps portion of the header (although the
;      baudlen may be incorrect).
;
;
;TIMING INFO:
;
; Timing info can be returned if tmi=tmi keyword is provided. The tmI 
; structure holds times for different parts of the code. Each time
; structure has the number of times the code was timed, the total sum
; and the total sum of squares. The routine printtmI,tmi can be used
; to print this info out.
;    An example output is:
;
;IDL> printtmi,tmi
;tmTot:675.096 read: 3.987 
;
;  CODECONJ Ntot:  1000 tmTot:  0.4328 avgTm0.000433 sig:0.000006
;    CODEM1 Ntot:601000 tmTot: 51.1495 avgTm0.000085 sig:0.000005
;      FFT1 Ntot:601000 tmTot:122.8049 avgTm0.000204 sig:0.000008
;    ACCUM1 Ntot:601000 tmTot:135.5683 avgTm0.000226 sig:0.000006
;    CODEM2 Ntot:601000 tmTot: 51.2731 avgTm0.000085 sig:0.000004
;      FFT2 Ntot:601000 tmTot:122.8776 avgTm0.000204 sig:0.000007
;    ACCUM2 Ntot:601000 tmTot:135.2315 avgTm0.000225 sig:0.000006
;   BUF1TOT Ntot:601000 tmTot:322.3068 avgTm0.000536 sig:0.000013
;   BUF2TOT Ntot:601000 tmTot:322.0795 avgTm0.000536 sig:0.000012
;
; All times are in seconds. the columns are:
;
;totmeasTm  total wall time
;read:      total time for reading data.
;sectionNm  The section of code that was timed.
;Ntot  is how many times this section was timed., 
;tmTot is the total time for this section.
;avgTm is the average time for 1 execution of this code
;sig   is the sigma for the Ntot measurements
;
; The sections are:
; CODECONJ : extract and conjugate the tx samples
; CODEM1   : extract hght data, multiply by code, 0 extend.
;  FFT1    : compute the fft (using fttw)
;  accum1  : compute the power and accumulate
; BUF1TOT  : total time for buf1. includes some data manipulation times
;            not included in the above times
; The xxx2 : same as xxx1 but for the second chan (if present)
;
;totmeasTm : this is just the sum of the measured times. It does not
;            include the overhead of timing (about 2usecs per call).
;
;
; The example above had 1000 codeconj so 1000 ipps were processed (10 secs
; of data).
; You'll notice that computing the power and accumulating is taking
; longer than the fft. 
; For this computer fftw in C took about 44 usecs for a 1k xform. So it
;should take about 211 usecs for a 4k. It is averaging 204 so there doesn't
;look like there is any speed up time in the fft.
; Code speedup would probably come by writing an external module
;that was passed a tx rec, hght rec, and then it did the fftw and
;power, accumulate, returing the averaged buf. This might give you
; 50% speed up.
;-
;
function shsclp,desc,ippToAvg=ippToAvg,spcBuf1Avg,spcbuf2Avg,baudLen=baudLen,$
            spclen=spclen,txSmpSkip=txSmpSkip,hdr=hdr,dinfo=dinfo,tmI=tmI,$
            dotm=dotm,nheights=nheights,verbose=verbose,cliprfi=cliprfi,$
			minipp=minipp,usenoise=usenoise,dinp=dinp,firstheight=firstheight

    forward_function timeit
	 common colph,decomposedph,colph

;   if cliprfi caused rms to decrease byloopRatio
;   then iterate with points above cliprfi thrown out
;   else use all points cliprfi above the first rms
;
	loopRatio=2.
;
;   time info
;
;
	readD=n_elements(dinp) eq 0
	codeLenUsec=440.
    a={ nsmp : 0L,$
        sum  : 0D,$
        sumSq: 0D}
    tmHiRes=keyword_set(dotm)
    tmI = {$
            tmTot: 0D, $
            read : 0D, $
            codeConj: a ,$
            codeM1  : a ,$
            fft1    : a ,$
            accum1  : a ,$  
            codeM2  : a ,$
            fft2    : a ,$
            accum2  : a ,$  
            buf1tot : a ,$
            buf2tot : a }
    tmI.tmTot=systime(1)

    txUsecSkipDef=5.            ; if not specified, skip 2 usecs from start
    baudLenUsec=1.              ; local copy baudlen
	ippToAvgL=1000L
    if n_elements(ippToAvg) ne 0 then ipptoAvgL=ippToAvg
	if not readD then ippToAvgL=((n_elements(dinp)*dinp[0].nipps) < ippToAvgL)
    if n_elements(baudLen) ne 0 then baudLenUsec=baudLen
	if n_elements(verbose) eq 0 then  verbose=0
	if n_elements(minipp) eq 0 then  minipp=ippToAvgL
	if n_elements(usenoise) eq 0 then  usenoise=0
	nsigClip=(n_elements(cliprfi)  eq 1)?abs(cliprfi):0. 
	clipI={$
		   mean:0.,$; spectral mean
		   rms :0.,$; spectum rms
		   ndel:0.,$, ;nchan removed
		   rmsLoop:0$ ;times we looped, 1 or 2
		   }
	a={ rec: 0L,$
	    ippRec:0L,$; ipp within rec
		ippCum:0L,$ ; from start of file 
		; following computes on spc.. if nsigdel 0.
		clipI   : replicate(clipI,2) $; the 2 chan
		}
	ippI=replicate(a,ippToAvgL)
		 
;
;   read the data, 1 rec to get ipps/rec then rest of the records
;   
	if readD then begin
    	now=sysTime(1)
   	    istat=shsget(desc,d)
        tmI.read=sysTime(1) - now
    	if istat le 0 then begin
		 	stop
			return,istat     ; eof or error
		endif
	    curRec=shscmprec(desc) - 1L
        if (verbose) then print,"riead rec:",curRec
	endif else begin
		d=dinp[0]
	    gwUsec=.2	;hardcoded. normally use descriptor
		curRec=0L
	endelse
;
;   header info
;
    if arg_present(hdr) then hdr=d[0].dhdr
    spipp  =d.dhdr.dim0/2L			; /2 since dim0 is i or q samples
    ippsbuf=d.nipps
	if readD then gwUsec=desc.phdr.sampletime
    numChn=d.dhdr.numchannels
;
    codeLenGw  =round(codeLenUsec/gwUsec)
    smpInTx    =d.dhdr.txlen/2L
    codelenBauds=round(codeLenUsec/baudlenUsec)
;
;    txSkip about 2 usecs in gw samples or at least 1 sample
;
    txSmpSkipL=(n_elements(txSmpSkip) ne 0)?txSmpSkip:$
                                    round(txUsecSkipDef/gwUsec) > 1
;
;   round spectr up to next power of 2 if they didn't request one
;
    if n_elements(spclen) eq 0 then begin
        pwr2=long(alog10(codeLenGw)/alog10(2.))
        if 2.^pwr2 lt codeLenGw then pwr2=pwr2+1L
        spcLen=2L^pwr2
    endif
;
;    grab the tx samples we want
;
    txInd1=txSmpSkipL       ; first tx smp to use
    txInd2=(txInd1 + codeLenGw - 1) < (smpInTx - 1L)    ; smaller of the 2
    codeLenGw=txInd2-txInd1+1L                  ; we actually used

    hghtStep=round(baudlenUsec/gwUsec)          ;independant hght samples
    ndataSmp=d[0].dhdr.datalen/2L
    nhghts=(n_elements(nheights) gt 0)? nheights:(ndataSmp-codeLenGw)/hghtStep + 1L
    firsthght=(n_elements(firstheight) eq 0)?firstheight:0L
    spcBuf1Avg                     =fltarr(spcLen,nhghts)
    if numChn eq 2 then spcBuf2Avg=fltarr(spcLen,nhghts)
    spcCmpBuf                      =complexarr(spcLen) ;cmp spectra here,0 fills
    spcOutBuf                      =fltarr(spcLen);compute spectra here,0 fills
    bw=1./gwUsec
;
; 	see if we replace rfi with noise
;
	if useNoise then begin
		seed=''
		nsei=randomn(seed,ndataSmp)
		nseq=randomn(seed,ndataSmp)
		nse=complex(nsei,nseq)
	endif
;
;   now loop till we get the requested ipp to avg
;
    nd1=0L
    d1nd1=0L
    codeLenGw_m1=codeLenGw -1L
		
    ippCur=0L
	skipOn=0 
	irec=0L
	while (ippCur lt ipptoAvgL) do begin
;
;       loop over ipps in buf
;
        for iipp=0,ippsbuf-1 do begin    &$

			if (shsclpchkipp(d.d1.tx[*,*,iipp]) eq 0) then begin
				if (ippcur gt 0) then begin
				  ;start over
				  ippcur=0L
				  spcbuf1Avg*=0.
				  if numchn eq 2 then spcbuf2Avg*=0.
				  print,"--> discarding ",ippcur," avgd ipps.. hit non clp rec"
				endif
				if skipOn eq 0 then skipOn++
			endif else begin
				; if skip to not skip, report count
				if skipOn gt 0 then print,"--> ipps skipped:",skipOn
				if ippCur ge ippToAvgL then break
				skipOn=0
			endelse
			if (verbose and (iipp mod 10 eq 0)) then print,"ippCum, ippRec,skipOn:",$
						ippCur,iipp,skipOn
			if skipOn then continue
					
            now=sysTime(1)
            codeDat1=conj(reform(complex(d.d1.tx[0,txInd1:txind2,iipp],d.d1.tx[1,txInd1:txind2,iipp])))
            tmI.codeConj=timeit(sysTime(1)-now,tmI.codeConj)
            d1=reform(complex(d.d1.dat[0,*,iipp],d.d1.dat[1,*,iipp]))
			if numChn eq 2 then begin
            	d2=reform(complex(d.d2.dat[0,*,iipp],d.d2.dat[1,*,iipp]))
                codeDat2=conj(reform(complex(d.d2.tx[0,txInd1:txind2,iipp],d.d2.tx[1,txInd1:txind2,iipp])))
			endif
;
; 	do we clip rfi?
;
			if (nsigClip ne 0.) then begin
				for ichn=0,numchn-1 do begin
					vspc=(ichn eq 0)?fft(d1):fft(d2)
					spc=(abs(vspc))^2
					a1=rms(spc,/quiet)
					iigd1=where( abs(spc -a1[0]) lt (a1[1]*nsigclip),cnt1)
					if cnt1 eq 0 then continue
					a2=rms(spc[iigd1],/quiet)
					if (a1[1]/a2[1] gt loopRatio) then begin &$
						sig=a2[1]
                        meanVal=a2[0]
						iibad=where(abs(spc - a2[0]) gt (sig*nsigclip),cnt)
					    ippi[ippCur].clipI[ichn].ndel=cnt
					    ippI[ippCur].clipI[ichn].mean=a2[0]
					    ippI[ippCur].clipI[ichn].rms=sig
					    ippI[ippCur].clipI[ichn].rmsLoop=2
						if cnt eq 0 then continue &$
					endif else begin &$
						sig=a1[1]
                        meanVal=a1[0]
						iibad=where((spc - a1[0]) gt (sig*nsigclip),cnt) &$
					    ippI[ippCur].clipI[ichn].ndel=cnt
					    ippI[ippCur].clipI[ichn].mean=a1[0]
					    ippI[ippCur].clipI[ichn].rms=sig
					    ippI[ippCur].clipI[ichn].rmsLoop=1
						if cnt eq 0 then continue &$
					endelse &$
					if (useNoise) then begin
						iigd=where(abs(spc-meanval) lt sig*nsigclip)
					    a=rms(vspc[iigd],/quiet)
						sigV=(imaginary(a[1]) + float(a[1]))*.5
						vspc[iibad]=nse[iibad]*sigv
					endif else begin
						vspc[iibad]*=0.
					endelse
					if ichn eq 0 then begin
						d1=fft(vspc,/inverse)
					endif else begin
						d2=fft(vspc,/inverse)
					endelse
			   endfor
			endif
;
;           loop over heights
;
            ih2=firstHght*hghtStep
            if tmHiRes then begin
                for ihght=firsthght,firsthght + nhghts-1 do begin &$
                    tmbuf1=sysTime(1)
                    spcCmpBuf[0:codeLenGw-1]=d1[ih2:ih2+codeLenGw_m1]*$
                                          codeDat1 &$
                    tmI.codeM1=timeit(sysTime(1)-tmbuf1,tmI.codeM1)
                    now=sysTime(1)
                    spcOutBuf=fftw(spcCmpBuf) &$
                    tmI.fft1 =timeit(sysTime(1)-now,tmI.fft1)
                    now=sysTime(1)
                    spcBuf1Avg[*,ihght]+=$
                        float(spcOutBuf)^2+imaginary(spcoutBuf)^2
                    done=systime(1)
                    tmI.accum1 =timeit(done-now,tmI.accum1)
                    tmI.buf1tot=timeit(done-tmbuf1,tmI.buf1tot)

                    if numChn eq 2 then begin
                        tmbuf2=sysTime(1)
                        spcCmpBuf[0:codeLenGw-1]=d2[ih2:ih2+codeLenGw_m1]*$
                                          codeDat2  &$
                        tmI.codeM2=timeit(sysTime(1)-tmbuf2,tmI.codeM2)
                        now=sysTime(1)
                        spcOutBuf=fftw(spcCmpBuf) &$
                        tmI.fft2=timeit(sysTime(1)-now,tmI.fft2)
                        now=sysTime(1)
                        spcBuf2Avg[*,ihght]+=$
                            float(spcOutBuf)^2+imaginary(spcoutBuf)^2
                        done=systime(1)
                        tmI.accum2 =timeit(done-now,tmI.accum2)
                        tmI.buf2tot=timeit(done-tmbuf2,tmI.buf2tot)
                    endif
                    ih2=ih2+hghtStep &$
                endfor  ; height loop
;

            endif else begin
                for ihght=firsthght,nhghts-1 do begin &$
                    spcCmpBuf[0:codeLenGw-1]=d1[ih2:ih2+codeLenGw_m1]*$
                                          codeDat1 &$
                    spcOutBuf=fftw(spcCmpBuf) &$
                    spcBuf1Avg[*,ihght]+=$
                        float(spcOutBuf)^2+imaginary(spcoutBuf)^2
                    if numChn eq 2 then begin
                        spcCmpBuf[0:codeLenGw-1]=d2[ih2:ih2+codeLenGw_m1]*$
                                          codeDat2  &$
                        spcOutBuf=fftw(spcCmpBuf) &$
                        spcBuf2Avg[*,ihght]+=$
                            float(spcOutBuf)^2+imaginary(spcoutBuf)^2
                    endif
                    ih2=ih2+hghtStep &$
                endfor  ; height loop
            endelse
			ippI[ippCur].rec=currec
			ippI[ippCur].ippRec=iipp
			ippI[ippCur].ippCum=curRec*ippsBuf + iipp
			ippCur++
			if ippCur ge ippToAvgL then break
        endfor      ; ipp buf loop
		if (ippCur lt ippToAvgL) then begin
			if readD then begin
    			istat=shsget(desc,d)  
	  			if istat le 0 then begin
			  		print,"shsget error:",istat," endof file?"
					return,istat     ; eof or error
				endif
	        	curRec=shscmprec(desc) - 1L
            	if (verbose) then print,"read rec:",curRec
			endif else begin
				irec+=1
				if irec ge n_elements(dinp) then begin
				   print,"IpptoAvg >  number of recs in dinp"
					return,-1
				endif
				d=dinp[irec]
            	if (verbose) then print,"move to rec:",irec
			endelse
		endif
    endwhile          ; rec loop
;
;   put spectra in the center
; 
	ippAvgd=ippCur
    spcBuf1Avg=shift(spcBuf1Avg/(ippAvgd),spclen/2)
    if numChn eq 2 then  $
        spcBuf2Avg=shift(spcBuf2Avg/(ippAvgd),spclen/2)
;
;   return info structure used
;
    dinfo={ $
        gwUsec     : gwUsec,$
        baudLenUsec: baudLenUsec,$
        codeLenGw  : codeLenGw,$
        nhghts     : nhghts,$
        hghtStepGw : hghtStep,$
        ippAvged   : ippAvgd,$
        spcLen     : spclen,$
        txSmpSkip  : txSmpSkipL,$
        numChn     : numChn ,$
          bwMhz   : bw,$
		nsigclip  : nsigclip,$
		useNoise  : useNoise,$
		ippI      : ippI } ; info on each ipp
    tmI.tmTot=systime(1) - tmI.tmTot
    return,ippToAvgL
end

function timeit,dif,a
        a.nsmp =a.nsmp+1
        a.sum  =a.sum+dif
        a.sumsq=a.sumsq + dif*dif
    return,a
end
pro  printtmi,tmI
    lab=string(format='("tmTot:",f7.3," read:",f6.3)',$
                    tmI.tmtot,tmI.read)
    print,lab
    nms=tag_names(tmI)
    measTot=0.
    for i=2,n_elements(nms)-1 do begin
        a=tmI.(i)
        nsmp=a.nsmp
        if nsmp eq 0 then begin
            avg=0D
            sumSq=0D
            nsmp=1 
        endif else begin
            avg =a.sum/nsmp
            sumSq=a.sumsq
        endelse
        lab=string(format=$
        '(a10," Ntot:",i6," tmTot:",f8.4," avgTm",f8.6," sig:",f8.6)',$
            nms[i],nsmp,a.sum,avg,sqrt(sumSq/nsmp - avg*avg))
        print,lab
        if (i le n_elements(nms)-3) then measTot=measTot+a.sum
    endfor
    print,format='("totmeasTm:",f8.3)',measTot
    return
end
