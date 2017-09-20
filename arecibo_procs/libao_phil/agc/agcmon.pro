;+
;NAME:
;agcmon - monitor the drive motor torques. 
;SYNTAX: agcmon,yymmdd,axis=axis,disp=disp,win=win,mlab=mlab,$
;               magpnts=magpnts,msmo=msmo,delay=delay,hshift=hshift,$
;               smo=smo,debug=debug,veldaily=veldaily,hortm=hortm,$
;               highres=highres
;ARGS:
;   yymmdd: long    date to display. -1 --> current day
; 
;KEYWORDS:
;     axis :    string axis for torques. az,gr, ch. default is 'gr'
;     disp :    int  1 ->upper magnified display only
;                    2 ->lower daily display only
;                    default both
;       win:    long window number to display in. This allows the user to
;                    setup the window dimensions and position before
;                    calling this routine. The default is 0. Window 4
;                    is used for the pixwin, so do not use it as the 
;                    display window number.
;  mlab[6]:   float  specify motor label text position
;					 [0] - line 0..31   def 2.5
;					 [1] - line step    def  .7
;					 [2] - xpos 1st col def  .02
;					 [3] - xpos 2nd col def  .12
;					 [4] - xpos HB      def  .22
;					 [5] - charsize     def 1.3
; highres:           if set then stop after each magpnts display
;                    so use can inspect it.
;-->keywords for HI RESOLUTION upper display
;   magpnts:    long the number of points for the upper magnified display. Each
;                    point is 1 second. The default is 600 (ten minutes).
;      msmo:    long The number of points to smooth/decimate the magnified
;                    display. The default is 5 seconds.
;     delay:    long The seconds to wait between each display of the magnified
;                    display. The default is msmo seconds.
;    hshift:    long The number of points to leave blank on the right 
;                    side of the magnified display. The default is 20.
;-->keywords for DAILY lower display
;       smo:    long the number of points to smooth,decimate the daily display.
;                    The default is 61 seconds. This is also the update
;                    rate for the daily display.
;  veldaily:    if set then include the velocity plot with the daily torques.
;				The default is to plot just the position.
;
;     debug:    If set then output some debugging info about the the number
;               of points we read at each i/o.
;DESCRIPTION:
;   agcmon will monitor the motor torques for the azimuth, ch, or dome.
;The monitor data includes the vertex critical block and full block status 
;blocks. It is written to disc (directory:/share/obs1/pnt/log) once a second 
;by the online computers. The last 6 months of data are left on disc 
;(data before this is backed up on tape).
;
;   agcmon can be used to display an entire days worth of data by setting
;the parameter yymmdd to the data of interest. If yymmdd is set to -1 then
;the monitoring will display the current day and then continue updating 
;every DELAY seconds.
;
;	The highRes keyword will cause the program to stop and wait for
;keyboard input after each display (rather than waiting delaySecs).
;
;   There are two displays each showing torque in foot-lbs versus hour of
;day: a high resolution plot and a plot of the entire day. The DISP keyword
;can be used to limit the output to just one of these plots (the default
;is both plots are output).The axis motors (gr=8, az=8, ch=2) are plotted 
;in different colors.
;
;   The top plot is a high resolution display showing the last MAGPNT seconds
;of data. At the top of this plot is a solid white line that plots the
;za of the dome (0 deg at the dotted white line, 20 degs at the top of the
;plot). The red line is the velocity of the dome. The dotted red line is
;0 veolicty with the dotted white line being the most negative and the top
;of the plot the most positive. The data is smoothed and decimated by 
;MSMO points (to make it easier to see the data). The dislay will be updated
;every DELAY seconds. The *'s at the right of the plot are the last data points.
;   
;   The lower plot is the torques versus hour of day for the entire day.
;The data has been smoothed and decimated by SMO seconds. The graph at the
;top of the plot shows the dome za. This plot will be updated every SMO seconds.
;
;   The dotted white line (in both plots) is the maximum torque of any motor 
;(rounded up to the next foot-lb) for the time period of the display. It is
;computed before smoothing the data so you will know the maximum instantaneous
;torques of the system.
;
;EXAMPLES:
;
; There are 4 different ways to use agcmon:
;   1. look at a single day all at once:
;	   -->	agcmon,131125,axis='gr'
;   2. Look at a single day in highres mode.
;      - user hits return after every plot,
;      - they probably don't want the 2nd cumulative display
;      - at end of file, routine returns
;	   -->	agcmon,131125,axis='gr',/highRes,disp=1
;   3. Monitor from current day with auto updates
;	   -->	agcmon,-1,axis='gr'
;   4. Monitor from current day with user inputs between displays
;      - when end of file is hit program continues. User still
;        hits return, but new updates don't occur until
;        data if available.
;	   -->	agcmon,-1,axis='gr',/highres,disp=1
;     
;
;      
;   - monitor the current day, smoothing the daily plot to 11 secs.
;     Use 300 pnts (5 minutes) for the magnified plot smoothing it to 2 
;     seconds and updating every 2 seconds.
;     --> agcmon,-1,smo=11,magpnts=300,msmo=2,delay=2
;   -Display just the magnified plot as fast as you can with no
;    smoothing. Do not output the daily plot:
;    --> agcmon,-1,disp=1,msmo=1,delay=.5
;   -Monitor the azimuth torques.
;    --> agcmon,-1,axis='az'
;
;Notes:
;	- magpnts determines how many points are display in the upper 
;     panel. You can use this in high res mode to change how many
;     points are displayed.
;   - msmo - smooths the upper display. The default is 5 points
;     for highres mode the default is switched to 1 point (no smoothing)
;-
pro agcmon,yymmdd,magpnts=magpnts,smo=smo,msmo=msmo,delay=delay,hshift=hshift,$
                  debug=debug,axis=axis,win=win,disp=disp,veldaily=veldaily,$
				  mlab=mlab,hortm=hortm,highres=highres
;   
    common colph,decomposedph,colph
    on_error,1
    if not keyword_set(debug) then debug=0
    xdimdef=640
    ydimdef=512
    !x.style=1
    !y.style=1
    wpixwintouse=4
    maxrecs=86400+100
    cs=1.4
	useHor=n_elements(hortm) eq 2
	useHr=keyword_set(highres)
;
;   motor labe positions
;
	if n_elements(mlab) eq 6 then begin
		mlabln = mlab[0]
		mlabscl= mlab[1]
  	    mlabxp1= mlab[2]
   	    mlabxp2= mlab[3]
        mlabxpb= mlab[4]
        mlabcs=1.3
	endif else begin
		mlabln = 2.5
		mlabscl=.7 
  	    mlabxp1=.02
   	    mlabxp2=mlabxp1 + .1
        mlabxpb=mlabxp1 + .2
        mlabcs=1.3
	endelse
    upperfract=.15                      ;to hold, za,vel 15%
;

    if not keyword_set(smo) then   smo=61
    if not keyword_set(msmo) then begin
		; if high res they probably don't want smoothing
		msmo=(keyword_set(highres))?1:5
	endif
    if not keyword_set(magpnts) then magpnts=600
    if not keyword_set(delay) then delay=msmo
    if not keyword_set(hshift) then hshift=20
    if not keyword_set(axis) then axis='gr'
    if not keyword_set(disp) then disp=0
    if not keyword_set(veldaily) then veldaily=0
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
    case axis of 
        'gr': begin
    mot=[ 'mot11','mot12','mot21','mot22','mot31','mot32','mot41','mot42']
              posind=1
              velslew=.04
              posmax=20.
              end
        'az': begin
    mot=[ 'mot11','mot12','mot51','mot52','mot41','mot42','mot81','mot82']
              posind=0
              velslew=.4
              posmax=360.
              end
        'ch': begin
    mot=[ 'mot1','mot2']
              posind=2
              velslew=.04
              posmax=20.
              end
        else: message,'axis values are gr,ch,or az'
    endcase
    nmot=n_elements(mot)
    dec=smo
    b=replicate({cbfb},maxrecs)
    ilast=-1L
    done=0
    totpnts=0
    botcnt=0
    maxbotcnt= long(smo/delay  + .5)     ; how often to update lower plot
    t4=0
    t3=0
;
;   loop here on the data
;
	totpnts=0L
	totPntsLast=-1L
	i1=0L
	i2=0L
	i2Inp=0L
    repeat begin
		;
		; see if we need to read more data
	 	;
;		print,"top: i1,i2,i2inp,totpnts",i1,i2,i2inp,totpnts
		if (not useHr) or (i2 ge i2Inp) then begin
        	t1=systime(1)
       	    newpnts=agcmoninp(yymmdd,bloc,curpos=curpos,inprecsize=inprecsize)
            if yymmdd eq -1 then begin
            	a=bin_date()
            	yymmddl=string(format='(i2.2,i2.2,i2.2)',a[0] mod 100,a[1],a[2])
        	endif else begin
           	    yymmddl=string(yymmdd)
            endelse
        	totpnts=curpos/inprecsize
;			print,"rdBlk 1: i1,i2,i2inp,totpnts",i1,i2,i2inp,totpnts,totPntsLast
			if (totPntsLast gt totpnts) then begin
				; new file
				i1=0
			endif
			totpntslast=totpnts
        	i2Inp=totpnts-1
;			print,"rdBlk 2: i1,i2,i2inp,totpnts",i1,i2,i2inp,totpnts,totPntsLast
        	if newpnts ne 0 then b[i2Inp-newpnts+1:i2Inp]=bloc ;put new data in our buffer
        	if (newpnts eq 0) or (totpnts lt (2*msmo)) then begin
				goto,nexttm
		 	endif
		endif
	    if (useHr) then begin
;				print,"midUsehr 1: i1,i2,i2inp,totpnts",i1,i2,i2inp,totpnts
				i2=(i1 + magpnts -1) < i2inp
				i1=((i2 - magpnts) +1) > 0
;				print,"midUsehr 2: i1,i2,i2inp,totpnts",i1,i2,i2inp,totpnts
		endif else begin
			i2=i2inp
        	i1=(0 > (i2-magpnts+1))
		endelse
        t2=systime(1)
        tm1=b[i1:i2].cb.time/3600.
        if tm1[0] gt tm1[1] then tm1[0]=tm1[1]
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
        case axis of
            'az': tq1=transpose(b[i1:i2].fb.tqaz)
            'ch': tq1=transpose(b[i1:i2].fb.tqch)
            else: tq1=transpose(b[i1:i2].fb.tqgr)
        endcase
        lab=string(format='(a," ",a," motor torques last:",f5.1," minutes")',$
            yymmddl,axis,magpnts/60.)
        max1=long(max(tq1)+.9) > 2
        vmax1=(max1 + upperfract*max1)*1.02
        ver,-.2,vmax1
        hmax=max(tm1,min=hmin)
        hmax1=hmax+hshift/3600.
        hor,hmin,hmax1
;		tq1[299,*]=5.
        stripsxy,tm1,tq1,0,0   ,/step,charsize=cs,$
        xtitle='hour',ytitle='torque [ftlbs]',title=lab,$
        smo=msmo,dec=msmo
;;		plot,tm1,tq1[*,0]
;       put an * on each last pnt
        col=lindgen(nmot)+1
        ii=i2-i1
        x=fltarr(nmot)+tm1[ii]
        plots,x,tq1[ii,*],color=colph[col],psym=2
;
;   plot pos,vel
;
        upperlen=upperfract*max1
        pos=((b[i1:i2].cb.pos[posind]/posmax) mod 1.)  *upperlen + max1
        vel=b[i1:i2].cb.vel[posind]/(2.*velslew)*upperlen  + max1 + upperlen/2.
        oplot,tm1,pos
        oplot,tm1,vel,color=colph[2]
        oplot,[0,24],[max1,max1],linestyle=1
        oplot,[0,24],[max1,max1]+upperlen/2.,linestyle=1,color=colph[2]
        xyouts,hmax1,max1,' pos'
        xyouts,hmax1,max1+upperlen/2.,' vel',color=colph[2]
;
;   label motors
;
        for i=0,nmot/2-1 do begin &$
         note,mlabln+i*mlabscl,mot[2*i]  ,xp=mlabxp1,color=colph[i*2+1],$
                charsize=mlabcs&$
         note,mlabln+i*mlabscl,mot[2*i+1],xp=mlabxp2,color=colph[i*2+2],$
            charsize=mlabcs &$
         if ((i mod 2) eq 0) and (axis eq 'gr')  then $
             note,mlabln+i*mlabscl,'(HB)',xp=mlabxpb,charsize=mlabcs &$
        endfor

pltlow: if debug then print,'botcnt: ',botcnt
        hor
        if useHor then hor,horTm[0],hortm[1]
        if (totpnts gt (smo*2) and ((botcnt mod maxbotcnt) eq 0) and $
            (disp ne 1)) then begin
            case axis of
                'az': tq=transpose(b[0:i2].fb.tqaz)
                'ch': tq=transpose(b[0:i2].fb.tqch)
                else: tq=transpose(b[0:i2].fb.tqgr)
            endcase
            tm=b[0:i2].cb.time/3600.
            if tm[0] gt tm[1] then tm[0]=tm[1]
            lab=string(format=$
        '(a," ",a," motor torques (smoothed to",i4," secs)")',$
            yymmddl,axis,smo)
            max2=long(max(tq) + .9)
            vmax2=(max2 + upperfract*max2)*1.02
            ver,-.2,vmax2
            stripsxy,tm,tq,0,0,/step,dec=dec,smo=smo,charsize=cs,$
            xtitle='hour',ytitle='torque [ftlbs]',title=lab
;
;   plot za
;
            upperlen=upperfract*max2
            pos= ((b[0:i2].cb.pos[posind]/posmax) mod 1.)  *upperlen  + max2
            oplot,tm,pos 
            oplot,[0,24],[max2,max2],linestyle=1
			if (veldaily) then begin
            	vel=   b[0:i2].cb.vel[posind]/(2.*velslew)*upperlen  + max2 + $
				  upperlen/2.
        		oplot,tm,smooth(vel,smo,/edge),color=colph[2]
        		oplot,[0,24],[max2,max2]+upperlen/2.,linestyle=1,color=colph[2]
			endif
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
        if debug then begin
lab=string(format=$
'("new:",i5," tot:",i5," tm1:",f5.3," tm2:",f5.3," tm3:",f5.3," tmt:",f5.3)',$
            newpnts,totpnts,t2-t1,t3-t2,t4-t3old,t3-t1)
            print,lab
        endif
		if useHr then begin
			print,"enter for next page, 'q' to quit "
			key=checkkey(/wait)
			if (key eq 'q') then return
;			print,'After wait 1:i1,i2,i2Inp,totPnts',i1,i2,i2inp
			i1=(i2+1)
			i2= (i1 + magpnts -1) < i2inp
;			print,'After wait 2:i1,i2,i2Inp,totPnts',i1,i2,i2inp
			;
			; see if we are done with single file
			;
			if (yymmdd gt 0) then begin
				if (i2 ge (i2inp - 2*msmo)) then begin
					print,"hit end of file in single day mode"
					return
				endif
			endif
		endif else begin
        	wait,delay
		endelse
        t4=systime(1)
    endrep until done
    return
end
