;+
;NAME:
;rmmon - monitor the receiver temperatures.
;SYNTAX: rmmon,yymmdd,temp=temp,disp=disp,win=win,tlab=tlab,ver=ver,$
;               min=min,delay=delay,hshift=hshift,smo=smo,debug=debug,log=log
;ARGS:
;   yymmdd: long    date to display. -1 --> current day
; 
;KEYWORDS:
;     temp :    int  temp to monitor 0:16K,1:70K,2:omt
;    ver[2]:    float vertical scale to use (min,max). If 1 number then
;                     go 0 to ver.
;     disp :    int  1 ->upper magnified display only
;                    2 ->lower daily display only
;                    default both
;       win:    long window number to display in. This allows the user to
;                    setup the window dimensions and position before
;                    calling this routine. The default is 0. Window 4
;                    is used for the pixwin, so do not use it as the 
;                    display window number.
;  tlab[4]:   float  specify temp label text position
;                    [0] - start line 0..31   def 3
;                    [1] - line step          def 1
;                    [2] - xpos left (0..1)   def  .02
;                    [4] - charsize           def 1.3
;   log   :          if set the make vertical display logarithmic.
; -->keywords for HI RESOLUTION upper display
;      min :    long number of minutes for upper hi res display. default:
;                    60.
;     delay:    long The seconds to wait between each display of the magnified
;                    display. The default is 20 seconds.
;    hshift:    long The number of minutes to leave blank on the right 
;                    side of the magnified display. The default is 1 minute
; -->keywords for DAILY lower display
;       smo:    long the number of points to smooth,decimate the daily display.
;                    The default is 5 or 100  seconds. This is also the update
;                    rate for the daily display.
;     debug:    If set then output some debugging info about the the number
;               of points we read at each i/o.
;DESCRIPTION:
;   rmmon will monitor the receiver temperatures. The monitor data is 
;being written to disc once every 3 seconds for each receiver.
;
;   rmmon can be used to display an entire days worth of data by setting
;the parameter yymmdd to the data of interest. If yymmdd is set to -1 then
;the monitoring will display the current day and then continue updating 
;every DELAY seconds. The default delay is about 20 seconds (one complete
;cycle reading all of the receivers).
;
;   There are two displays each showing temperature versus hour of
;day: a high resolution plot and a plot of the entire day. The DISP keyword
;can be used to limit the output to just one of these plots (the default
;is both plots are output). By default the 16K stage of the amplifiers are
;displayed. The temp keyword lets you select the 70K or the OMT stage.
;
;   The top plot is a high resolution display showing the last MIN minutes
;of data. The dislay will be updated every DELAY seconds. The *'s at the 
;right of the plot are the last data points. The value on the left are the
;temperatures for the last reading.
;   
;   The lower plot is the temperature versus hour of day for the entire day.
;The data has been smoothed and decimated by SMO seconds. This plot will 
;be updated every SMO sample points.
;
;EXAMPLES:
;   - Plot the temp  data for 24dec02
;   rmmon,022402
;   - monitor the current day.
;   rmmon,-1
;   - monitor the current day, smoothing the magnified plot to 1 minute (3 
;     samples) and displaying 3 hours of data. 
;   rmmon,-1,smo=3,min=180
;
;NOTE:
;   If you call rmmon,-1... you will need to ctrl-c to get out of it.
;After this you should do a retall to get back to the main idl procedure.
;-
pro rmmon,yymmdd,temp=temp,min=hrmin,smo=smo,delay=delay,ver=ver,$
          hshift=hshift,debug=debug,axis=axis,win=win,disp=disp,tlab=tlab,$
		  rcvmonstr=rcvmonstr,log=log
;   
;    on_error,1
	common colph,decomposedph,colph
    if not keyword_set(debug) then debug=0
    xdimdef=640
    ydimdef=512
    !x.style=1
    !y.style=1
    wpixwintouse=4
    maxrecs=86400/3 + 100       ; 1 rec every 3 secs
    cs=1.4
    labtemp=['16K','70K','OMT']
    rcvnums=[1    ,2    ,3    ,5    ,6    , 12  ,7    ,8    ,9    ,10   , 11]
    rcvLabs=['327','430','800','LBW','LBN','SBN','SBW','SBH','CB ','CBH','XB ']
    rcvcol =[  5  , 2   ,  8  ,  1  ,  5  , 6   , 7   , 3   , 9   ,8    , 10  ]
    numrcvs=n_elements(rcvnums)
    hfract=.17                          ; 10 % used for labels,temp
;
;   label positions
;
    if n_elements(tlab) eq 4 then begin
        tlabln   = tlab[0]
        tlabscl  = tlab[1]
        tlabxp   = tlab[2]
        tlabcs   = tlab[3]
    endif else begin
        tlabln = 3
        tlabscl=1 
        tlabxp =.02
        tlabcs=1.3
    endelse
;
;   default vertical scaling for different temps
;
	if keyword_set(log) then begin
    	verdef=[[5,300],[5,300],[5,350]]
		ylog=1
	endif else begin
    	verdef=[[0,30],[0,100],[0,100]]
		ylog=0
	endelse
;

    if n_elements(smo) eq 0 then   smo=5
    if not keyword_set(hrmin) then hrmin=60.
    if not keyword_set(delay) then delay=20
    if not keyword_set(hshift) then hshift=2
    if not keyword_set(disp) then disp=0
    if not keyword_set(temp) then temp=0
    case n_elements(ver) of
        1: begin
            if string(ver) eq 'auto' then begin
                ver
            endif else begin
                ver,0,ver
            endelse
           end
        2: begin 
			if ver[1] ne 0 then begin
				ver,ver[0],ver[1]
		   endif else begin
           		ver,verdef[0,temp],verdef[1,temp]
		   endelse
		   end
     else: ver,verdef[0,temp],verdef[1,temp]
     endcase
;
;    they specified a window to use??
;
    if n_elements(win) eq 0 then  begin
        win=0
        window,0,xsize=xdimdef,ysize=ydimdef
    endif else begin
        if win eq 4 then begin
            message,$
        'window 4 is use for the internal pixwin,pick another window...'
        endif
        wset,win
    endelse
    xdim=!d.x_size
    ydim=!d.y_size
    wpixwin=-1
    case temp of 
        0: begin
              end
        1: begin
              end
        2: begin
              end
        else: message,'temp values 0,1,2'
    endcase
    dec=smo
    ilast=-1L
    done=0
    totpnts=0
    botcnt=0
;   number of delays before max bot cnt
;

    if delay gt 0 then begin
    maxbotcnt= long((smo*20)/delay  + .5)     ; how often to update lower plot
    endif else begin
    maxbotcnt=1
    endelse
    t4=0
    t3=0
;
;   loop here on the data
;
    append=0
    repeat begin
        t1=systime(1)
        newpnts=rmmoninp(yymmdd,b,curpos=curpos,inprecsize=inprecsize,$
                         append=append,rcvmonstr=rcvmonstr)
        append=1L
        if yymmdd eq -1 then begin
            a=bin_date()
            yymmddl=string(format='(i2.2,i2.2,i2.2)',a[0] mod 100,a[1],a[2])
        endif else begin
            yymmddl=string(yymmdd)
        endelse
        totpnts=n_elements(b)
        i2=totpnts-1
        if (newpnts eq 0) or (totpnts lt (2)) then begin
            goto,nexttm
        endif
        t2=systime(1)
;
;   setup the pixwin
;
        if (!d.x_size ne xdim) or (!d.y_size ne ydim) or (wpixwin lt 0) $
            then begin
           xdim=!d.x_size
           ydim=!d.y_size
           window,wpixwintouse,/pixmap,xsize=xdim,ysize=ydim
           wpixwin=!d.window
           botcnt=0
        endif
        wset,wpixwin
;
        if (disp eq  1) or (disp eq 2) then begin
            !p.multi=0
        endif else begin
            !p.multi=[0,1,2]
        endelse
        if disp eq 2 then goto,pltlow
;
;       high res points to display
;
        ind=where( b.day ge ( b[i2].day - hrmin/(60.*24)),count)
        if count lt 2 then goto,nexttm
        i1=ind[0]
        tm1=(b[i1:i2].day - fix(b[i1].day)) *24.
        if tm1[0] gt tm1[1] then tm1[0]=tm1[1]
        rcvnum=b[i1:i2].rcvnum
        case temp of
            0: yt=b[i1:i2].t16k
            1: yt=b[i1:i2].t70k
            2: yt=b[i1:i2].tomt
        endcase
        lab=string(format='(a," ",a," dewar temps last:",f5.1," minutes")',$
            yymmddl,labtemp[temp],hrmin)
        hmax=max(tm1,min=hmin)
        hmax1=hmax+hshift/60.
        hor,hmin-(hmax1-hmin)*hfract,hmax1
        rcvlasttemp=fltarr(numrcvs) - 1.
        plot,tm1,yt,charsize=cs,ylog=ylog,$
            xtitle='hour',ytitle='temp [deg K]',title=lab,/nodata
        for i=0,numrcvs-1 do begin
            ind=where(rcvnum eq rcvnums[i],count)
;           print,rcvnums[i],count
            if count gt 1 then begin
                x=tm1[ind]
                y=yt[ind]
                ii=count-1
                oplot,x,y,color=colph[rcvcol[i]]
;               put an * on each last pnt
                plots,x[ii],y[ii],color=colph[rcvcol[i]],psym=2
                rcvlasttemp[i]=y[ii]
            endif
        endfor
;
;   label temps
;
        ln=tlabln
        ii=0
        for i=0,numrcvs-1 do begin &$
            if rcvlasttemp[i] ne -1. then begin
                lab=string(format='(a," ",f5.1," ")',rcvLabs[i],rcvlasttemp[i])
                note,ln+ii*tlabscl,lab,xp=tlabxp,color=colph[rcvcol[i]],$
						charsize=tlabcs
                ii=ii+1
            endif
        endfor

pltlow: if debug then print,'botcnt: ',botcnt
        hor
        if (totpnts gt (smo*10) and ((botcnt mod maxbotcnt) eq 0) and $
            (disp ne 1)) then begin
            case temp of
                0: yt=b[0:i2].t16k
                1: yt=b[0:i2].t70k
                2: yt=b[0:i2].tomt
            endcase
            tm= (b[0:i2].day - fix(b[0].day))*24
            if tm[0] gt tm[1] then tm[0]=tm[1]
            lab1=string(format='(a," ",a," temps (smoothed to",i4," secs)")',$
                yymmddl,labtemp[temp],smo*20)

            lab2=string(format='(a," ",a," temps (no smoothing)")',$
                yymmddl,labtemp[temp])
            newplot=1
            for i=0,numrcvs-1 do begin
                ind=where(b.rcvnum eq rcvnums[i],count)
;               print,rcvnums[i],count
                if count gt smo then begin
                     if smo gt 1 then begin
                     x=select(smooth(tm[ind],smo,/edge_truncate),dec/2,dec)
                     y=select(smooth(yt[ind],smo,/edge_truncate),dec/2,dec)
                        lab=lab1
                     endif else begin
                       x=tm[ind]
                       y=yt[ind]
                       lab=lab2
                    endelse
                    if newplot then  begin
                        plot,x,y,charsize=cs,ylog=ylog,$
                         xtitle='hour',ytitle='temp [deg K]',title=lab,/nodata
                        newplot=0
                    endif
                    oplot,x,y,color=colph[rcvcol[i]]
;                   put an * on each last pnt
                endif
            endfor
        endif
        wset,win
        if (botcnt  eq 0) or (disp eq 1) or (disp eq 2)  then begin 
            device,copy=[0,0,xdim,ydim,0,0,wpixwin]
        endif else begin
            device,copy=[0,ydim/2-1,xdim,ydim/2,0,ydim/2-1,$
                wpixwin]
        endelse
        t3old=t3
        t3=systime(1)
nexttm:
        botcnt=(botcnt+1) mod maxbotcnt
        if yymmdd ne -1 then goto,done
        if debug then begin
lab=string(format=$
'("new:",i5," tot:",i5," tm1:",f5.3," tm2:",f5.3," tm3:",f5.3," tmt:",f5.3)',$
            newpnts,totpnts,t2-t1,t3-t2,t4-t3old,t3-t1)
            print,lab
        endif
        wait,delay
        t4=systime(1)
    endrep until done
done:
    return
end
