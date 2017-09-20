;+
;NAME:
;imgfrq - get a single frequency subset of a days data.
;SYNTAX:  imgfrq,d,frq,d1frq
;
;ARGS:
;   d:{iminpday} data for entire day from iminpday().
; frq:float		 Center frequency of band to return. The list of frequencies
;			     can be found in d.frql
;
;RETURNS:
; d1frq:{iminpday} single freq data for 1 day.
;
;DESCRIPTION:
;   Create a subset of a days data that contains only the band centered
;at frq.
;-
pro imgfrq,dall,frq,dfrq
; dall {imday} all days info
; frq  float   to return
; dfrq {imday} holding just the frq of interest
;
    indlist=where(dall.r.h.cfrdataMhz eq frq,count)
    if (count le 0) then begin
        print,frq,' not found in daily data'
        return;
    end
     dfrq={yymmdd:dall.yymmdd,nrecs:count,frql:[frq],$
        r:temporary(dall.r[indlist]),crec:0     ,cfrq:frq}
     return
end
