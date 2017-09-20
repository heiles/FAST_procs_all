;.............................................................................
pro tssmo,d,smo=smo,decimate=decimate,todecimate=todecimate
;
;   boxcar smooth the pitch,roll data
;  9 , 19 ;   smooths to fwhm of 25 points 
;  or  .05 degs in za (.01 deg/sec 5hz sampling)
;      1   degs in az (.2 deg/sec 5hz sampling)
; 
;warning: this routines assumes that the data is in time order
;         after calling azswsmofit() it is sorted back to az order mod 360.
;         use d.aznomod to resort to time order before calling this routine
;
;   if decimate set then decimate the data
;
	if n_elements(smo)        eq 0 then smo=9
	if n_elements(todecimate) eq 0 then todecimate=25 &; assume default smo
	smo1=smo
	smo2=smo1*2+1
    for i=1,10 do begin &$
        d.p=smooth(temporary(d.p),smo1,/edge_truncate) &$
        d.r=smooth(temporary(d.r),smo1,/edge_truncate) &$
    end
    d.p=smooth(temporary(d.p),smo2,/edge_truncate) &$
    d.r=smooth(temporary(d.r),smo2,/edge_truncate) &$
;
;   edge points are biased. take points startig at half the decimate length 
;
	if keyword_set(decimate) then d=select(d,todecimate/2,todecimate)
    return
end
