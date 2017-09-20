;+
;prfgain - compute pitch,roll fractional gain.
;SYNTAX - result=prfgain( x,rcvr=rcvr)
;ARGS:    
;	  x:	float tilt in x direction (good for pitch or roll) in deg.
;KEYWORDS : 
;	  rcvr:	string 	rcvr to use. 'lb','sb',cb'or 'xb'. default: 'sb'
;	  freq:	float   Mhz. If provided then return the gain for this freq
;						 using the specified rcvr data. If not provided use
;						 the default freq for the rcvr.
;RETURNS:
;		Result: float fraction of peak gain (linear).
;DESCRIPTION:
; 	Return the fraction of peak gain for a pitch or roll in degrees.
;Fit by mike nolan 15apr00 to 21cm,12.6cm 6 cm,3cm.
;
; 21aug00 .. 21cm fit from data below..
;m
;Here are all of the runs, including L-bnad.  They
;have 0 to allow plotting by column when there is no run.
;pitch         Gain (dB)
; deg    12.6cm  6cm   3cm    21cm
; 0.5    73.106  0      0     69.361
; 0.4    73.578 77.837  0     69.587
; 0.3    73.897 79.016  0     69.675
; 0.2    74.164 79.981 83.915 69.708
; 0.1    74.259 80.624 86.031 69.863
; 0.05   74.373 80.722 86.662 69.916
; 0.025  74.399 80.827 86.741 69.926
; 0      74.410 80.864 86.881 69.931
;-0.05   74.370  0      0      0
;-0.1    74.273  0      0      0
;-0.2    74.172  0      0      0
;-0.5    73.186  0      0      0
;
;
function prfgain,x,rcvr=rcvr,freq=freq
 
	c=3d10			; cm/sec
	if n_elements(rcvr) eq 0 then rcvr='sb'
	case rcvr of
		'sb': begin
				lambdaDef=12.6
				y=(0.998770 - 0.146217*x -0.732674*x*x)
			  end
		'cb': begin
				lambdaDef=6.
				y=(1.00702  - 0.619787*x -1.68171* x*x)
			  end
		'xb': begin
				lambdaDef=3.
				y=(1.00193  -  .928726*x -7.80984*x*x) 
			  end
		'lb': begin
				lambdaDef=21.
				y=( 1.0003558D + $
				x*(0.036926968D +  $
				x*(-3.1918765D  +  $
                x*(11.960319D   +  $ 
				x*(-13.429455)))))
			  end
	    else: message,'prfgain.rcvr: lb,sb,cb,or xb'
	endcase 
	if n_elements(freq) gt 0 then begin
		freqDef=c/lambdaDef *1D-6
		y=prfgainrel(y,freqDef,freq)
	endif

	return,y
end
