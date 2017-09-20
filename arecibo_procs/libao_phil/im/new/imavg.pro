;+
;NAME:
;imavg - compute daily average
;
;SYNTAX:  davg=imavg(d1frq)
;
;ARGS:
;	d1frq:{iminpday} single freq data  for 1 day (see imgfrq())
;
;RETURNS:
;  davg:{imdrec}  Holds the averaged data.
;
;KEYWORDS:
;
;DESCRIPTION:
;	Average a days worth of data at 1 frequency. The user should call:
; iminpday,yymmdd,d
; and then
; imgfrq,d,freq,d1frq
; and then pass d1frq to this routine.
;	The data is first converted from db to linear, averaged, and then
; converted back to db.
;
;---------------------------------------------------------------------------
function imavg,d
;
; {imdrec}=imavg {imday} - average recs in imd. call imgfrq first.
;                          assumes data is linear
;
    s=size(d.r.d)
    davg={imdrec}
    davg.h=d.r[0].h
    davg.d= total(d.r.d,2)/(1.*s[2])
    return,davg
end
