;+
;NAME:
;tec0intro - Intro to using the atm tec routines.
;   
;   The  tec (Total Electron Cnt) data is recorded from a receiver
;at the lidar lab. It receives a dual frequency beacon from a number
;of satellites and converts this info to tec. Data is processed and stored
;once a second for each satellite pass. Routines are used to move this data
;to an idl archive where it can be extracted and plotted with the tec
;idl routines.
;   Each pass of a satellite will last a few hundred seconds. The processed
;data is stored in an idl structure at 1 second intervals. This data
;structure contains the data from the processed file  (the interpretation of
;some of the elements is still waiting on hien).
;
; help,tar,/st
; JD       DOUBLE   2454161.7 ; julian date for sample to 1 sec resolution
; TEC      FLOAT    0.686000  ; slant relative tec for this second.
; SAT      INT      6         ; satellite code (see tecsatnm(code) for name)
; PH       INT      20        ; phase flag ??
; UHF      INT      0         ; uhf flag
; VHF      INT      4         ; vhf flag
; PASSNUM  LONG     18        ; unique number for each pass of a satellite
; AZ       FLOAT    318.140   ; azimuth of satellite from ao
; EL       FLOAT    19.5100   ; elevation of the satellite from ao.
; FLAT     FLOAT    23.4100   ; lattitude where ao-sat pierces fregion
; FLON     FLOAT    -71.9000  ; longitude where ao-sat pierces fregion
; ELAT     FLOAT    20.0500   ; lattitude where ao-sat pierces eregion
; ELON     FLOAT    -68.5100  ; longitude where ao-sat pierces eregion
;
;
;=========================
; Notes on the dataset:
;=========================
; -  The data set started on 20dec06. 
; -  It looks like the tec data has not been range corrected.
; -  There has been no data quality filtering. There are a bunch of 
;    elevations < 0.
;
;
;=========================
; Using  the tec idl routines:
;=========================
;   - starting idl:
;   idl
;   @phil
;   @tecinit
;
;   - inputting a range of tec data (say 28jan07 thru 31jan07);
;
;   yymmdd1=070128
;   yymmdd2=070131
;   npnts=tecget(yymmdd1,yymmdd2,tar)
;
;   - converting from slant tec to vertical tec for 300 km:
;     hght=300.
;     tecV=tecver(tar,hght)k
;
;   - plotting:
;     - the tecvalue
;     plot,tar.tec
;     - the tec value by date:
;     xtickf=tecbydate()
;     plot,tar.jd,tar.tec,xtickf=xtickf
;
;     - tec value by ast hour
;       hr=tecasthr(tar)            ; convert to ast hr
;       plot,hr,tar.tec,psym=1      ; put a cross at each point
;
;   - help
;     explain,tecdoc    .. list tec routines
;     explain,tec0intro .. list this help
;     explain,tecget    .. list tecget doc
;
;-
