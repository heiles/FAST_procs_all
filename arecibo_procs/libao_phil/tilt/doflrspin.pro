;
; do floor spin
;
pro doflrspin,d,stTimes,offTimes,flrPitchAr,flrRollAr,flrIndAr
;
; stTimes[n] - when each started
; offTimes[n] - when each flrspin reached other side (255)
; returns:
; flrPitchAr[n]
; flrRollAr[n]
; flrIndAr[4,n]   index 75 (start,stop), 255 (start,stop) used each spin.
;
    common colph,decomposedph,colph
	nptsAll=n_elements(d)
	nflrspin=n_elements(stTimes)
	flrPitchAr=fltarr(nflrspin)
    flrRollAr =fltarr(nflrspin)
	flrIndAr   =fltarr(4,nflrspin)
    flrPitcho=0.
    flrRollo=0.
	for i=0,nflrspin-1 do begin &$
		tmFlrRot=(offTimes[i]-stTimes[i])
    	tsflrspin,d,flrPitcho,flrRollo,stTimes[i],flrpitchN,flrrollN,$
              tsflrind,tmstep=tmFlrRot &$
    	flrPitchAr[i]=flrpitchN &$
   	    flrRollAr[i] =flrRollN &$
        flrIndAr[*,i]=tsflrInd &$
	endfor
	slop=200L
	!p.multi=[0,1,nflrspin]
	hor
;;;	ver,-1,1
	for i=0,nflrspin-1 do begin &$
    	i1=(flrIndAr[0,i] - slop) > 0L &$
        i2=(flrIndAr[3,i] + slop) < (nptsAll -1) &$
    	plot,d[i1:i2].p,title='floor spin' &$
    	oplot,d[i1:i2].r,col=colph[2]  &$
    	flag,flrindAr[*,i]-i1,linestyle=3,col=colph[3] &$
	endfor
	ln=2.5
    scl=.7
    xp=.04
	note,ln,'pitch',xp=xp
    note,ln+1*scl,'roll',xp=xp,col=colph[2]
	print,'pitch:',flrPitchAr,' avg:',mean(flrpitchar)
	print,'roll :',flrRollAr ,' avg:',mean(flrrollar)
    return
end
