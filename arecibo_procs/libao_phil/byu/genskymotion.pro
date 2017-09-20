;+
;NAME:
;genskymotion - az,za motions for positioning to A0,A1-A6,C1-C6,D1-D6
;SYNTAX: genskymotion,tofile=tofile
;KEYWORDS:
;tofile: string if set then send to default file:
;                /home/online/Tcl/proc/byu/data/skyOffsetsForCenters.dat
;RETURNS:
;DESCRIPTION 
; 	generate the az,za skyoffsetss for the different centers.
;-
pro   genskymotion,tofile=tofile
;
; get the xy offsets
;
	defFile="/home/online/Tcl/Proc/byu/data/skyOffsetsForCenters.dat"
	useOutFile=0
	if keyword_set(tofile) then begin
		useOutFile=1
		openw,lunOut,defFile,/get_lun	
	endif
	A0f=[0.,0.]
	pos_skyoff,Af,Cf,Df 
;
; generate radius and angle for motion
;
;                            angleDeg radiusCm
;#cen ang   rad
;b0  1111.1 1111.1 
    lab="#cen azOffAmin zaOffAmin"
	print,lab
	if useoutfile then printf,lunout,lab
	lab=string(format='("A0  ",f7.3,1x,f7.3)',A0f[0],a0F[1])
	print,lab
	if useoutfile then printf,lunOut,lab
	for j=0,2 do begin
		case j of
		  0: begin
			labP='A'
			ff=Af
			end
		  1: begin
			labP='C'
			ff=Cf
			end
		  2: begin
			labP='D'
			ff=Df
			end
		endcase
		for i=0,5 do begin
	        lab=string(format='(a1,i1,2x,f7.3,1x,f7.3)',$
		  	 labP,i+1,ff[0,i],ff[1,i]) 
			print,lab
	        if useoutfile then printf,lunOut,lab
		
		endfor
	endfor
	if useoutfile then free_lun,lunout
	return
end
