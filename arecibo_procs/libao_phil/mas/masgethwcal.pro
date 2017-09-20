;NAME:
;masgethwcal: input 25hz hardware cal data
;SYNTAX:istat=masgethwcal(fnmI,calI,bonar,boffar,avgrow=avgrow,verb=verb,$
;                         incrfreq=incrfreq,$
;						  bavgAr=bavgAr,brmsAr=brmsAr,avgmed=avgmed,$
;						  sumI=sumI)
;ARGS:
; fnmI[n] :{}       files to input. returned from masfilelist
;KEYWORDS:
; avgrow   : int    if set then return bonar,boffar averaged to 
;                   a row's worth of data (usually 1 second). If not
;                   set then data is averaged to 1 cal cycle (on 20ms,off20ms)
; freqorder: int    if set then return bonar[*,n] in freq order
;                   default is order in fnmI.
; verb    :         if present then print 1 line file summary
; incrfreq:         if set then make all data retunred in the
;                   arrays increasing freq. For those bands with decreasing
;                   freq, the data is flipped and the header is adjusted
;                   accordingly.
;avgmed   :         if set then use median when computing row and file averages
;RETURNS:
; istat : int     >=0 number of files input
;                 < 0 error:
;                 -1 = can't open file
;                 -2 = file has different number of rows
;calI[n]: {}      holds info  about each file input
;bonAr[m,n]: {}   mas struct of cal on,m number of cal cycles
;boffar[m,n]:{}   mas struct of cal off
;bAvgAr[n,2]:{}   if present then also return averaged data for each file
;                 [*,0]=calon, [*,1]=caloff
;brmsAr[n,2]:{}   if present then compute rms by chan for each file
;                 [*,0=calOn,1=calOff . If rowavg is provided, the rms
;                 is computed after the row avg.
;sumI[n]: {}      summary info each file
;
;DESCRIPTION:
; 	input hardware winking cal (25Hz) data from files 
;User can specify the files using flist[n] or with the fnmI= keyword (see
;masfilelist). 
;	The program uses masgetwcal() to input the data. The processing is:
;1. separate the calons, cal offs for each row.
;   average the ons and the offs separately for row.
;   When doing the average, discard the first and last spectra of 
;   each cal transition. The 25hz cal has 20millisecs on, 20millisecs off.
;   if you sampled at 1 millisec then
;   avg 2-19 on, 2-19 off. This is to not include the transitions.
;   Any adc blanking will be corrected in the averaging.
;2. Load the bonAr, boffAr first index with the row averaged values.
;   The average will  normally be 1sec. or 25 cycles.
;3. Each file must have the same number of rows...
;4. fill in the calI[i] struct for info about this file.
;
;	For this to work, the spectra need have integrations that are
;divisible into 20 milliseconds. Since we throw out the 1st and last 
;you need at least 4 samples (5 ms each) 2ms per spectra is probably better.
; This routine assumes that the integration of each spectra is a 
; multiple of 1 millisecond (it rounds the exposure to the nearest millisec).
;
;-
function masgethwcal,fnmI,calI,bonAr,boffAr,verb=verb,avgrow=avgrow,$
                     freqorder=freqorder,bavgAr=bavgAr,brmsAr=brmsAr,$
					 avgmed=avgmed,incrfreq=incrfreq,sumI=sumI
;
; 	get file summary
;
	if n_elements(verb) eq 0 then verb=0
	if n_elements(avgmed) eq 0 then avgmed=0
	if n_elements(incrfreq) eq 0 then incrfreq=0
	if (n_elements(freqorder) eq 0) then freqorder=0
	if (n_elements(avgrow) eq 0) then avgrow=0
	nfiles=masfilesum(flist,sumI,fnmI=fnmI,list=verb)
	if nfiles eq 0 then return,0
	if freqorder then begin
		ii=sort(sumI.h.crval1)
		fnmIL=fnmI[ii]
		sumI=sumI[ii]
	endif else begin
		ii=lindgen(nfiles)
		fnmIL=fnmI
	endelse
	calHz=25L
	calCycleMs=1000L/25
	calHalfCycleMs=calCycleMs/2L
	a={  scan: 0L ,$
		 calNum:0l,$  ;for calget1() routine. type of cal
         calNm : '',$ ; hcorcal, etc.. 
	     calDate:lonarr(2),$; [year,dayno] for calget1 call
		 calHybrid:0,$ ;  if true they hybrid in, avg pola,B
		 nrows :0L ,$ ; this file
		 smpTmMs:0L, $; millisecs each spectra
         tmRowSec:0d, $ ; secs  
		 cfrMhz:0d, $ ; center frequency Mhz
		 fname :''  $ ; filename (without the dir)
       }
	calI=replicate(a,nfiles)
		 
	for ifile=0,nfiles-1 do begin
		if verb then print,ifile,' ',fnmIL[ifile].fname
		istat=masopen(file,desc,fnmi=fnmI[ii[ifile]])
		if istat lt 0 then begin
			print,"Error openning file:",fnmIL[ifile].fname 
			return,-1
		endif
		integTmMs=long(sumI[ifile].h.exposure * 1000L + .5)
;
; make it look like mas winking cal
;
		ncalOn=calCycleMs/(2*integTmMs)
		ncalOff=ncalon
;
		desc.hsp1.calon=ncalon
		desc.hsp1.caloff=ncalon
		desc.hsp1.calctl=2
		rew,desc
		toavg=1
;
;       actually masgetwcal wants number of cals cycles per row to avg
;       but if we give it a number too big, it just averages all of them
		if avgrow then toavg=sumI[ifile].dumprow
			
		istat=masgetwcal(desc,bon,boff,nrows=desc.totrows,toavg=toavg)
		npol=bon[0].npol
		nrows=n_elements(bon)
		if ifile eq 0 then begin
			bonAr =replicate(bon[0],nrows,nfiles)
			boffAr=replicate(boff[0],nrows,nfiles)
			nrowsFile=nrows
		endif
		if (nrowsFile ne nrows) then begin
			print,"file has different # of rows. 1st,cur,fname:",$
				nrowsFile,nrows,fnamIL[ifile]
			return,-2
		endif
		if (incrfreq and (bon[0].h.cdelt1 lt 0)) then begin
;			if stokes, you need to multiply stokes V by -1
			bon.d=reverse(bon.d,1,/overwrite)
			boff.d=reverse(boff.d,1,/overwrite)
			if npol eq 4 then begin
				if bon[0].ndumps gt 1 then begin
					bon.d[*,3,*]*=-1.
					boff.d[*,3,*]*=-1.
				endif else begin
					bon.d[*,3]*=-1.
					boff.d[*,3]*=-1.
				endelse
			endif 
;			flipping moves the recorded freq down by one
			bon.h.crpix1-=1
			bon.h.cdelt1*=-1
			bon.h.uppersb=1

			boff.h.crpix1-=1
			boff.h.cdelt1*=-1
			boff.h.uppersb=1
		endif
		bonAr[*,ifile] =bon
		boffAr[*,ifile]=boff
		if arg_present(bavgAr) then  begin
			bavg=masmath(bonAr[*,ifile],/avg,median=avgmed)
			if ifile eq 0 then begin
				bavgAr=replicate(bavg,nfiles,2)
			endif
			bavgAr[ifile,0]=bavg
			bavgAr[ifile,1]=masmath(boffar[*,ifile],/avg)
		endif
		if arg_present(brmsAr) then  begin
			brms=masrms(bonAr[*,ifile])
			if ifile eq 0 then begin
				brmsAr=replicate(brms,nfiles,2)
			endif
			brmsAr[ifile,0]=brms
			brmsAr[ifile,1]=masrms(boffar[*,ifile])
		endif
		masclose,/all
		h=bon[0].h
	    calI[ifile].scan=h.scan_id
		calI[ifile].calnum=$
		    (h.caltype eq 'hcorcal')?1:$
            (h.caltype eq 'lcorcal')?0:$
            (h.caltype eq 'hcal'   )?5:$
            (h.caltype eq 'lcal'   )?4:$
            (h.caltype eq 'hxcal'  )?3:$
            (h.caltype eq 'lxcal'  )?2:$
            (h.caltype eq 'h90cal' )?7:$
            (h.caltype eq 'l90cal' )?6:-1
         calI[ifile].calNm=h.caltype
		 calI[ifile].nrows   =n_elements(bon)
		 calI[ifile].smpTmMs =integTmMs
         calI[ifile].tmRowSec=bon[0].ndump*calCycleMs*.001 ; secs
		 calI[ifile].cfrMhz  =h.crval1*1e-6 
		 calI[ifile].fname   =fnmI[ifile].fname
		 year  =long(strmid(h.datexxobs,0,4))
    	 mon   =long(strmid(h.datexxobs,5,2))
    	 day   =long(strmid(h.datexxobs,8,2))
    	 calI[ifile].caldate=[year,dmtodayno(day,mon,year)]
		 calI[ifile].calhybrid=(((h.rfnum eq 5)  and (h.lbwhyb ne 0)) or  $
            					((h.if1sel eq 4) and  (h.hybrid ne 0))) and $
           						 (h.rfnum ne 17)
    	 if h.rfnum eq 100 then begin
        	calI[ifile].calhybrid=0
            calI[ifile].calnum=5
    	 endif
	endfor
	return,nfiles
end
