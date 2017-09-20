;+
;mpvctodac - convert monitor port vel req to dac value
;SYNTAX: dacVal=mpvctodac(mpvc,ind)
;ARGS  : 
;		mpvc[]	: int monitor port vel cmd for 4ms integration
;		ind     : int 0-4 .. which axis to use vl,vr,hl,hr,tilt
;DESCRIPTION
;	Taken from sine wave fit to monitor port req cmd and req dac (dosin2.) 
; 17nov00.
;-
function mpvctodac,mpvc,ind
	dacamp=[782.571,789.897,626.074,637.217,648.054]
    dacoff=[2.06499,2.58813,-0.225404,-0.388058,-0.00976496]
	mpamp =[498.524,500.381,406.322,409.344,403.617]
	mpoff =[2003.38,1993.07,1991.55,2026.55,2012.14]
	if ind gt 1 then sgn=1. $
	else sgn=-1.
	return,  (dacamp[ind]/mpamp[ind])*(sgn*(mpvc-mpoff[ind]))+ dacoff[ind]
end
