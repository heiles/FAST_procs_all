;
; header for lrdata from logfile
;
a={lrdf ,day:           double(0.),$;
	     temp:          0.,$;
	     hght:          0.,$;
		 stat:          0L}
a={lrpcd , dist:		0.,$; distance
           secs:		0}  ; took to measure
;
; data on disc from pc
;
a={lrpcinp, daynum:		0, $; 
         hour  :		0, $; 
         min   :		0, $; 
         sec   :		0, $; 
		 telpos:fltarr(3), $; not filled in
		 wrap  :        0, $; not filled in
		 tempB :        0.,$; bowl temp
		 tempPl:        0.,$; platform temp
		 m	   : replicate({lrpcd},7),$;
		 tiltNS:        0.,$; north south tilt sensor.. not installed
		 tiltEW:        0.,$; east west tilt sensor  .. not installed
	    tmcon  :       0.,$; tilt sensor time constant
	 secPerPnt :       0 ,$; seconds between measurements.
	    zeros  : intarr(2)  }; seconds between measurements.
;
; coordsys C1: x-west,ynorth,z-down cm
; coordsys C2: x-west,ynorth,z-up feet above sea level
; coordsys C3: delta distances cm
;
a={lrdat, date:		0.D, $; daynumber. includes fractional day
		 tempB :        0.,$; bowl temp
		 tempPl:        0.,$; platform temp
		 dist  : fltarr(6),$; the 6 measurements
		 distTm: fltarr(6),$; the times for the 6 measurements
		 avgh  :	   0. ,$;C2 average height feet..corrected to feet above slC
		cornerh: Fltarr(3),$;C2 height each corner corrected + up,T12,T4,T8
		 dx    :       0. ,$;C1 average x translation of platform in
		 dy    :       0. ,$;C1 average y translation of platform in
		 dz    :       0. ,$;C1 average y translation of platform in
		 xrot  :	   0. ,$;C1 rotation about x [radians]
		 yrot  :	   0. ,$;C1 rotation about y [radians]
		 zrot  :	   0. ,$;C1 rotation about z [radians]
		 pnts  : fltarr(3,3),$;C1 [xyz,T12,T4,T8] cm no corrections. z down
		dok    :       0  ,$; 1 if all 6 distances were measured
	 secPerPnt :       0   }; seconds between measurements.

;
; extended.. includes az,gr,ch positions.
;
a={lrdatext, date:     0.D, $; daynumber. includes fractional day
         tempB :        0.,$; bowl temp
         tempPl:        0.,$; platform temp
         dist  : fltarr(6),$; the 6 measurements
         distTm: fltarr(6),$; the times for the 6 measurements
         avgh  :       0. ,$;C2 average height feet..corrected to feet above slC
        cornerh: Fltarr(3),$;C2 height each corner corrected + up,T12,T4,T8
         dx    :       0. ,$;C1 average x translation of platform in
         dy    :       0. ,$;C1 average y translation of platform in
         dz    :       0. ,$;C1 average y translation of platform in
         xrot  :       0. ,$;C1 rotation about x [radians]
         yrot  :       0. ,$;C1 rotation about y [radians]
         zrot  :       0. ,$;C1 rotation about z [radians]
         pnts  : fltarr(3,3),$;C1 [xyz,T12,T4,T8] cm no corrections. z down
        dok    :       0  ,$; 1 if all 6 distances were measured
     secPerPnt :       0  ,$;
         az    :       0. ,$;
         zagr  :       0. ,$;
         zach  :       0. }

