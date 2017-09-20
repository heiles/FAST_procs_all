;+
;NAME:
;pos_skyoff - skyoffsets for positions A1-A6 and C (C1-C6), D1-d6
;SYNTAX: pos_skyoff,asky,csky,dsky 
;RETURNS:
;n - 6
;asky[2,6] float  A position offsets Amins (az,za) from center 
;csky[2,6] float  C position offsets Amins (az,za) from center
;dsky[2,6] float  D position offsets Amins (az,za) from center
;DESCRIPTION 
; 	Return the az,za  offsets for positions a1..a6 and c1 to c6,d1 to d6
;These are the offsets on the sky for the center positions. to
; put a source at this center, you must move the az,za by minus this.
;asky,bsky,csky are the values recorded in the datafiles used by
;the tcl routines.
;
; The returned values are in amins the order is [0,*]=daz,[1,*]=dza
;-
pro   pos_skyoff,a,c,d
;
; get the xy offsets
;
	n=pos_xyoff(Af,Cf,Df)
;
; now compute sky offsets
;
	xytosky,af,A
	xytosky,cf,C
	xytosky,df,D
	return
end
