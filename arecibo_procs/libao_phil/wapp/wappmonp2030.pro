;+
;NAME:
;wappmonp2030 - monitor p2030 data 
;SYNTAX - wappmonp2030,yymmdd,online=online,clip=clip,img=img
;ARGS:
;  yymmdd: long     date to monitor. This is the ast date. It will include
;                   2 mjd days.
;KEYWORDS: 
;  online:          if set (online=1) then also search online data files.
;                   WARNING: this should not be used if people are using the
;                   wapps. Default is 0
; clip[2]: float    min,max value for clipping data in units of Tsys. Default
;                   is clip=[-.2,.2]
;wappmonimgp        Any other parameters used by wappmonimgp can also
;                   be used (except for pol,lvlcor,han which are set by
;                   this routine.
;RETURNS: 
;img[npnts,2]:float last image displayed. first index is sample points,
;                   2nd index is the 2 boards of the wapp displayed.
;DESCRIPTION:
;   monitor p2030 pulsar data using dynamic spectra. It calls the
;routine wappmonimgp() to do the display. Hitting any key while running
;brings up a selection menu. See wappmonimgp for a further description .
;
;EXAMPLE:
;   wappmonp2030,050411
;
;will display the data for 11apr05
;
;SEE ALSO:
;   wappmonimgp
;-
pro wappmonp2030,yymmdd,online=online,clip=clip,img=img,_extra=_e
;
    projid='p2030'
    han=1
    lvlcor=1
    if n_elements(online) eq 0 then online=0
    if n_elements(clip) eq 0 then clip=[-.2,.2]
;
;    make sure date is in the past
;
    a=bin_date()
    yymmddC=(a[0] mod 100L)*10000L + a[1]*100L + a[2]
    if yymmddC lt yymmdd then begin
        print,'Err: Requested date is in the future',yymmdd
        return
    endif
    if (yymmddC eq yymmdd) and (not online) then begin
        print,'Warning: Online option is 0. Data may not yet be offline'
    endif
    img=wappmonimgp(lun,h,projid=projid,yymmdd=yymmdd,clip=clip,$
                    lvlcor=lvlcor,han=han,pol=12,online=online,$
                    _extra=_e)
    return
end
