;+
;NAME:
;utctout1 - convert utc to ut1
;SYNTAX: ut1FractOffset=utctout1(juldat,utcinfo)
;ARGS:
;   julDateUtc[n]: double julian date 
;   utcInfo:{}     read in by utcinfoinp
;RETURNS:
;   ut1FracOffset[n]: double add this to utc based times to get ut1
;
;DESCRIPTION
;
; Return the offset from utc to ut1 as a fraction of a day. The returned
; value (dut1Frac) is defined as ut1Frac=utcFrac + dut1Frac;
; The fraction of a day can be  < 0. 
;   
; The utc to ut1 conversion info is passed in via the structure UTC_INFO.
;-
function  utcToUt1,juldat,utcInfo

    return,(1d-3*1./86400.D * $
          (utcInfo.offset + ((juldat - utcInfo.juldatAtOff))*utcInfo.rate))
end
