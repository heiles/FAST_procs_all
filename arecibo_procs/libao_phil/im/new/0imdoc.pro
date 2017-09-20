;+
;NAME:
;0imdoc - interference mon documentation.
;
;*DAY-----------------------
;imgfrq,{imday},frq,{imday}  - extract 1 freq subset from {imday}
;iminpday,yymmdd ,{imday}    - input the days worth of data
;imls                      - ls current im files online
;imopen  ,yymmdd ,lun      - open file, return lun in lun
;{imdrec}=imavg  ,{imday1frq} -return average rec for day. use imgfrq 1st
;*PLOTTING_-----------------
;implot  ,{imdrec}         - plot a an im data structure
;implloop,{imday} ,delay   - loop plotting imd with delay secs between each
;x[401]=immkfrq ,{imdrec}  - return x array holding the freq for the rec
;immktm  ,{imday} ,y       - return y array holding the times(hour)for the rec
;*PLOTTING SEQUENTIAL-------
;imfreq  ,{imday} ,freq    - freq to plot or -1 freq any freq
;imd     ,{imday} ,recnum  - plot recnumber
;imc     ,{imday}          - replot current rec
;imn     ,{imday}          - plot next rec of selected freq
;*MISC----------------------
;iminprec,lun,{imdrec}     - input the next record from the file
;imlin   ,{imday}          - convert data from db to linear scale
;imdb    ,{imday}          - convert data from linear to db
;tsys=imtsys,freq          - return tsys for this freq. 0 if not known
;davg=imavg(imday)         - compute average 1 freq, 1 day
;drms=imrms(imday)         - rms by channel 1 freq, 1 day
;
;*STRUCTURES----------------
;d:{imday}          - returned by iminpday
;d:yymmdd           - int
;d.nrecs            - how many records in day
;d.frql[int]        - list of frequencies for this day
;d.r[imdrec]        - array of data records. hdr and data
;d.crec             - current rec for plotting 1..nrecs
;d.cfrq             - current rec for plotting (or -1).
;d.r.d[12]          - data record 12, 401 points
;
;r:{imdrec}         - one integration in {imday}
;r.h                - {imhdr} header
;r.d                - [float 401]   data
;
;h:{imhdr}          - header routine for each record
;h.hdrMarker        - bytarr(4)
;h.hdrlen           - 0L
;h.reclen           - 0L
;h.versionj         - bytarr(4)
;h.date             - yyyyddd
;h.secMid           - 0L
;h.cfrDataMhz       - float
;h.cfrAnaMhz        - float
;h.spanMhz          - float
;h.integTime        - long, seconds
;h.srcAzDeg:        -   0L
;-
