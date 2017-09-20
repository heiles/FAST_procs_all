;+
;NAME:
;lrplottemp - plot platform temp for the data set passed in.
;SYNTAX:
;   lrplottemp,d ,title=title,cs=cs,xp=xp,off=off,sep=sep,clip=clip,year=year
;ARGS:
;   d[n]: {lrdist}  data input from lrpcinprange 
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
;   sep     -        if set then make 1 plot per day user should set
;				     !p.multi before calling the routine. 
;   clip[]  -float   clip the data to [mintemp,maxtemp]. allows auto scaling
;					 with bad data points..
;   year    - long   for the first point of the file. If not supplied then
;                    assume the current year.
;                    
;DESCRIPTION
;   Plot the platform temperature by  hour of day for the data passed in.
;(the routine limits the output to a maximum of 31 days).
;The plot will have N subwindows with up to 7 consecutive days per window. 
;Each day will be color coded within a window. Any extra days (>28 will appear
;in the last window). The routine internally uses daynumber of year for
;computations so it will not cross year boundaries gracefully. 
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
;   lrplottemp,d,title='platform temps for jul01',  cs=1.6
;NOTES:
;	The routine is setup to plot 1 month of data at a time.
;-
pro lrplottemp,d,title=title,cs=cs,xp=xp,off=off,sep=sep,clip=clip,year=year
;
	common colph,decomposedph,colph

;
;   ignore data with values outside of this range.
;
    mintemp=50.
    maxtemp=120.
;
;   clip plotted values to this range
;
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
;
; limit data to 31 days
;
	if not keyword_set(year) then  begin
	   a=bin_date()
       year=a[0]
    endif
    day1=long(d[0].date)
    day2=max(d.date) <  (day1 + 30L)
    ndays=day2-day1 + 1L
    if ndays gt maxdays then begin
        day2=day1+maxdays-1
        ndays=maxdays
    endif
;
    nwin=ndays/7
    if (ndays mod  7 ) ne 0 then nwin=nwin+1
    if nwin gt 4 then nwin=4
    curday=day1
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
        ind=where((long(d.date) eq curday)   and $
                       (d.temppl ge mintemp) and $
                       (d.temppl le maxtemp),count)
        if count gt 1 then begin
            lninwin=i-curwin*7
            offl=off*lninwin
            h=(d[ind].date - long(d[ind[0]].date))*24.
            a=daynotodm(curday,year)
            lab=string(format='(i2.2,i2.2,i2.2)',year mod 100,$
                a[1],a[0])
			y=d[ind].temppl
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
