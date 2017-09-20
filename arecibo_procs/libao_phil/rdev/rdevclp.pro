;+
;NAME:
;rdevclp - decode rdev CLP data
;SYNTAX: n=rdevclp(desc,avgspc,nipps=nipps,baudUsec=baudUsec,$
;                     codeLenUsec=codeLenUsec,fftlen=fftlen,$
;                     txSmpSkip=txSmpSkip,heights=heights,$
;                     posIpp=posIpp,clpi=clpi,verb=verb
;ARGS:
; desc: {} 	from rdevopen.
;KEYWORDS:
;	nipps: long	number of ipps to decode. def=1
;baudUsec: float       baud in usecs. Def=1.
;codeLenUsec:float    code len in usec. def=440.
;fftlen     :long     length fft to do (def:16384)
;txSmpSkip  :long     samples to skip at start of tx samples
;heights[2] :long     1st hght,nhghts to process
;					  if dim=1 then first height(cnt 0) , nhghts=1
;                     default=[0,(datasmpIpp-(fftlen-1))/(dataSamples1baud)
;posIpp     :long     position to this ipp before start. cnt from 0
;clpI       :{}       structure returning info on the computation.
;verb       :int      if set then print start of each ipp as we go
;RETURNS:
;nippsaccum: long     number of ipps we accumulated
;avgSpc[fftlen,nhghts]: float height spc avged over nipps
;                             dcchan=fftlen/2 (count from 0) 
;clpI{}    :          struct holding info on clp data
;DESCRIPTION:
;	Decode then compute spectra for the requested heights.
;The height spacing is set to the baudLen. 
;	The routine returns the average of the ipps. 
;
;-
;
function rdevclp,desc,spcBuf,nipps=nipps,baudUsec=baudUsec,$
                      codeLenUsec=codeLenUsec,fftlen=fftlen,$
				      txSmpSkip=txSmpSkip,heights=heights,$
					  posIpp=posIpp,verb=verb,clpI=clpI
;
	fftlen  =(n_elements(fftlen) eq 0)?16384L:long(fftlen)
	baudUsec=(n_elements(baudUsec) eq 0)?1.:baudUsec
	codeLenUsec=(n_elements(codeLenUsec) eq 0)?440.:codeLenUsec
	bwMhz=rdevbw(desc)
	if bwMhz lt 0 then return, -1
	 smpTmUsec=1./bwMhz
	 smpBaud=long((baudUsec*bwMhz) + .5)
	 smpCode=long((codeLenUsec*bwMhz) + .5)
	 hghtStepSmp=smpBaud
	 txSmpSkip=(n_elements(txSmpSkip) eq 0)?0:txSmpSkip
	 case n_elements(heights) of
		2: begin
			hght1=heights[0]
			nhghts=heghts[1]
		   end
		1: begin
			hght1=heights
			nhghts=1
			end
		else:begin
			hght1=0
			nhghts=(desc.dsmpipp - (smpCode-1L))/hghtStepSmp 
		end
	endcase
;
;   fix up some pointers
;
	itx0=txSmpSkip
	itx1=(itx0 + smpCode - 1L) < (fftlen+itx0-1)
;
	id0=hght1		; start height

	codeCmp=complexarr(smpCode)
	spcBuf =fltarr(fftlen,nhghts)
	fftIn  =complexarr(fftlen)
	posippL=(n_elements(posIpp) eq 0)?-1:posIpp
	nippAccum=0L
	clpI={ baudUsec : baudUsec,$
		   codeLenUsec: codeLenUsec,$  
		   bwMhz    : bwMhz,$
		   fftlen   : fftlen,$
		   txSmpSkip: txSmpSkip,$
		   hght1    :hght1  ,$ from data window
		   nhghts   :nhghts ,$
	   hghtStepUsec :hghtStepSmp*smpTmUsec,$
	  dataWinOffUsec:desc.doffSmp*smpTmUsec,$
		   ippAccum : 0L$
		}
	for ipp=0,nipps-1 do begin
		if keyword_set(verb) then print,ipp
		if (rdevgetipp(desc,d,tx,nipps=1,/cmplx,posipp=posippL) ne 1) then begin
			print,'get ipp returned error on ipp',ipp,' Hit eof??'
			break;
		endif
		posIppL=-1
       	codeCmp=conj(tx[itx0:itx1]) &$
		for ih=0L,nhghts-1 do begin  &$
        	i1=id0 + ih*hghtStepSmp &$
        	i2=i1+smpCode-1 &$
			fftIn[0:smpCode-1]=codeCmp*d[i1:i2]
         	spcbuf[*,ih]+=abs(fftw(fftIn))^2 &$
    	endfor 
		nippAccum++
	endfor
	clpI.ippAccum=nippAccum
	if nippAccum eq 0 then begin
		spcBuf=''
		return,0
	endif
	spcBuf=shift(spcBuf,fftlen/2,0)/nippAccum
	return,nippAccum
end
