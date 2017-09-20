;+
;NAME:
;amplot - plot alfa dewar monitoring
;SYNTAX: amplot,d,temp=temp,Id=Id,Vd=vd,Vg=vg,over=over,sym=sym,
;               color=col,ln=ln,adate=adate,drange=drange,$
;               cs=cs,log=log,v1=v1,v2=v2,cont=cont,vmed=vmed,labbm=labbm,
;               xpinc=xpinc,tosmo=tosmo,useoff=useoff,fl=fl,ldate=ldate,$
;				mytitle=mytitle
;ARGS:   
;   d[]:{alfamon} array of data input via aminpday.
;KEYWORDS:
;   temp    : int    if set then plot 16 and 70 K temps
;   Id      : int    amplifier bias drain curreint. plot stage= 1,2,3
;   Vd      : int    amplifier bias drain voltage.  plot stage  1,2,3
;   Vg      : int    amplifier bias gain  voltage.  plot stage  1,2,3
;   over    : int   if set then overplot rather than start a new plot
;   sym     : int   1,2,3 .. plot a symbol at each measured position.
;                   1 +, 2 *, 3 . , Negative number -1,-2,-3 will plot 
;                   the symbol and the connecting lines.
;  color    : int   if provided then plot the current data set in this color.
;                   colors are: (1-white, 2-red, 3-green,4-blue,5-yellow...
;  ln       : int   line number for rcvr name labels. values 3..33
;  adate    : int   if set then plot using alphanumeric dates: ddMMMyy
;  drange[3]: float Date range to plot. Use with /adate to limit the
;                   dates plotted.  format:[year,daynum,Numdays]
;                   keep numdays about year,daynum. (numdays can be positive
;                   or negative). These are AST dates
;  cs       : float character size scaling if single plot. default=1
;  log      :       if true then use log for vertical scale.. 
;                   (warning.. don't set lower vertical scale to 0..)
; v1[2]     : float min,max value for top plot. default is auto scale
; v2[2]     : float min,max value for bottom. default is auto scale
;                   Note: v2 only works with Temps. For Id,Vd,Vg v1[]
;                        will set top and bottom veritcal scales the same.
; vmed      : float fractional value about median to display
; cont      :       if true then continue adding plots to this page.
;                   need to set !p.multi=[0,n,m] before calling the first
; 					time
;labbm[2]   : float  [line number,xp] for where to label the beams
;xpinc      : float  fraction to space between beam labels. def: .05
;tosmo      : int    number of points to smooth/decimate
; useoff    :        if set then used data with amps off.
; fl[]      :        flag these locations in plots (jd)
;ldate      : string if present and adate set then use this for
;                    label_date() format. Default:"%D%M"
;mytitle    : string if present add to end of title
;
;RETURNS:
; gotdata:           1 if data found, 0 if no data found
;
;DESCRIPTION:
;   Plot the alfa dewar info data versus day of year. The data 
;must be first input with aminpday. By default it will plot the 16 degree 
;temperature stage. You can use the keywords to select the following data to
;plot:
; temp: 1    : plots 16 and the 70 K temps
;   Vd: 1,2,3  : stage 1st,2nd, or 3rd amplifier bias drain voltages
;   Id: 1,2,3  : 1st,2nd, or 3rd amplifier bias currents.
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
;   By default each pol  is plotted in a different color on one plot.
;
;   When using the adate keyword, the tickmark end up being spaced by
;some reasonable number of days (5,10,20..etc).
;
;   Making hardcopy requires that you set the destination of the output to
;a postscript file before you call the routine.
;   pscol,'filename.ps'
;   amplot,d
;   hardcopy
;   x
;The data will then be in the postscript file filename.ps.
;
;EXAMPLES:
;   To start idl:
;   idl
;   @phil
;   @alfamoninit
;   ... 
;nrecs=aminpday,021224,d,ndays=6         .. input dec 20 to 25
;hor
;ver,0,50                          .. vertical scale 0 to 50 K
;amplot,d                          .. plot all 16 deg stage
;amplot,d,vd=1,/adate              .. plot drain voltage, ascii dates
;
;
;NOTE:
;-
;history:
;
pro ver_slop,ymin,ymax,fract

		sgnMin=(ymin lt 0.)? -1. : 1.
		sgnMax=(ymax lt 0.)? -1. : 1.
		ver,ymin*(1-sgnMin*fract),ymax*(1+sgnMax*fract)
		return
end
;
pro amplot,d,temp=temp,Id=Id,Vd=Vd,Vg=Vg,over=over,sym=sym,$
        color=col, ln=ln,adate=adate,drange=drange,cs=cs,$
		log=log,v1=v1,v2=v2,cont=cont,vmed=vmed,labbm=labbm,mytitle=mytitle,$
		xpinc=xpinc ,tosmo=tosmo,useoff=useoff,fl=fl,ldate=ldate,gotdata=gotdata
;
	common colph,decomposedph,colph
	forward_function ver_slop

	gotdata=0
	if n_elements(ldate) eq 0 then ldate='%D%M'
	if n_elements(tosmo) eq 0 then tosmo=1
	if n_elements(mytitle) eq 0 then mytitle=''
	astToUtc=4D/24D
	if not keyword_set(cs) then cs=1.
;    no16K=[]
	verSlop=.01				; vertical scale 1 % outside min,max
    doid=0
    dovg=0
    dovd=0
    dotemp=0
	ls=2
	colfl=10
    !x.style=1
    !y.style=1
    if n_elements(ln) eq 0 then ln=26
    if n_elements(temp) eq 0 then temp=0
	usev1=n_elements(v1) eq 2
	usev2=n_elements(v2) eq 2
	caldat,d[0].jd-astToUtc,mon,day,year
	title=''
    case 1 of
       n_elements(Id) gt 0: begin
            Idstage =Id
            doId=1
			if (Idstage lt 1) or (Idstage gt 3) then begin
				print,"Id value is : 1..3 for stages 1 to 3"
				return;
			endif
			 title=string(format=$
				'("Id:Drain Current. stage ",i1," (year ",i4,")")',idStage,year)

            end
       n_elements(Vd) gt 0: begin
            Vdstage=Vd
            doVd=1
			if (Vdstage lt 1) or (Vdstage gt 3) then begin
				print,"Vd value is : 1..3 for stages 1 to 3"
				return;
			endif
            title=string(format=$
				'("Vd:Drain Voltage. stage ",i1," (year ",i4,")")',VdStage,year)
            end
       n_elements(Vg) gt 0: begin
            Vgstage=Vg
            doVg=1
			if (Vgstage lt 1) or (Vgstage gt 3) then begin
				print,"Vg value is : 1..3 for stages 1 to 3"
				return;
			endif
            title=string(format=$
				'("Vg:Gate  Voltage. stage ",i1," (year ",i4,")")',VgStage ,year)
            end
       keyword_set(temp): begin
			doTemp=1
			end
        else: begin
			dotemp=1
		 end
    endcase
	title=title + mytitle
	if doTemp then begin
    	title1=string(format='("Dewar temps - 16K stage (year ",i4,")")',$
            year) + mytitle
    	title2=string(format='("Dewar temps - 70K stage (year ",i4,")")',$
            year) + mytitle
    end

	ylog=(keyword_set(log) and (dotemp ne 0))?1:0
    if keyword_set(adate) then begin
        a=label_date(date_format=ldate)
        xtformat='label_date'
        xtitle='date'
    endif else begin
        xtformat=''
        xtitle='daynumber of year'
    endelse
    if n_elements(drange) eq 3 then begin
       x =d.jd
;     drange is ast. convert to utc
       x1=daynotojul(drange[1],drange[0]) + astToUTC
       x1=x1[0]
       delta=drange[2]
	   eps=1e-6
       if delta lt 0. then begin 
;                 include current day
        ind=where((x ge (x1+delta)) and (x lt (x1 + 1D - eps)),count)
       endif else begin
        ind=where((x ge x1) and (x le (x1+ delta-eps)),count)
       endelse
       if count le 0 then begin
            printf,-2,"no data between daynumbers:",drange
            return 
        endif
        dd=d[ind]
    endif else begin
        dd=d
    endelse
;
; 	ignore samples were all 14 amps are off unless useoff set.
;
	if not keyword_set(useoff) then begin
	ii=where(total(reform(dd.bias_stat,14,n_elements(dd)),1) gt 0,cnt)
	if cnt eq 0 then begin
		print,"No data for time period.. bias_stat left off.."
		return
	endif
	if cnt ne n_elements(dd) then dd=dd[ii]
	endif
;
    xp=.02
    scl=.8
    n=n_elements(dd)
    if n_elements(sym)  eq 0 then sym=0
    lcol=1
    if n_elements(color)  ne 0 then lcol=col
;
;
    if keyword_set(adate) then begin
        x=dd.jd - astToUtc			; to ast
;       print,'min x:',min(x)
;       print,'max x:',max(x)
;
;      idl puts major tick marks with labels at 12Hours: this is
;      jd 0, but utc 12. add .5 to make the major tick marks show
;      up at utc 0
;      not needed if hour present
		if ((strpos(ldate,'H') eq -1) and (strpos(ldate,'h') eq -1)) then $
        x=x+.5     	; to center days at midnite not noon.. in plots  
     endif else begin
		caldat,dd.jd-astToUtc,mon,day,yr,hr,min,sec
		x=dmtodayno(day,mon,yr) +       (hr + (min + sec/60.)/60.)/24
    endelse
	if not keyword_set(cont) then !p.multi=[0,1,2]
;
;   
;
	case 1 of
		dotemp: begin
			if usev1 then begin
			 	ver,v1[0],v1[1]
		    endif else begin
				if keyword_set(vmed) then begin
			       avgV=median(dd.t20)
				   ver_slop,avgV,avgV,vmed
				endif else begin
					ymin=min(dd.T20,max=ymax)
					ver_slop,ymin,ymax,verSlop
				endelse
			endelse
            stripsxy,x,transpose(dd.T20),0,0,/step,xtickformat=xtformat,$
					ylog=ylog,xtitle=xtitle,ytitle='deg K',title=title1,$
                        psym=sym,charsize=cs,smo=tosmo,dec=tosmo
			if (n_elements(fl) gt 0) then flag,fl,linestyle=ls,col=colph[colfl]
		    if usev2 then begin
                ver,v2[0],v2[1]
            endif else begin
				if keyword_set(vmed) then begin
                   avgV=median(dd.t70)
				   ver_slop,avgV,avgV,vmed
                endif else begin
                	ymin=min(dd.T70,max=ymax)
					ver_slop,ymin,ymax,verSlop
				endelse
            endelse
            stripsxy,x,transpose(dd.T70),0,0,/step,xtickformat=xtformat,$
					ylog=ylog,xtitle=xtitle,ytitle='deg K',title=title2,$
                        psym=sym,charsize=cs,smo=tosmo,dec=tosmo
			if (n_elements(fl) gt 0) then flag,fl,linestyle=ls,col=colph[colfl]
			
			for i=1,4 do note,15,string(format='("K",i1)',i),xp=-.1+(i-1)*.07,$
				col=colph[i]
                end
        doVd: begin
			if usev1 then begin
			 	ver,v1[0],v1[1]
		    endif else begin
				if keyword_set(vmed) then begin
                	avgV=median(dd.vd[*,*,vdStage-1])
				    ver_slop,avgV,avgV,vmed
                endif else begin
					ymin=min(dd.vd[*,*,vdStage-1],max=ymax)
					ver_slop,ymin,ymax,verSlop
				endelse
			endelse
			yA=transpose(reform(dd.Vd[0,*,vdStage-1]))
			yB=transpose(reform(dd.Vd[1,*,vdStage-1]))
            stripsxy,x,ya,0,0,/step,xtickformat=xtformat,xtitle=xtitle,$
				ytitle='Volts',title= title + ' PolA', psym=sym,charsize=cs,$
				smo=tosmo,dec=tosmo
			if (n_elements(fl) gt 0) then flag,fl,linestyle=ls,col=colph[colfl]
            stripsxy,x,yb,0,0,/step,xtickformat=xtformat,xtitle=xtitle,$
				ytitle='Volts', title= title + ' PolB', psym=sym,charsize=cs,$
				 smo=tosmo,dec=tosmo
			if (n_elements(fl) gt 0) then flag,fl,linestyle=ls,col=colph[colfl]
            end
        doVg: begin
			if usev1 then begin
			 	ver,v1[0],v1[1]
		    endif else begin
			   if keyword_set(vmed) then begin
                    avgV=median(dd.vg[*,*,vgStage-1])
				    ver_slop,avgV,avgV,vmed
                endif else begin
					ymin=min(dd.vg[*,*,vgStage-1],max=ymax)
					ver_slop,ymin,ymax,verSlop
				endelse
			endelse
			yA=transpose(reform(dd.Vg[0,*,vgStage-1]))
			yB=transpose(reform(dd.Vg[1,*,vgStage-1]))
            stripsxy,x,ya,0,0,/step,xtickformat=xtformat,xtitle=xtitle,$
				ytitle='Volts',title= title + ' PolA', psym=sym,charsize=cs,$
				smo=tosmo,dec=tosmo
			if (n_elements(fl) gt 0) then flag,fl,linestyle=ls,col=colph[colfl]
            stripsxy,x,yb,0,0,/step,xtickformat=xtformat,xtitle=xtitle,$
				    ytitle='Volts',title= title + ' PolB', psym=sym,charsize=cs,$
					smo=tosmo,dec=tosmo
			if (n_elements(fl) gt 0) then flag,fl,linestyle=ls,col=colph[colfl]
            end
        doId: begin
			if usev1 then begin
			 	ver,v1[0],v1[1]
		    endif else begin
				if keyword_set(vmed) then begin
                    avgV=median(dd.Id[*,*,IdStage-1])
				    ver_slop,avgV,avgV,vmed
                endif else begin
					ymin=min(dd.Id[*,*,idStage-1],max=ymax)
					ver_slop,ymin,ymax,verSlop
				endelse
			endelse
			
			yA=transpose(reform(dd.Id[0,*,idStage-1]))
			yB=transpose(reform(dd.id[1,*,idStage-1]))

            stripsxy,x,ya,0,0,/step,xtickformat=xtformat,xtitle=xtitle,$
				ytitle='milliAmps',title= title + ' PolA', psym=sym,charsize=cs,$
				smo=tosmo,dec=tosmo
			if (n_elements(fl) gt 0) then flag,fl,linestyle=ls,col=colph[colfl]
            stripsxy,x,yb,0,0,/step,xtickformat=xtformat,xtitle=xtitle,$
				ytitle='milliAmps',title= title + ' PolB', psym=sym,charsize=cs,$
				smo=tosmo,dec=tosmo
			if (n_elements(fl) gt 0) then flag,fl,linestyle=ls,col=colph[colfl]
            end
	end
	if n_elements(labbm) eq 2 then begin
		if n_elements(xpinc) eq 0 then xpinc=.07
		for i=0,6 do begin
			lab=string(format='("bm",i1)',i)
;			print,i,labbm[0],labbm[1],labbm[1]+i*xpinc
			note,labbm[0],lab,xp=labbm[1] + i*xpinc,col=colph[i+1]
		endfor
	endif
	gotdata=1
    return
end
;
