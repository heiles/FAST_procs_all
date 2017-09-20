a={shim,   za:  0.,$
	       l:   0.,$
		   r:   0. }
openr,lun,'shim.dat',/get_lun
sh=replicate(a,16)
readf,lun,sh
close,lun
; current error  ccw roll 
rollf=-(sh.r-sh.l)/144. * 180./!pi
plot,sh.za+1.118,rollf,psym=-4, $
	title='30jan00 current roll from shim measure [+ ccw]',$
	ytitle='roll inches [+ ccw]',$
	xtitle='encoder za'
