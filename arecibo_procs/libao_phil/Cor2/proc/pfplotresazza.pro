;+
; pfplotresazza - plot residuals from az,za fit
;SYNTAX: pfplotresazza,az,za,fitI,key=key,sbc=sbc,vsaz=vsaz,_extra=e
;  ARGS:
;		az[npts] : float azimuth positions
;		za[npts] : float za positions
;		 y[2,nsbc,npts] raw data 
;		fitI[2,nsbc] : {azzafit} returned from fitazza
;KEYWORDS:
;		key 	 : int  key=1 residuals by sample
;		                    2 esiduals by  za
;		                    default both
;		sbc		: int	sbc to plot 0-3,4 all
;		vsaz	: if set then plot vs azimuth (modulo 360)
;		_extra  :  keywords for pfplot

;-
pro pfplotresazza,srcinp,srcout,az,za,y,fitI,tit=tit,key=key,sbc=sbc,$
		  vsaz=vsaz,_extra=e
	lnsta=0
	lnstb=1
	ln=3
	xp=.05
	col=[1,2,3,5]
	if not keyword_set(key) then key=3
	if not keyword_set(tit) then tit=''
	if not keyword_set(sym) then sym=[0,0]
	if keyword_set(vsaz) then begin
		pltx=az
		xlab='az'
	endif else begin
		pltx=za
		xlab='za'
	endelse
	if    n_elements(sbc) eq 0 then sbc=4

	s=size(fitI)
	if (s[0] eq 1 ) then begin
		nbrds=1
	endif else begin
		nbrds=s[2]
	endelse
	sbc1=0
	sbc2=nbrds-1
	if sbc lt 4 then begin
		 sbc1=sbc
		 sbc2=sbc
	endif
;
	yfita=y
	res=y
	npts=(size(y))[3]
	for i=sbc1,sbc2 do begin &$
		res[0,i,*]= y[0,i,*] - fitazzaeval(az,za,fitI[0,i]) &$
		res[1,i,*]= y[1,i,*] - fitazzaeval(az,za,fitI[1,i]) &$
	endfor

	title=tit + ' ' + fitI[0,0].type + ' data - fit(az,za)'
	if (key eq 1) or (key  eq 3) then begin
		hor,0,npts-1
		pfplot,srcinp,srcout,findgen(npts),res,'sample',fitI[0,0].ytitle,$
			title,sbc=sbc,_extra=e
	endif

	if (key eq 2) or (key  eq 3) then begin
		if not keyword_set(vsaz) then hor,0,20
		pfplot,srcinp,srcout,pltx,res,xlab,fitI[0,0].ytitle,$
			title,sbc=sbc,_extra=e
	endif
	return
end
