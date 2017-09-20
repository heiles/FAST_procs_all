;+
;NAME:
;sunazza - compute sun az,za (approximate).
;
;SYNTAX: [az,za]=sunazza(ra1,dec1,ra2,dec2,gmtSecs)
;ARGS:
;   ra1[3]: double,float  hour, min,sec sun start of gmt day 1
;                         apparent right ascension
;                    see astronomical almanac c4->
;  dec1[3]: double,float  deg, min,sec sun start of gmt day 1
;   ra2[3]: double,float  hour, min,sec sun start of gmt day 2
;  dec2[3]: double,float  deg, min,sec sun start of gmt day 2
;  gmtsecs: double        secsmidnite from ra1 day start for computation.
;                         (ast+4 hours)
;-
function sunazzaq,ra1,dec1,ra2,dec2,gmtsecs
    az=0.
    za=0.
    fractDay=gmtSecs/86400.
    ra1Rd=(ra1[0]+ra1[1]/60.D+ra1[2]/3600.D)/24.D*2.D*!pi
    ra2Rd=(ra2[0]+ra2[1]/60.D+ra2[2]/3600.D)/24.D*2.D*!pi
    dec1Rd=(dec1[0]+dec1[1]/60.D+dec1[2]/3600.D)*!dtor
    dec2Rd=(dec2[0]+dec2[1]/60.D+dec2[2]/3600.D)*!dtor
    raSunRd =ra1Rd+(ra2Rd-ra1Rd)*fractDay
    decSunRd=dec1Rd+(dec2Rd-dec1Rd)*fractDay
    latobsRd=( 18.+21./60. + 14.2/3600.)*!dtor ; ao latitude
    message,"routine not done yet"
    return,[az,za]  
