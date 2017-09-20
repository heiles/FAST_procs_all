;+
;NAME:
;tempplot - plot temperature in turret room for a range of days.
;SYNTAX:
;   tempplot,yymmdd1,yymmdd2 ,title=title,cs=cs,xp=xp,off=off,lun=lun,sep=sep,$
;           clip=clip
;ARGS:
;   yymmdd1 - long  first day to plot
;   yymmdd2 - long  last day to plot
;KEYWORDS:
;   title   - string title for top of each plot
;   cs      - float  scale factor for labels. For multiple windows you may
;                    want to increase this to 1.5 or 1.8. default is 1.
;   xp      - float  xposition [0.,1.] where dates are printed. default:.02.
;                    For hardcopy setting this to 1. puts the dates on the
;                    right column.
;   off     - float  number of degrees to offset each day within it's 
;                    window so the plots don't lay on top of each other.
;                    defaut:0.
;   lun     - int    if supplied, then you've already opened the input file.
;                    Use this to access previous years:
;                    eg: /share/obs4/temp/Y01/temp.dat
;   sep     -        if set then make 1 plot per day user should set
;                    !p.multi before calling the routine. 
;   clip[]  -float   clip the data to [mintemp,maxtemp]. allows auto scaling
;                    with bad data points..
;                    
;DESCRIPTION
;   plot the temperature in the turret room by hour of day for the
;range of dates specified (the routine limits it to a maximum of 31 days).
;The plot will have N subwindows with up to 7 consecutive days per window. 
;Each day will be color coded witin a window. Any extra days (>28 will appear
;in the last window). The routine internally uses daynumber of year for
;computations so it will not cross year boundaries gracefully. It also reads
;from the temperature file that holds info by year (so the current year 
;is the only one that will work.
;
;You should call ldcolph to setup the colortables for indices 0-10. You 
;should also set the vertical scale to temperature range you want via 
;ver,vmin,vmax. The horizontal scale should be set to hor,0,24.
;The extra keywords that may be used are:
; charsize=cs. If the multiple windows cause the letters to come out
;too small.
;
;EXAMPLES:
;   hor,0,24
;   ver,70,90
;   tempplot,010701,010731,title='turret room temps for jul01',$
;            cs=1.6
;NOTES:
;   This routine reads from the file /share/obs4/temp/temp.dat. The routine
;will only work when run at AO (since the file is not accessible at
;remore sites). 
;   The routine will not cross year boundaries very gracefully. The 
;data files usually contain only one years worth of data. The previous
;years data is in (/share/obs4/temp/yyyy/temp.dat where yyyy is the year.
;   Tempread has not yet been updated to work on a pc (you need to run it
;on a sun (big endian machine).
;SEE ALSO:
;   tempread.
;-
pro tempplot,yymmdd1,yymmdd2,title=title,cs=cs,xp=xp,off=off,lun=lun,$
            sep=sep,clip=clip
;
    common colph,decomposedph,colph
    cliploc=[-1e6,1e6]
    if n_elements(off) eq 0   then off=0
    if n_elements(title) eq 0 then title=''
    if n_elements(cs) eq 0    then cs=1.
    if n_elements(xp) eq 0    then xp=.02
    if n_elements(lnscl) eq 0 then lnscl=[1.,.5,.5,.5]
    if n_elements(sep) eq 0   then sep=0
    if n_elements(clip) eq 2   then cliploc=clip
    lnstar=[[3,0,0,0],$         ;line notes start for nwins
         [2,17,0,0],$
         [1,11,21,0],$
         [1,8.5,16,23.5]]
    xp=xp
    sclar=[1.,.5,.5,.5]
    maxdays=31
    dayinmon=[31,28,31,30,31,30,31,31,30,31,30,31]
    monl=0
    if keyword_set(month) then monl=1
    yy1=yymmdd1/10000 + 1900
    yy2=yymmdd2/10000 + 1900
    if yy1 lt 1990 then yy1=yy1+100
    if yy2 lt 1990 then yy2=yy2+100
    mm1=(yymmdd1/100 mod 100)
    mm2=(yymmdd2/100 mod 100)
    day1=(yymmdd1 mod 100)
    day2=(yymmdd2 mod 100)
    if monl eq 1 then begin
        day1=1
        day2=day1+dayinmon[mm1]-1
    endif
    dayno1=dmtodayno(day1,mm1,yy1)
    dayno2=dmtodayno(day2,mm2,yy2)
    ndays=dayno2-dayno1  + 1            ; will not cross years..
    if ndays gt maxdays then begin
        dayno2=dayno1+maxdays-1
        ndays=maxdays
    endif
;
;   try reading data at one fell swoop 
;
    nrecs=maxdays*86400./10.        ; sampled every 10 secs
    d=tempread(yymmdd1,nrec=nrecs,lun=lun)
    nwin=ndays/7
    if (ndays mod  7 ) ne 0 then nwin=nwin+1
    if nwin gt 4 then nwin=4
    curday=dayno1
    winleft=nwin
    for i=0,ndays-1 do begin
        if i mod 7 eq 0 then begin
            if i eq 0 then begin
                if not sep then !p.multi=[0,1,nwin]
                needplot=1
                color=1 
                curwin=0
            endif else begin
                winleft=winleft-1   
                if winleft gt 0 then  begin
                    if not sep then !p.multi=[winleft,1,nwin]
                    color=1 
                    curwin=curwin+1
                    needplot=1
                endif
            endelse
        endif
        ind=where(long(d.time) eq curday,count)
        if count gt 0 then begin
            lninwin=i-curwin*7
            offl=off*lninwin
            h=(d[ind].time- long(d[ind[0]].time))*24.
            a=daynotodm(curday,yy1)
            lab=string(format='(i2.2,i2.2,i2.2)',yy1 mod 100,$
                a[1],a[0])
            y=d[ind].temp
            ind=where(y lt cliploc[0],count)
            if count gt 0 then y[ind]=cliploc[0]
            ind=where(y gt cliploc[1],count)
            if count gt 0 then y[ind]=cliploc[1]

            if needplot or sep then begin
                titlel=title
                if sep then titlel=title+' '+lab
                plot,h,y+offl,xtitle='hour of day',$
                    ytitle='temp DegF',title=titlel,charsize=cs
                needplot=0
                color=1
            endif else begin
                oplot,h,y+offl,color=colph[color]
            endelse
            lnst=lnstar[curwin,nwin-1]
            scl=sclar[nwin-1]
            if not sep then $ 
            note,lnst+lninwin*scl,lab,xp=xp,color=colph[color]
        endif

        color=color+1
        curday=curday+1
    endfor
    return
end
