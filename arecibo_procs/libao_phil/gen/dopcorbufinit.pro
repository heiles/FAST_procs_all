;+
;NAME:
;dopcorbuf - init for dopcorbuf()
;SYNTAX:dopCorI=dopcorbufinit(dopFrqHz,dopTmU,bufStTmU,smptmStepU,$
;                             tmUToSec,bandflipped=bandflipped) 
;ARGS:
;dopFrqHz[n]: double  measured doppler frequencies
;dopTmU[n]  : double times for each dop Frq
;bufSttmU   : double start time for first sample of buf
;smpTmStepU : double time step for each sample in buf
;tmUToSec   : double value that converts user time units to
;                  seconds.
;KEYWORDS:  
;bandflipped:       if true then freq band had been flipped
;                   this will flip the sign of the 
;                   doppler used for the correction
;RETURNS:
;dopcorI  :{}      structure to pass to each call of dopcorbuf()
;
;DESCRIPTION:
;	Initialize for calls to dopcorbuf().
;The user passes an array of doppler frequencies as
;well as the timestamp of each of these. The frequency is 
;positive if the signal frequency is greater than the rest frequency
;(blue shifted.. object coming toward us)
;
;	The user also provides the timestamp for the first
;sample in the buffer as well as the timestep between
;samples in a buffer.
;
;	The time value can be anything the user want, but
;it must be the same for all of the provided times.
;All the variables ending in U are in these user time units.
;The variable tmUToSec converts from the users time units
;to seconds (eg. if units are hours, then tmUToSec=3600D).
;The user must also verify there is enough resolution 
;in the data type (best to use double).
;
;	Set the bandflipped keyword if the sampled data band has been
;flipped in frequency (by an odd number of high side mixing stages).
;
;	After calling this routine, the user should
;make multiple calls to dopcorbuf() starting with the 
;buffer that starts at bufStTm.
;
;Notes:
;     - this routine does not correct for time dilation.
;     - resolution:
;       using hours and double, the time resolution is 3.6*10-13 sec
;	    using mjd  and double,  the time resolution is .86 usecs
;	    using jd   and double,  the time resolution is .86 millisecs
;	    For sample times on the order of usecs, it's probably best to
;       use hours for the time unit.
;     - these two routines probably need some more debugging.
;EXAMPLE:
;	Suppose the doppler values have units of 1day, and the complex 
;signal has bandwidth BW (in hz) then
;dopFrq[n] - doppler frequencies
;dopTmU[n] - these will have units of 1 day.
;bufStTmU  - starting daynumber.fract for first sample in buffer
;            in dayno units
;smpTmUStep = (1/bandwidhz)/(86400D) . this is the sample time in 
;             units of 1day.
;tmUToSec   = 86400D  .. to convert user time unit (1day) to seconds
;-
function dopcorbufinit,dopFrq,dopTmU,bufStTmU,smpTmUStep,tmUToSec,$
			bandflipped=bandflipped

	flip=keyword_set(bandflipped)?-1d:1d
	return,{$
		dopFrq:dopFrq,$
		dopFrqUsed:dopFrq*flip,$
		dopTmU:dopTmU,$
	    bufStTmU:bufStTmU,$
	    smpTmUStep:smpTmUStep,$
	    smpTmSec :smpTmUStep*tmUToSec,$
		curbufTmU:bufStTmU,$
		phOffRd:0d}
end
