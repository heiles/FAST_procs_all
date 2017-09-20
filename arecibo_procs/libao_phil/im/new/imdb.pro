;+
;NAME:
;imdb  - compute data from line to db format
;SYNTAX:  imdb,d
;
;ARGS:
;   d:{iminpday} data input via iminpday. All of the data will be
;				 converted from a linear to db scale. The converted data is
;				 returned in place.
;RETURNS:
;  d:{iminpday}  data returned in place.
;
;DESCRIPTION:
;	Convert the data from linear to db format. It is the users responsibility
;to keep track of the current data format (linear or db). This routine is
;normaly used when averaging a days data: (imlin,imavg,imdb).
;
;-
pro imdb , d
    d.r.d=alog10(d.r.d)*10.
    return
end
