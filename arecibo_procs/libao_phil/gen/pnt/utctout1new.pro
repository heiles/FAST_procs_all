;+
;NAME:
;utctout1new - convert utc to ut1
;SYNTAX: ut1FractOffset=utctout1new(juldat)
;ARGS:
;   julDateUtc[n]: double julian date 
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
function  utcToUt1new,juldat

    jdTomjd=2400000.5D
    mjdF=juldat -  jdToMjd
    stop
    t   = 2000D - (51544.4D - mjdF)/365.242189813D
    dut2_ut1=0.022D*sin(2D*!dpi*T) - 0.012D* cos(2D * !dpi*T) $
                  - 0.006D* sin(4D*!dpi*T) + 0.007d* cos(4D*!dpi*T)

    return,(-.5323D  - .00031D * (mjdF - 53402D) - (DUT2_UT1))
end
;
; Mjd:53402 = -0.52158  compute   zeros mjdF dif..
;             -0.53132589  delta=10 ms..
;
; Mjd:51544 =   .048556     -0.52158  compute   zeros mjdF dif..
;
