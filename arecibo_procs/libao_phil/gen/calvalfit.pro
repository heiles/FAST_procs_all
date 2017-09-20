;+
;NAME:
;calvalfit - fit calvalues to a freq range
;
;SYNTAX:
;   istat=calvalfit(f1,f2,npnts,calData,coefAr,fitOrder=fitOrder,$
;					,hybrid=hybrid,swappol=swappol,alfaBmNum=alfaBmNum)
;
;ARGS:
;    f1:  float  Mhz. first frequency
;    f2:  float  Mhz. last frequency
; npnts:   long  number of points to return with f1,f2 being first
;                last freq values
;calData{}:      calinfo input via calinpdata
;KEYWORDS:
;  fitOrder: int order for fit. Default is linear
;    hybrid:    if keyword set, then average the polA,polb values 
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
;  coefAr[ncoef,npol]: float linear fit coef. c0 + c1*freq
;                If this is alfa then the calV is [ncoef,2,7] unless 
;                alfaBmNum is supplied 
;
;DESCRIPTION:
;   Compute a linear fit to the cal data between f1 and f2
; The calData should have already been read in with calInpData. 
;The data is returned in an array of (ncoef,2)
; the fit is calVal= calval[0,*] + calval[1,*]*freqMhz
;
;	It is ok for f1 to be  gt f2..
;
;   The normal way to get cal values is via mascalval()
;They call this routine.
;
;SEE ALSO:corhcalval, calget, calinpdata.
;-
;history:
;25jun09 - wrote
;
function calvalfit,f1,f2,calData,coefAr,fitOrder=fitOrder,$
			hybrid=hybrid,swappol=swappol,alfaBmNum=alfaBmNum
;
;   on_error,1
;
;
	f1L=f1
	f2L=f2
	if f1 gt f2 then begin
		f1L=f2
		f2L=f1
	endif
    useAlfa=calData.rcvnum eq 17
	useAlfaBmNum=0
	ncoef=2
	npol=2
	deg=1
	if n_elements(fitOrder) eq 1 then deg=fitOrder 
	if (n_elements(alfaBmNum) gt 0) and useAlfa then begin
		useAlfaBmNum=1
		if (alfaBmNum lt 0) or (alfaBmNum gt 6) then begin
			print,"calval: alfaBmNum must be 0 to 6"
			return,-2
		endif
	endif

    gotit=0
    eps=1e-4
   	coefAr=(useAlfa and (not useAlfaBmNum))?fltarr(ncoef,npol,7)$
 										   :fltarr(ncoef,npol)
    if (calData.numFreq eq 1) then begin
		retstat=0
       	coefAr[0,0]=calData.calA[0]
       	coefAr[0,1]=calData.calB[0]
        if ((abs(calData.freq[0]- f1) lt eps) and $
               (abs(calData.freq[0]- f2) lt eps)) then retstat=1
        goto,done
    endif
;
;   find all cal values not zero
;
	igdA=where(calData.calA[*,0] ne 0,ngdA)
	igdB=where(calData.calB[*,0] ne 0,ngdB)
	if (ngdA eq 0) or (ngdB eq 0) then return,-1 
	minCalFrq=min(calData.freq[igdA],max=maxCalFrq)
;
; find the good cal values between f1L and f2L
; add one extra point on each end if possible
;
;  pola
;   throw out all calFreq lt f1L 
;
	ii=where(caldata.freq[igdA] ge f1L,cnt)
	if cnt gt 0 then  begin
		ii1a=(ii[0] gt 0)?ii[0]-1:ii[0] ; add one more point on left
	endif else begin
		ii1a=ngdA-1
	endelse
;
;   throw out all calFreq gt f2l

	ii=where(caldata.freq[igdA] gt f2L,cnt)
	if cnt gt 0 then  begin
		ii2a=(ii[0] lt (ngdA-1))?ii[0]+1:ii[0] ; add one more point on left
	endif else begin
		ii2a=ngda-1
	endelse
;
;   polB
;   throw out all calFreq lt f1L 
    ii=where(caldata.freq[igdB] ge f1L,cnt)
    if cnt gt 0 then  begin
        ii1B=(ii[0] gt 0)?ii[0]-1:ii[0] ; add one more point on left
    endif else begin
        ii1B=ngdB-1
    endelse
;
;   throw out all calFreq gt f2l polB

    ii=where(caldata.freq[igdB] gt f2L,cnt)
    if cnt gt 0 then  begin
        ii2B=(ii[0] lt (ngdB-1))?ii[0]+1:ii[0] ; add one more point on left
    endif else begin
        ii2B=ngdB-1
    endelse
;
;	fit to min,max
;
	if (not useAlfa) then begin
		if (ii1a ne ii2a) then begin
			coefAr[*,0]=poly_fit(calData.freq[igdA[ii1a:ii2a]],$
                                 calData.calA[igdA[ii1a:ii2a]],deg)
		endif else begin
			coefAr[0,0]=calData.calA[igdA[ii1a:ii1a]]
		endelse
		if (ii1b ne ii2b) then begin
			coefAr[*,1]=poly_fit(calData.freq[igdB[ii1b:ii2b]],$
                                 calData.calB[igdB[ii1b:ii2b]],deg)
		endif else begin
			coefAr[0,1]=calData.calB[igdB[ii1b:ii1b]]
		endelse
	endif else begin
		if (useAlfaBmNum) then begin
			ii=alfaBmNum
			if (ii1a ne ii2a) then begin
				coefAr[*,0]=poly_fit(calData.freq[igdA[ii1a:ii2a]],$
                                 calData.calA[igdA[ii1a:ii2a],ii],deg)
			endif else begin
				coefAr[0,0]=calData.calA[igdA[ii1a:ii1a],ii]
			endelse
			if (ii1b ne ii2b) then begin
				coefAr[*,1]=poly_fit(calData.freq[igdB[ii1b:ii2b]],$
                                calData.calB[igdB[ii1b:ii2b],ii],deg)
			endif else begin
				coefAr[0,1]=calData.calB[igdB[ii1b:ii1b],ii]
			endelse
		endif else begin
			for i=0,6 do  begin
		  		if (ii1a ne ii2a) then begin
                	coefAr[*,0,i]=poly_fit(calData.freq[igdA[ii1a:ii2a]],$
                                 calData.calA[igdA[ii1a:ii2a],i],deg)
            	endif else begin
                  coefAr[0,0,i]=calData.calA[igdA[ii1a:ii1a],i]
            	endelse
            	if (ii1b ne ii2b) then begin
                	coefAr[*,1,i]=poly_fit(calData.freq[igdB[ii1b:ii2b]],$
                                calData.calB[igdB[ii1b:ii2b],i],deg)
            	endif else begin
                	coefAr[0,1]=calData.calB[igdB[ii1b:ii1b],i]
            	endelse
		  	endfor
		endelse
	endelse
;
;	if any freq fell off the edge, return 0 else 1
;
    retstat=((calData.freq[igdA[0]] le f1) and $
             (calData.freq[igdA[ngdA-1]] ge f2))?1:0
done:
;
;    if hybrid active, average polA, polB
;
    if keyword_set(swappol) then begin
		coefAr=[coefAr[*,1],coefAr[*,0]]
    endif
    if keyword_set(hybrid) and (retstat ge 0) then begin 
        coefAr[*,0]=(coefAr[*,0] + coefAr[*,1])*.5
        coefAr[*,1]=coefAr[*,0]
    endif

    return,retstat
end
