;-
;NAME:
;masalfatsys - alfa tsys from winking calfiles
;SYNTAX: stat=masalfatsys(yyyymmdd,projId,fileNum,tsysI,lineOut,$
;                grp=grp,verbose=verbose,$
;                lobandoff=lobandoff,hibandoff=hibandoff)
;ARGS:
;yyyymmdd: long	date for files to process
;projid  : string projid for files to process
;fileNum : long   filenumber of date,projid to process
;KEYWORDS:
; grp    : int    0,1 which pdev group has the files. Def=0
; verbose:        if set the output info to  stdout
;lobandoff:       if set then turn off lo IfBand (cfr=1450)
;hibhandoff:      if set then turn off hi IfBand (cfr=1300)
;                 Default is to process both bands
;RETURNS:
;stat	: long	  0 ok , -1 error
;tsysI  : {}      structure holding the tsys info computed
;lineOut[]: strarr array holding the tsys output info for each
;                  beam,freq band computed
;DESCRIPTION:
;	Compute alfa tsys for data taken with the winking cal on. The user
;supplies the data,projid, and filenumber. The routine then finds the
;14 files for this specication that were taken (2 bands * 7 beam). By
;default it looks in group 0. The keyword grp=1 will switch that.
;
;	The data should be taken with the winking cal driven by the
;mock spectrometer. For now it assumes the hical was used. The
;processing  for each band of beam is:
;	1. input  the entire files using  masgetwcal().
;   2. call mascalonoff() to compute the calonoff
;   3. call mascalscl() using the caloff  data to compute Tsys
;      for each cal off spectra.
;   4. compute the average Tsys for all of the calOff spectra.
;-

; compute tsys for alfa using winking cal
;
function  masalfatsys,yyyymmdd,projid,filenum,tsysI,lineOut,grp=grp,$
			verbose=verbose,lobandoff=lobandoff,hibandoff=hibandoff
;
	if n_elements(grp) eq 0 then grp=0
	nbeams=7
;   this is the order they come out  band[0] (1450) then band 1(1300)
	bandAr=[0,1]
	if (keyword_set(lobandoff)) then bandar=[1]
	if (keyword_set(hibandoff)) then bandar=[0]
	nbands=n_elements(bandar)
	fbase='/share/pdata'
	nfiles=nbeams*nbands
;
;	generate the filenames. this is a lot faster than
;   masfilelist() given the number of files in /share/pdataN/pdev
;
	fileAr=strarr(nbeams,nbands)
	for ibm=0,nbeams-1 do begin
		for iiband=0,nbands-1 do begin
			iband=bandar[iiband]	
			filear[ibm,iiband]=string(format=$
			'(a,i1,"/pdev/",a,".",i8,".b",i1,"s",i1,"g",i1,".",i05,".fits")',$
			fbase,ibm+1,projid,yyyymmdd,ibm,iband,grp,filenum)
		endfor
	endfor
		
;
	a={  cfr : 0.,$
		 bw  : 0.,$
 	 	bm  : 0,$
		adrms: fltarr(2,2),$   [iq,ab]
	 	Tsys: fltarr(2),$
	 	tsysrms:fltarr(2),$
		calVal:fltarr(2),$
	fractUsed:fltarr(2)}

	tsysI=replicate(a,nbeams,nbands)
; compute total power
	code=3
	lineOut=strarr(nbeams,nbands)
	iline=0
	tit=$
"  bm  cfr   calA   calB    TsysA  TsysB   digIQ_A    digIQ_B rms"
	for iiband=0,nbands-1 do begin
;
;		want to store low freq the high freq so reverse
;      iband-> ib
;
		iband=bandar[iiband]
		for ibm=0,nbeams-1 do begin
			if((istat=masopen(fileAr[ibm,iiband],desc,hdr=hdr)) ne 0) then begin
				print,"masalfatsys:Error opening:",filear[ibm,iiband]
				return,-1
			endif
;			print,'masalfatsys: num',filenum," file:",fileAr[ibm,iband]
			if ((istat=masgetwcal(desc,bon,boff,nrows=desc.totrows)) lt 1) $
				then begin
				print,"masalfatsys:masgetwcal err:",istat," file:",$
						filear[ibm,iiband]
					masclose,desc
				return,-1
			endif
			masclose,desc
			if ((istat=mascalonoff(bon,boff,calI,/cmpmask)) lt 0) then begin
				print,"masalfatsys:mascalonoff err file:",$
						filear[ibm,iiband]
				return, -1
			endif
			if ((istat=mascalscl(boff,calI,code,bk)) lt 0) then begin
				print,"masalfatsys:mascalscl err file:",$
						filear[ibm,iiband]
				return, -1
			endif
;
; get the rms values
;
			a=strpos(hdr,"ADRMS_")
			ii=where(a ne -1,cnt)
			if cnt ne 4 then begin
				print,"masalfatsys:no ADRMS_ in header. file:",$
						filear[ibm,iiband]
				return, -1
			endif
			
 			a=stregex(hdr[ii],"ADRMS_[AB][IQ]= *([0-9.]*)",/extract,/sub)
		    rmsDigAr=float(reform(a[1,*]))
;
;		start lowfreq,hifreq in tsysI[beams,iband]
;
			tsysI[ibm,iiband].cfr=bon[0].h.crval1*1e-6
			tsysI[ibm,iiband].bw=bon[0].h.bandwid
	    	tsysI[ibm,iiband].bm=ibm
			avgA=rms(bk[0,*],/quiet)
			avgb=rms(bk[1,*],/quiet)
			tsysI[ibm,iiband].tsys=[avgA[0],avgB[0]]
			tsysI[ibm,iiband].tsysrms=[avgA[1],avgB[1]]
			tsysI[ibm,iiband].fractUsed=(1.*calI.npnts)/bon[0].nchan
			tsysI[ibm,iiband].calval=calI.calval
			tsysi[ibm,iiband].adrms=reform(rmsDigAr,2,2)
			lineOut[ibm,iiband]=string(format=$
'(i2,1x,i1,1x,f6.1,1x,f6.3,1x,f6.3," |",f5.1,2x,f5.1," |",f5.1,1x,f5.1,1x,f5.1,1x,f5.1)',$
		17,ibm,tsysI[ibm,iiband].cfr,tsysI[ibm,iiband].calval,$
    		tsysI[ibm,iiband].tsys,TsysI[ibm,iiband].adrms)
			if keyword_set(verbose) then begin
				if iline eq 0 then print,tit
			    print,lineOut[ibm,iiband]
			endif
			iline++
		endfor
	endfor
	return,0
end
