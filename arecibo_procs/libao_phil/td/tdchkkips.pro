;+              
;NAME:          
;tdchkkips - check td kips and avg plt height
;SYNTAX: n=tdchkkips(yymmdd,retI)
;ARGS:
;  yymmdd :   date to look at
;RETURNS:
;   n:     int  how many td entries found
;  retI[n]: {}  array of structs holding info found
;DESCRIPTION:
;   Plot showing tiedown tensions for each cable. Also return
;avg platform height.
; need @tdinit, @lrinit before calling
;-
;
function tdchkkips,yymmdd,retI,useReti=useRetI,$
		kipsV=kipsV,posV=posV,hghtV=hghtV,hrlim=hrlim

	if not keyword_set(useRetI) then begin
		n=lrpcinp(yymmdd,lrd)
		n=tdinpday(yymmdd,td)
;
		retI={$
        yymmdd:yymmdd,$
        nlr   :n_elements(lrd),$
        lrAvgH:lrd.avgH,$
        lrtemp:lrd.temppl,$
        hrLr  :(lrd.date mod 1D)*24,$
;       
        ntd : n_elements(td),$
        kips: transpose(reform(td.kips,6,n)),$
        tdpos:transpose(td.pos),$
        hrtd :(td.secm/3600.)}
	endif
;
	cs=1.8
	csn=1.5
	font=1
	if n_elements(hrlim) eq 2 then begin
		iitd=where((retI.hrtd ge hrlim[0]) and $ 
		           (retI.hrtd le hrlim[1]),cnt)
		if cnt eq 0 then begin
			print,'no td data for hours:',hrlim 
			return,0
		endif
		iilr=where((retI.hrlr ge hrlim[0]) and $ 
		           (retI.hrlr le hrlim[1]),cnt)
		if cnt eq 0 then begin
			print,'no lr data for hours:',hrlim 
			return,0
		endif
	endif else begin
		iitd=lindgen(reti.ntd)
		iilr=lindgen(reti.nlr)
	endelse
;
	!p.multi=[0,1,3]
	ver
	if n_elements(kipsV) eq 2 then  ver,kipsV[0],kipsV[1]
	stripsxy,retI.hrtd[iitd],retI.kips[iitd,*],0,0,/step,$
		chars=cs,font=font,$
		xtitle='Hour of day',ytitle='Kips',$
		title='tiedown tension vs hour for :'+string(yymmdd)
		
;
	ver
	if n_elements(posV) eq 2 then  ver,posV[0],posV[1]
	stripsxy,retI.hrtd[iitd],retI.tdpos[iitd,*],0,0,/step,chars=cs,$
		font=font,$
		xtitle='Hour of day',ytitle='td position [inches]',$
		title='tiedown positio vs hour'
		
	sym=-1
	ver,1256,1256.8
	if n_elements(hghtV) eq 2 then  ver,hghtV[0],hghtV[1]
	plot,retI.hrlr[iilr],retI.lrAvgH[iilr],chars=cs,psym=sym,$
		font=font,$
		xtitle='Hour of day',ytitle='Feet above sea level',$
		title='Average platform height vs hour'
	xp=.04
	note,22,'Requested height=1256.22',xp=xp,chars=csn,font=font
	return,1	
end
