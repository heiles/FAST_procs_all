;+
;NAME:
;tdkips - input and plot tiedown tensions 
;SYNTAX: nrec=tdkips(yymmdd,tmrange=tmrange,td=td,usetd=usetd,$
;                sym=sym,v1=v1,v2=v2,flaghr=flaghr,title=title,$
;                hardcopy=hardcopy,psname=psname,plotnum=plotnum,cont=cont,$
;				 cs=cs,avgmin=avgmin)
;ARGS:
;    yymmdd: long  date to look at
;tmrange[2]: float start,end hour to display. default is entire day  
;
;KEYWORDS:
;    v1[2]: float   vert range for individual cable kips
;    v2[2]: float   vert range for ldcell1-ldcell2
;    sym  : int     symbol to used (default: none)
;flagHr[m]: float   range of hours to flag in each plot
;    title: string  to add to top of first plot
;tmrange[2]:long    if provided, then limit the plots to
;                   the hours tmrange[0] to tmrange[1].
;    usetd: long    if set then the routine will use the info in the
;                   td=td structure passed in by the user rather than
;                   reading the data from the disc. This lets you rapidly
;                   replot various time ranges.
;     td[]:{}        This can be output or input. On the first call the
;                   data array is returned here. On subsequent calls if
;                   /usetd is set then this will be the source of the
;                   data rather than rereading it from disc.
; hardcopy:         if set then make a postscript hardcopy. If psname is
;                   not set, then the output filename will be 
;                   tdkips_ddMONyy.ps.
;   psname:string   The name of the postscript file to write (if hardcopy
;                   is set). The default is 'tdkips_ddMONyy.ps'
;   plotnum:int     1 --> just do first plot (kips vs hour of day)
;                   2 --> just do 2nd plot (ldcell1-ldcell2) vs avg kips
;      cont:        if set then don't call !p.multi=0. This lets you 
;                   put multiple days data on the same page
;  avgMin:          if set then output minute averages
;
;  
;RETURNS:
;   nrec: int number of records found in tmrange
;td[nrec]:{} td structure for the day.
;
;DESCRIPTION:
;   Input a days worth of tiedown archive information (at 1 second
;resolution) and make a plot of the tensions. The tmrange keyword can limit the
;range of the input data to tmrange=[hourst,hourend]. The data input
;will be returned in the keyword td=td;
;
;   You can make subsequent calls on the same data set by setting
; /usetd and passing in the data td=td read from the previous call. This 
;will speed things up since it doesn't have to reread the data. You
;can also change the tmrange=tmrange values to blowup different portions of the
;day.
;
;   The top plot is the tiedown tensions in kips (1000lbs=1kip) versus
;hour of day. The tensions are color coded:
;
;  white td12-1    red td12-2
;  green  td4-1   blue  td4-2
; yellow  td8-2 purple  td8-2
;
;
;The bottom plot is the difference in the tensions for 1 tiedown vs the
;average tension of that tiedown. This will show offsets and non linearities.
;They difference are color coded:
;
; white  (td12-1 - td12-2)
; green  ( td4-1 -  td4-2)
; yellow ( td8-1 -  td8-2)
;
;EXAMPLES:
;
;1. plot the tiedown tensions for 28apr06
;
;   n=tdkips(060428,td=td)
;
;2. replot the time range 12:00 to 16:00
;
;   n=tdkips(060428,td=td,/usetd,tmr=[12,16])
;
;3. replot the time range 18 to 20 hours limiting the vertical range
;   of the first plot to 0 to 25 kips, and the range of the 2nd plot to
;   -10 to 10 kips
;
;   n=tdkips(060428,td=td,/usetd,tmr=[18,20],v1=[0,25],v2=[-10,10])
;
;4. make a hardcopy of the plot in 3. use the default name:tdkips_28apr06.ps
;   n=tdkips(060428,td=td,/usetd,tmr=[18,20],v1=[0,25],v2=[-10,10],/hard)
;
;SEE ALSO: tdchkday
;-
function tdkips,yymmdd ,td=td,tmrange=tmrange,usetd=usetd,$
            v1=v1,v2=v2,title=title,flaghr=flaghr,hardcopy=hardcopy,$
            psname=psname,plotnum=plotnum,cont=cont,cs=cs,avgmin=avgmin

	    common colph,decomposedph,colph

    titleL=keyword_set(title)? title:yymmddtodmy(yymmdd) + ' '
    ldate=string(yymmdd,format='(i6.6)')
    if n_elements(sym) eq 0 then sym=0 
    if n_elements(plotnum) eq 0 then plotnum=3 
	plotnum=((plotnum lt 1) or (plotnum gt 2))?3:plotnum
    if keyword_set(usetd) then begin
       npts=n_elements(td)
    endif else begin
        npts=tdinpday(yymmdd,td)
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
    kips =transpose(reform(td[i1:i2].kips,6,i2-i1+1L))
    pos  =transpose(td[i1:i2].pos)
    tm   =td[i1:i2].secm
    hr   =tm/3600.
;
    if n_elements(cs) eq 0 then cs=1.0
    csn=1.3
    scl=.6
    ln=(plotnum eq 3)?1.8:2.5
    xp=.04
    x=hr
	lnoff=0L
;
	if not keyword_set(cont) then begin
    if plotnum eq 3 then begin
		!p.multi=[0,1,2]
	endif else begin
		!p.multi=0
	endelse
	endif
    if n_elements(v1) eq 2 then begin
        ver,v1[0],v1[1]
    endif else begin
        max=max(kips) + 1.
        ver,0 ,max
    endelse
    hor
;
    if keyword_set(hardcopy) then begin
        if n_elements(psname) eq 0 then psname='tdkips_'+ldate+'.ps'
        pscol,psname,/full
    endif
	if (plotnum and 1 ) ne 0 then begin
    stripsxy,hr,kips,0,0,/step,chars=cs,psym=sym,charsize=cs,$
        xtitle='time [Hr]',ytitle='Kips',$
        title=titleL +' td tensions vs time'
    if n_elements(flaghr) gt 0 then flag,flaghr,linestyle=2
    xinc=.1
    note,ln,'td12-1',xp=xp,color=colph[1],charsize=csn
    note,ln,'td12-2',xp=xp+xinc,color=colph[2],charsize=csn
    note,ln,'td4-1',xp=xp+xinc*2,color=colph[3],charsize=csn
    note,ln,'td4-2',xp=xp+xinc*3,color=colph[4],charsize=csn
    note,ln,'td8-1',xp=xp+xinc*4,color=colph[5],charsize=csn
    note,ln,'td8-2',xp=xp+xinc*5,color=colph[6],charsize=csn
	lnoff=14L
	endif
;
	if (plotnum and 2 ) ne 0 then begin
    ii=[0,2,4]
    dif=kips[*,ii]-kips[*,ii+1]
    avg=(kips[*,ii]+kips[*,ii+1])*.5

    if n_elements(v2) eq 2 then begin
        ver,v2[0],v2[1]
    endif else begin
        ver,min(dif)-1,max(dif)+1
    endelse

    syml=(sym eq 0) ? (3):abs(sym)
    plot,[0,1],[0,1],/nodat,xrange=[0,max(avg)+1.],charsize=cs,$
        xtitle='Kips',ytitle='ldcell1-ldcell2 (kips)',$ 
        title ='Ldcell1-ldcell2 vs avg tension'
    for i=0,2 do begin &$
        kipt=(kips[*,2*i]+kips[*,2*i+1])*.5 &$
        col=i*2+1 &$
        oplot,kipt,kips[*,2*i]-kips[*,2*i+1],psym=syml,col=colph[col] &$
    endfor
    ln=2.5+lnoff
    note,ln,'td12',xp=xp,color=colph[1],charsize=csn
    note,ln,'td4' ,xp=xp+xinc,color=colph[3],charsize=csn
    note,ln,'td8-1',xp=xp+xinc*2,color=colph[5],charsize=csn
	endif
    if keyword_set(hardcopy) then begin
        hardcopy
        x
        print,'Output write to:',psname
    endif
    return,npts
end
