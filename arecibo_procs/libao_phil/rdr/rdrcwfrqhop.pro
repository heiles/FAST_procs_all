;+
;NAME:
;rdrcwfrqhop - input cw frq hopped spectra and average.
;SYNTAX: n=rdrcwfrqhop,spcfile,azelfile,azelhdr,azeldat,davgall,davghopF,$
;                     frqAr=frqAr,swap=swap,deg=deg,fitHopFract=fitHopFract,$
;					  sigIgnHopFract=sigIgnHopFract
;ARGS:
;spcfile:string	 Name of file containing the spectra. It should end in 
;                 .p1 or .p2 to specify whether it is OC or SC.
;azelFile:string Name of azEl file created by greg blacks routine for this 
;                set of freq hops. 
;
;KEYWORDS:
;	swap:		 if set then swap the spectral data as it is read in.
;				 only needed if the data is a different endianness than
;				 the machine you are running on.
;	deg :int	 The degree for the polynomial fit of the baselined
;                data. The fit is over fitHopFract*(hopFreq) hz about the
;			     freqHopped position. The default value is deg=2 .
;fitHopFract:float This parameter will limit the baseline fit to
;		         (hopFreq*fitHopFract) hz. The default value is .8
;sigIgnHopFract:float
;                The sigmas for the averages are normally computed over
;				 hopFrq*fitHopFract Hz about each hopped freq. 
;				 SigIgnHopFract will ignore this fraction of the hopFrq
;			     around the center when computing the sigmas. This is
;				 to not include  parts of the source. The default
;			     value is .05. For the 1 hz 62500 Hz bw that is 3125 Hz
;				 (+/- 3125/2.)
;
;RETURNS:
;	n: long		 number of total hops averaged together.
;davgall[fftlen]:float
;				 The averaged spectra. Only the central portion
;				 (+/- hopFrq/2) is calibrated.
;davgHopF[fftlen,nhops]:float
;				 The averaged spectra for each hop frequency. This has
;			     been averaged to become davgAll.
;frqAr[fftlen]:float the frequency array for the data
;
;azelHdr{}:		structure holding the azel info and a few other things:
;  	 NHOPS          LONG                 4
;  	FRQHOP          FLOAT           10000.0
;  	FRQHOPST        FLOAT          -15000.0
;  	HOPTM           FLOAT           10.0000
;  	SMPRATE         FLOAT           62500.0
;	GW              FLOAT       1.60000e-05
;   FFTLEN          LONG            625000
;   NHOPSTOT        LONG               225
;   FITHOPFRACT     FLOAT          0.800000
;   SIGIGNHOPFRACT  FLOAT         0.0500000
;
;azelDat[n]:{} 	structure holding the azel data read in from the 
;				azelfile for each freq hop.
;
;DESCRIPTION:
;	Read in and average a files worth of frequency hopped data. The
;spectra should already have been passed through the filter scripts
;that compute the spectra and average each hop. The program uses the
;name of the spectral file and the azelfilename.  
;	The processing is:
;	1. input the azel file. For each hop get the Tsys and the gain^2.
;   2. read in the entire file of spectra.
;	3. for Each hopped freq average all of the hops. Weight each spectra
;      averaged by Gain^4/Tsys^2
;   4. for each hop average all of the hops that don't include this
;      frequency. Call this the avgBl[fftlen,nhops]
;   5. for each of the avgBl do a robust polynomial fit  of
;      deg=deg to hopFrq*fitHopFract hz about the cfr for this freq hop.
;   6. divide hopAvg by the fit  and then shift it to dc.
;   7. Compute the mean and the sig for frqHop*fitHopFract hz excluding
;      frqHop*sigIgnHopFract hz about the center.
;   8. divide by the avg, scale by the sum of the weights from 3 and then
;      add to the grand average hopAVg.
;   9. Scale the individual hopAvg to (hopavg-avg)/sig
;  10. When done with all the freqHops, rescale the avg of all of them
;      to sigmas using the same frequency rantge as 7.
;
;GOTCHAS:
;1.	The routine looks for .p1 or .p2 at the end of the spectra
;  filename to decide to use TsysA or TsysB in the weights.
;2. the sampling rate is taken from the azelfilename (it's embedded).
;3. The routine should probably return the subset of the good data
;   rather than returning everything.
;4. The hops are averaged and then baselined. It wouldn't be hard to
;   change this to do it in sections (in case the baseline is changing
;   with time.
;5. Probably not a bad idea do compute rms/mean along the time direction for:
;   - all the hops of a particular freq.
;   - all the hops used for each baseline spectra. 
;   It would give you an idea of interference.
;
;-
function rdrcwfrqhop,spcfile,azelfile,azelHdr,azelDat,davgAll,davghopF,$
		   swap=swap,frqAr=frqAr,fitHopFract=fitHopFract,deg=deg ,$
		   sigIgnHopFract=sigIgnHopFract
;
;
	if n_elements(fitHopFract) eq 0 then fitHopFract=.8
	if n_elements(sigIgnHopFract) eq 0 then sigIgnHopFract=.05
	if n_elements(deg) eq 0 then deg=2
;
; az,el file definitions
;
; data
;
	azel1={ $
	spcInd:0,time:0.,hop:0L,az:0.,za:0.,$
	TsysA:0.,TsysB:0.,gain2:0.,txpwr:0.,rtt:0.,ra:0.,dec:0.}
;
; hdr
;
	azelhdr={$
		nhops: 0L,frqHop:0.,frqHopSt:0.,hopTm:0.,smpRate:0.,gw:0.,$
		fftlen:0L,nhopsTot:0L,fitHopFract:0.,sigIgnHopFract:0.}
;
; open the files
;
	lun=-1
	lunAzEl=-1
	openr,lun,spcfile,/get_lun
	openr,lunAzEl,azelFile,/get_lun
;
; read the azel,file header
;
	inpArr=strarr(5)
	rew,lunazel 
	readf,lunazel,inparr
	a=strsplit(inpArr[2],/extract)
	nhops=long(a[1])
	frqHop=float(a[3])
	frqSt =float(a[4])
	frqSt =float(a[4])
	hopTm =float(a[5])
	a=strsplit(inpArr[3],/extract)
	sampRate=float(a[1])
;
; 	get the fftlen from the azel filename
;
	a=stregex(azelfile,'.*_([0-9]*).azel',/extract,/subex)
	fftlen=long(a[1])
;
; get the pol from the datafile name .p1 or .p2
;
	a=stregex(spcfile,'.*p([12])$',/extract,/subex)
	pol=long(a[1])				; 1=polA , 2=polb
;
	gw      =1./sampRate
	bw=1./(gw)
	freqOff=findgen(nhops)*frqHop + frqSt
	chnw=bw/fftlen
	toshift=-freqOff/chnw
;
; load the azelheader
;
	maxhops=500
	azelDat=replicate(azel1,maxhops)
	azElhdr.nhops    =nhops
	azElhdr.frqhop   =frqHop
	azElhdr.frqHopSt =frqSt
	azElhdr.hopTm    =hopTm
	azElhdr.smpRate  =sampRate
	azElhdr.gw       =gw
	azElhdr.fftlen   =fftlen
	azElHdr.fitHopFract=fitHopFract
	azElHdr.sigIgnHopFract=sigIgnHopfract
	i=0L
	on_ioerror,doneread
	while (1) do begin &$
		readf,lunazel,azel1 &$
		azelDat[i]=azel1 &$
		i++ &$
	endwhile
doneread:
	if i eq 0 then begin
		azeldat=''
		return,0
	endif
	azeldat=azeldat[0:i-1]
	on_ioerror,NULL
	nhopstot=i
	free_lun,lunazel
	lunazel=-1
	azElhdr.nhopsTot =nhopstot
;
; allocate input array for spectral data
;
	d=fltarr(fftlen,nhopstot)
;
; input the spectra.. the entire file
;
	rew,lun
	readu,lun,d
	if keyword_set(swap) then d=swap_endian(temporary(d))
	frqAr=(findgen(fftlen)/fftlen - .5)/(gw)
;
; compute the scaling factor for each dwell
;
;  scale G^2/Tsys^2
;	scale=(pol eq 1)?azElDat.gain2/(azElDat.tsysA^2.)$
;                   :azElDat.gain2/(azElDat.tsysB^2.)
;	
;  scale G^4/Tsys^2
;
	scale=(pol eq 1)?(azElDat.gain2^2.)/azElDat.tsysA^2.$
                    :(azElDat.gain2^2.)/azElDat.tsysB^2.
;
; now process 1 hop at a time
;
	davghop=fltarr(fftlen,nhops)		; average the hops
	davgBl =fltarr(fftlen,nhops)		; average the hops
	dwhop  =fltarr(nhops)				; hold the weights
	for ihop=0,nhops-1 do begin &$
		indhop=where(azeldat.hop eq ihop,spcThisHop) &$
		indBl =where(azeldat.hop ne ihop,spcThisBl) &$
		for j=0,spcthisHop-1 do begin &$
			k=indhop[j] &$
			davgHop[*,ihop]+=(d[*,k]*scale[k]) &$
			dwhop[ihop]+=scale[k] &$
		endfor &$
		davgBl[*,ihop]=total(d[*,indBl],2)/spcThisBl &$
	endfor
;
; for each of the 4 average baselines
; fit  a polynomial ofr fitHopFract*hopFreq about each freq Hop
;
	x=findgen(fftlen)/fftlen
	davghopF=davghop			; each avg freq after fit and shiftin
	davgAll =fltarr(fftlen)     ; all the freq's averaged
	bwfit=azElHdr.frqHop * azElHdr.fitHopFract
	bwSigIgn=sigIgnHopFract*azElHdr.frqHop
	chnWd=1./(azElhdr.gw)/fftlen
	w=dwhop/min(dwhop)          ; how to weight the averages
;		for sigmas use fit bw minus the exclude part about the signal
;		we've already shifted to zero hz.
	iisig=where(((frqAr gt  (-bwfit/2.)) and ( frqAr le (-bwSigIgn/2.))) or $
		         ((frqAr lt ( bwfit/2. ) and ( frqAr ge ( bwSigIgn/2.)))))

	for ihop=0,nhops-1 do begin &$
		cfr=azElHdr.frqHopSt +ihop*azElHdr.frqHop &$
		i1=((cfr - bwfit/2.) - frqar[0])/chnWd &$
		i2=((cfr + bwfit/2.) - frqar[0])/chnWd &$
		coef=robfit_poly(x[i1:i2],davgBl[i1:i2,ihop],deg) &$
		yfit=poly(x,coef) &$
		davghopF[*,ihop]=shift(davghop[*,ihop]/yfit,toshift[ihop]) &$
		avg=meanrob(davghopF[iisig,ihop],sig=sig) &$
;
;	    for avg normalize to 1 then scale by our weights
;
		davgAll+=((davgHopF[*,ihop]/avg)*w[ihop]) &$
;
; 		individual freq hop, remove mean, convert to sigmas
;
		davghopF[*,ihop]=(davghopF[*,ihop]-avg)/sig &$
	endfor
;
;	 now convert the average to sigmas
;
	avg=meanrob(davgAll[iisig],sig=sig)
	davgAll=(davgAll-avg)/sig
	if lunazel ne -1 then free_lun,lunazel
	if lun ne -1 then free_lun,lun
	return,nhopstot
end
