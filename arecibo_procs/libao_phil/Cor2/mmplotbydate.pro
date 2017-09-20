;+ 
;NAME:
;mmplotbydate - plot calibration observations by receiver and date
;SYNTAX: mmplotbydate,date=date
;KEYWORDS:
;   date[2]: long   start, end date for plot. format is [yymmdd1,yymmdd2]
;   flagmon:        if set then flag the start of each month.
;
;DESCRIPTION:
;   Make a plot of the cumulative calibration observations done vs date. 
;Each receiver is plotted separately. By default the observations done in the 
;previous 12 months are used. The keyword date lets you specify a different 
;date range.
;
;NOTE:
;   This routine uses the calibration database which is updated at the end
;of each month. The current months data will not be available until the
;start of the next month.
;-
pro mmplotbydate,date=date,flagmon=flagmon
        common colph,decomposedph,colph


    flagjdcol=2
    flagjdls =2
    MJD_OFFSET=2400000.5D
    if n_elements(date) ne 2 then begin
        a=bin_date()
        yr2 =a[0]
        mon=a[1]
;
;       first day this month
;
        day=01
        yr1=yr2-1
        yr1=yr1 mod 100
        yr2=yr2 mod 100
        yymmdd1=yr1*10000L + mon*100L + day
        yymmdd2=yr2*10000L + mon*100L + day
    endif else begin
        yymmdd1=date[0]
        yymmdd2=date[1]
    endelse
;
;    get the data
;   
    n=mmgetarchive(yymmdd1,yymmdd2,mm)
;
;   do we generate flags start of each month?
;
    if keyword_set(flagmon) then begin
        mon=(yymmdd1/100L)  mod 100L
        yr =(yymmdd1/10000L) + 2000L
        jdlast=yymmddtojulday(yymmdd2)
        flagjd=0
        repeat begin
            dayno=dmtodayno(1,mon,yr)
            jd=daynotojul(dayno,yr)
            mon+=1
            if mon gt 12 then begin
                mon=1
                yr+=1
            endif
            flagjd=(flagjd[0] eq 0)?jd:[flagjd,jd]
        endrep until jd ge jdlast
;
;      so we line up with tick marks.
;
        flagjd-=.5d 
    endif
;  
;
;   just keep board 1
;
    ind=where(mm.brd eq 0,n)
    if n eq 0 then return
    mm=mm[ind]
    ind=sort(mm.julday)
    mm=mm[ind]
;
;   split receivers into 4 plots
;
    a={a,   rcvNum: 0,$ 
          rcvFrq : 0.,$
          rcvLab : '',$
          pltNum : 0 ,$
          maxpnts: 0L }  ; 
    rcvL=replicate(a,15)

    rcvL[0]={a,1   , -1. , '327'  ,0,0} 
    rcvL[1]={a,2   , -1. , '430gr',0,0} 
    rcvL[2]={a,100 , -1., '430ch',0,0} 
;    rcvL[3]={a,3   , -1., '610'  ,0,0} 
    rcvL[3]={a,3   , -1., '800'  ,0,0} 
    rcvL[4]={a,5   , 1175., 'lbw_L',1,0} 
    rcvL[5]={a,5   , 1415., 'lbw_H',1,0} 
    rcvL[6]={a,12  , -1   , 'sbn'  ,1,0} 
    rcvL[7]={a,7   , -1   , 'sbw'  ,1,0} 

    rcvL[8]={a,8   , -1   , 'sbh'  ,2,0} 
   rcvL[ 9]={a,9   , 4100., 'cb_L' ,2,0} 
   rcvL[10]={a,9   , 4500., 'cb'   ,2,0} 
   rcvL[11]={a,9   , 5000., 'cb_H' ,2,0} 

   rcvL[12]={a,10  , -1.  , 'cbH'  ,3,0} 
   rcvL[13]={a,11  , 8500.  , 'xb_L' ,3,0} 
   rcvL[14]={a,11  , 10500. , 'xb_H' ,3,0} 

   laball='Cumulative calib scans for: '
   labplt=[labAll + '327, 430 dome, 430 ch, 800 Rcvrs',$
           labAll + 'lbw_L, lbw_H, sbn, sbw Rcvrs',$
           labAll + 'sbh, cb_L, cb, cb_H Rcvrs',$
           labAll + 'cbh, xb, xb_H Rcvrs']
    
    nplots=4
;
; now get the list of receivers we found
;
    nrcv=n_elements(rcvL)
;
;   now round to each day
    juld1=long(yymmddtojulday(yymmdd1) - .5D)
    juld2=long(yymmddtojulday(yymmdd2) - .5D)
;
;   loop over plots and receivers
;
    x=findgen(juld2-juld1+1L) + juld1*1D

    colar=[1,2,4,7]
    symar=[1,2,4,5]
    a=label_date(date_format='%D%M%Z')
    xtformat='label_date'
;
;
;   first loop thru computing max for each plot
;
    for  ircv=0,nrcv-1 do begin
        if rcvL[ircv].rcvFrq gt 0. then begin
            ind=where((mm.cfr    eq rcvL[ircv].rcvFrq ) and $
                      (mm.rcvnum eq rcvL[ircv].rcvNum),count)
        endif else begin
            ind=where((mm.rcvnum eq rcvL[ircv].rcvNum),count)
        endelse
        rcvL[ircv].maxpnts=count
    endfor
;
; now the plotting
;
    !p.multi=[0,1,4]
    xp=.04 
    ln=2
    linc=7.5
    scl=.7
    cs=1.8
    hor,juld1-5,juld2+5
    curplot=-1
    sym=0
    for  ircv=0,nrcv-1 do begin
        if rcvL[ircv].rcvFrq gt 0. then begin
            ind=where((mm.cfr    eq rcvL[ircv].rcvFrq ) and $
                      (mm.rcvnum eq rcvL[ircv].rcvNum),n)
        endif else begin
            ind=where((mm.rcvnum eq rcvL[ircv].rcvNum),n)
        endelse
        if curplot ne rcvL[ircv].pltNum then begin
            icol=0
            curplot=rcvL[ircv].pltNum
            ii=where(rcvL.pltNum eq curPlot,jj)
            maxV=max(rcvL[ii].maxpnts) + 50
            maxV=maxV/50L * 50L
            ver,0,maxV 
            plot,[0,1],[0,1],/nodata,xtickformat=xtformat,$
                xtitle='Date',ytitle='number of measurements',$
                charsize=cs,title=labPlt[curplot]
            if keyword_set(flagmon) then flag,flagjd,col=colph[flagjdcol],$
                        linestyle=flagjdls
        endif
        if n eq 0 then goto,next
;
; -.5 since plots center the ticks at 12noon.. we prefer 0
;
        jd=mm[ind].julday +  mjd_offset - .5D
        jd=[jd,julD2]
        y=lonarr(n) + 1L
        y=[y,0L]
        oplot,jd,total(y,/cum),psym=sym,col=colph[colar[icol]]
next:
        note,ln+curplot*linc + icol*scl,rcvL[ircv].rcvLab,xp=xp,$
            col=colph[colar[icol]]
        icol=icol+1
    endfor
    ldate=string(format='(i6.6," thru ",i6.6)',yymmdd1,yymmdd2)
    note,ln,ldate,xp=xp+.2
    return
end
