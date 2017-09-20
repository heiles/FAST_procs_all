;+ 
;prfgainrel - compute relative gain falloff 
;SYNTAX - gain2frac=prfgainrel( gain1frac,gain1freq,gain2freq)
;ARGS:    
;	  gain1frac: float fractional gain 0..1 for freq1
;	  gain1frq : float freq Mhz for gain1
;	  gain2frq : float freq Mhz for gain2 (target)
;RETURNS:
;		gain2frac: float fractional gain for freq 2
;DESCRIPTION:
; 	Given the fractional gain (0..1) for 1 frequency do to pitch,roll,
;return the fractional gain at freq2. This is from kildal memo no 4-92 pg
;4. It is only valid out to about 1 db.
;The db gain scales quadratically in frequency..
;=
function prfgainrel,g1,frq1,frq2
 
	g1db=(alog10(g1))*10
	g2db=g1db*(float(frq2)/frq1)^2
	return,10^(g2db*.1)
end
