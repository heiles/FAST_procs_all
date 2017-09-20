;+
;NAME:
;wggrpvel - compute waveguide group velocity vs freq
;SYNTAX: vgrp[n]=wggrpvel(freqMhz,widthMet,w2100=w2100)
;
;ARGS:
; freqMhz[n] : float freq in mhz to compute group vel
;    widthMet: float  waveguide width in meters.
;KEYWORDS    :
;       w2100:        if set then ignore widthMet and
;              use width for w2100 waveguide (the guide
;              used for 430 xmiter).
;RETURNS:
; vgrp[n]: float   group velocity for each frqequency.
;                 the units are c
;DESCRIPTION:
;	Compute group velocity in a waveguide for a given
;set of frequencies. The data is returned in units of c.
;For values less than the cutoff, -1 is returned as the
;group velocity.
; 
function  wggrpvel,freqM,widthMet,w2100=w2100
;
	c=299792458D
    lambda=c/(freqM*1e6)
;   if w2100 set, ignore a0M, used published valu
;   this is the 430wg we use.
	if keyword_set(w2100) then widthMet=.5334
	a=(1.-(lambda/(2.*widthMet))^2)
	n=n_elements(freqM)
	vgrp=fltarr(n)  - 1.
	ii=where(a ge 0,cnt)
	if cnt  gt 0 then vgrp[ii]=sqrt(a[ii])
	if n eq 1 then vgrp=vgrp[0]
	return,vgrp
end
