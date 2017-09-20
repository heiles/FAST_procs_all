;+
;prfSrc - compute p,r,f, tdPos,kips, and pointing error for source rise to set
; SYNTAX:
;	    dec[3]  holding deg,min,secs of source
;      temp     temperature for the computation 
;-
pro prfSrc,dec,temp,prfk,azErr,zaErr,step=step,foff=foff,roff=roff,$
				poff=poff,prf2d=prf2d
	forward_function prfkposcmp
;
; 	input the pitch,roll,coef..
;
	if n_elements(step) eq 0 then  step=1  
	if n_elements(roff)  eq 0 then  roff=0. 
	if n_elements(poff) eq 0 then  poff=0. 
	if n_elements(foff)   eq 0 then  foff=0. 
	if keyword_set(prf2d) then begin
		prf2dloc=prf2d
	endif else begin
		prfit2dio,prf2dloc
	endelse
;
;
;	 compute az,za
;
	npnts=decToAzZa(dec,az,za,step=step)
;
;	do the pitch,roll,focus computation
;
	prfk=prfkposcmp(az,za,temp,prf2dloc,poff=poff,roff=roff,$
				   foff=foff)
;
; 	now the pointing error
;
	prfPntErr,za,-prfk.pitch,-prfk.roll,-prfk.focus,azErr,zaErr
	return
end
