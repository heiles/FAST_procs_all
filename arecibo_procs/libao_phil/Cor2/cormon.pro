;+
;NAME:
;cormon - monitor data from file.
;SYNTAX: cormon,lun,b,m=pltmsk,han=han,vel=vel,pol=pol,scan=scan,
;                   avgscan=avgscan,quiet=quiet,no1rec=no1rec,sl=sl,delay=delay
;                   secperwait=secperwait
;    ARGS:
;           lun:    int assigned to open file.
;KEYWORDS:
;             m:    which sbc to plot.. bitmask b0->b3 for brd1->4
;           han:    if set then hanning smooth the data
;           pol:    limit the polarizations to look at 1- polA, 2-polB
;           vel:    if set then plot versus velocity. def:freq.
;          scan: long position to scan before starting the monitoring
;       avgscan:    if set then only plot scan averages 
;       quiet  :    if set and avgscan set, then do not print out rec numbers
;       no1rec :    if set and avgscan set,  do not plot scans that contain
;                   only 1 record.
;       sl[]   :  {sl} if scan list is provided (see getsl()) then 
;                   only display the scans in sl. When done return
;                   rather than wait for next rec.
;       delay  : float seconds to wait between plots (useful if you are 
;                      scanning a file offline. default:0
;       secperwait: float When no data is available, the routine will
;                      wait 1 sec before checking again. You can override
;                      this (if you are dumping faster than once a second.
; RETURNS:
;             b:    {corget}  data from last read
;DESCRIPTION:
;   Monitor the data in a file. When the routine hits the end of file it
;will continue plotting as new data becomes available. This routine
;is normally used for online monitoring. To exit the routine use ctrl-c.
;
;   Use the avgscan keyword if you want to only plot the scan averages. This
;is a good thing to do if you are observing remotely and the network
;connection can not keep up with displaying every record.
;
;   An annoyance with the  /avgscan setting is that it always displays the 
;scan average of the last completed scan. Suppose you are doing 5 minute
;on/offs followed by 10 second cal/offs. You will wait 5 minutes for the
;on scan, 5 minutes for the off scan, and then in 10 seconds the cal on
;scan will be plotted (losing the off scan plot). The /no1rec keyword tells
;cormon to not bother plotting scans that only have 1 record (the calon,
;caloff records are separate scans of 1 record each). This will give
;you the complete 5 minutes to look at the 5 minute off.
;
;   The sl option can be used to scan files offline. The routine will
;return when done rather than wait. It also allows you to plot a subset
;of a file.
;
;EXAMPLES:
;   cormon,lun      .. monitor every rec, all sbc,pol
;   cormon,lun,m=1  .. monitor every rec, sbc 1, both pol.
;   cormon,lun,m=2  .. monitor every rec, sbc 2, both pol.
;   cormon,lun,m=5  .. monitor every rec, sbc 1,3, both pol.
;   cormon,lun,m=8,pol=1 ..monitor every rec, sbc 4, pol A.
;   cormon,lun,/avgscan.. monitor scan averages only
;   cormon,lun,/avgscan,/no1rec.. monitor scan averages,skip scans with 1 rec
;   cormon,lun,/avgscan,/quiet.. monitor scan averages,don't output rec #'s
;   use the sl option to plot all records from receiver 6
;   sl=getsl(lun)
;   ind=where(sl.rcvnum eq 6,count)
;   if count gt 0 then cormon,lun,sl=sl[ind]
;SEE ALSO:
;   corplot, getsl()
;-
pro cormon,lun,b,m=pltmsk,han=han,vel=vel,pol=pol,avgscan=avgscan,quiet=quiet,$
                    no1rec=no1rec,sl=sl,delay=delay,scan=scan,$
                    secperwait=secperwait
;
; monitor from file
;
    on_error,1
    forward_function waitnxtgrp
    if (n_elements(pltmsk) eq 0) then pltmsk=15
    if (n_elements(pol) eq 0) then pol=0
    if (not keyword_set(vel)) then vel=0
    if (not keyword_set(han)) then han=0
    if (not keyword_set(avgscan)) then avgscan=0
    if (not keyword_set(quiet)) then quiet=0
    if (not keyword_set(no1rec)) then no1rec=0
    if (n_elements(delay) eq 0) then delay=0.
    slscan=-1
    slrec =0
    if n_elements(sl) gt 0 then begin
        slscan=0
        slnum=n_elements(sl)
;       position to start of first scan
        scanstart=sl[0].scan
        if keyword_set(scan) then scanstart=scan
        istat=posscan(lun,scanstart,1,sl=sl)
        if istat ne 1 then begin
            print,sl[0].scan,' not in file'
            return
        endif
    endif else begin
        if keyword_set(scan) then begin
          istat=posscan(lun,scan,1,sl=sl)
          if istat ne 1 then begin
            print,scan,' not in file'
            return
          endif
        endif
    endelse
    recaccum=0.
    lastscan=-1
    for i=0L,99999  do begin
        if slscan eq -1 then begin
            istat=waitnxtgrp(lun,secperwait=secperwait)
            if (istat  ne 0)  then begin
                 print,"waitnxtgrp error. istat",istat
                return
            endif
            point_lun,-lun,a
            istat=corget(lun,b,han=han)
            if istat ne 1 then return
        endif else begin     
;           new scan , position
;           print,slscan,slrec,sl[slscan].scan,sl[slscan].numrecs
            istat=1
            if (slrec ge sl[slscan].numrecs) then begin
                slscan=slscan+1
                if slscan ge slnum then return
;               print,'position to sl[slcan].scan'
                istat=posscan(lun,sl[slscan].scan,1,sl=sl)
                slrec=0
            endif
            if istat eq 1 then istat=corget(lun,b,han=han)
            if istat ne 1 then begin
                print,'scan:',sl[slscan].scan,' not in file'
                return
            endif
            slrec=slrec+1
        endelse
        if avgscan then begin
           if lastscan ne b.b1.h.std.scannumber then begin
                if ((recaccum gt 0) and (no1rec eq 0)) or $
                    ((recaccum gt 1) and (no1rec eq 1)) then begin
                    corplot,baccum,m=pltmsk,vel=vel,pol=pol
                endif
                coraccum,b,baccum,/new
                recaccum=1.
            endif else begin
                coraccum,b,baccum
                recaccum=recaccum+1.
            endelse
            lastscan=b.b1.h.std.scannumber
            if not quiet then $
                    print,b.b1.h.std.scannumber,b.b1.h.std.recnumber
        endif else begin
            corplot,b,m=pltmsk,vel=vel,pol=pol
        endelse
        if delay gt 0. then wait,delay
    endfor
end
