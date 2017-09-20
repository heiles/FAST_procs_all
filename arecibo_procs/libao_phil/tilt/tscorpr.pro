;+
;NAME:
;tscorpr - correct tilt sensor pitch, roll to reflector or theodolite origin
;SYNTAX: tscorpr,az,za,pitchcor,rollcor,az1terms=az1terms,date=yymmdd
;ARGS:
;	az[n]	   : float az positions in degrees
;	za[n]	   : float za positions in degrees
;KEYWORDS:
;	az1terms[4]: float if supplied, then this is the amplitude in degrees
;				      and phase in radians for the 1az sin fit of the
;					  tilt sensor data for the pitch and roll.
;					  eg: Ampl*sin(azRd-phaseRd). 
;					  If not supplied then the 1az term measured when
;					  the data was taken will be used.
;				   [0] - pitch amplitude
;				   [1] - pitch phase in radians
;				   [2] - roll  amplitude
;				   [3] - roll  phase in radians
;   date       ; long yymmdd fit to use. default is most recent
;   ao9	       : if set then correct to ao9. default is to correct to the
;				 reflector center. Note this is only valid for the 
;			     aug01 data.
;RETURNS:
; 	pitchcor[n]: float pitch correction (add to tilt sensor pitch).
; 	 rollcor[n]: float roll  correction (add to tilt sensor roll).
;
;DESCRIPTION:
;	Compute the correction to go from tilt sensor pitch,roll (measured with
;the tiltsensors in the dome) to the pitch/roll measurements of the dome
;relative to the center of the reflector (taken 09aug01). The procedure is:
;
;1. take the tilt sensor data.
;2. measure the floor offset of the tilt sensor (use the tcl routine
;   tsflrspin() in vxWorks).
;3. input the tilt sensor data with tsnext using the floor offsets 
;   you measured in two. This routine will remove the floor offset
;   and switch from sin(angle) to degrees for the tilt sensors.
;4. call this routine with the az,za positions to get the corrections
;5. add the corrections onto the pitch,roll from setp 3.
;
;
;There is a horizontal offset of the center bearing from ao9. This 
;creates a 1 az term in the theodolite data (and the optics) that is 
;not present in the tilt sensor meausurements. The correction was:
;
; 1. The 1 az term is removed from the tilt sensor data (if not input
;    then the value used from the original measurement is used).
; 2. The 1 az data  was removed from the theodolite data.
; 3. The linear fit to the differences was made.
; 4. The differences plus the  1 az term of the theodolite data is
;    returned to the user as the correction.
;
;By default this corrects to the center of the reflector. If the ao9 keyword
;is set, the the correction is done to ao9 (only for aug01).
;
;History:
;-----------------
;9aug01
;-----------------
;	The correction was computed using the tilt sensor data from
;04aug01 and the theodolite data from 09aug01.
;
;The tilt sensor offsets measured and used were:
; roll: -.1412, pitch: .672 degrees.
;The residuals from the fit of the 43 theodolite measurements was;
; 09aug01
; roll : .009 degrees 
; pitch: .008 degrees  
;
;-
;
pro tscorpr,az,za,pitchcor,rollcor,az1terms=az1terms,ao9=ao9,date=date
;
;  linear fits: (theodolite-tiltsensor)=c0 + c1*za
;		fit thd-ts  after removing 1az terms 
;           c0 (P)       c1*za P        c0 (R)     c1*za (R)
;
	fitZa=[[9.7818605D,-0.99574748D,0.35241408D,-0.021237118D], $;aug01 ao9
		   [9.7805516D,-0.99616380D,0.35219817D,-0.021223288D], $;aug01 refl
		   [9.7756208D,-0.99496319D,0.35075564D,-0.020165173 ]] ;17feb03 refl
;
;	theodolite 1az term
;	           cos P        sin P          cos R         sin R
thd1az=[[-.020551749D,-.0061430125D, .0011097509D,-.024803430D],$;aug01 ao9
	    [-.026963521D, .0082133831D,-.013157951D ,-.032208655D],$;aug01 refl
		[-.027223170D,-.0033670052D, .0010685981D,-.022476704D]];17feb03 refl
;
;	tilt sensor 1a (if they don't supply it) A*sin(az*!dtor -phRd)
;	           Amp P        phRd P          amp R         phRd R
ts1az=[[.0026330893D,5.9970214D,.0017175009D,6.0130987D], $; aug01 
	   [.0026330893D,5.9970214D,.0017175009D,6.0130987D], $; aug01 
	   [.00186473D  ,5.79619D  ,.00104733D  , .352162  ]]  ; 17feb03

	if not keyword_set(date) then date=999999L
	case 1 of 
		(date lt 030217): i=(keyword_set(ao9)) ?  0 : 1
		else            : i=2
	endcase
		
;;
;;	if keyword_set(ao9) then begin
;;	fitZaPC0=9.7818605D
;;	fitZaPC1=-0.99574748D
;;	;
;;	fitZaRC0=0.35241408D
;;	fitZaRC1=-0.021237118D
;;;
;;;  theodolite Acos(az) + Bsin(az) for pitch and roll
;;;
;;	thAmpCosP=-0.020551749D
;;	thAmpSinP=-0.0061430125D
;;	thAmpCosR= 0.0011097509D
;;	thAmpSinR=-0.024803430D
;;;
;;; tilt sensor Amp*sin(az-phaseRd) for pitch and roll 
;;;
;;	ts1azAmpP=0.0026330893D
;;	ts1azPhP =5.9970214D  
;;	ts1azAmpR=0.0017175009D
;;	ts1azPhR =6.0130987D  
;;
	if n_elements(az1terms) eq 4 then ts1az[*,i]=az1terms
;
;	remove 1az term from tilt
;
	azrd=az*!dtor
	pitchcor=-(ts1az[0,i]*sin(azrd-ts1az[1,i]))    + $;remove 1az tilt sensor
      (thd1az[0,i]*cos(azrd) + thd1az[1,i]*sin(azrd))+$;add theodolite 1 az term
      (fitZa[0,i] + fitZa[1,i]*za)				      ; include linear fit
;
	rollcor=-(ts1az[2,i]*sin(azrd-ts1az[3,i]))    + $;remove 1az tilt sensor
      (thd1az[2,i]*cos(azrd) + thd1az[3,i]*sin(azrd))+$;add theodolite 1 az term
      (fitZa[2,i] + fitZa[3,i]*za)				      ; include linear fit

;
; correct to center of reflector
;
;;    fitZaPC0=9.7805516
;;    fitZaPC1=-0.99616380
;;    ;
;;    fitZaRC0=0.35219817
;;    fitZaRC1=-0.021223288
;;;
;;;  reflector Acos(az) + Bsin(az) for pitch and roll
;;;
;;    rflAmpCosP=-0.026963521
;;    rflAmpSinP=0.0082133831
;;    rflAmpCosR=-0.013157951
;;    rflAmpSinR=-0.032208655
;;;
;;; tilt sensor Amp*sin(az-phaseRd) for pitch and roll
;;;
;;    ts1azAmpP=0.0026330893D
;;    ts1azPhP =5.9970214D
;;    ts1azAmpR=0.0017175009D
;;    ts1azPhR =6.0130987D
;;
;;    if n_elements(az1terms) eq 4 then begin
;;        ts1azAmpP=az1terms[0]
;;        ts1azPhP =az1terms[1]
;;        ts1azAmpR=az1terms[2]
;;        ts1azPhR =az1terms[3]
;;    endif
;
;   remove 1az term from tilt
;
	return
end
