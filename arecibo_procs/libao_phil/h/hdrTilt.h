;   data structure for tilt sensor data
;
; history
; 2apr99.. added aznomod to tslr, moved dp,dr to p,r
;  input of dat on disc
; 23jan02.. added za*4az,za*6az to prfit2d
;
;a={tsinp,         sec:         0.,$;seconds from midnite
;			         p:         0.,$;pitch
;			         r:         0.,$;roll 
;			        az:         0.,$;azimuth
;			        za:         0. } ; zenith angle
;
;	same as input but includes aznomod.. to keep track of 
;   actual az (for linear fit vs az
;
a={ts,             sec:         0.,$;seconds from midnite
			         p:         0.,$;pitch
			         r:         0.,$;roll 
			        az:         0.,$;azimuth
			        za:         0.,$; zenith angle
					aznomod:    0.}; if az mod 360. this one remains unchanged
;
; for azimuth swing fits
;
a={ azf1,   c0:      0.,$; constant term
            c1:      0.,$; linear term (p,r) deg / azdeg
            az1A:    0.,$; 1az Amp     deg
            az1Ph:   0.,$; 1az phase (radians)
            az3A:    0.,$; 3az ampl    deg
            az3Ph:   0.} ; 3az phase (radians)

a={ azf,    za:     0.      ,$; za degrees for swing
             p:     {azf1}  ,$; pitch
             r:     {azf1} }  ; roll
; ts,lr struct to get dx,dy offset horizontal motion
;   use x,y coordinates so
;     x + is east
;     y + is north
;   to go az,za -->x,y
;     - az=0  north,cw posi--> az->-az, + 90 deg
;   to go b dx,dy --> lr.dx,dy.. flip sign dx to x axis points east
;
a={tslr ,  sec:  0. ,$; time when this was sampled
           x:  0. ,$; x position dome east  positive(unit deg za)
           y:  0. ,$; y position dome north positive
           az:  0. ,$; az with possible mod 360
      aznomod:  0. ,$; az .. raw azimuth
           za:  0. ,$; za
           dx:  0. ,$; dx motion  inches. positive east
           dy:  0. ,$; dy motion  inches. positive north
           p:  0. ,$; pitch angle deg
           r:  0. };  roll deg
;
; structure to hold interpolated pitch,roll grid
;
a={prgrid , az: fltarr(360),$; az value 0..359
            za: fltarr(41),$; za value 0,.5.,1.,1.5....20.
			 p: fltarr(360,41),$; pitch 
             r: fltarr(360,41)}; roll  
;
; structure to use for 2d (az,za) fit for pitch roll data
;
a={ prfit2d_1,  c0:     0.D,$; constant term
            az1A:    	0.D,$; 1az Amp     deg
            az1Ph:      0.D,$; 1az phase (radians)
            az3A:       0.D,$; 3az ampl    deg
            az3Ph:      0.D,$; 3az phase (radians)
            za3A :      0.D,$; za* 3az
            za3Ph:      0.D,$; za* 3az
            za4A :      0.D,$; za* 4az
            za4Ph:      0.D,$; za* 4az
            za6A :      0.D,$; za* 6az
            za6Ph:      0.D,$; za* 6az
            czapoly: dblarr(20)}; za polynomial,za,za^2,za^3...

a={ prfit2d,  p:     {prfit2d_1}  ,$; pitch
              r:     {prfit2d_1}  ,$; roll
			  zaPolyMin:        0.D,$; to subtract from za deg
			  zaPolyDiv:        0.D,$; to divide into za deg
			  zapolyDeg:		0L ,$;	
			  version:          0L }; to keep track of changes 	

a={ prazza,    azrd:  0.D,$; radians
			   za:    0.D} ; degrees
;
; used by prfkposcmp.. pitch,roll,focus:
;
a={prfk ,    az:	0.,$;azimuth degrees
             za:	0.,$;dome za degrees
             temp:	0.,$;temperature deg f
             pitch:	0.,$;computed pitch deg
             roll:	0.,$;computed roll  deg
             focus:	0.,$;computed radial focus error inches
             tdPos: fltarr(3),$;td position inches , 12,4,8
             kips:  fltarr(3)};kips at each td block. 12,4,8
