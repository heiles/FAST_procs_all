;+
;NAME:
;imlin  - compute data from db to linear format
;SYNTAX:  imlin,d
;
;ARGS:
;   d:{iminpday} data input via iminpday. All of the data will be
;                converted from a db to a linear scale. The converted data is
;                returned in place.
;RETURNS:
;  d:{iminpday}  data returned in place.
;
;DESCRIPTION:
;   Convert the data from db to linear format. It is the users responsibility
;to keep track of the current data format (linear or db). This routine is
;normaly used when averaging a days data: (imlin,imavg,imdb).
;
;-

pro imlin , d
;---------------------------------------------------------------------------
;
; imlin,{imday}
; convert data from db to linear
;
    d.r.d=10.^(d.r.d*.1)
    return
end
