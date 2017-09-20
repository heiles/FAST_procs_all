;+
;NAME:
;fftint - integer based fft routine 
;SYNTAX:  fftint,xr,xi,lenfft,bshift=bshift,doplot=doplot,coefBits=coefBits,$
;					   cosAr=cosAr,sinAr=sinAr
;ARGS:
; xr[lenfft]: long 	real data
; xi[lenfft]: long  imaginary data
;lenfft     : long  length of fft
;KEYWORDS:
;bshift: long	bitmap telling  whether or not to downshift on each butterfly
;			    stage. For an fft of lenfft there are nbut=alog2(lenfft) butterfly
;               stages. Bit  nbut-1  (counting from 0) is the first butterfly stage.
;				A one in the bit bitposition --> downshift, a 0 is no downshift.
;				The default value is 0x555555  downshift everyother butterfly.
;coefBits:long  number of bits to use in the coefficients. The default is 16
;doplot:        if set then plot each stage of the butterfly and wait for 
;               users response. (s --> stop in routine, e--> exit routine, any
;               other key is continue).
;cosAr[lenfft]:l64 input/output the cos table.
;sinAr[lenfft]:l64 input/output the sin table.
;RETURNS:
;xr[lenfft] long   the fft values are returned in place.
;yr[lenfft] long
;cosAr[lenfft]:l64 input/output the cos table.
;sinAr[lenfft]:l64 input/output the sin table.
;DESCRIPTION:
;	Perform and integer based fft. The user inputs the data as real and imaginary
;arrays. Lenfft should be a power of 2. The coef's are scaled to numCoef bits (16 by
;default). The multiplications are done in long long format to prevent overflows. The
;return data is converted back to long. 
;	If you supply cosAr,sinAr (with length ne lenfft) then the routine will return the
;cosar, sinar used in the computation. On the next call you can input these arrays
;and save the time to compute the sin,cos's.
;
; 	You can use this routine to investigate integer round off errors, bit size on
;different transformlengths.
;
;	Each butterfly step has been vectorized. For and 8k transform it runs about
; 9 times slower than the idl fft routine (50 vs 6 milliseconds).
;
;EXAMPLE: 
;;
;; make a sine wave with peak value of 35 counts
; pksin=35
; lenfft=1024
; xr=long(mksin(lenfft,10)*pksin)
; xi=long(mksin(lenfft,10,phase=-.25)*pksin)
; fftinf,xr,xi,lenfft,bshift=0x2aa
; freq=lindgen(lenfft) - lenfft/2
; spcpwr=shift((xr^2L + xi^2L),lenfft/2L)
; plot,freq,spcpwr
;-
pro fftint,xxr,xxi,N,bshift=bshift,doplot=doplot,coefBits=coefBits,cosAr=cosAr,sinAr=sinAr

	common colph,decomposedph,colph
	forward_function bitreverse

	nbitsCoef=(n_elements(coefBits) gt 0)?coefBits:16L
	coefScl=2L^(nbitsCoef-1L)
	xr=long64(xxr)
	xi=long64(xxi)
	nu=long( alog10(N)/alog10(2.) + .5)
	if (n_elements(bshift) eq 0) then bshift='55555555'XUL and (2L^(nu+1) - 1)
	step=N/2L
	k=0
	nu1=nu-1
	bshiftMask=2L^(nu-1)		; start left, test each butterfly if downshift
	if n_elements(cosAr) ne N then cosAr=round(cos(lindgen(N)*2.*!pi/N)*coefScl,/l64) 
	if n_elements(sinAr) ne N then sinAr=round(sin(lindgen(N)*2.*!pi/N)*coefScl,/l64)
;
; 	loop over the butterflys
;
	for ibutterfly=1,nu  do begin
;
;      vectorize 1 butterfly
;
	   lastdim=N/(step*2L)
	   kAr=lindgen(step,2,lastdim)
	   m=ishft(kAr[*,0,*],-nu1)
	   p=bitreverse(m,nu)
;       arg=2L*!pi*p/N
;       c=round(cos(arg)*coefScl,/l64) & s=round(sin(arg)*coefScl,/l64)
		c=cosAr[p]
		s=sinAr[p]
;
;	   ii1,ii2 are the dual nodes
;
       ii1=kAr[*,0,*]
       ii2=kAr[*,1,*]
       tr=(xr[ii2]*c)/coefScl  + (xi[ii2]*s)/coefScl
       ti=(xi[ii2]*c)/coefScl  - (xr[ii2]*s)/coefScl
       xr[ii2]= xr[ii1] - tr  
       xi[ii2]= xi[ii1] - ti 
       xr[ii1]= xr[ii1] + tr 
       xi[ii1]= xi[ii1] + ti 
;
; 	if debugging
;
		if keyword_set(doplot) then begin
	    	max=max([abs(xi),abs(xr)])*1.1
	    	ver ,-max,max
			a=rms(xr,/quiet)
			b=rms(xi,/quiet)
			plot,xr,title=string(format='(i2," rms i,q:",f9.1,1x,f9.1)',$
					ibutterfly,a[1],b[1])
			oplot,xi,col=colph[2]
			key=checkkey(/wait)
			if key eq 's' then stop
		endif
		if (bshift and bshiftMask) ne 0 then begin
;		    print,ibutterfly,pshiftMask,format='("pshift:",i2,1x,z5.5)'
			xr=xr/2L
			xi=xi/2L
		endif
		k=0L
		nu1--
		step/=2
	     bshiftMask=ishft(bshiftMask,-1)
	endfor
;
;  vectorized bit reversal
;
	kAr=lindgen(N)
	ii=bitreverse(kAr,nu)
	jj=where(ii gt kAr)
	tr=xr[kAr[jj]]
	ti=xi[kAr[jj]]
	xr[kAr[jj]]=xr[ii[jj]]
	xi[kAr[jj]]=xi[ii[jj]]
	xr[ii[jj]]=tr
	xi[ii[jj]]=ti
	
	xxr=long(xr)
	xxi=long(xi)
	return
end
