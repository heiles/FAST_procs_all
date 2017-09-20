;+ 
;NAME:
;lrplotdistfail - plot distomat failures by az,za
;
; SYNTAX: lrplotdistfail,d,year,gooddist=gooddist,includehr=includehr,$
;                          exclHr=exclhr,totcnt=totcnt,badcnt=badcnt
;   ARGS:
;d[npts]: {lrdat} laser ranging data input via lrpcinprange with the /ext
;                 option set.
;   year:  long   4 digit year for data in d (d had daynumber but no year)
;
;KEYWORDS:
; gooddist: int     number of distomats that have to have good data
;                   before the measurement is used (default is 3).
; includehr:fltarr[2]   range of hours (min,max) to use. default is
;                        0 to 24.
;    exclhr:fltarr[2]   range of hours (min,max) to exclude.
;                        0 to 24.
;    title : string  title to use on top of plot.. default is date range.
;RETURNS:
;    totcnt:lonarr[2]:  totcnt[0]: number of measurments made (after applying 
;                                  includehr, exclude hr, and the ch at stow.
;                       totcnt[1]: number of measurements that had at least
;                                  1 distomat bad but at least goodist ok.
;    badcnt:lonarr[6]: number of bad counts for each distomat.
;
; also outputs the plot..
;
;DESCRIPTION:
;   Make a plot of distomat failures versus az,za for the data set passed in. 
;To input the dataset use:
; lrpcinprange(y,mmdd1,mmdd2,d,/ext)
;Data is made available after the monthly processing of each month ( so the
;current months is not available unless the processing is run manually).
;
;   The points in the dataset will be constrained so that:
;1. there are at least "gooddist" distomat measurements for each point
;   used. This is to eliminate heavy rainfall where all of them were
;   out. The default value is that 3 distomats must be working.
;
;2. The hour of the meausurment must fall within includehdr (default
;   is 0 to 24) and it must not fall within excludehr (default is 
;   to not exclude anything.
;
; The hour include/exclude allows to to look at daytime or nighttime
; eg. includehr[6.,19.] will use 6am to 7pm (daylight)
;     exclhr=[6.,19.] will exclude 6am to 7pm (to keep nighttime)
;
;   The routine then plots the distomats that were not working versus 
;azimuth and zenith angle. The distomats at the same platform corner are 
;grouped together (1,6 td12), (2,3 td 4), (4,5 td8). Colors are used to 
;differentiate the two distomats at each color. Yellow dashed lines are 
;plotted at the azimuth of the corner that contains the two distomat 
;targets and at 180 degrees away. This is the azimuth where the dome
;can cause the maximum platform tilt for this pair. 
;
;Example:
;
; istat=lrpcinprange(2004,1201,1231,d,/ext)
; pscol,'lrfail_dec04.ps',/full
; lrplotdistfail,d,totcnt=totcnt,badcnt=badcnt
; hardcopy
; x
;-
pro lrplotdistfail,d,year,gooddist=gooddist,includehr=includehr,$
                   excludeHr=excludehr,totcnt=totcnt,badcnt=badcnt,$
                   byhr=byhr

;
    common colph,decomposedph,colph

    closeToStow=.01         ; within .01 degrees.
    if n_elements(gooddist) eq 0 then gooddist=3
    if (gooddist lt 0 ) or (gooddist gt 5) then begin
        print,"number of good distomats should be 0 thru 5'
        return
    endif
;
    if n_elements(includehr) ne 2 then includehr=[0.,24.]
    use_excl=0
    if n_elements(excludeHr) eq 2   then use_excl=1
    igood=lonarr(n_elements(d)) + 1L 


;
;   ch close to stow
;
;;    ind=where((abs(d.zach - 8.835) gt .01),count)
;;;;    if count gt 0 then igood[ind]=0 ; skip these
;
;   time 
;
    hr=(d.date mod 1.)*24.
    ind=where((hr lt includehr[0]) or (hr gt includehr[1]),count)
    if count gt 0 then igood[ind]=0         ; skip these
    if use_excl then begin
        ind=where((hr ge excludeHr[0]) and (hr le excludeHr[1]),count)
        if count gt 0 then igood[ind]=0     ; skip
    endif
;
;
;   at least gooddist distomat measurements
;   
    ind=where(d.avgh eq 0.,count)   ; where at least 1 is bad
    jj=lonarr(count)
    for i=0,count-1 do begin  &$
        ii=where(d[ind[i]].dist gt 1.,count1)  &$
        if (count1 ge gooddist) then igood[ind[i]]=igood[ind[i]]+1 &$ ;
    endfor
    
    ind=where(igood ge 1,totcnt)
    ind=where(igood eq 2,totbad)
    if totbad eq 0 then begin
        print,'no data fits criteria.. no plots'
        return
    endif
    badcnt=lonarr(6)

    az=d[ind].az mod 360.
    if keyword_set(byhr) then begin
        y=hr[ind]
        ytitle='hourOfDay'
        ver,0,25.
    endif else begin
        y=d[ind].zagr
        ytitle='za'
        ver,0,21.
    endelse


;
;   figure out the title
;
    if not keyword_set(title) then begin
        avgday=long(mean(d.date))
        a=daynotodm(avgday,year)
        imon=a[1]-1
        monL=['jan','feb','mar','apr','may','jun','jul','aug','sep',$
              'oct','nov','dec']
        title=string(format='(a,1x,i4," ")',monL[imon],year)
    endif
    hor,-10,370
    sym=2
    sym2=1
    lf=2
    colf=5
    cs=1.6
    !p.multi=[0,1,3]
;
;   distomat 6,1
;
    ii=where(d[ind].dist[0] eq 0,count1)
    plot,az[ii],y[ii],psym=sym,charsize=cs,$
    xtitle='az',ytitle=ytitle,$
    title=title + ' distomats 1,6 failures (T12)'
    lnstep=11.
    ln=7.5
    ln=-.65
    xp=.78
    xpinc=.1
    note,ln+1,'* DIST1',xp=xp
    note,ln+1,'+ DIST6',xp=xp+xpinc,color=colph[2]
    lab=string(format='("GoodDist:",i1)',gooddist)
    note,ln+1,lab,xp=xp+2*xpinc
    ii=where(d[ind].dist[5] eq 0,count6)
    oplot,az[ii],y[ii],psym=sym2,color=colph[2]
    flag,[2.87,182.87],color=colph[colf],linestyle=lf
;
    ii=where(d[ind].dist[1] eq 0,count2)
    plot,az[ii],y[ii],psym=sym,charsize=cs,$
    xtitle='az',ytitle=ytitle,$
    title=title + ' distomats 2,3 failures (T4)'
    ln1=ln+lnstep
    note,ln1,'* DIST2',xp=xp
    note,ln1,'+ DIST3',xp=xp+xpinc,color=colph[2]
    ii=where(d[ind].dist[2] eq 0,count3)
    oplot,az[ii],y[ii],psym=sym2,color=colph[2]
    flag,[122.87,302.87],color=colph[colf],linestyle=lf
;
;
    ii=where(d[ind].dist[3] eq 0,count4)
    plot,az[ii],y[ii],psym=sym,charsize=cs,$
    xtitle='az',ytitle=ytitle,$
    title=title + ' distomats 4,5 failures (T8)'
    ln3=ln + 2.*lnstep-1.
    note,ln3,'* DIST4',xp=xp
    note,ln3,'+ DIST5',xp=xp+xpinc,color=colph[2]
    ii=where(d[ind].dist[4] eq 0,count5)
    oplot,az[ii],y[ii],psym=sym2,color=colph[2]
    flag,[242.87,62.87],color=colph[colf],linestyle=lf
    badcnt=[count1,count2,count3,count4,count5,count6]
    xp=-.2
    ln=8
    scl=.6
    for i=0,5 do begin &$
       lab=string(format='("fail",i1,":",i5)',i+1,badcnt[i]) &$
        note,ln+i*scl,lab,xp=xp,color=colph[4] &$
    endfor
       lab=string(format='("totBad",i5)',totbad) &$
        note,ln+6*scl,lab,xp=xp,color=colph[3] &$
       lab=string(format='("totCnt",i5)',totcnt) &$
        note,ln+7*scl,lab,xp=xp,color=colph[3] &$
    
    return
end
