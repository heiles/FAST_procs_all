;
; plot limits for freq, amp of sine wave for no accel limiting
;
pro testlimsin,axis=axis

	!p.multi=[0,1,2]
	if n_elements(axis) eq 0 then axis='tilt'
	ln=2
	sclln=.5
	nvel=4
	naccSec=10
	case axis of &$
		'ver': maxVelInPerSec =2.0	 &$
		'hor': maxVelInPerSec =3.5 &$
		'tilt': maxVelInPerSec=3.5 &$
	endcase
	maxVelDac=findgen(nvel)*512 + 512
	maxAccSec=findgen(naccsec)*.5 + .5
	limsin,maxveldac,maxaccsec,maxVelInPerSec,maxfrq,maxamp
	hor,maxvelinpersec/4.-.1, maxvelinpersec + .1 
	ver,-.1,1.5
	!x.style=1
	!y.style=1
	x=maxVelDac/2048 * maxVelInPerSec
	xp=.5
	for i=0,naccsec-1 do begin &$
	    col=(i) mod 10 + 1 &$
	    if (i eq 0) then begin &$
	        plot,x,maxfrq[*,i],xtitle='maxReqvel [in/sec]',ytitle='MaxFrqHz',$
			title='maxFrq sinWave by maxReqVel(x) and maxAccSec(color)',$
	        col=col,psym=-2 &$
	    endif else begin &$
	        oplot,x,maxfrq[*,i],col=col,psym=-2 &$
	    endelse &$
	note,ln+(1+i)*sclln,string(format=$
		'("MaxAccSec:",f3.1)',maxAccSec[i]),xp=xp,col=col&$
	endfor
	lab=string(format='("accel: secs to reach ",f5.3," in/sec")',maxVelInPerSec)
	note,ln,lab,xp=xp
	note,ln,"axis: "+ axis,xp=.03
;
;	maximum amplitude
;
	ver,0,10.
	xp=.2
	loff=15
	for i=0,naccsec-1 do begin &$
	    col=(i) mod 10 + 1 &$
	    if (i eq 0) then begin &$
	        plot,x,maxAmp[*,i],xtitle='maxReqvel [in/sec]',ytitle='MaxAmp[in]',$
			title='maxAmp sinWave by maxReqVel(x) and maxAccSec(color)',$
	        col=col,psym=-2 &$
	    endif else begin &$
	        oplot,x,maxAmp[*,i],col=col,psym=-2 &$
	    endelse &$
	note,ln+loff+(1+i)*sclln,string(format=$
			'("MaxAccSec:",f3.1)',maxAccSec[i]),xp=xp,col=col&$
	endfor
   lab=string(format='("accel: secs to reach ",f5.3," in/sec")',maxVelInPerSec)
	note,ln+loff,lab,xp=xp
	return
end
