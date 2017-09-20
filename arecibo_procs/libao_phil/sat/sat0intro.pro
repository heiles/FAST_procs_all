;+
;NAME:
;sat0intro - Intro to using the ao satellite prediction routines.
;   
;   The  ao idl satxxx routines will predict passes of satellites over AO.
;They interface to the predict program:
;         PREDICT: A satellite tracking/orbital prediction program         
;         Project started 26-May-1991 by John A. Magliacane, KD2BD       
;                       Last update: 14-May-2006                     
;   The routines use two line element sets (tle's) that are updated daily
;at the observatory. They can only be run at AO since they are calling
;the predict program which is not distributed with phil's idl routines.
;
; Getting started:
;   @phil
;   @satinit
;   satpassplt,/gps
;   .. will plot the gps constellation passes for the current time.
;
; the routines currently available can be found via:
; explain,satdoc
;  .. it outputs:
;
;satdoc - routine list (single line)
;
; normal routines called by user
;  satdoc           - routine list (single line)
;1.satinfo          - return tle entry for all satellites
;2.satpass          - compute satellite pass at AO
;3.satpassconst     - compute satellite pass for a constellation
;4.satpassplt       - plot all sat of  constellation as they pass over AO
;
; utility routines used by above routines (and be user if they want)
;
isatfindtle       - find tle file for satellite name
;satsetup         - return setup info for sat routines
;satinptlefile    - input an entire tle file
;satlisttlefiles  - return list of tle files
;
;*************************************************************
;1. satinfo -  to find out which satellites we have tle files for:
;*************************************************************
;   return a structure holding info on all satellites we know about:
;
;  n=satinfo(satI)
;help,satI,/st
;   NM              STRING    'GIOVE-A'
;   TLEFILE         STRING    '/share/megs/phil/predict/tle/galileo.tle'
;   TLE             STRUCT    -> <Anonymous> Array[1]
;
;   .. The tle info for each satellite
;help,satI.tle,/st
;   SATNM           STRING    'GIOVE-A'
;   SATNUM          INT          28922
;   SATCLASS        STRING    'U'
;   LAUNCHYR        LONG              2005
;   LAUNCHNUM       INT             51
;   LAUNCHPIECE     STRING    'A  '
;   EPOCHYR         LONG              2008
;   EPOCHDAY        DOUBLE           260.32344
;   TMDER1          DOUBLE       2.2000000e-07
;   TMDER2          STRING    ' 00000-0'
;   DRAG            DOUBLE           10000.000
;   EPHTYPE         STRING    '0'
;   ELMNUM          INT            394
;   INCLINATION     DOUBLE           56.055200
;   RAASCNODE       DOUBLE           164.58550
;   ECCENTRICITY    STRING    '0007843'
;   ARGOFPERIGEE    DOUBLE           331.59930
;   MEANANOMALY     DOUBLE           28.417500
;   MEANMOTION      DOUBLE           1.7019477
;   REVNUM          LONG              1690
;   LINES           STRING    Array[3]
;
;************************************************************
;2. satpass - Compute a single pass for a 1 satellite:
;************************************************************
; npts=satpass(satNm,passI,hhmmss=hhmmss,yymmdd=yymmdd)
;   Returns and array passI[npts] that holds info for each point of the
;pass.
;
; help,passI
; JD       DOUBLE       2.7793265e+08 .. jd for this point
; SECS     DOUBLE       1.2221659e+09 .. secs 1970 for this point
; AZ       DOUBLE           204.47500 .. source az for pnt
; ZA       DOUBLE           89.974000 .. za for this pnt
; RAHR     DOUBLE          0.23571587 .. J2000 right ascension in hours for ;
;                                        this point
; DECD     DOUBLE          -66.452344 .. J2000 declination in deg for this point
; PHASE    LONG               226     .. phase in orbit 0..255
; LAT      LONG               -50     .. north lattitude of sat sub orbit point
; LON      LONG               105     .. west longitude  of sat sub orbit point
; RANGEKM  LONG             25677     .. slant range in kilometers to satellite
; ORBITNUM LONG              4142     .. orbit number. increments once each orbit.  
;
;************************************************************
;3. Compute satellite passes for a constellation of satellites
;************************************************************
; npts=satpassconst(satAr,/gps)
;   Returns satAr[31]. Each entry is the pass info for a single satellite
;in the gps constellation.
;
;help,satAr[0],/st
;   NPNTS           LONG       92   .. pnts in pass for this satellite
;   SATNM           STRING    'GPS16' .. sat Nm
;   ZAMIN           FLOAT           18.8350 .. min za for pass
;   SECSMIN         DOUBLE       1.2217464e+09     .. time for minza secs1970
;   P               STRUCT    -> SATPASS Array[150] .. pnts in pass
;
; Note that satAr[0].p[150] is dimensioned as 150 but there are only
;satAr[0].npts = 92 valid points in the array. The number of points
;varies with each satellite pass.
;
;************************************************************
;4. plot passes for  a  satellite constellation
;************************************************************
;   satpassplt,yymmdd=yymmddd,hhmmss=hhmmss,satAr=satAr,v=v,/glonass
;  Will plot the az,za for each of the glonass satellites for the given time.
;The passInfo can be returned in satAr if you want. You can control
;the vertical scale with v. 
;   To get hardcopy with za 0 to 20 for 23sep08 141500 AST (when the
;next L3 test is scheduled) you could:
;
;pscol,'gpspass_1.ps',/full
;hhmss=141500
;yymmdd=080923
;v=[0,20]
;satpassplt,yymmdd=yymmdd,hhmmss=hhmmss,v=v,/gps
;hardcopy
;x
;ldcolph
;
; Note that the azimuth plotted is the source azimuth.
;WARNINGS:
;	- the keyword: tlefile=  or tledir= keyword has been
;     added to let you use non-standard locations for the
;     tlefiles. I've noticed that predict only allows
;     up to 48 characters for the entire filename..
;     So don't use long path/filenames...
;
;************************************************************
; for more info use
; explain,satroutine
;-
