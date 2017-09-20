;+
;NAME:
;rdevbw - return bandwidth of observation
;SYNTAX: bwMhz=rdevbw(desc)
;ARGS:
; desc: {} 	from rdevopen.
;RETURNS:
;bwMhz: float        band in Mhz of observation
;DESCRIPTION:
;	Return the bandwidth of the observation. The routine decodes the
; h2.decf decimation factor. The clock is hardcoded to 160 Mhz.
;-
;
function rdevbw,desc
;
;	clock=140.
;	case desc.h2.decf of
;		1: bwMhz=35.
;	    2: bwMhz=clock/7.
;	    3: bwMhz=clock/14.
;	    4: bwMhz=clock/28.
;	    5: bwMhz=clock/56.
;	    6: bwMhz=clock/140
	clock=140.
	case desc.h2.decf of
		1: bwMhz=35.
	    2: bwMhz=20.
	    3: bwMhz=10.
	    4: bwMhz=5.
	    5: bwMhz=2.5
	    6: bwMhz=1.
	   else: begin
			lab=string(format=$
			   '("Unkown decF in desc.h2.decF.:",i4," legal values:1..6")',$
				     desc.h2.decf)
			print,lab
			return,-1
			end
	 endcase
	return,bwMhz
end
