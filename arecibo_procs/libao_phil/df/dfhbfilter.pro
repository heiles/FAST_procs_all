;+
;NAME:
;dfhbfilter - return half band filter spectra.
; 
;SYNTAX:  spc=dfhbfilter(nchn,phase=phase,norm=norm,cascase=cascade,two=two,$
;						      fup=fup,fintp=fintp,flip=flip)
;				
;ARGS  :  nchn	  The number of channels to the 6db rolloff. The spc
;				  will be 2*nchn channels long.
;KEYWORDS:
;	phase:	  return the phase (radians) in phase
;	norm :	  if set then normalize the spectra
; cascade: int Number of extra times to apply the filter
;	 fold:    if set then fold the alias power back into the spectra
;			  in this case only nchn channels are returned.
;	 two :    if set then return a two sided filter (nchn/2) on each side
;			  of center. This is what the correlator actually uses since it
;			  does complex filtering. (warning .. phase is probably not 
;			  returned correctly.
;	 fup :    if set then do extra filtering step before upconvert
;			  to real. This occurs in the correlator upconvert and interpolate
;			  step.
; fintp  :int The number of times to apply a real version of the filter
;			  after upconvert and interpolate. This only affects the
;			  high freq side of the bandpass. This is done for < 25 Mhz bw.
; flip  :     if keyword set then flip bandpass before returning. This is
;			  handy for correlator data that has an odd number of hi side
;			  los.
;RETURNS:   
; spc[m]: double  The spectra of the filter. m=2*nchn if fold is not set,
; 			  or m=nchn of fold is set.
;
;DESCRIPTION:
;	Return the halfband filter shape. There will be 2*n channels returned
;with the filter falling to 6db at n. If you are generating a filter shape
;for the correlator than n should be the number of lags used.
;
;	The correlator reduces the bandwidth by cascading halfband filters. The
;cascade keyword will generate these filter shapes by reapplying the 
;halfband filter. The value for Nchn should be the one you want to end up with.
;	correlator_bandwidths  bw_num  cascade
;		12.5				 3       2
;		 6.25			     4       3
;		 3.125		         5       4
;		 1.5625	             6       5
;		  .78125             7       6
;		  .390625            8       7
;		  .1953125           9       8
;Because the filters are so flat, cascading has little affect on the
;filter shape (but requires an fft 2^cascade time larger than the bandpass).
;
;	So create bandpass correction filters use the routine cordfbp().
;
;SEE ALSO: cordfbp()
;-
;history:
; 04sep0t started
function dfhbfilter,nchn,phase=phase,norm=norm,cascade=cascade,fold=fold,$
					fup=fup,fintp=fintp,two=two,flip=flip
; 
     on_error,1
     if 4*nchn lt 67 then begin
		print,'channel length must be at least 67 channels (fir length)'
		return,''
	 endif
	 toloop=0
	 if keyword_set(cascade) then begin
	 	if cascade ge 2 then begin
	 		toloop=cascade
			nchnLoc=long(nchn)*2^(toloop-1)
		endif
	 endif
	 if toloop eq 0 then begin
		toloop=1
		nchnLoc=long(nchn)
		cascade=0
	 endif 
	 if keyword_set(two) then nchnLoc=nchnLoc/2
	 savnchn=nchnLoc
	 for i=0,toloop-1 do begin
	 	coef=dfgetcoefdat(/complex,len=4*nchnLoc)
	 	a=fft(coef)
	 	a=a[0:2*nchnLoc-1]
	 	if keyword_set(norm)  then a=a/(262144.D/(2*nchnLoc))
		if cascade ge 2 then begin
			if i eq 0 then begin
				aa=a
			endif else begin
				aa=a*aa
			endelse
			nchnLoc=nchnLoc/2
		endif
	endfor
	if cascade ge 2 then begin
	 	if keyword_set(phase) then phase=atan(aa)
		aPwr=abs(aa)^2
	endif else begin
 		if keyword_set(phase) then phase=atan(a)
		aPwr=abs(a)^2
	endelse
	if keyword_set(fold) then begin
		aPwr=aPwr[0:savnchn-1]+ reverse(aPwr[savnchn:*])
		if keyword_set(phase) then phase=phase[0:savnchn-1]
	endif
	if keyword_set(fup) then aPwr=aPwr*aPwr
	if keyword_set(two) then begin
		n=savnchn
		n1=n
		if keyword_set(fold) then n1=n_elements(aPwr)
		aa=dblarr(2*n)
		aa[0:n-1]=reverse(aPwr[0:n1-1])
		aa[n:*]  =aPwr[0:n1-1]
		aPwr=aa
		if keyword_set(phase) then begin
			aa[0:n-1]=reverse(phase[0:n1-1])
			aa[n:*]  =phase[0:n1-1]
			phase=aa
		endif
	endif
;
; 	fintp step after up convert. number of times to apply it
;
	if keyword_set(fintp) then begin
	       n=n_elements(aPwr)
		   coef=dfgetcoefdat(/complex,len=4*n)
		   aa=fft(coef)
		   aa=aa[0:n-1]
		   if keyword_set(norm)  then aa=aa/(262144.D/(2*n))
		   aaPwr=abs(aa)^2
;
;		looks like no folding since interpolated...
;		need to apply filter twice more rather than once ???   
;       to make it work...
		   aPwr=aPwr*(aaPwr)^(fintp)
	endif
	if keyword_set(flip) then begin
		if keyword_set(phase) then phase=reverse(phase)
		return,reverse(aPwr)
	endif
	return,aPwr
end
