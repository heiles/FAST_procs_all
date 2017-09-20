;+
;NAME:
;immkfrq  - make the frequency array for a set of data.
;SYNTAX:  frq=immkfrq(d1frq)
;
;ARGS:
;   d1frq:{imdrec} a single data record.
;RETURNS:
;  frq[401]:float  the frequency array that corresponds to the 401 data
;				   points in the record.
;
;DESCRIPTION:
;   Compute the frequency array for a single data record. There are 401
;data points in each data record. The routine uses the band center frequency,
;bandwidth, and number of points to compute the array.
;-
function immkfrq,r
; r     {imdrec} 1 record
; returns float[401]  return freq here
;
    return,(findgen(401) - 200.) * r.h.spanMhz/400. + r.h.cfrDataMhz
end
