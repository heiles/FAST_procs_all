;+
;NAME:
;aIntro- Using the rcvmon  routines:
;    
;    The receivers have a dewar monitoring package that lets us monitor the
;dewar temperatures, bias voltages and currents, as well as some of the
;power supply voltages. Prior to 20dec02 this data was read manually by
;the operators and can be accessed using the dwtemp routines. 
;
;    On 20dec02 we switched to an automated continuous monitoring of the 
;receivers. It takes about 2.5 seconds to measure all of the information of
;a receiver and 22 seconds to cycle through all of the receivers. This 
;processes continues 24 hours a day. The data is written to disc in  a
;binary format. A new disc file is created each month using the filenaming
;conventions:
;    /share/obs4/rcvm/rcvmN     .. the current month
;    /share/obs4/rcvm/rcvmN.yymm .. previous months eg rcvmN.0211 for nov02
;
;Each of the files contains about 70Mbytes of data. The data is stored
;sequentially in time as it is sampled.
;
;    The routines in the rcvmon package let you access and plot this data. You
;need to be a bit careful what you ask for (because you might get it..). 
;Run idl on a computer with lots of memory (say fusion01, mango, mofongo,
;or pat each of which have 2 gigabytes).
;
;    The main routines used by users are:
;    
;rminpday() - input one or more days of data.
;rmplot()   - plot the temperatur data that was input.
; 
;rmmon()    - input and plot the data for a day, or continually monitor
;             the current values.
;
;The other routines are support routines used by these 3.
;
;The data structure used for each sample is:
;
;IDL> help,d,/st
;** Structure RCVMON, 13 tags, length=88:
;   KEY             BYTE      Array[4] The string 'rcv'
;   RCVNUM          BYTE               The receiver number
;   STAT            BYTE               bitfield
;                                      B0 - lakeshore disp is on
;                                      B1 - hemtLed polA on
;                                      B2 - hemtLed polB on
;   YEAR            INT                4 digit year
;   DAY             DOUBLE             daynumber of year with fraction of day.
;   T16K            FLOAT              16K stage temperature in deg K
;   T70K            FLOAT              70K stage temperature in deg K
;   TOMT            FLOAT              omt temperature in deg K
;   PWRP15          FLOAT              dewar +15 volt supply voltage
;   PWRN15          FLOAT              dewar -15 volt supply voltage
;   POSTAMPP15      FLOAT              postamp +15 volt supply voltage
;   DCUR            FLOAT  Array[3, 2] bias current [Amps123 , polAB]
;   DVOLTS          FLOAT  Array[3, 2] bias voltage [amps123 , polAB]
; 
;
;rminpday will input an array of these structures d[n]. You can use rmplot
;to plot the data, or you can use the normal idl plot routines for plotting.
;
;Unless you have specified a particular rcvnum on the call to rminpday(), you
;will have all receivers combined in d. You can use the idl where() routine
;to make a subset of the input data.
;
;EXAMPLES:
;;  start idl
;    idl
;    @phil
;    @rcvmoninit
;
;; input dec20 through 25
; 
;    nrecs=rminpday(021220,d,lastday=021225) ; this takes about 10 seconds
;                                            ; and 15 mbytes.
;;  plot the 16 k stage using colors for each and ascii dates
;    ver,0,30
;    rmplot,d,/adate
;;  plot the 70k stage 1 receiver per frame
;    ver,0,100
;    rmplot,d,temp=1,/adate,/mframe
;;
;    plot the 70k and omt  stage on same plot.   
;    ver,0,120
;    rmplot,d,temp=1,/adate
;    rmplot,d,temp=2,/adate,/over
;
;; plot the bias currents for the third amp
;    rmplot,d,cur=2,/adate
;
;; do the above plot using where() and plot of idl
;   ind=where(d.rcvnum eq 11)       ; xband
;   plot,d[ind].dcur[2,0]             ; pola 3rd amp
;   oplot,d[ind].dcur[2,1],color=2     ; polB 2rd amp,red
;-
