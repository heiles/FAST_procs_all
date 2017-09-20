;+
;NAME:
;dfinterpol - interpolate using half band filter
; 
;SYNTAX:  spc=dfinterpol(d)
;ARGS  :  
;  d[n]:      data to interpolate (in the time domain).
;				  will be 2*nchn channels long.
;KEYWORDS:
;	phase:	  return the phase (radians) in phase
;	norm :	  if set then normalize the spectra
; cascade: int Number of extra times to apply the filter
;	 fold:    if set then fold the alias power back into the spectra
;			  in this case only nchn channels are returned.
;RETURNS:   
; spc[m]: double  The spectra of the filter. m=2*nchn if fold is not set,
; 			  or m=nchn of fold is set.
;
;DESCRIPTION:
;-
;history:
; 04sep0t started
function dfinterpol,d
; 
;    on_error,1
;
;	 length to process
;
	len=n_elements(d)
	dout=dblarr(2,len)
	dout[0,*]=d
	dout=reform(temporary(dout),2*len)
 	coef=dfgetcoefdat()
	dret=convol(dout,coef,center=0)
	return,dret
end
