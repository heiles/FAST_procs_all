;+
;NAME:
;genskymotiondip - az,za motions for dipole positions
;SYNTAX: genskymotiondip,gcdat=gcdat,tofile=tofile,gcdat=gcdat
;KEYWORDS:
;gcdat : if set then use coordinates provided by german
;        instead of his equations from 2010.
;
;tofile: string if set then send to default file:
;         /home/online/Tcl/proc/byu/data/skyOffsetsForDipA0.dat
;             if gcdat set then default is:
;         /home/online/Tcl/proc/byu/data/skyOffsetsForDipA0gc.dat
;RETURNS:
;DESCRIPTION 
; 	generate the az,za skyoffsetss for the the dipole postions.
; the dipole names are dp1..dp19
;-
pro   genskymotiondip,gcdat=gcdat,tofile=tofile
;
; get the xy offsets
;
	defFile  ="/home/online/Tcl/Proc/ao19/data/skyOffsetsForDipA0.dat"
	defFileGc="/home/online/Tcl/Proc/ao19/data/skyOffsetsForDipA0gc.dat"
	useOutFile=0
	defFileUse=(keyword_set(gcdat))?defFileGc:defFile
	
	if keyword_set(tofile) then begin
		useOutFile=1
		openw,lunOut,defFileUse,/get_lun	
	endif
	n=dipolexyoff(xy)
	xytosky,xy,skyA0
;                            angleDeg radiusCm
;#cen ang   rad
;b0  1111.1 1111.1 
    lab="#cen azOffAmin zaOffAmin"
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
	return
end
