;lroffset - return x,y offset of laser ranging in ao9 coordinate system.
pro lroffset,xoff,yoff
;
; x is east, y is north ..
; lrdx + offsetx = ao9 dx
; lrdy + offsety = ao9 dy
;
; this offset was from :
;  1az term theodolite 10deg az spin with tiltsensor 1az removed
;  1az term laser ranging from all the az spins on 8mar00 no tilt sensor
;      1az removed. used 435 feet going from dx,dy to pitch,roll
;  assumed lr,and theod have 0 degrees true north.
;  see ../doc/lroffset.doc
; 
	xoff=.03
	yoff=.78
	return
end
