;+
;prfkposcmp - compute pitch,roll,focus,kips as a function of az,za,temp
;SYNTAX:
;    prfk=prfkposcmp(az,za,temp,prf2d,pitch=pitch,roll=roll,focus=focus,
;					 foff=foff,poff=poff,roff=roff)
;ARGS:
;	az[n]	: float	azimuth positions deg
;	za[n]	: float	za positions
;	temp	: float	temp to use F. 
;KEYWORDS:
;	pitch[n]: float deg.use this for the pitch at each position rather than the
;				    model.
;	roll[n]:  float deg. use this for the roll  at each position rather than the
;				    model.
;  focus[n]:  float inches. use this for the focus error at each position
;				    rather than the model.
;  foff    :  float inches. Add this to the model focus.
;  roff    :  float inches. Add this to the model roll.
;  poff    :  float inches. Add this to the model pitch.
;
;RETURNS:
;    prf2d - structure holding pitch,roll coef. see prfit2dio
;      prfk.az 
;      prfk.za 
;      prfk.temp
;      prfk.pitch
;      prfk.roll
;      prfk.focus
;      prfk.tdPos[3]
;      prfk.kips[3]
; DESCRIPTION
;    This routine computes the pitch, roll, and focus error from a model derived
; from the tiltsensors, thedolite. It then computes the tiedown positions and
; kips to correct for this error (it moves the platform in the opposite
; direction.
;
;	You can substitute the model pitch,roll,or focus errors using the
;keywords pitch,roll,focus. You can add values to the model using
;the offset keywords.
;
; before using this routine:
; initialize routine in ~phil/idl/gen :
; @prfinit
; prfit2dio,prf2d
;
; to play with 
;
;-
function prfkposcmp,az,za,temp,prf2d,pitch=pitch,roll=roll,focus=focus,$
		   foff=foff,poff=poff,roff=roff
;
	forward_function prfit2deval,focerr,tdcor,kipstd
;	
	if n_elements(foff) eq 0 then foff=0.
	if n_elements(poff)   eq 0 then poff=0.
	if n_elements(roff)   eq 0 then roff=0.
	npts=(size(az))[1]
	prfk=replicate({prfk},npts)
	prfk.az=az
	prfk.za=za
	prfk.temp=temp
	if (n_elements(pitch) eq 0 ) then begin
		prfk.pitch=prfit2deval(prf2d,az,za) + poff
	endif else begin
		prfk.pitch=pitch
	endelse
	if (n_elements(roll) eq 0 ) then begin
		prfk.roll =prfit2deval(prf2d,az,za,/roll) + roff
	endif else begin
		prfk.roll=roll
	endelse
	if (n_elements(focus) eq 0 ) then begin
		prfk.focus=focerr(az,za) + foff
	endif else begin
		prfk.focus=focus
	endelse
	prfk.tdPos=tdcor(az,za,prfk.pitch,prfk.roll+roff,$
			focus=(prfk.focus),temp=temp) 
;
	prfk.kips=kipstd(az,za,temp,prfk.tdPos)
	return,prfk
end
