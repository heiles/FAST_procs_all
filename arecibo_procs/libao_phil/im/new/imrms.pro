;+
;NAME:
;imrms - compute rms for 1 frequency for a given day.
;SYNTAX: drms=imrms(d1)
;ARGS:
;   d1frq[] :   {imday} where you've extracted just 1 freq via imfrq()
;               and passed it thru imlin so it is a linear scale.
;   drms:        {imdrec} return rms here
;DESCRIPTION:
; compute rms/Mean by channel for a single frequency. d1 should contain
;a single frequency and be linear. You can do this via:
;iminpday,yymmdd,d
;imlin,d
;imgfrq,d,d.frql[i],d1
;drms=imrms(d1)
;
; You could then loop on i
;-
function imrms,d1
;
    npts=401
    drms={imdrec}
    drms.h=d1.r[0].h                 ; use first header
    for i=0,npts-1 do begin
        val=moment(d1.r.d[i],/double)
        drms.d[i]=sqrt(val[1])/val[0]
    endfor
    return,drms
end
