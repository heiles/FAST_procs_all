;+
;prfit2deval - evaluate the pitch or roll 2d fit
;
;SYNTAX:
;     y=prfit2deval(prf2d,az,za,roll=roll)
;
;ARGS:
;    prf2d  - {prf2d}  returned from prf2dfit routine
;     az    - az in degrees where to evaluate  fit
;     za    - az in degrees where to evaluate  fit
;
;KEYWORSDS
;    roll   - if non zero, evalaute roll. if 0, then pitch
;
;RETURNS:
;     y[]   - pitch or roll evaluated at the supplied az,za
;               that are passed indirectly to prfit2dFunc via svdfit
;clipping limits set at 2, 19.5 za for evaluation.
;-
;23jan02 add a za*6az za*4az term to the azimuth
function prfit2deval,prf2d,az,za,roll=roll
	if n_elements(roll) eq 0 then roll = 0
	prf={prfit2d_1}
 	if roll ne 0 then begin	
		prf=prf2d.r
	endif else begin
		prf=prf2d.p
	endelse
	zaLoc=za < 19.5
	zaLoc=zaLoc > 2.0
    zaM=(zaLoc - double(prf2d.zaPolyMin) )/prf2d.zaPolyDiv

    zaPol=double(0.);
    for i=prf2d.zaPolyDeg-1,0,-1 do begin &$
            zaPol=zaM*(prf.czaPoly[i] + zaPol) &$
    endfor
    return,(prf.c0 + $
        prf.az1A*sin(   az*!dtor-prf.az1Ph)   + $
        prf.az3A*sin(3.*az*!dtor-prf.az3Ph)   + $
        prf.za3A*zaLoc*sin(3.*az*!dtor-prf.za3Ph)+ $
        prf.za4A*zaLoc*sin(4.*az*!dtor-prf.za4Ph)+ $
        prf.za6A*zaLoc*sin(6.*az*!dtor-prf.za6Ph)+ $
		   zaPol)
end
