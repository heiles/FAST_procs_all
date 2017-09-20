;+
;NAME:
;aIntro- Using the cgen  routines:
;    
;    The cummings generators are monitored using some modbus routines.
;Data is written to disc (/share/phildat/cummings/) once a minute 
;(if the generators are on).  Each file contains a months worth of
;data (filename: cgen_yyyymm.dat). 
;
;    The routines in the cgen package let you access and plot this data. 
;
;    The main routines used by users are:
;    
;@phil
;@cgeninit      - these routines will initialize the cgen routines
;cgeninpmonth() - input data for 1 month.
;cgenplot()     - plot some datainput and plot the data for a day, or continually monitor
;
;The data structure used  for each record:
;IDL> help,d,/st                                                       
;** Structure CGENINFO, 6 tags, length=664, data length=664:           
;   RECMARKER       BYTE  Array[4]  : "RECm" 
;   RECNUM          LONG            : 1.. N within file
;   YYYYMMDD        LONG            : 20131121  yyyymmdd when data read                             
;   SECMID          LONG            : 12964  secMid ast for data read                             
;   JD              DOUBLE          : julian data for data   read (gmt based)
;   GENI            STRUCT CGEN1 Array[4]: holds data for each generator                 
;
; The data for 1 generator:
;IDL> help,d[500].geni[2],/st
;** Structure CGEN1, 40 tags, length=160, data length=160:
;   DEVTYPE         LONG   3
;   CTRLSW          LONG   2
;   STATE           LONG   3
;   FAULTCODE       LONG   0
;   FAULTTYPE       LONG   0
;   KWPERCENT       FLOAT   76.0000
;   TOTKWST         FLOAT   755.000
;   NFPA110         LONG   24576
;   EXTENDEDST      LONG     0
;   FREQ            FLOAT   59.0000
;   TOTPF           FLOAT    0.921850
;   TOTKVA          FLOAT  821.000
;   TOTKW           FLOAT  755.000
;   TOTKVAR         FLOAT  319.000
;   VOLTSAB         FLOAT  4169.00
;   VOLTSBC         FLOAT  4174.00
;   VOLTSCA         FLOAT  4171.00
;   VOLTSA          FLOAT  2408.00
;   VOLTSB          FLOAT  2411.00
;   VOLTSC          FLOAT  2413.00
;   AMPSA           FLOAT  111.000
;   AMPSB           FLOAT  111.000
;   AMPSC           FLOAT  112.000
;   AMPSAPERCENT    FLOAT   64.5000
;   AMPSBPERCENT    FLOAT   64.0000
;   AMPSCPERCENT    FLOAT   64.5000
;   BATVOLT         FLOAT   27.1000
;   OILPRES         FLOAT   54.4037
;   OILTEMP         FLOAT   91.8400
;   COOLANTTEMP     FLOAT   80.1400
;   MISCTEMP1       FLOAT 6280.34
;   MISCTEMP2       FLOAT   37.5400
;   FUELRATE        FLOAT    0.00000  <-- this is not loaded by cummings
;   ENGRPM          FLOAT 1770.00
;   ENGSTARTS       LONG   684
;   ENGRUNTIME      FLOAT 1754.36
;   TOTKWH          FLOAT 530280.
;   TOTFUEL         FLOAT  55177.3
;   STARTCTRL       LONG     590
;   RESETCTRL       LONG    4169
;
;cgengetmonth will input an array of these structures d[n]. You can use cgenplot
;to plot the data, or you can use the normal idl plot routines for plotting.
;
; the d.genI.state variable will tell which generators were in used:
; ii=where(b.geni.state ne 0)
;
;
;EXAMPLES:
;;  start idl
;    idl
;    @phil
;    @rcgeninit
;
;    input month of nov13
;    nrecs=cgengetmonth(1311,d)
; 
;   plot a summary of the data
;	cgenplot,d
;-
