;+
;NAME:
;masgetwcal - Inp Row, compute CalOn+calOff, calOn-calOff for winking cal
;SYNTAX: istat=masgetwcal(desc,bsum,bdif,toavg=toavg,bin=bin,row=row)
;ARGS:
;desc :  {}   from masopen()
;KEYWORDS:
;	row: long 	position to row before reading..`
;               count from 1. row=0 --> start current position
; toavg: int    number of calcycles to average. This must divide into the
;               number of calcycles in a row. If it is greater than the
;               number of calcycles in a row, then all of the calcyles in
;               a row will be averaged (eg.. toavg=999) will probably 
;               sum all of them.
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
;	Normally winking cal data is taken at a high data rate with
;multiple winking cal cycles  within 1 row of data. This routine will
;input a rows worth of winking cal data and compute Calon+calOff and
;calOn-caloff for each cal cycle in the row. When computing the  cal 
;sum and difference ignore the first and last spectra of each 
;calon or caloff. 
;   If there are 10 specta with calOff followed by 10 spectra with calOff
;then sum spectra 2-9 of each before computing the sum and difference.
;
;NOTES:
;1.	The output spectra are summed (not averaged) over ncalon-2 and ncaloff-2
;   spectra. The bdif data is scaled up by 2 so it will have the same
;   time duration as the bsum (since calon,caloff is 1/2 the time of 
;   calOn + calOff).
;
;2. For now, the routine wants an integral number of calCycles in
;   a row... 
;
;3. The accumulation of the calOn, caloff cycles reduces the number of
;   spectra in the output data structures. eg. suppose you have
;   2048 channel, stokes data with 500 spectral samples per row, and
;   20 spectral time samples in the cal cycle (10 caloff , 10 calon). Then
;   the dimensions of the input, output data are:
;
;   bin.d[2048,4,500]  .. input
;   bsum.d[2048,4,25]  .. 500/20
;   bdif.d[2048,4,25]  .. 500/(20)
;-
;
function masgetwcal,desc,bsum,bdif,bin=bin ,row=row,toavg=toavg

;
	if (desc.hsp1.calctl ne 2 ) then begin
		print,'Data does now have winking cal enabled...'
		return,-2
	endif
	navg=keyword_set(toavg)?toavg:1
	if navg eq 0 then navg=1 		;; this is no avg.
	ncalon =desc.hsp1.calon
	ncaloff=desc.hsp1.caloff
	calCycleLen=ncalon+ncaloff
	if (ncalon ne ncaloff) then begin
		print,'number calon != number caloff'
		return,-1
	endif
;
; 	read the data
;
	istat=masget(desc,bin,row=row)
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
	iiu=lindgen(ncalon-2)+1        ; skip first and last of transition..
	if ncycleInRow lt 1 then begin
		print,'record does not have at least 1 cal cycle'
		return,-3
	endif
;
; 	see if we are synced with calon or cal off
;
	calstat=bin.st[0:calcycleLen-1].calon
	val1=total(calstat[iiu])
    val2=total(calstat[iiu+ncalon])
;
;	start with cal off
;
	if (((calstat[1] eq 0) and ((val1 ne 0) or (val2 ne (ncalon-2)))) or $
	    ((calstat[1] eq 1) and ((val2 ne 0) or (val1 ne (ncalon-2))))) then begin
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
	bsum={  h:bin.h,$
	     nchan:nchan,$	
	     npol :npol,$	
	     ndump:ncycleOut,$	
		 pol  :bin.pol,$
;                 take first of each cal cycle
	     st   :bin.st[indgen(ncycleOut)*cycleOutStep*calCycleLen],$
		 d    :fltarr(bin.nchan,npol,ncycleOut)}
	bdif=bsum
;
;	get indices for calon ,caloff
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
;	note .. multiply cal by 2 since we return calOn + caloff.
;
	calscl=2.			; since we calon+caloff twice as long as calon-caloff
;
;   if no averaging..
;
	if navg eq 1 then begin
		bsum.d=total($
			(reform(bin.d,nchan,npol,calCycleLen,ncycleInRow))[*,*,iiall,*],3)
	    bdif.d=(reform(total((reform(bin.d,nchan,npol,ncalon,2,ncycleInRow)$
                             )[*,*,iiu,indon,*],3),$
			           nchan,npol,ncycleInRow)  - $
	            reform(total((reform(bin.d,nchan,npol,ncalon,2,ncycleInRow)$
                             )[*,*,iiu,indoff,*],3),$
                       nchan,npol,ncycleInRow))*calscl
	endif else begin
;
;		average the sum, difference cycles..
;
		ilast=(ncycleOut eq 1)?3:4
		bsum.d=total(total($
			(reform(bin.d,nchan,npol,calCycleLen,navg,ncycleOut)$
            )[*,*,iiall,*,*],3),ilast)
	    bdif.d=(reform(total(total($
					(reform(bin.d,nchan,npol,ncalon,2,navg,ncycleOut)$
                    )[*,*,iiu,indon ,*,*],3),4),nchan,npol,ncycleOut)  - $
	            reform(total(total($
				    (reform(bin.d,nchan,npol,ncalon,2,navg,ncycleOut)$
                    )[*,*,iiu,indoff,*,*],3),4),nchan,npol,ncycleOut))*calscl
	endelse
;
; sum the overflow errors for all recs of each accum
;
	if navg eq 1 then begin
		bsum.st.adcoverflow=total($
			(reform(bin.st.adcoverflow,calCycleLen,ncycleOut))[iiall,*],1)
		bsum.st.pfboverflow=total($
			(reform(bin.st.pfboverflow,calCycleLen,ncycleOut))[iiall,*],1)
	endif else begin
		bsum.st.adcoverflow=total(total($
				(reform(bin.st.adcoverflow,calCycleLen,navg,ncycleOut)$
                )[iiall,*,*],1),1)
		bsum.st.pfboverflow=total(total($
                (reform(bin.st.pfboverflow,calCycleLen,navg,ncycleOut)$
                )[iiall,*,*],1),1)
	endelse
	bdif.st.adcoverflow=bsum.st.adcoverflow
	bdif.st.pfboverflow=bsum.st.pfboverflow
	return,ncycleOut
end
