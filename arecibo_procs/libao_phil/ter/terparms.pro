;+
;NAME:
;terparms - return some of the tertiary parameters.
;SYNTAX: terparms,dcorig=dcorig,encorig=encorig,dctofocdeg=dctofocdeg
;ARGS:
;	none
;KEYWORDS:
;	dcorig[4,8]:float The connection point positions in dome centerline
;				    coordinates for the focus origin. The points are ordered:
;				    P1L,P2L,P3L,P4,P5,P1R,P2R,P3R,.L=left,R=right looking
;				    uphill. The 4 dimension is x,y,z,translation
;  encorig[5]:float  encoder values when tertiary is at focus origin.
;					VL,VR,HL,HR,Tilt
;  dctofocdeg:float angle (in degrees) to rotate from dome centerline to 
;				    focus coordinate system. def=18 degrees.
;
;DESCRIPTION:
;	The dcorigin comes from the original number of lynn baker circa 1992.
;The dctofocdeg is a rough guess.
;The encoder positions are from the survey of the tertiary 01aug01.
;-
pro terparms,dcorig=dcorig,encorig=encorig,dctofocdeg=dctofocdeg
;
;	until we figure out yl,yr use 0..
;
	yl=0.
	yr=0.
	dcorig=[[-210.307,yl, -262.410,1.],$;  p1l
	        [-280.000,yl, -376.000,1. ],$;  p2l 
			[-204.000,yl, -389.000,1. ],$   ;p3l 
			[-445.122,0., -427.144,1. ],$   ;p4
			[-397.00 ,0., -459.000,1. ],$   ;p5
	        [-210.307,yr, -262.410,1. ],$;  p1r
	        [-280.000,yr, -376.000,1. ],$;  p2r 
			[-204.000,yr, -389.000,1. ]]    ;p3r 
	encorig=[ 579385.,556144.,485800.,461040.,517300L]
	dctofocdeg=18. 
	return
end
