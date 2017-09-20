;+
;NAME:
;puprchanfreq - compute cfr freq each puppi gpu
;SYNTAX: puprget,rfcfr,bwTot,nchan,gpucfr,chancfr,verb=verb,gpunames=gpunames
;ARGS:
;   rfcfr: double rf center freq on sky (Mhz)
;   bwTot: double total bw (Mhz) of observation.
;                 us -n if band is flipped.
;   nchan: int    total number of puppi channels
;              -1 , or not present --> input next block
;KEYWORDS:
;verb    : int   if true then also print results to stdout
;
;RETURNS:
;   gpuCfr[8]:double center freq (Mhz) each gpu.
; chanCfr[nchan/8,8] - cfr Mhz  each chan. The first index
;                      goes over a gpu, the 2nd index of gpus 
; gpuNames[8]:strarr   name of each gpu
;
;DESCRIPTION:
;	Given apuppi configuration(total bandwidth, rfcfr, total number of channels)
;compute the center frequency for each gpu (this should be the value in the
;gpu header) as well as the center frequency of each channel.
;
; If Nchan 0.n-1 then dc goes to the center of chan N/2
;-
pro   puprchanfreq,rfcfr,bwTot,nchan,gpuCfr,chanCfr,gpuNames=gpuNames,$
	               verb=verb

;
; compute the freq in each gpu then
; the cfr of each channel
;
	if n_elements(verb) eq 0 then verb=0

	bwTotL=bwTot
	frqDir=(bwTotL ge 0)?1:-1
	if frqDir lt 0 then bwTotL=-bwTotL
	gpuNames=["gpu01","gpu02","gpu03","gpu05","gpu06","gpu07","gpu08","gpu09"]
	ngpu=8
;
; let gpu indices be 0,1,2,3,4,5,6,7
; rfcfr center center of 1st channel of gpu[4]
;   all bw's below  are positive. frqDir take care of the flip
;
	bwGpu=bwTotL/ngpu
	bwChan= bwTotL/nchan
	nchanGpu=nchan/ngpu
;
; the rfcr is 1/2 chan into the 4th gpu (counting from 0)
; compute freq of left edge each gpu then add .5 bwgpu
;       
	indEdg= 4 + .5/nchangpu 
	gpuCfr=((findgen(ngpu)) - (indEdg) + .5) *bwGpu * frqDir + rfCfr
;
; now figure out the cfr of each channel
;
	chanCfr=fltarr(nchanGpu,ngpu)
	for igpu=0,ngpu-1 do begin &$
		for ichn=0,nchanGpu-1 do begin &$
			chanCfr[ichn,igpu]= gpuCfr[igpu] - frqDir*(nchanGpu/2)*bwChan + $
			(.5 + ichn)*bwChan*frqDir &$
		endfor &$
	endfor
	if (verb) then begin
		chanCum=0L
		for igpu=0,ngpu-1 do begin &$
			print,format='("gpu:",a5,"  cfr:",f9.3)',gpuNames[igpu],gpuCfr[igpu] &$
			print,"  cumChn gpuChn" &$
			for ichn=0,nchangpu-1 do begin &$
				print,format='(4x,i4,3x,i3,1x,f9.3)',chanCum,ichn,chanCfr[ichn,igpu] &$
				chanCum++ &$
			endfor &$
		endfor
	endif
	return
end
