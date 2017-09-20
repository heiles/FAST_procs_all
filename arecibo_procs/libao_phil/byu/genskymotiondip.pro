;+
;NAME:
;genskymotiondip - az,za motions for dipole positions at center
;SYNTAX: genskymotiondip,tofile=tofile
;KEYWORDS:
;tofile: string if set then send to default file:
;                /home/online/Tcl/proc/byu/data/skyOffsetsForDipA0.dat
;                /home/online/Tcl/proc/byu/data/skyOffsetsForDipA0R.dat
;RETURNS:
;DESCRIPTION 
; 	generate the az,za skyoffsetss for the the dipole postions a0 (norotation)
; and a0 rotated.
; the dipole names are dp1..dp19
;-
pro   genskymotiondip,tofile=tofile
;
; get the xy offsets
;
	rotangle=40.8934
	defFile="/home/online/Tcl/Proc/byu/data/skyOffsetsForDipA0.dat"
	defFiler="/home/online/Tcl/Proc/byu/data/skyOffsetsForDipA0R.dat"
	useOutFile=0
	if keyword_set(tofile) then begin
		useOutFile=1
		openw,lunOut,defFile,/get_lun	
		openw,lunOutR,defFileR,/get_lun	
	endif
	n=dipolexyoff(xy)
	xytosky,xy,skyA0
	xyr=rotvec(xy,-rotangle)
	xytosky,xyr,skyA0R
;                            angleDeg radiusCm
;#cen ang   rad
;b0  1111.1 1111.1 
    lab="#cen azOffAmin zaOffAmin"
    labR="#cen azOffAmin zaOffAmin dipole 2 rotated to y=0"
	print,lab
	if useoutfile then begin
			printf,lunout,lab
	endif
	for i=0,n-1 do begin
	    lab=string(format='("dp",i0,1x,f7.3,1x,f7.3)',i+1,$
			skyA0[0,i],skyA0[1,i])
		print,lab
		if useOutFile then printf,lunout,lab
	endfor
;
	print,labR
	for i=0,n-1 do begin
	    lab=string(format='("dp",i0,1x,f7.3,1x,f7.3)',i+1,$
			skyA0r[0,i],skyA0r[1,i])
		print,lab
		if useOutFile then printf,lunoutr,lab
	endfor
	if useOutFile then begin
		free_lun,lunout
		free_lun,lunoutr
	endif
	return
end
