;+
;NAME: 
;pdevsimtmd - simulate time domain sampling.
;SYNTAX: istat=pdevsimtmd(npnts,rmsInpV,dec,hr_shift,nbits,retI,$
;                 ifsmp=ifsmp,linelossdb=linelossdb,filtertype=filtertype,$
;				  presmo=presmo,ysmo=ysmo
;ARGS:
; npnts: long    number of complex points to use
;                power of 2 is quicker since fft for filtering
; rmsInpV: float rms input voltage. .787 is peak too peak max 
;                - should be the measured input rms voltage.
;                  (at scope before linelossdb).
;    dec : int   decimation 1.. 1024
; hr_shift:int   upshift before taking nbits
; nbits    :int  bits to keep, 4,8 
;filtertype: string filter type to use. Values are:
;               rect,hamming,hanning,blackman,bartlett 
;	 			The default type is hanning
;KEYWORDS:
; ifsmp:  if true then then if sampling. only i dig.
;         for power this just kicks things down by 2
; dlpffn: string  name of file holding lpf data (leave off the .1,.2..3,.4)
; lineLossDb: float  loss in line from rmsInpV measure to a/d
;                 (in case you use the scope measurement in control room)
;		           measured value about 1.2 db (cable and filter)
; presmo: long   presmooth the noise data by this amount (boxcar).
;                this can HELP simulate IF sampling.
;                eg: clock=160Mhz, IF BW=20Mhz. presmooth by 8.
;
;RETURNS:
; istat: int      0 ok, -1 error
; retI: {}         struct holding info
; ysmo[fftlen]    return double smoothed data.
;                 processing:
;                   1. random numbers scaled 
;                      to have 1sigma=rpsInpV
;DESCRIPTION:
;	Generate npnts gaussian random complex numbers. 
;   (note npnts should be a large power of 2: 2&18 or more) 
; - scale so that rmsInpV is  1 sigma. 
; - scale this so .787 V is -2048 to +2047
; - round to integer
; - create filter time series, filter type.
; - 0 extend to npnts, fft,x, cener about npnts/2
; - xform data, shift by npnts/2
; - multily data , filter
; - shift back by npnts/2
; - transform back to time domain. this is ysmo
; - scale  by shift, nbit factors
; - clip to upper 4 bits
; - compute statistics, return
;
; Note: if you are only interested in ysmo, the values for hr_shift are
;    not used (but should be reasonable)
;
; History
; 06dec13 - remove filter from struct. so we can pt
;           multiple runs of different decs into a single
;          retiAr[]
;-
function pdevsimtmd,npnts,rmsInpV,dec,hr_shift,nbits,retI,ifsmp=ifsmp,$
		lineLossdb=linelossDb,filterType=filterType,presmo=presmo,ysmo=ysmo
;
;   generate the complex data
;
	presmo=(n_elements(presmo) eq 0)?1:presmo
	if n_elements(ifsmp) eq 0 then ifsmp=0
	if n_elements(linelossdb) eq 0 then linelossdb=0.
	filtertype=(n_elements(filtertype) eq 0)? "hanning":filtertype
	; if IF sampling,we lose 1/2 the voltage (only 1 dig)
	ifsmpScl=(ifsmp)?.5:1.
	lineLoss=(n_elements(linelossdb) gt 0)?(10.^(linelossdb*.1)):1.
	lineLossScl=sqrt(1./lineloss)

	; from measurements, the output value is 3.5 times lower than expected
	; part of this was found in jeffs fpga code.
	; 2.0 looks better .. and 2.0 is just off by a bit .. which the code has
	sclExtra=1./3.5
	sclExtra=1./2.0
	sclExtra=1.
	rmsI={mean : complex(0.,0.),$
	       rms : complex(0.,.0)}
	if ((istat=pdevmklpf(filtertype,dec,filter)) ne 0 ) then begin
		print,"error ",istat,"  pdevmklpf() using filtertype:",filtertype
		return,-1
	endif
	nn=2L^nbits
	minNeg=(nbits eq 8)?-128:-8
	retI={$
		rmsInpV:rmsInpV,$
		lineLossDb:linelossdb,$
		 sclExtra : sclExtra,$
		   dec : dec,$
	       nbits: nbits,$
     hr_shift  : hr_shift,$
		filterGain:0.,$
;		filter : filter,$   ; we input
		statInp12:rmsI,$
		statInpB :rmsI,$
		statOut  :rmsI,$
		hinp12_y :lonarr(4096),$
		hinp12_x :lonarr(4096),$
		hout_y  :lonarr(nn),$
		hout_x  :lonarr(nn) $
	}

	pkToPk=.787
	seed1=systime(/seconds)
	seed2=seed1/!pi
	scl=(rmsInpV/(pkToPk/2.))*2048* lineLossScl
	vi=randomn(seed1,npnts)*scl
	if (ifsmp ne 0 ) then begin
		vq=randomn(seed2,npnts)*scl
	endif else begin
		vq=vi*0.
	endelse
	if presmo gt 1 then begin
		vi=smooth(vi,presmo)
		vq=smooth(vq,presmo)
	endif
	ivi=lonarr(npnts)
	ivq=lonarr(npnts)
;
	iin=where(vi lt 0.,cntN)
	iip=where(vi ge 0.,cntP)
	if cntN gt 0 then ivi[iin]=fix(vi[iin] - .5)
	if cntP gt 0 then ivi[iip]=fix(vi[iip] + .5)
	ivi=(2047 < (ivi > (-2048)))

	iin=where(vq lt 0.,cntN)
	iip=where(vq ge 0.,cntP)
	if cntN gt 0 then ivq[iin]=fix(vq[iin] - .5)
	if cntP gt 0 then ivq[iip]=fix(vq[iip] + .5)
	ivq=(2047 < (ivq > (-2048)))
;
	retI.hinp12_x=findgen(4096)-2048
	retI.hinp12_y=histogram(ivi,bins=1)
	a=rms(ivi,/quiet)
	retI.statInp12.mean=a[0]
	retI.statInp12.rms=a[1]
	bscl=(nbits eq 4)?256.:16.
	retI.statInpB.mean=a[0]/bscl
	retI.statInpB.rms=a[1]/bscl
;
;	do the smoothing
;
	flen=n_elements(filter)
	f=fltarr(npnts)
;	move filter to large buf. already normalized to unity
 	f[0:flen-1]=filter
	retI.filterGain=max(f[0:flen-1])
; 	f[0]=1.
	; filter in freq domain
	f=shift(fft(shift(f,-flen/2)),npnts/2l)*npnts
;	go to freq domain
	ic=dcomplex(ivi,ivq)	
	ysmo=fft(shift(shift(fft(ic),npnts/2L)*f,-npnts/2),1)
;
;	now scale using upshift, and the 26bit reg
;   filter gain
;
;	1. we started with 12 bits, but placed it in uppper
;      12 bits of 16 bit reg before filter. so increase
;      our numbers by 16.
;   2. decimation additions,  value grows as sqrt(dec)
;      16 since going from 12 to 16 bits
;	3. upshift and clipping to nbits
;   4. see above for sclExtra
	scl=ifsmpScl*16.*retI.filterGain*sclExtra
;
;   25nov13.. had 26 but should be 22 since 16. above already
;             did 4bits of the shift
;	scl*=2D^(hr_shift - (26-nbits))
	if nbits eq 16 then scl*=2D^(hr_shift - 10 )
	if nbits eq 8  then scl*=2D^(hr_shift - 18 )
	if nbits eq 4  then scl*=2D^(hr_shift - 22 )
;	
	ivi=lonarr(npnts)
    ivq=lonarr(npnts)
;
	vi=float(ysmo)*scl
	vq=imaginary(ysmo)*scl
;
;	try rounding before clip
;
    iin=where(vi lt 0.)
    iip=where(vi ge 0.)
    ivi[iin]=fix(vi[iin] - .5)
    ivi[iip]=fix(vi[iip] + .5)
    ivi=((-minneg - 1) < (ivi > (minneg)))
;
    iin=where(vq lt 0.)
    iip=where(vq ge 0.)
    ivq[iin]=fix(vq[iin] - .5)
    ivq[iip]=fix(vq[iip] + .5)
    ivq=((-minneg - 1) < (ivq > (minneg)))

	reti.hout_x=findgen(-minNeg*2)+minNeg
	reti.hout_y=histogram(ivi,bins=1)
	a=rms(complex(ivi,ivq),/quiet)
	retI.statOut.mean=a[0]
	retI.statOut.rms=a[1]
	return,reti
end
