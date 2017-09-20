;+
;NAME:
;am0intro - Using the alfamon  routines:
;    
;    Alfa has a dewar monitoring package that lets us monitor the
;dewar temperatures, bias voltages and currents, as well as some of the
;power supply voltages. 
;
;	The data is sampled once every 300 seconds.  This processes continues 
;24 hours a day. The data is written to disc in  ascii format. The current
;file is /share/cima/Logs/ALFA_logs/alfa_logger.log. At the end of 
;each month the data is moved to alfa_logger_yyyy_mm.log.
;
;Each of the files contains about 10Mbytes of data. The data is stored
;sequentially in time as it is sampled.
;
;    The routines in the alfamon package let you access and plot this data. You
;need to be a bit careful what you ask for (because you might get it..). 
;Run idl on a computer with lots of memory (say alocn)
;
;    The main routines used by users are:
;    
;aminpday() - input one or more days of data.
;amplot()   - plot the temperature,voltages, or currents that were input.
; 
;ammon()    - input and plot the data for a day, or continually monitor
;             the current values. (not yet implemented..)
;
;The other routines are support routines used by these 3.
;
;The data structure used for each sample is:
;
;DL> help,d,/st
;** Structure ALFAMON, 21 tags, length=664, data length=662:
;   TMA       STRING '20090202000417' yyyymmddhhmmss in ascii
;   JD        DOUBLE 2454864.7
;   BIAS_CTL  INT    0              0 local, 1 remote
;   BIAS_STAT INT    Array[2, 7]    [pol,beam] 0 off, 1 amps on ; 
;   VD        FLOAT  Array[2, 7, 3] [pol,beam,stage1,2,3] drain Voltage
;   ID        FLOAT  Array[2, 7, 3] [pol,beam,stage1,2,3] drain Current
;   VG        FLOAT  Array[2, 7, 3] [pol,beam,stage1,2,3] gate Voltage
;   T20       FLOAT  Array[4]       20K temp K1..K4
;   T70       FLOAT  Array[4]       70K temp K1..K4
;   V32P      FLOAT  31.9630        Plus 32Volt power supply
;   V20P      FLOAT  19.9060        Plus 20 Volt power supply
;   V20N      FLOAT  -20.1310       negative 20 Volt power supply
;   V9P       FLOAT  8.77000        Plus 9 Volt power supply
;   V15P      FLOAT  Array[6]       Plus 15 Volt power supply R1..R6
;   V15N      FLOAT  Array[4]       Neg  15 Volt power supply R1..R4
;   V5P       FLOAT  Array[2]       Plus 5 Volt power supply R1..R2
;   CALCTL    INT    3
;   NSELEV    INT    1
;   NSEDIODET INT    0
;   VACSTAT   INT   96
;   VACLEV    FLOAT  0.00000
;
;aminpday will input an array of these structures d[n]. You can use amplot
;to plot the data, or you can use the normal idl plot routines for plotting.
;
;
;EXAMPLES:
;;  start idl
;    idl
;    @phil
;    @alfamoninit
;
;; input 01feb09 thru 10feb09
; 
;    nrecs=aminpday(20090201,d,lastday=20090210) ; 
;;  plot the 16/70  k stage using colors for each and ascii dates
;    ver,0,30
;    amplot,d,/adate,/temp
;;
;; plot the bias Drain currents for the third stage amps
;    amplot,d,Id=3,/adate
;
;-
