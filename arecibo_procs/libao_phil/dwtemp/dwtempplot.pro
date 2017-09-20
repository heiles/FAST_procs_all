;+
;NAME:
;dwtempplot - plot dewar temperatures.
;SYNTAX: dwtempplot(d,temp=temp,rcv=rcv,over=over,sym=sym,color=col,$
;                          mrcv=mrcv,ln=ln,adate=adate,drange=drange,$
;                          mframe=mframe)
;ARGS:   
;   d[]:{dwtemp} array of data input via dwtempinp
;KEYWORDS:
;   temp    : int    temperature to plot:
;                    0 16  deg stage (default)
;                    1 70  deg stage
;                    2 omt deg stage
;   rcv[]   : string or strarray.. rcvnames to plot. If supplied, then only
;                    plot these receivers..
;                    the default is to plot all of the receivers.
;                    rcvr names are:
;                   '430','lbw','lbn','sbw','sbn','sbh','cb','xb' 
;                   This assumes that more than one receiver was input with
;                   dwtempinp.
;   over    : int   if set then overplot rather than start a new plot
;   sym     : int   1,2,3 .. plot a symbol at each measured position.
;                   1 +, 2 *, 3 . , Negative number -1,-2,-3 will plot 
;                   the symbol and the connecting lines.
;  color    : int   if provided then plot the current data set in color
;                   col. (1-white, 2-red, 3-green,4-blue,5-yellow...
;  mrcv     : int   if set, over plot all recievers using different colors.
;  ln       : int   line number of labels of mrcv 3..33
;  adate    : int   if set then plot using alphanumeric dates: ddMMMyy
;  drange[2]: float daynum range of year to plot
;  mframe   : int   if set then use a multiframes. 1 frame per receiver.
;
;DESCRIPTION:
;   Plot the receiver dewar temperature data versus day of year. The data 
;must be first input with dwtempinp. By default it will plot the 16 degree 
;stage. You can plot the temperatures versus daynumber of the year 
;(default) or versus an ascii date ddMonyy. 
;
;   The axis can be scaled using hor,min,max and ver,min,max (these are two
;idl functions). Entering hor or ver without any arguements will autoscale to
;the min,max.
;
;   The adate keyword plots the x axis in a more human readable form
;ddMonyy. To plot a subrange of the data with this format, hor,min,max
;will not work (since the x data gets converted to julian date). Use the
;drange[day1st,daylast] keyword to limit the day range in this case.
;
;   By default all receivers are plotted (adjacent in time). To plot
;all receivers with a different color, use /mrcv keyword. The rcv keyword
;lets you overplot a subset of receivers (each in a  different color).
;
;   When using the adate keyword, the tickmark end up being spaced by
;some reasonable number of days (5,10,20..etc).
;
;   The mframe keyword will plot 1 receivers in different frames all in
;white. This is handy if you are making hardcopy and you don't have a 
;color printer.
;
;   Making hardcopy requires that you set the destination of the output to
;a postscript file before you call the routine.
;   pscol,'filename.ps'
;   dwtemplot,d,/mrcv
;   hardcopy
;   x
;The data will then be in the postscript file filename.ps.
;
;   If you used the /mframe keyword, then you don't need color postscript,
;but you will probably want to use the entire page for plotting:
;   ps,'filename.ps',/full
;   dwtemplot,d,/mrcv,/mframe
;   hardcopy
;   x
;
;EXAMPLES:
;   To start idl:
;   idl
;   @phil
;   @dwinit
;   To exit idl:
;   exit
;   ... 
;dwtempinp,d                       .. input all data current year
;hor
;ver,0,50                          .. vertical scale 0 to 50 K
;dwtempplot,d                      .. plot all receivers 16 deg stage
;dwtemplot,d,rcv='lbw'             .. plot lbw 16 deg stage
;dwtemplot,d,rcv=['lbw','lbn'],/adate .. plot lbw,lbn use, ascii dates
;dwtemplot,d,/mrcv,temp=1          .. plot all rcvrs,  70 deg stage
;hor,30,80
;dwtemplot,d,rcv=['lbw','lbn','cb'].. plot lbw,lbn, day 30 through 80
;hor
;dwtemplot,d,rcv='xb',drange=[30,80],/adate. plot xb days 30-80 in ascii date
;-
;history:
; if stage == omt, donot plot sbn,lbn,430.. they don't have the stage
;
pro dwtempplot,d,temp=temp,rcv=rcv,over=over,sym=sym,color=col, mrcv=mrcv,$
                 ln=ln,adate=adate,drange=drange,mframe=mframe
;
    noOmt=['327','sbn','lbn','430']
    no70K=['lbn','sbn']
    no16K=['327']
    !x.style=1
    !y.style=1
    if n_elements(ln) eq 0 then ln=26
    if n_elements(mframe) eq 0 then mframe=0
    if n_elements(temp) eq 0 then temp=0
    stageList=['16K','70K','OMT']
    if keyword_set(adate) then begin
        a=label_date(date_format='%D%M')
        xtformat='label_date'
        xtitle='date'
    endif else begin
        xtformat=''
        xtitle='daynumber of year'
    endelse
    if n_elements(drange) eq 2 then begin
        ind=where((d.day ge drange[0]) and (d.day le drange[1]),count)
        if count lt 0 then begin
            printf,-2,"no data between daynumbers:",drange
            return 
        endif
        dd=d[ind]
    endif else begin
        dd=d
    endelse
    title=string(format='("Dewar temps ",a3," stage (year ",i4,")")',$
            stageList[temp],d[0].year)
    xp=.02
    xpinc=.1
    scl=.8
    rcvnames=['327','430','lbn','lbw','sbn','sbw','sbh','cb','xb']
    rcvorder=[ 1   ,2    , 3   ,  4  , 5   , 6   , 7   , 8  , 9 ]
    n=n_elements(d)
    ind=lindgen(n)
    if keyword_set(mrcv) then begin
        rcv=dd[uniq(dd.nm,sort(dd.nm))].nm
;
;       sort them to be in the rcvordr rather than alphabetical name order
;
        nrcv=n_elements(rcv)
        rcvorderl=lonarr(nrcv)
        for i=0,nrcv-1 do begin
            ind=where(rcv[i] eq rcvnames)
            rcvorderl[i]=rcvorder[ind]
        endfor
        ind=sort(rcvorderl)
        rcv=rcv[ind]
        doall=0
    endif
    nrcv=n_elements(rcv)
    if nrcv ne 0 then begin
        doall=0
        for i=0,nrcv-1 do begin
            ind=where(rcv[i] eq rcvnames,count)
            if count lt 0 then begin
            print,-2,$
            'rcv names are:"327","430","lbw","lbn","sbn","sbw","sbh","cb","xb"'
            return
            endif
        endfor
    endif else begin
        doall=1
    endelse
    if n_elements(sym)  eq 0 then sym=0
    lcol=1
    if n_elements(color)  ne 0 then lcol=col
    if (temp lt 0) or (temp gt 2) then begin
        printf,-2,'bad temp value requested. values are:0-16K,1-70K,2-omt temps'
        return
    endif
;
;
    if keyword_set(adate) then begin
        x=daynotojul(dd.day,dd.year)
        x=x+.5          ;julday starts at noon... we want .5 more of a day.
     endif else begin
        x=dd.day
    endelse
    if mframe then begin
        nrcv=n_elements(rcv)
        case 1 of
        nrcv eq 1 : !p.multi=0
        nrcv eq 2 : !p.multi=[0,1,2]
        nrcv le 4 : !p.multi=[0,2,2]
        nrcv le 6 : !p.multi=[0,2,3]
        nrcv le 8 : !p.multi=[0,2,4]
        nrcv le 10: !p.multi=[0,2,5]
        endcase
        cs=1
        if nrcv gt 2 then cs=1.5
;
;   
;
        for i=0,nrcv-1 do begin
            nodata=0
            case temp of
              0 : begin
                    ii=where( rcv[i] eq no16K,count) 
                    if count ne 0 then nodata=1
                  end
              1 : begin
                    ii=where( rcv[i] eq no70K,count) 
                    if count ne 0 then nodata=1
                  end
              2 : begin
                    ii=where( rcv[i] eq noOMT,count) 
                    if count ne 0 then nodata=1
                  end
            else: nodata=0
            endcase
            if doall then begin
                plot,x,dd.temp[temp],xtickformat=xtformat,psym=sym,$
                xtitle=xtitle,ytitle='deg K',title=rcv[i]+ ' ' + title,$
                charsize=cs,nodata=nodata
            endif else begin
               ind=where(dd.nm eq rcv[i],count)
               if count gt 2 then begin
                 plot,x[ind],dd[ind].temp[temp],xtickformat=xtformat,$
                 xtitle=xtitle,ytitle='deg K',title=rcv[i]+ ' ' + title,$
                 psym=sym,charsize=cs,nodata=nodata
               endif
            endelse
        endfor
        !p.multi=0
    endif else begin
;
; single frame color
;
        if not keyword_set(over) then begin
         plot,x,dd.temp[temp],/nodata,xtickformat=xtformat,$
            xtitle=xtitle,ytitle='deg K',title=title
        endif
        if doall then begin
           oplot,x,dd.temp[temp],color=lcol,psym=sym
        endif else begin
            for i=0,n_elements(rcv)-1 do begin
             ind=where(dd.nm eq rcv[i],count)
             if count gt 0 then begin
                nodata=0
                case temp of
                0 : begin
                    ii=where( rcv[i] eq no16K,count) 
                    if count ne 0 then nodata=1
                    end
                1 : begin
                    ii=where( rcv[i] eq no70K,count) 
                    if count ne 0 then nodata=1
                    end
                2 : begin
                    ii=where( rcv[i] eq noOMT,count) 
                    if count ne 0 then nodata=1
                    end
                else: nodata=0
                endcase
                if nodata eq 0  then begin 
                    oplot,x[ind],dd[ind].temp[temp],color=lcol,psym=sym
                    cs=1.5
                    note,ln,rcv[i],color=lcol,xp=xp+xpinc*i,charsize=cs
                endif
                lcol=(lcol mod 10) +1 
             endif
            endfor
        endelse
    endelse
    
    return
end
