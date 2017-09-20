;+
;NAME:
;rmplot - plot dewar temperatures.
;SYNTAX: rmplot,d,temp=temp,cur=cur,volt=volt,rcv=rcv,over=over,sym=sym,
;               color=col,ln=ln,adate=adate,drange=drange,$
;               mframe=mframe,cs=cs,log=log,labadate=labadate,$
;               nolab=nolab,xtitle=xtitle,title=title,pol=pol,abpolcol=abpolcol,$
;				font=font
;ARGS:   
;   d[]:{rcvmon} array of data input via rminpday.
;KEYWORDS:
;   temp    : int    temperature to plot:
;                    0 16  deg stage (default)
;                    1 70  deg stage
;                    2 omt deg stage
;   cur     : int    amplifier bias current to plot 0,1,2
;   volt    : int    amplifier bias voltage to plot 0,1,2
;   rcv[]   : string or strarray.. rcvnames to plot. If supplied, then only
;                    plot these receivers..
;                    the default is to plot all of the receivers.
;                    rcvr names are:
;                   '430','lbw','lbn','sbw','sbn','sbh','cb','xb' 
;   over    : int   if set then overplot rather than start a new plot
;   sym     : int   1,2,3 .. plot a symbol at each measured position.
;                   1 +, 2 *, 3 . , Negative number -1,-2,-3 will plot 
;                   the symbol and the connecting lines.
;  color    : int   if provided then plot the current data set in this color.
;                   colors are: (1-white, 2-red, 3-green,4-blue,5-yellow...
;  ln       : int   line number for rcvr name labels. values 3..33
;  adate    : int   if set then plot using alphanumeric dates: ddMMMyy
;  labadate : string if supplied, then this is the output format
;                   for label_date call:
;                   %M-monName,%N-monNun,%D-dayNo,%Z-yy,%H-hr,%I-min
;  drange[3]: float Date range to plot. Use with /adate to limit the
;                   dates plotted.  format:[year,daynum,Numdays]
;                   keep numdays about year,daynum. (numdays can be positive
;                   or negative)
;  mframe   : int   if set then plot multiple frames on a page with 1 frame
;                   per receiver.
;  cs       : float character size scaling if single plot. default=1
;  log      :       if true then use log for vertical scale.. 
;                   (warning.. don't set lower vertical scale to 0..)
;  nolab    :       if set then don't print receiver names at the 
;                   bottom.. handy if you supply title=
; xtitle    : string Use this for the xtitle. Handy if you want to specify
;                    the dd:hh for labadate
; title     : string Use this for the reciever name
;	 				(but not oplot)
; pol       :  1,2   if present then just plot pola(1) or polB 2
; abpolcol  :        if set  and single frame, then plot always plot polb in red.
;	 				 normally used for 1 rcv/page pola=black,polb=red
; font      : int   1-truetype, 0 regular
;
;DESCRIPTION:
;   Plot the receiver dewar info data versus day of year. The data 
;must be first input with rminpday. By default it will plot the 16 degree 
;temperature stage. You can use the keywords to select the following data to
;plot:
; temp: 0,1,2  : T16K,T70K, or Tomt temperatures
; cur : 0,1,2  : 1st,2nd, or 3rd amplifier bias currents.
; volt: 0,1,2  : 1st,2nd, or 3rd amplifier bias voltages
;
;The data can be plotted versus daynumber of the year (default) or
;versus an ascii date ddMonyy (using /adate). 
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
;   By default each receiver is plotted in a different color on one plot.
;The /mframe keyword will plot each receiver in a separate frame (all on one
;page. The rcv keyword lets you specify a subset of the receivers to plot.
;
;   When using the adate keyword, the tickmark end up being spaced by
;some reasonable number of days (5,10,20..etc).
;
;   When plotting the voltage or currents, both polarizations will
;be plotted. If /mframe is set then polA is white and polB is red. If 
;not , then then they are overplotted in the same color. Keyword colpol 
;will override this.
;
;   Making hardcopy requires that you set the destination of the output to
;a postscript file before you call the routine.
;   pscol,'filename.ps'
;   rmplot,d
;   hardcopy
;   x
;The data will then be in the postscript file filename.ps.
;
;   If you used the /mframe keyword, then you don't need color postscript,
;but you will probably want to use the entire page for plotting:
;   ps,'filename.ps',/full
;   rmplot,d,/mframe
;   hardcopy
;   x
;
;EXAMPLES:
;   To start idl:
;   idl
;   @phil
;   @rcvmoninit
;   To exit idl:
;   exit
;   ... 
;nrecs=rminpday,021224,d,ndays=6         .. input dec 20 to 25
;hor
;ver,0,50                          .. vertical scale 0 to 50 K
;rmplot,d                          .. plot all receivers 16 deg stage
;rmplot,d,/mframe                  .. plot all receivers 1 per frame
;rmplot,d,rcv='lbw'             .. plot lbw 16 deg stage
;rmplot,d,rcv=['lbw','lbn'],/adate .. plot lbw,lbn use, ascii dates
;rmplot,d,temp=1                   .. plot all rcvrs,  70 deg stage
;
;; plot the voltage from amp 1
;ver,0,5
;rmplot,d,volt=0
;
;; overplot omt and 70K stages
;  ver,0,120
;  rmplot,d,temp=1
;  rmplot,d,temp=2,/over
;
;NOTE:
;    The datasets contain 70 Mbytes per month. You should run this on 
;a computer with lots of memory (pat,fusion01,mango,mofongo).
;-
;history:
; if stage == omt, donot plot sbn,lbn,430.. they don't have the stage
; 12feb04 - removed lbn, addec cbh
; 08aug09 - for 800 Mhz 16 stage is only 80 K so kick up the
;           ver scale to 0,100
;
pro rmplot,d,temp=temp,cur=cur,volt=volt,rcv=rcvNms,over=over,sym=sym,$
        color=col, ln=ln,adate=adate,drange=drange,mframe=mframe,cs=cs,$
		log=log,labadate=labadate,xtitle=xtitle,title=title,nolab=nolab,$
		pol=pol,abpolcol=abpolcol,font=font
;
    forward_function rmconfig
	common colph,decomposedph,colph

	csL=1.
	npol=2
	ipol=[0,1]
	if keyword_set(cs) then csL=cs
	if n_elements(pol) eq 1 then begin
		if (pol ne 1) and (pol ne 2) then begin
			print,"pol must be 1 or 2" 
			return;
		endif
		ipol[0]=(pol eq 1)?0:1
		npol=1
	endif
    noOmt=['327','800','sbn','lbn','430']
    no70K=['800','lbn','sbn']
;    no16K=[]
    docur=0
    dovolt=0
    dotemp=0
    !x.style=1
    !y.style=1
    if n_elements(ln) eq 0 then ln=26
    if n_elements(mframe) eq 0 then mframe=0
    if n_elements(temp) eq 0 then temp=0
    case 1 of
       n_elements(cur) gt 0: begin
            indcv  =cur
            docur=1
            end
       n_elements(volt) gt 0: begin
            indcv=volt
            dovolt=1
            end
        else: dotemp=1
    endcase
	ylog=(keyword_set(log) and (dotemp ne 0))?1:0
    stageList=['16K','70K','OMT']
    if keyword_set(adate) then begin
		aa=(n_elements(labadate) gt 0)?labadate:'%D%M'
		labDateOff=(strpos(aa,"H") ne -1)?0.:.5
        a=label_date(date_format=aa)
        xtformat='label_date'
        xtitleL='date'
    endif else begin
        xtformat=''
        xtitleL='daynumber of year'
    endelse
	if n_elements(xtitle) gt 0 then xtitleL=xtitle

    if n_elements(drange) eq 3 then begin
;	   Note: we're treating drange, and the d.day,d.year as
;            gmt times below.It's ok since it's all relative.
;
       x =daynotojul(d.day,d.year) 
       x1=daynotojul(drange[1],drange[0])
       x1=x1[0]
       delta=drange[2]
       if delta lt 0. then begin 
        ind=where((x ge (x1+delta)) and (x le x1),count)
       endif else begin
        ind=where((x ge x1) and (x le (x1+ delta)),count)
       endelse
       if count le 0 then begin
            printf,-2,"no data between daynumbers:",drange
            return 
        endif
        dd=d[ind]
    endif else begin
        dd=d
    endelse
    case 1 of
     (docur): begin
        titleL=string(format='("Dewar Current stage ",i1," (year ",i4,")")',$
            indcv+1,d[0].year)
        end
     (dovolt): begin
        titleL=string(format='("Dewar voltage stage ",i1," (year ",i4,")")',$
            indcv+1,d[0].year)
        end
    else :begin
        dotemp=1
    titleL=string(format='("Dewar temps ",a3," stage (year ",i4,")")',$
            stageList[temp],d[0].year)
        end
    endcase
	if n_elements(title) gt 0 then titleL=title

    xp=.02
    xpinc=.1
    scl=.8
    rcvnamesAll=['327','430','800','LBW','SBN','SBW','SBH','CB','CBH','XB']
    rcvnumsAll =[  1  ,  2  , 3   , 5   , 12  , 7,    8,    9  ,10   , 11]
    rcvorderAll=[ 1   ,  2  , 3   ,  4  , 5   , 6   , 7   , 8  , 9   , 10 ]
    n=n_elements(d)
    ind=lindgen(n)
    if n_elements(rcvNms) gt 0 then begin
        rcvNms=strupcase(rcvNms)
        for i=0,n_elements(rcvNms)-1 do begin
            if (rcvnumtonam(ii,rcvNms[i],/num) eq 0) then begin
                print,-2,$
            'rcv names are:"430","lbw","sbn","sbw","sbh","cb","cbh","xb"'
                return
            endif
        endfor
    endif else begin
;
;       find receivers we record
        rcvnumL=lonarr(16)
        ifound=0
        for i=0,15 do begin
            if (rmconfig(i) eq 1) then begin
                rcvnumL[ifound]=i
                ifound=ifound+1
            endif
        endfor
        if ifound eq 0 then return
        rcvnumL=rcvnumL[0:ifound-1]
        istat=rcvnumtonam(rcvnuml,rcvNms)
    endelse
;
;   put in rcvordr above
;
    nrcv=n_elements(rcvNms)
    rcvorderl=lonarr(nrcv)
    for i=0,nrcv-1 do begin
            ind=where(rcvNms[i] eq rcvnamesAll,count)
            if count gt 0 then begin
                rcvorderl[i]=rcvorderAll[ind]
            endif else begin
                rcvorderl[i]=-1
            endelse
    endfor
    ind=where(rcvorderl ne -1)
    rcvorderl=rcvorderl[ind]
    ind=sort(rcvorderl)
    rcvNms=rcvNms[ind]
;
    if n_elements(sym)  eq 0 then sym=0
    lcol=1
    if n_elements(col)  ne 0 then lcol=col
    if (temp lt 0) or (temp gt 2) then begin
        printf,-2,'bad temp value requested. values are:0-16K,1-70K,2-omt temps'
        return
    endif
;
;
    if keyword_set(adate) then begin
        x=daynotojul(dd.day,dd.year)
;       print,'min x:',min(x)
;       print,'max x:',max(x)
;
;      idl plotting with just mon:day puts the major ticks at
;      12 noon (start of julday). We put a .5 offset so the 
;      plot starts at midnite..
;      If our adate has Hours in it, then we don't need this..
        x=x+ labDateOff      
     endif else begin
        x=dd.day
    endelse
    if mframe then begin
        nrcv=n_elements(rcvNms)
        case 1 of
        nrcv eq 1 : !p.multi=0
        nrcv eq 2 : !p.multi=[0,1,2]
        nrcv le 4 : !p.multi=[0,2,2]
        nrcv le 6 : !p.multi=[0,2,3]
        nrcv le 8 : !p.multi=[0,2,4]
        nrcv le 10: !p.multi=[0,2,5]
        endcase
        csL=1
        if nrcv gt 2 then csL=1.5
;
;   
;
        for i=0,nrcv-1 do begin
			vsav=!y.range
            ind=where(rcvNms[i] eq rcvnamesAll,count)   ; file has num not names
            rcvNum=(rcvnumsAll[ind])[0]
            nodata=0
            istat=rmconfig(rcvNum,temps=temps,amps=amps)
            ind=where(dd.rcvnum eq rcvnum,count)
            case 1 of 
                dotemp: begin
                    nodata=temps[temp] eq 0
                    if count gt 2 then begin
                        case temp of
                            0: begin
								y=dd[ind].T16K
								if rcvNms[i] eq '800' then ver,0,100
							   end
					
                            1: y=dd[ind].T70K
                            2: y=dd[ind].Tomt
                        endcase
                        plot,x[ind],y,xtickformat=xtformat,ylog=ylog,$
                   xtitle=xtitleL,ytitle='deg K',title=rcvNms[i]+ ' ' + titleL,$
                        psym=sym,charsize=csL,nodata=nodata
						!y.range=vsav
                    endif
                end
                dovolt: begin
                    nodata=amps[indcv] eq 0
                    if count gt 2 then begin
                        y=dd[ind].dvolts[indcv,ipol[0]]
                        plot,x[ind],y,xtickformat=xtformat,$
                   xtitle=xtitleL,ytitle='Volts',title=rcvNms[i]+ ' ' + titleL,$
                        psym=sym,charsize=csL,nodata=nodata
                        y=dd[ind].dvolts[indcv,1]
						if (npol eq 2) and (not nodata)  then begin
                           y=dd[ind].dvolts[indcv,ipol[1]]
                           oplot,x[ind],y,psym=sym,color=colph[2]
						endif
                    endif
                end
                docur : begin
                    nodata=amps[indcv] eq 0
                    if count gt 2 then begin
                        y=dd[ind].dcur[indcv,ipol[0]]
                        plot,x[ind],ya,xtickformat=xtformat,$
               xtitle=xtitleL,ytitle='milliAmps',title=rcvNms[i]+ ' ' + titleL,$
                        psym=sym,charsize=csL,nodata=nodata
						if (npol eq 2) and (not nodata)  then begin
                           y=dd[ind].dcur[indcv,ipol[1]]
                           oplot,x[ind],y,psym=sym,color=colph[2]
						endif
                    endif
                end
            endcase
        endfor
        !p.multi=0
    endif else begin
;
; single frame color
;
        case 1 of
            dotemp: begin
                case temp of
                    0: y=dd.T16K
                    1: y=dd.T70K
                    2: y=dd.Tomt
                endcase
                nplot=1
                ytitle='deg K'
                end
            docur:  begin
                 y =dd.dcur[indcv,ipol[0]]
                 yb=dd.dcur[indcv,ipol[1]]
                nplot=npol
                ytitle='milliAmps'
                end
            dovolt:  begin
                 y =dd.dvolts[indcv,ipol[0]]
                 yb=dd.dvolts[indcv,ipol[1]]
                ytitle='Volts'
                nplot=npol
                end
        endcase

        if not keyword_set(over) then begin
         plot,x,y,/nodata,xtickformat=xtformat,ylog=ylog,$
            xtitle=xtitleL,ytitle=ytitle,title=titleL,charsize=csL,font=font
        endif
        for i=0,n_elements(rcvNms)-1 do begin
              ind=where(rcvNms[i] eq rcvnamesAll,count) ; file has num not names
              rcvNum=(rcvnumsAll[ind])[0]
               ind=where(dd.rcvnum eq rcvnum,count)
             if count gt 0 then begin
                istat=rmconfig(rcvnum,temps=temps,amps=amps)
                if dotemp then begin
                    nodata=temps[temp] eq 0
                endif else begin
                    nodata=amps[indcv] eq 0
                endelse
                if nodata eq 0  then begin 
                    oplot,x[ind],y[ind],color=colph[lcol],psym=sym
                    if nplot eq 2 then begin
						 llcol=(keyword_set(abpolcol))?2:lcol
						 oplot,x[ind],yb[ind],color=colph[llcol],psym=sym
					endif
                    csL=1.5
				    if not keyword_set(nolab) then $
                    note,ln,rcvNms[i],color=colph[lcol],xp=xp+xpinc*i,charsize=csL,font=font
                endif
                lcol=(lcol mod 10) +1 
             endif
        endfor
    endelse
    
    return
end
