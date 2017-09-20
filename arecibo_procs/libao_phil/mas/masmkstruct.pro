;+
;NAME:
;masmkstruct - make a mas structure from template
;SYNTAX: bnew=masmkstruct(btempl,float=float,double=double,ndump=ndump,$
;                      npol=npol,nelm=nelm)
;ARGS: 
;btempl:  {masget} template struct to use
;KEYWORDS:
;     keywords can override settings of templ
;   float:  make data float
;  double:  make data double
;  ndump : int  make ndump spectra per entry
;  npol  : int  make npol pols
;  nelm  : int  make nelm entries in array
;RETURNS:
; bnew[nelm]:{masget} struct with accum entry
;
;DESCRIPTION:
;   Create masget struct using btempl as a template. Override 
;things in btempl with the keywords.
;-
function masmkstruct,btempl,float=float,double=double,ndump=ndump,$
                       npol=npol,nelm=nelm 

	TYPE_FLOAT=4
	TYPE_DOUBLE=5
	nchan=btempl[0].nchan
	if n_elements(nelm)  eq 0 then nelm=1
	if n_elements(ndump) eq 0 then ndump=long(btempl[0].ndump)
	ndumpL=long(ndump)
	if n_elements(npol)  eq 0 then npol=btempl[0].npol
	sz=size(btempl[0].d)	
	Dtype=sz[n_elements(sz)-2]
	if keyword_set(double)then Dtype=TYPE_DOUBLE
	if keyword_set(float) then Dtype=TYPE_FLOAT
	blankCorDone=btempl[0].blankCorDone

;   build data array size

	ndim=1			; freq
	szN=[ndim,nchan]
	if npol gt 1 then begin
		szN[0]+=1
		szN=[szN,npol]
	endif
	if ndumpL gt 1 then begin
		szN[0]+=1
		szN=[szN,ndumpL]
	endif
	szN=[szN,Dtype,nchan*npol*ndumpL]
	if nelm eq 1 then begin
	   bnew={ 	h    :btempl[0].h ,$
			nchan:nchan,$
			npol :npol,$
			ndump:ndumpL,$
		    blankcordone:blankCorDone,$
			st   :replicate(btempl[0].st[0],ndumpL),$
	  	  accum  : 0d,$
	      d  :make_array(size=szN)}
	endif else begin
	   a={ 	h    :btempl[0].h ,$
			nchan:nchan,$
			npol :npol,$
			ndump:ndumpL,$
			blankcordone:blankCorDone,$
			st   :replicate(btempl[0].st[0],ndumpL),$
	  	  accum  : 0d,$
	      d  :make_array(size=szN)}
		bnew=replicate(a,nelm)
	endelse
	return,bnew
end
