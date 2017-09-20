;+
;NAME:
;genxymotion - motions for x,y positioning to A0,A1-A6,C1-C6,D1-D6
;SYNTAX: genxymotion,tofile=tofile
;KEYWORDS:
;tofile: string if set then send to default file:
;                /home/online/Tcl/proc/byu/data/positionerCmdsForCenters.dat
;RETURNS:
;DESCRIPTION 
; 	generate the motions for the positioner to move to the center of each
; position.
;Note that the positioner goes 0 to 360 with 
; ccw rotation standing on the rotary floor looking down at the positioner. 
; 
; the germans x,y coordinate system has x downhill, y towards
;the stairwell. 
; german th ->    david 180-th
;-
pro   genxymotion,tofile=tofile
;
; get the xy offsets
;
	rotangle=-40.8934
	defFile="/home/online/Tcl/Proc/byu/data/positionerCmdsForCenters.dat"
	useOutFile=0
	if keyword_set(tofile) then begin
		useOutFile=1
		openw,lunOut,defFile,/get_lun	
	endif
	A0f=[0.,0.]
	n=pos_xyoff(Af,Cf,Df)
;
; generate radius and angle for motion
;
;                            angleDeg radiusCm
;#cen ang   rad
;b0  1111.1 1111.1 
    lab="#cen ang   radius (positioner coordinate system"
	print,lab
	if useoutfile then printf,lunout,lab
	if rotangle lt 0.    then rotangle=360.+rotangle
	if rotangle gt 360 then rotangle=rotangle - 360
	lab=string(format='("A0  ",f6.1,1x,f6.1)',rotangle,0.)
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
			ff=df
			end
		endcase
		for i=0,5 do begin
			angleD=atan(ff[1,i],ff[0,i])*!radeg
			angleD=180-angleD
			if (angleD gt 360.) then angleD -=360.
			if (angleD lt 0.) then angleD +=360.
		    RadiusCm=sqrt(ff[0,i]^2 + ff[1,i]^2)
	        lab=string(format='(a1,i1,2x,f6.1,1x,f6.1)',$
		  	 labP,i+1,angleD,radiusCm) 
			print,lab
	        if useoutfile then printf,lunOut,lab
		
		endfor
	endfor
	if useoutfile then free_lun,lunout
	return
end
