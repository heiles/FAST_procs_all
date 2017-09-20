;+
;NAME:
;cmpbflytwiddle - compute butterfly twiddle factors
;SYNTAX - cmptwiddle,lenfft,nbfly,ntwiddleAr,bflytwiddle
;ARGS:
;lenfft: 	long	length of fft
;RETURNS:
; nbfly:   int		number of butter fly stages.
; ntwiddleAr[nbfly]: 	step size, number of twiddle values this butterfly
;bflytwiddle[2,lenfft,nbfly]: float hold the twiddle values for this butterfly
;					 for each butterfly i, the first ntwiddleAr[i] entries of
;					 bflytwiddle[lenffit,i] will hold the values.
;DESCRIPTION:
;	Compute the fft twiddle factors for lenfft. This routine is for
;debugging, not for speeding up the fft computation. For each butterfly
;stage the m uniq twiddlefactors for that stage are returned in 
;bflyTwiddle[0:m-1,ibutterfly]. NtwiddleAr[nflys] holds how many uniq
;twiddle factors there are at each stage.
;-
pro cmptwiddle,lenfft,nbfly,ntwiddleAr,bflytwiddle,cosAr=cosAr,sinAr=sinAr
;
	forward_function bitreverse
	nbfly=round(alog10(lenfft)/alog10(2.))
	th   =2.*!pi/lenfft
	cosAr=cos(th*findgen(lenfft))
	sinAr=sin(th*findgen(lenfft))
	kar=lindgen(lenfft)
	ntwiddleAr=lonarr(nbfly)
	bflyTwiddle=fltarr(2,lenfft,nbfly)
	
	for ib=1,nbfly do begin
		k=ishft(kar,-(nbfly-ib))
		k=bitreverse(k,nbfly)
		last=-1
		jj=0L
		for j=0,lenfft-1 do begin
			if last ne k[j]  then begin
				k[jj]=k[j]
				last=k[j]
				jj++
			endif
		endfor
		ntwiddleAr[ib-1]=jj
		bflytwiddle[0,0:ntwiddleAr[ib-1]-1,ib-1]=cosAr[k[0:jj-1]]
		bflytwiddle[1,0:ntwiddleAr[ib-1]-1,ib-1]=sinAr[k[0:jj-1]]
	endfor
	return
end
