;+
;NAME:
;terparmsN - return some of the tertiary parameters.
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
; history 
; updated dcorig to be a struct with left,right side measurements
pro terparmsN,dcorig=dcorig,encorig=encorig,dctofocdeg=dctofocdeg
;
;	until we figure out yl,yr use 0..
;
	yl=0.
	yr=0.
	dcorig={dcorig,$
     		p1L:[-208.855,     135.789,    -262.731,1.],$;
            p1R:[-208.833,    -137.201,    -262.030,1.],$;
            p2L:[-275.307,     134.798,    -377.241,1.],$;
            p2R:[-275.464,    -136.961,    -376.034,1.],$;
			p3L:[-204.041,     136.983,    -385.053,1.],$;
            p3R:[-203.673,    -136.973,    -384.879,1.],$;
            p4 :[-414.621,    -1.62156,    -402.958,1.],$;
            p5 :[-397.443,   -0.234600,    -454.539,1.]};
		
	encorig=[ 579385.,556144.,485800.,461040.,517300L]
	dctofocdeg=18. 
	return
end
