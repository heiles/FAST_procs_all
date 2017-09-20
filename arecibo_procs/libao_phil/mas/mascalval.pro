;+
;NAME:
;mascalval - return the pol A/B  cal values/info for a mas struct
;
;SYNTAX: stat=mascalval(hdr,calI,date=date,edgeFract=edgeFract,
;                       mask=mask)
;						
;
;ARGS:
;     hdr: {b.hdr}    header for spectra input via masget
;
;KEYWORDS:
; date[2]: intarray [year,dayNum] if provided, then compute the calvalues
;                      that were valid at this epoch.
;edgeFract[2]:float  fraction of the band to discard at the edges.
;					 edgeFract= single ..  fraction to discard on both sides.
;                    edgeFract=[2]     ..  edge[0] -fraction on lowFreqedge
;                                          edge[1] -fraction on hiFreqedge.
;                    Default value=.06
;                           Note that hi/low is in frequency (even if the
;                           band was flipped).
;mask[nchan]:  int if supplied then mask saying which frequencies
;                   to use when doing the average. 
;                   1=use, 0= don't use this freq channel.
;                   nchan must match channels in spectra.
;                   The freq order of freqMask is the same as the spectra.
;                   If the spectra are flipped (hdr.cdelt1<0) then
;                  freqMask[0] is the highest freq,instead of the lowest.
;                   The same mask is used for polA and polB
;                    
;RETURNS:
; calI:{}         structure containing:
;                 calI.calVal[2]    :polA, b cal value averaged over the band
;                 calI.numPol     1 :if only stokes I data returned. The
;                                    cal values will be averaged and returned in
;                                    both calval[0] and calVal[1]. 
;                 calI.exposure:    zeroed. filled in by mascalonoff
;                 calI.cntsToK[2].. zeroed. filled in by mascalonoff
;                 calI.npnts     4000: points used for averages
;                 calI.freqRange[2]: freq Mhz used to compute the average
;                 calI.flipped    : 1 if freqRange[0]>freqRange[1]
;                 calI.edgeFract[2]: fraction to drop at each edge when
;                                   computing spectra. Ignored if usemask
;                                   freq order same as spectra
;                 calI.usemask    : if 1 then mask was supplied to generate
;                                   indused[]
;                 calI.indUsed[calI.npnts] indices into freq array
;                                   that were used for the averages.
;      stat: int   .. -1 error, 0 got the values ok.
;
;DESCRIPTION:
;   Return the cal values in degrees K for the requested spectra. The 
;calvalues will be averaged over the frequency band excluding 
;edgefract fraction on each edge. If mask= is included, then 
;only the channels with mask[ichan]=1 will be used in the average.
;By default the date in the header is used to determine
;which cal values should be used. You can override this with the date
;keyword.
;
;	The data is returned in the calI structure. 
;
;The following is returned with calI.freqInd[0] < calI.freqInd[1] so 
;you can say mean(b.d[calI.freqInd[0]:calI.freqInd[1]). This will 
;make freqRange[0]>freqRange[1] if flipped is set. Returned values
;with this order are:
;
;calI.freqInd[]
;calI.freqRange[]  .. if flipped set then freqRange[0] > freqRange[1]
;calI.edgeFract[]  .. These will now correspond to freqInd
;                     It will be the reverse of the input if flipped is 1.
;calI.flipped         1 if freqRange[0]>freqRange[1]
;calI.indUsed[nchanUsed] index into freq for channels used.
;
;
;EXAMPLE:
;
;NOTE:
;   Some cals have measurements at a limited range of frequencies (in some
;cases only 1 frequency). If the frequency is outside the range of measured
;frequencies, then the average is performed over the available range.
;
;SEE ALSO:
;mascalscl, gen/calget gen/calval.pro, gen/calinpdata.pro
;-
;history:
; 24jun09 - stole from corhcalval
; 10nov09 - switched to return calI and the average value.
;
function mascalval,hdr,calI,date=date,edgefract=edgefract,mask=mask
;
; return the cal value for this board
; retstat: -1 error, ge 0 ok
;
	edgeFractDef=.06
	edgefractL=[edgeFractDef,edgeFractDef]
  	nchan=fix(hdr[0].crpix1 - 1 + .5)*2
	numPol=hdr.num_pols < 2
	flipped=hdr[0].cdelt1 lt 0
	if n_elements(date) eq 0 then begin
;		warning this is utc.. so be careful on date cals change.
        year  =long(strmid(hdr.datexxobs,0,4))
        mon   =long(strmid(hdr.datexxobs,5,2))
        day   =long(strmid(hdr.datexxobs,8,2))
        date=[year,dmtodayno(day,mon,year)]
	endif
	useMask=n_elements(mask) gt 0 
	if useMask then begin
		if n_elements(mask) ne nchan then begin 
			print,"mascalval:mask number of channels in correct"
			return,-1
		endif
	endif else begin
		case n_elements(edgefract) of
			1: edgefractL=[edgeFract,edgeFract]
        	0: edgefractL=[edgeFractDef,edgeFractDef]
			else: edgeFractL=edgeFract[0:1]   
		endcase
	endelse
	calnum= (hdr.caltype eq 'hcorcal')?1:$ 
	        (hdr.caltype eq 'lcorcal')?0:$
	        (hdr.caltype eq 'hcal'   )?5:$ 
	        (hdr.caltype eq 'lcal'   )?4:$
	        (hdr.caltype eq 'hxcal'  )?3:$
	        (hdr.caltype eq 'lxcal'  )?2:$
	        (hdr.caltype eq 'h90cal' )?7:$
	        (hdr.caltype eq 'l90cal' )?6:-1
	if calnum eq -1 then begin
		print,"Unknown caltype in header:",hdr.caltype
		return,-1
	endif
;   if hybrid in then average pola, polB cals.
	hybrid =(((hdr.rfnum eq 5)  and (hdr.lbwhyb ne 0)) or  $
			((hdr.if1sel eq 4) and (hdr.hybrid ne 0))) and $
			(hdr.rfnum ne 17)
	if hdr.rfnum eq 100 then begin
		hybrid=0
		calnum=5
	endif
;	compute 
;
	freq=masfreq(hdr[0]) 
	alfaBmNum=hdr.beam
    istat=calget1(hdr.rfnum,calnum,freq,calval,hybrid=hybrid,date=date,$
			alfabmnum=alfaBmNum)
;
	if useMask then begin
		iiused=where(mask ne 0,numfreqused)
		if numfreqused lt 1 then begin 
			print,"mascalval: mask includes no channels"
			return,-1
		endif
	endif else begin
;		edgefractl is always in increasing frequency
		if (flipped) then begin
			i2=nchan - 1 - fix(edgefractl[0]*nchan + .5)
			i1=fix(edgefractl[1]*nchan + .5)
			edgeFractL=[edgeFractL[1],edgeFractL[0]]
		endif else begin
			i1=fix(edgefractl[0]*nchan + .5)
			i2=nchan - 1 - fix(edgefractl[1]*nchan + .5)
	
		endelse
		numFreqUsed=i2-i1+1
		iiused=lindgen(numfreqused) + i1
	endelse
;
	calavg=total(calval[*,iiused],2)/numfreqused
	if numpol eq 1 then begin
		calavg[0]=(calavg[0]+calavg[1])*.5
		calavg[1]=calavg[0]
	endif
	
 	calI={ calVal   : calAvg,$;  averaged cal values
		   numPol   : numpol,$;   
		  exposure  : 0.    ,$; filled in by mascalonoff
		   cntsToK  : fltarr(2),$; filled in by mascalonoff 
		  npnts     : numFreqUsed,$ ; points used to compute average cal.
		  flipped   : flipped,$ ; 1 if band is flipped
		  edgeFract : edgeFractL,$  ; now same order as spectra
		  usemask   : useMask,$  ; 1--> used freq mask
;                                     0--> used edgeFract
		  indUsed   : iiused}       ; indices used to compute average

	return,istat
end
