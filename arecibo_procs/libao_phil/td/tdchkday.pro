;+
;NAME:
;tdchkday - check td performances for a day
;SYNTAX: nrec=tdchkday,yymmdd,tmrange=tmrange,td=td,usetd=usetd,$
;                sym=sym,v1=v1,v2=v2,v3=v3,v4=v4,v5=v5,flaghr=flaghr,$
;                title=title,cmdveltd=cmdveltd
;ARGS:
;    yymmdd: long  date to look at
;tmrange[2]: float start,end hour to display. default is entire day  
;
;KEYWORDS:
;    v1[2]: float   vert range for position (inches 0,24)
;    v2[2]: float   vert range for velocity fdback (dacnts: -2048:2048)
;    v3[2]: float   vert range for ampSpd (dacnts: -2048:2048)
;    v4[2]: float   vert range for status (0 to 2)
;    v5[2]: float   vert range for current (a/d counts: 0:2048)
;    sym  : int     symbol to used (def -1)
;flagHr[m]: float   range of hours to flag in each plot
;    title: string  to add to top of first plot
;cmdVeltd : int     0 to 2. overplotted commanded velocity on velfb plot
;                   for this td
;tmrange[2]:long    if provided, then limit the plots to
;                   the tmrange[0],tmrange[1] time range. the format
;                   for each is hours
;    usetd: long    if set then the routine will use the info in the
;                   td=td structure passed in by the user rather than
;                   reading the data from the disc. This lets you rapidly
;                   replot various time ranges.
;       td[]:{}     This can be output or input. On the first call the
;                   data array is returned here. On subsequent calls if
;                   /usetd is set then this will be the source of the
;                   data rather than rereading it from disc.
;  
;RETURNS:
;   nrec: int number of records found in tmrange
;td[nrec]:{} td structre for the day.
;
;DESCRIPTION:
;   Input a days worth of tiedown archive information (at 1 second
;resolution and make a plot of the info. The tmrange[2] can limit the
;range of the input data to tmrange=[hhmmss1,hhmmss2]. The data input
;will be returned in the keyword td=td;
;   You can make subsequent calls on the same data set by setting
; /usetd and passing in the data td=td read from the previous call. You
;can change the tmrange=tmrange values to blowup different portions of the
;day.
;   The plot is color coded with white=td12,red=td4, green=td8.The plot
;contains:
;1. tiedown position in inches versus hour of day.
;2. Velocity feedback of the D/A versus time. This yellow plot is
;   the requested commanded velocity for td12 (this can be changed with the
;   cmdVelTd keyword).
;3. The amplifier speed monitor for each of the tiedowns.
;4. The drive status of each of the tiedowns. The values are:
;    0 - off
;    1 - enabled and running
;    2 - powered (but no running).
;5.  The drive current for each of the motors. I think the units are
;    amps but the calibration may be a little off. It should at least be
;    linear in current.
;
;EXAMPLES:
;   Input a days worth of data, the recall the routine blowing up the
;area around 230000 to 240000 and finally 234500 to 235500.
;    nrec=tdchkday,060302,td=td)
;
;;  now recal it
;    nrec=tdchkday(060302,td=td,/usetd,tmrange=[230000,240000])
;
;;  now look closer
;
;    nrec=tdchkday(060302,td=td,/usetd,tmrange=[234500,235500])
;
; You can resize the plot window by dragging the cornerers and then 
;replotting the data.
;
;-
function tdchkday,yymmdd ,td=td,tmrange=tmrange,usetd=usetd,$
            v1=v1,v2=v2,v3=v3,v4=v4,v5=v5,title=title,flaghr=flaghr,$
            cmdveltd=cmdveltd,sym=sym
	    common colph,decomposedph,colph

    cntToCurI=.01788            ; comes from forcing foldback=10amps
;                               ; see tieProg.h bottom.
    titleL=keyword_set(title)? title:''
    if n_elements(cmdveltd) eq 0 then cmdveltd=0
    if n_elements(sym) eq 0 then sym=-1
    tdparms,inchPerEncCnt=inchPerEncCnt
    if keyword_set(usetd) then begin
       npts=n_elements(td)
    endif else begin
        npts=tdinpday(yymmdd,td,/alldat)
    endelse
    if npts eq 0 then begin
        print,'no data found:',yymmdd
        return,0
    endif

;
    if n_elements(tmrange) eq 2 then begin
        hr=td.secM/3600.
        ind=where((hr ge tmrange[0]) and (hr le tmrange[1]),npts)
        if npts eq 0 then return,0
        i1=ind[0]
        i2=ind[npts-1]
    endif else begin
        i1=0L
        i2=npts-1
    endelse
    velfb=fltarr(npts,3)
    cur  =fltarr(npts,3)
    spd  =fltarr(npts,3)
    vcmd =fltarr(npts,3)
    drvst=fltarr(npts,3)
    flt  =fltarr(npts,3)
    pos  =fltarr(npts,3)
    tm   =td[i1:i2].secm
    hr   =tm/3600.
    for i=0,2 do begin &$
        velfb[*,i]=td[i1:i2].slv[i].ticki.tdstat.ai_velfb &$
        cur[*,i]  =td[i1:i2].slv[i].ticki.tdstat.ai_mampcurmon*cntToCurI &$
        spd[*,i]  =td[i1:i2].slv[i].ticki.tdstat.ai_mampspdmon &$
        vcmd[*,i] =td[i1:i2].slv[i].ticki.tdstat.aO_velcmd &$
       drvst[*,i] =td[i1:i2].slv[i].ticki.tdstat.st_mdrv and 3&$
         pos[*,i] =td[i1:i2].slv[i].ticki.pos*inchPerEncCnt
         flt[*,i] =td[i1:i2].slv[i].ticki.tdstat.st_fault &$
    endfor
;
    cs=1.6
    scl=.6
    ln=3
    xp=.04
    x=hr
;
    !p.multi=[0,1,5]
    if n_elements(v1) eq 2 then begin
        ver,v1[0],v1[1]
    endif else begin
        min=min(pos,max=max)
        ver,min,max
    endelse
    
	xtit='Hr of day'
    stripsxy,x,pos,0,.02,/step,chars=cs,psym=sym,$
        xtitle=xtit,ytitle='inches',$
        title=titleL +' td position vs time'
    if n_elements(flaghr) gt 0 then flag,flaghr,linestyle=2
    note,ln      ,'td12',xp=xp,color=colph[1]
    note,ln+1*scl,'td4',xp=xp,color=colph[2]
    note,ln+2*scl,'td8',xp=xp,color=colph[3]
;
    if n_elements(v2) eq 2 then begin
        ver,v2[0],v2[1]
    endif else begin
        ver,-2048,2048
    endelse
    stripsxy,x,velfb,0,0,/step,chars=cs,psym=sym,$
        xtitle=xtit,ytitle='a/d counts',$
        title='velocity feedback versus time'
    flag,fv,linestyle=2
    if n_elements(flaghr) gt 0 then flag,flaghr,linestyle=2
    if n_elements(cmdveltd) gt 0 then begin
        i=cmdVelTd[0]
        i=( i > 0) < 2
        tdlab=['td12','td4','td8']
        lab=tdlab[i]
        oplot,x,vcmd[*,cmdvelTd[0]]-2048,color=colph[5]
        note,ln+4.5,lab +' commanded vel',xp=xp,color=colph[5]
    endif
;
    if n_elements(v3) eq 2 then begin
        ver,v3[0],v3[1]
    endif else begin
        min=min(spd,max=max)
        ver,min,max
    endelse
    stripsxy,x,spd,0,0,/step,chars=cs,psym=sym,$
        xtitle=xtit,ytitle='counts',$
        title='amplifier speed monitor versus time'
    if n_elements(flaghr) gt 0 then flag,flaghr,linestyle=2
;
    if n_elements(v4) eq 2 then begin
        ver,v4[0],v4[1]
    endif else begin
        ver,-1,4
    endelse
    stripsxy,x,drvst,0,0,/step,chars=cs,psym=sym,$
        xtitle=xtit,ytitle='stat bits',$
        title='drive status (0-off,2-powered,1-enabled,3-fault)'
    if n_elements(flaghr) gt 0 then flag,flaghr,linestyle=2
;
    if n_elements(v5) eq 2 then begin
        ver,v5[0],v5[1]
    endif else begin
        min=min(cur,max=max)
        ver,min,max
    endelse
    stripsxy,x,cur,0,0,/step,chars=cs,psym=sym,$
        xtitle=xtit,ytitle='amps (??)',$
        title='drive current (from amp monitor)'
    if n_elements(flaghr) gt 0 then flag,flaghr,linestyle=2
    return,npts
end
