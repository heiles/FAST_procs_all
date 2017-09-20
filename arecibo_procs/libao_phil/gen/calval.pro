;+
;NAME:
;calval - return the cal value for a given freq.
;
;SYNTAX:
;   istat=calval(freqReq,calData,calV,hybrid=hybrid,swappol=swappol,$
;				 alfaBmNum=alfaBmNum)
;
;ARGS:
;    freqReq[n]:  float     frequency in Mhz for cal
;    calData:  {calData} already input via calInpData()
;KEYWORDS:
;     hybrid:    if keyword set, then average the polA,polb values 
;               together (used when linear receivers are converted to circular
;               by a hybrid after the dewar).
;    swappol:   if set then swap the polA, polb calvalues in the calV array
;               on return. This can be used to correct for the 
;               1320 hipass polarization cable switch or the use of 
;               one of the xfer switches.
; alfaBmNum:    0..6 If specified then only return alfa data for this 
;               beam. By default data for all 7 beams are returned.
;               If not alfa data, this is ignored
;
;RETURNS:
;      istat:  1 ok within range, 0 outside range used edge,-1 all zeros,
;                   -2 error
;    calV[2,n]:  float array of [2] floats holding interpolated cal values for
;                    polA and polB. If this is alfa then the calV is 
;                    dimensioned 2,7  for the 7 pixels.
;
;DESCRIPTION:
;   Interpolate the cal value to the requested frequency. The calData 
;should have already been read in with calInpData. If the requested
;frequency is outside the data range, return the cal values at the
;edge (no extrapolation is done). The data is returned in an array
;of two by n values.
;
;   The normal way to get cal values is via corhcalval() or calget().
;They call this routine.
;
;SEE ALSO:corhcalval, calget, calinpdata.
;-
;history:
;5jul00  - added hybrid keyword
;16may08 - add support for freqReq[N] and interpolation
;24jun09 - added alfabmnum
;
function calval,freqReq,calData,calV,hybrid=hybrid,swappol=swappol,$
				alfaBmNum=alfaBmNum
;
;   on_error,1
    useAlfa=calData.rcvnum eq 17
	useAlfaBmNum=0
	if (n_elements(alfaBmNum) gt 0) and useAlfa then begin
		useAlfaBmNum=1
		if (alfaBmNum lt 0) or (alfaBmNum gt 6) then begin
			print,"calval: alfaBmNum must be 0 to 6"
			return,-2
		endif
	endif
	nfreq=n_elements(freqReq)
	multiF=(nfreq gt 1)
    gotit=0
    eps=1e-4
	if multiF then begin
    	calV=(useAlfa and (not useAlfaBmNum))?fltarr(2,7,nfreq):fltarr(2,nfreq)
	endif else begin
    	calV=(useAlfa and (not useAlfaBmNum))?fltarr(2,7):fltarr(2)
	endelse
    if (calData.numFreq eq 1) then begin
		retstat=0
		if multiF then begin
        	calV[0,*]=calData.calA[0]
        	calV[1,*]=calData.calB[0]
            ii=where(abs(calData.freq[0]-freqReq) gt eps,cnt)
		    if cnt eq 0 then retstat=1
		endif else begin
        	calV[0]=calData.calA[0]
        	calV[1]=calData.calB[0]
            if  abs(calData.freq[0]-freqReq) lt eps then retstat=1
	    endelse
        goto,done
    endif
;
;   find all cal values not zero
;
	igdA=where(calData.calA[*,0] ne 0,ngdA)
	igdB=where(calData.calB[*,0] ne 0,ngdB)
	if (ngdA eq 0) or (ngdB eq 0) then return,-1 
	minFrqCA=min(calData.freq[igdA],max=maxFrqCA)
;
;	find requested freq outside the calval freq range.. we set to the
;   edges..
;
	minFrqCB=min(calData.freq[igdB],max=maxFrqCB)
	iiLowA=where(freqReq lt minFrqCA,cnt0A)
	iiLowB=where(freqReq lt minFrqCB,cnt0B)
	iiHiA =where(freqReq gt maxFrqCA,cnt1A)
	iiHiB =where(freqReq gt maxFrqCB,cnt1B)
;
;	interpolate the to the requested frequencies
;
	if (not useAlfa) then begin
		calV[0,*]=interpol(calData.calA[igdA],calData.freq[igdA],freqReq)
		calV[1,*]=interpol(calData.calB[igdB],calData.freq[igdB],freqReq)
;
;		any points outside the calvalue freq are set to the extrema cal val
;
		if (cnt0A gt 0) then calV[0,iiLowA]=calData.calA[igdA[0]]
		if (cnt0B gt 0) then calV[1,iiLowB]=calData.calB[igdB[0]]
		if (cnt1A gt 0) then calV[0,iiHiA]=calData.calA[igdA[ngdA-1]]
		if (cnt1B gt 0) then calV[1,iiHiB]=calData.calB[igdB[ngdB-1]]
	endif else begin
		if (useAlfaBmNum) then begin
			calV[0,*]=interpol(calData.calA[igdA,alfaBmNum],calData.freq[igdA],$
									freqReq)
			calV[1,*]=interpol(calData.calB[igdB,alfaBmNum],calData.freq[igdB],$
									freqReq)
			if (cnt0A gt 0) then calV[0,iiLowA]=calData.calA[igdA[0],alfaBmNum]
			if (cnt0B gt 0) then calV[1,iiLowB]=calData.calB[igdB[0],alfaBmNum]
			if (cnt1A gt 0) then calV[0,iiHiA ]=calData.calA[igdA[ngdA-1],$
													alfaBmNum]
			if (cnt1B gt 0) then calV[1,iiHiB ]=calData.calB[igdB[ngdB-1],$
													alfaBmNum]
		endif else begin
		  for i=0,6 do  begin
			calV[0,i,*]=interpol(calData.calA[igdA,i],calData.freq[igdA],$
									freqReq)
			calV[1,i,*]=interpol(calData.calB[igdB,i],calData.freq[igdB],$
									freqReq)
			if (cnt0A gt 0) then calV[0,iiLowA,i]=calData.calA[igdA[0],i]
			if (cnt0B gt 0) then calV[1,iiLowB,i]=calData.calB[igdB[0],i]
			if (cnt1A gt 0) then calV[0,iiHiA,i ]=calData.calA[igdA[ngdA-1],i]
			if (cnt1B gt 0) then calV[1,iiHiB,i ]=calData.calB[igdB[ngdB-1],i]
		  endfor
		endelse
	endelse

;
;	if any freq fell off the edge, return 0 else 1
;
    retstat=((cnt0A + cnt0B +cnt1A + cnt1B) gt 0)?0:1
done:
;
;    if hybrid active, average polA, polB
;
    if keyword_set(swappol) then begin
        calV=[calV[1,*],calV[0,*]]          ;swap pols
    endif
    if keyword_set(hybrid) and (retstat ge 0) then begin 
        calV[0,*]=(calV[0,*]+calV[1,*]) * .5
        calV[1,*]=calV[0,*]
    endif

    return,retstat
end
