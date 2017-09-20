;+
; pfgainTheory - compute gain from prf, and za dependance
;SYNTAX:gainCmp=pfgainTheory(az,za,maxGain,rcvrNm,gainprfN,zaModel,pitch
;							 roll,focus)
;ARGS  :
;		 az[npts] : float az in degrees
;		 za[npts] : float za in degrees
;		   maxGain: float in K/Jy to use for this receiver
;		     rcvNm: string 'cb','lb','sb'
;RETURNS:
;   gainprfN[npts]: float fractional gain from pitch,roll,focus
;	zaModel[npts]:  float fractional gain from za spillover
;     pitch[npts]:  float  pitch in degrees
;      roll[npts]:  float  roll  in degrees
;     focus[npts]:  float  focus error in inches
;gainCmp[2,4,npts]: float gain K/Jy computed. The values in first 2 indices
;					     are all the same since it is only a function of az,za
;
;DESCRIPTION:
;	Compute the theoretical gain given the azimuth and zenith angles of
;the dome. 
;	The routine computes the fractional gain do to pitch,roll, and 
;focus using theodolite,tilt sensors, and aoant. The pitch,roll angles
;are added in quadrature and then the losses are computed from aoant
;runs at 21cm, 12.6c, or 6cm. The focus loss is computed using a gaussian
;derived from a focus curve at sband. The fwhm used for the gaussian is
;scaled linearly in wavelength from 12.6 cm. The focus loss is then 
;multiplied by the pr loss (probably falls off faster than this). This
;becomes the gainprfN where 1 is no loss and .6 would be a gain 40% down.
;
;The za model is 1. out to 15deg and then decreases linearly to 79% at 
;za=20deg.
; 
;	The gainCmp is then  gainprfN*zaModel*maxGain
;It is an array [2,4,npts] so you can pass it to the other routines  (fitting)
;that take this format although the first 2 indices have the same data.
;
;NOTE:
;	The gainprf is only computed at 21cm, 12.6, or 6 cm.
;   Before calling this routine you need to call @tsinit 
;-
function pfgaintheory,az,za,maxGain,rcvrNm,gainprfN,zaModel,$
						 pitch,roll,focus 
;
	gainprfN=prfgainall(az,za,rcvrNm,pitch,roll,focus)
	npts=(size(za))[1]
;
; compute gain vs za for idealized dish. drop linearly 15->20deg za
;  1 -> .79 in gain 
;
	zamodel=fltarr(npts) + 1.
	ind=where(za gt 15)
	zamodel[ind]= 1.+ (15.- za[ind])*.21/5. 
;
;
	gainCmp=fltarr(2,4,npts)
	for i=0,3 do begin
		gaincmp[0,i,*]=gainprfN*zamodel*maxGain
		gaincmp[1,i,*]=gainprfN*zamodel*maxGain
	endfor
	return,gaincmp
end
