;
; sigproc dedispersion code
;
a={sp_dedisp,$
	dm	: 0D	,$; dispersion measure
    refFrq:0D   ,$; reference freq Mhz. compute delays relative to this
	nchan :0L   ,$; number of channels
    frqChn1: 0D ,$; freq Mhz first channel
    df     : 0D ,$; freq step chan 1 to chan 2 
	tmSpc  : 0D ,$; time for 1 spectra (wall time)
    maxSmp : 0L ,$; max samples to dedisp. all fits in memory at once
    smpOff : 0L ,$; sample offset from start we are at (counts the spectra we
;                    have processed
	    bw : 0D ,$; bandwidth used 	 computed from df,nchan
    smbw   : 0D  $; time smearing across bw in seconds
}
