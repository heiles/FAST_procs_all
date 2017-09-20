;
; structure def for rfi histograms.
;
a={rfihistInfo, $
		frqSt	:0.,   $; starting freq Mhz
		frqEnd	:0.,   $; ending freq   Mhz
		frqStp	:0.,   $; freq step between bins Mhz 
		totchn  :0L,   $; number of channels in histogram
		edgeFrac:0.,   $; fraction of chns to skip on edge of band
		rejectFrac:0., $; if ge this fraction, skip sbc...
		sigmaToClip:0.} ; above this many sigma is rfi
	

