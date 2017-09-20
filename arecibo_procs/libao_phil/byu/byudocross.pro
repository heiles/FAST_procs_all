;
;byudocross - process cross file
;
function byudocross,filename,mmI,pntLab,plotit=plotit,srcFlux=srcFlux,$
			tit=tit,wait=wait,focus=focus,startscan=startscan,$
			npat=npat
;
	if n_elements(tit) eq 0 then tit=''
	openr,lun,filename,/get_lun &$
    rew,lun
    ncross=byucrossinp(lun,bAr,crossI,startscan=startscan,npat=npat)
	if ncross eq 0 then return,0
	free_lun,lun
;
	start=1
	for i=0,ncross-1 do begin
		ltit=tit +  " " + pntLab[i]
		istat=corcrossfit(bar[*,i],fitI,plotit=plotit,tit=ltit) &$
    	if istat eq 1 then begin &$
        	if start then begin &$
				a={ srcName: '',$
					azCen  :  0.,$
					zaCen  :  0.,$
				   focus   : -50. ,$
				bmsPerStrip:0,$
                secsPerStrip: 0,$
				posOffAzAmin: 0.,$
				posOffZaAmin: 0.,$
					pntNm  : '' ,$
				   srcFlux : 0. ,$
					sefd   : 0. ,$
					goodFit: 0  ,$
 					fitI   : fitI[0]} 
				mmI=replicate(a,ncross)
            	start=0 &$
			endif
			mmI[i].fitI=fitI
			mmI[i].srcName=crossI[i].srcname
			mmI[i].azCen  =crossI[i].azCen  
			mmI[i].zaCen  =crossI[i].zaCen  
			mmI[i].posOffAzAmin =crossI[i].posOffAzAmin
			mmI[i].posOffZaAmin =crossI[i].posOffZaAmin
			mmI[i].goodfit= fitI.trouble eq 0
			mmI[i].pntNm=pntLab[i]
			mmI[i].srcFlux=srcFlux
			mmI[i].focus=n_elements(focus) gt 0 ? focus:-999.
			if mmi[i].goodFit then begin
				mmI[i].sefd   =(fitI.offset / fitI.amp)  *srcFlux
			endif
			if keyword_set(wait) then begin
				key=checkkey(/wait)
				if key eq 'q' then return,i
			endif
		 endif else begin
           print,"fit err scan:",bar[0,i].b1.h.std.scannumber
		 endelse
	endfor
	return,ncross
end
