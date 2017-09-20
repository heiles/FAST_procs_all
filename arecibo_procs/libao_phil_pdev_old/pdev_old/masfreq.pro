;+
;NAME:
;masfreq - return freq array for a spectra
;SYNTAX: freqAr=masfreq(hdr)
;ARGS:
;    hdr: {} fit headers from b.h of masget
;RETURNS:
;     freqAr[]:  frequency array in Mhz for the points in the spectra
;-
function masfreq,hdr
;
;   optionally position to start of rec
;
	mastdim,hdr,nchan=nchan
	return,(findgen(nchan) - (hdr[0].crpix1 -1))*hdr[0].cdelt1*1e-6 +$
			 hdr[0].crval1*1d-6
end
