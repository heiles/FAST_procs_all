;
;
pro	calpltpos,ld,diff,coef,ln=lninp,xp=xp,lab=lab

	lnloc=23
	dac=ld[5000].velcmd
	if n_elements(lninp) ne 0 then lnloc=lninp
	xploc=.3
	if n_elements(xp) ne 0 then xploc=xp
    labax=['Vleft','Vright','Hleft','Hright','Tilt']
	hor,300000L,700000L
	ver,-1500.,1500.
	for i=0,4 do begin
    if (i eq 0) then begin
        plot,ld.enccur[i],diff[*,i],col=i+1,$
    xtitle='encoder position [encCnts]',ytitle='encPos-fitToPot [encCnts]',$
		title='EncPos-FitToPos vs encoder position',/xstyle,/ystyle
    endif else begin &$
        oplot,ld.enccur[i],diff[*,i],col=i+1
    endelse
endfor
	for i=0,4 do begin
		a=rms(diff[*,i],/quiet)
    dat=string(format=$
'("enc=",f8.1," + ",f9.5,"*pot + ",f9.6," pot^2 rms:",f5.1," ",a)',$
                coef[0,i],coef[1,i],coef[2,i],a[1],labax[i])
    note,lnloc,dat,col=i+1,xp=xploc
    lnloc=lnloc+1
	endfor

	labloc=string(format='("dacValues used:",i4,i4,i4,i4,i4," ")',$
		dac[0],dac[1],dac[2],dac[3],dac[4]);

	if keyword_set(lab) then begin
		 print,lab
		 print,labloc
		 labloc=labloc+lab
	endif
	note,3,labloc,xp=.05
	return
end
