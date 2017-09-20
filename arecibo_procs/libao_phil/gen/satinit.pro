;+
;NAME:
;satinit - initialize to use the satellite prediction routines.
;SYNTAX: @satinit   
;DESCRIPTION:
;   call this routine before using any of the satellite prediction routines.
;It sets up the path for the directory and defines the
;necessary structures.
;-
@geninit
addpath,'sat'
forward_function satinpfiles,satlistfiles,satpass,satsetup
;
  a={satPass,    jd: 0d,$ ; julday utc based
          secs:0d,$ ; from 1970
           az: 0d,$ ; source
           za: 0d,$ ;
          raHr:0d,$
          decD:0d,$ ;
;         some satellite info
          phase:0L,$ ; modulo 256. relative to perigee
          lat  :0L,$ ; of sub sat point (N)
          lon  :0L,$ ; of sub sat point (W)
          rangeKm:0L,$; slant range in km.
          orbitNum:0L}; increments each orbit.
;
	forward_function satinfo,satlisttlefiles,satpass,satpassplt,$
       satfindtle,satinptlefile,satpassconst,satsetup


