;
; try fittting the data
; before calling this routine call
;  @corinit
;  @procfileinit
;  @prfinit
;  @tsinit
; .run inpall
; .run prfcmp
;
;
pro fitazzaall,srcinp,srcout,nbrds,datatype,az,za,y,title,ytitle,fitIAr,yfit,$
			pol=pol,fittype=fittype
;
;	trying fitting all the frequencies 
;
	yfit=y
	fitI={azzafit}
	fitIAr=replicate(fitI,2,nbrds)
	s=size(y)
	pol1=0 
	pol2=1
	if n_elements(pol) ne 0 then begin
		pol1=pol-1
		pol2=pol1
	endif
	if n_elements(fittype) eq 0 then fittype=1

	for sbc=0,nbrds-1 do begin
		for pol=pol1,pol2 do begin
			yy=reform(y[pol,sbc,*],s[3])
			fitazza,az,za,yy,fitI,yfit=yyfit,fittype=fittype
			yfit[pol,sbc,*]=yyfit
			fitIAr[pol,sbc]=fitI
			fitIAr[pol,sbc].freq   =srcout[0].h.dop.freqbcrest+$
				 	     srcout[0].h.dop.freqoffsets[sbc]
			fitIAr[pol,sbc].rfNum   =iflohrfnum(srcout[0].h.iflo)
			polch='a'
			if pol eq 1 then polch   ='b'
			fitIAr[pol,sbc].pol     =polch
			fitIAr[pol,sbc].type    = datatype
			fitIAr[pol,sbc].title   = title
			fitIAr[pol,sbc].ytitle  = ytitle
		endfor
	endfor 
	return
end
