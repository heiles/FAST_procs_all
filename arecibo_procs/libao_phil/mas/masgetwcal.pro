;+
;NAME:
;masgetwcal - Inp Row, compute CalOn,calOff for winking cal
;SYNTAX: istat=masgetwcal(desc,bon,boff,toavg=toavg,bin=bin,row=row,$
;				nrows=nrows,lastonly=lastonly)
;ARGS:
;desc :  {}   from masopen()
;KEYWORDS:
;   row: long   position to row before reading..`
;               count from 1. row=0 --> start current position
; toavg: int    number of calcycles to average. This must divide into the
;               number of calcycles in a row. If it is greater than the
;               number of calcycles in a row, then all of the calcyles in
;               a row will be averaged (eg.. toavg=999) will probably 
;               sum all of them.
; nrows: int   number of rows to return. def=1 
;			   If more rows are requested than in file, then the only
;              the number of rows left is returned. No error is reported.
;lastonly: int if set then only drop the last sample of each group of 
;              calons, or cal offs. This works if the cal phase was set to
;              50% (where the transition occurred).
;RETURNS:
; istat:         n number of time samples in structure
;               -2 winking cal not enabled..
;               -3 record does not have at least 1 cal cycle
;               -4 spectra in row not a multiple of calCyleLen
;                  or requested toavg does not divide into
;                  cals cycles in row.
;               -5 calon,caloff out of sync.. not 10,10...
;   
; bsum[n]:  {}     sum calOn +calOff  for each cal cycle
; bdif[n]:  {}     sum (calOn - calOff) for each cal cycle
;bin[n]  :  {}     if supplied then also return the input data.
;
;DESCRIPTION:
;   Normally winking cal data is taken at a high data rate with
;multiple winking cal cycles  within 1 row of data. This routine will
;input a rows worth of winking cal data and compute Tsys + Calon,Tsys +calOff 
;When computing the  cal,  ignore the first and last spectra of each 
;calon or caloff. 
;   If there are 10 specta with calOff followed by 10 spectra with calOff
;then sum spectra 2-9 of each before computing the calon,caloff
;
;NOTES:
;1. The output spectra are summed (not averaged) over ncalon-2 and ncaloff-2
;   spectra. 
;2. If blanking has been enabled, then the spectra with fewer than normal
;   counts will be scaled up normalSum/blankedSum. The values
;
;3. For now, the routine wants an integral number of calCycles in
;   a row... 
;4. The .st status portion of the structure will have the adcOverflow,pfbOverflow
;   and the fftaccum adjusted for the number of integrations (summed). 
;5. the header entry exposure will be increased to reflect the 
;   accumulation time in the returned spectra. eg
;   suppose:
;   - 10  millisecond dumps
;   - 50  millisecond cal on, cal off
;   - average 10 cal cycles 
;   - the exposure time goes from .01 secs to:
;     10ms*3calon*10avg=300 millisecs
;     
;
;5. The accumulation of the calOn, caloff cycles reduces the number of
;   spectra in the output data structures. eg. suppose you have
;   2048 channel, stokes data with 500 spectral samples per row, and
;   20 spectral time samples in the cal cycle (10 caloff , 10 calon). Then
;   the dimensions of the input, output data are:
;
;   bin.d[2048,4,500]  .. input
;   bsum.d[2048,4,25]  .. 500/20
;   bdif.d[2048,4,25]  .. 500/(20)
;
;6. If blanking is enabled and bin=bin returns the input structure
;  note!! the blanked spectra have already been scaled to the average values
;  (it is not the raw input buffer).
;-
;
function masgetwcal,desc,bon,boff,bin=bin ,row=row,toavg=toavg,nrows=nrows,$
			lastonly=lastonly

;
    blankEna=(desc.hsp1.blanksel ne 15) || (desc.hsp1.ovfadc_thr lt 65535)
    if (desc.hsp1.calctl ne 2 ) then begin
        print,'Data does now have winking cal enabled...'
        return,-2
    endif
	dropLast=keyword_set(lastonly)
    navg=keyword_set(toavg)?toavg:1
    if navg eq 0 then navg=1        ;; this is no avg.
    ncalon =desc.hsp1.calon
    ncaloff=desc.hsp1.caloff
    calCycleLen=ncalon+ncaloff
    if (ncalon ne ncaloff) then begin
        print,'number calon != number caloff'
        return,-1
    endif
	rowL=(n_elements(row) gt 0)?row:0L
	nrowsL=(n_elements(nrows) gt 1 )?nrows:1
;    curRowtoRead counts from 0 ..
	curRowToRead=(rowL eq 0)?desc.currow:rowL-1
	rowsLeftToRead=desc.totrows-curRowToRead
	if nrows gt rowsLeftToRead then begin
		nrowsL=rowsLeftToRead
	endif
;
;   read the data
;
	blankCorDone=1
	for irow=0,nrows-1 do begin
    	istat=masget(desc,bin,row=rowL,/float,/blankcor)
		rowL=0L
    	if istat le 0 then begin
        	if istat eq 0 then begin
           		print,"hit eof"
            	return,0
        	endif
        	print,'masget returned status:',istat
        	return,-1
   		 endif
;
;  make sure we have integral number of cal cycles in the
;  spectra in row.
;
    	ncycleInRow=bin.ndump / calCycleLen
    	if (bin.ndump ne (ncycleInRow*calCycleLen))  then begin
        	print,"nspectra in row:",bin.ndump,$
    	" is not a multiple of calCycleLen:",calCycleLen
        	return,-4
    	endif
;
;   if navg.. make sure multiple of cycles in row
;
    	if navg gt 1 then begin
        	if (navg gt ncycleInRow) then navg=ncycleInRow
        	if (ncycleInRow mod navg) ne 0 then begin
            print,"CalCycles in row:",ncycleInRow,$
                " not a multiple requested avgs:",navg
                return,-4
        	endif
    	endif
;
	    if (droplast) then begin
    		iiu=lindgen(ncalon-1)          ; skip last of transition..
		endif else begin
    		iiu=lindgen(ncalon-2)+1        ; skip first and last of transition..
		endelse
    	if ncycleInRow lt 1 then begin
        	print,'record does not have at least 1 cal cycle'
        	return,-3
    	endif
;
;   see if we are synced with calon or cal off
;
    	calstat=bin.st[0:calcycleLen-1].calon
    	val1=total(calstat[iiu])
    	val2=total(calstat[iiu+ncalon])
;
;   start with cal off
;
		onsum=(dropLast)?ncalon-1:ncalon-2
    	if (((calstat[1] eq 0) and ((val1 ne 0) or (val2 ne (onsum)))) or $
          ((calstat[1] eq 1) and ((val2 ne 0) or (val1 ne (onsum))))) $
				then begin
            print,'calstat calon,caloff out of sync (val1,2):',val1,val2
            return,-5
    	endif
;
;    allocate the data, cal
;
    	nchan=bin.nchan
   	 	npol =bin.npol
    	ncycleOut=ncycleInRow/navg
    	cycleOutStep=ncycleInRow/ncycleOut  ; step between start each avg.
		if irow eq 0 then begin
		  if (nrows eq 1) then begin
    		bon={  h:bin.h,$
        	nchan:nchan,$  
         	npol :npol,$   
            ndump:ncycleOut,$  
           blankCorDone:blankCordone,$
;                 take first of each cal cycle
           st   :bin.st[indgen(ncycleOut)*cycleOutStep*calCycleLen],$
	    	accum: 0D,$
            d    :fltarr(bin.nchan,npol,ncycleOut)}
    		boff=bon
		  endif else begin
    		a={  h:bin.h,$
        	nchan:nchan,$  
         	npol :npol,$   
            ndump:ncycleOut,$  
            blankCordone:blankCordone,$
;                 take first of each cal cycle
           st   :bin.st[indgen(ncycleOut)*cycleOutStep*calCycleLen],$
	       accum: 0D,$
           d    :fltarr(bin.nchan,npol,ncycleOut)}
		   bon=replicate(a,nrows)
		   boff=bon
		  endelse
		endif
		if (irow gt 0) then begin
			bon[irow].h =bin.h 
			boff[irow].h=bin.h 
			bon[irow].st=bin.st[indgen(ncycleOut)*cycleOutStep*calCycleLen]
			boff[irow].st=bon[irow].st
		endif
;
;   get indices for calon ,caloff
;
    	if (calstat[1] eq 0) then begin
        	iion=iiu+ncalon
        	iioff=iiu
        	indon=1
        	indoff=0
    	endif else begin
        	iioff=iiu+ncalon
        	iion =iiu
        	indon=0
        	indoff=1
    	endelse
    	iiall=[iioff,iion]; ind for on and off.. skipping 1st,last of each trans
;
;
;   if blanking, scale bin for the fft with fewer accums to have
;   the same scale as those with full accum.
;       .. now done in masget
;;    	if  blankEna then begin
;;        	ii=where(bin.st.fftaccum ne desc.hsp1.fftaccum,cnt)
;;        	for i=0,cnt-1 do begin
;;            	j=ii[i]
;;            	bin.d[*,*,j]*=(desc.hsp1.fftaccum*1.)/bin.st[j].fftaccum
;;        	endfor
;;    	endif
        
;   if no averaging..
;
    	if navg eq 1 then begin
        	bon[irow].d=reform(total((reform(bin.d,nchan,npol,ncalon,2,$
					ncycleInRow))[*,*,iiu,indon,*],3),nchan,npol,ncycleInRow) 
        	boff[irow].d=reform(total((reform(bin.d,nchan,npol,ncalon,2,$
					ncycleInRow))[*,*,iiu,indoff,*],3),nchan,npol,ncycleInRow) 

    	endif else begin
;
;       average the on,off, cycles..
;
;        	ilast=(ncycleOut eq 1)?3:4
        	bon[irow].d=reform(total(total($
                    (reform(bin.d,nchan,npol,ncalon,2,navg,ncycleOut)$
                    )[*,*,iiu,indon ,*,*],3),4),nchan,npol,ncycleOut)
        	boff[irow].d=reform(total(total($
                    (reform(bin.d,nchan,npol,ncalon,2,navg,ncycleOut)$
                    )[*,*,iiu,indoff ,*,*],3),4),nchan,npol,ncycleOut)

    	endelse
;
; sum the overflow errors for all recs of each accum
;
    	if navg eq 1 then begin
        	bon[irow].st.adcoverflow=total($
            (reform(bin.st.adcoverflow,calCycleLen,ncycleOut))[iiall,*],1)
        	bon[irow].st.pfboverflow=total($
            (reform(bin.st.pfboverflow,calCycleLen,ncycleOut))[iiall,*],1)
        	bon[irow].st.fftaccum=total($
            (reform(bin.st.fftaccum,calCycleLen,ncycleOut))[iiall,*],1)
    	endif else begin
        	bon[irow].st.adcoverflow=total(total($
                (reform(bin.st.adcoverflow,calCycleLen,navg,ncycleOut)$
                )[iiall,*,*],1),1)
        	bon[irow].st.pfboverflow=total(total($
                (reform(bin.st.pfboverflow,calCycleLen,navg,ncycleOut)$
                )[iiall,*,*],1),1)
        	bon[irow].st.fftaccum=total(total($
                (reform(bin.st.fftaccum,calCycleLen,navg,ncycleOut)$
                )[iiall,*,*],1),1)
    	endelse
		bon[irow].h.exposure=bin.h.exposure*(ncalon-2)*navg
		boff[irow].h.exposure=bon[irow].h.exposure
    	boff[irow].st.adcoverflow=bon[irow].st.adcoverflow
    	boff[irow].st.pfboverflow=bon[irow].st.pfboverflow
    	boff[irow].st.fftaccum   =bon[irow].st.fftaccum
	endfor
   	return,ncycleOut
end
