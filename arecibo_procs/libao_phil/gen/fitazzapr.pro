;+ 
;NAME:
;fitazzapr - print/plot info on the az,za fit 
;SYNTAX: fitazzapr,fitI,over=over,ln=ln,sclln=sclln,nocoef=nocoef,tit=tit,$
;                  nosigma=nosigma,noplot=noplot,plterms=plterms,$
;                  plcomb=plcomb,xoff=xoff,_extra=e,azreq=azreq,zareq=zareq,
;                  xp=xp
;ARGS  :
;       fitI:   {azzafit} structure holding info returned from fitazza.
;KEYWORDS:
;       over:   int, if set then overplot
;         ln:   int, line # to start printing fit values . def= 3
;      sclln:   float scale spacing between lines. default=1.
;     nocoef:   int, if set, then don't bother to print fit coef.
;     nosigma:       if set then don't output sigma For coeff.
;                    they aren't meaningfull unless you specified weights
;     noplot :       if set then don't do the line plot, just print the values.
;        tit:   string, title for plot
;     plterms:  0 - plot az terms
;               1 - plot za terms
;               2 - plot all terms versus az
;               3 - plot all terms versus za
;     plcomb:  if set then plot the combined fit rather than overplotting
;              each term (only makes a difference for az terms).
;     xoff  :  float offset to add to default az or za before evaluating
;                    the fit (overplot does not lay on top of previous plot).
;     _extra:   keyword=value. passed to plot,oplot routines.
;                   (eg.. psym=2 to just plot symbols)
;     azreq[] : float azimuth values (deg) to compute fit at.
;     zareq[] : float za values (deg) to compute fit at.
;          xp : float xposition (0 to 1) for text (def .05)
;DESCRIPTION
;   Print out the fit values returned from fitazza. Output to the terminal
;and plot to a plotfile. 
;   The default output is to plot the individual azimuth terms versus
;az. The program will by default evaluate the fit at fixed azimuth and
;za values. You can use azreq zareq to evaluate it at different values
;(if you specify plterms=2,3 and you want to use azreq,zareq then you
;must provide both values).
;EXAMPLE:
;f(za):  9.16089 +( 0.77126)*za +(-0.06284)*(za-14)^2 +( 0.06741)(za-14)^3
;f(1az):  0.54/982*cos(1az) + (-1.85612)*sin(1az)
;f(2az):  1.30097*cos(2az) + ( 0.69671)*sin(2az)
;f(3az):  0.86003*cos(3az) + ( 1.33455)*sin(3az)
;SigCof: za  0.25757 0.02781 0.08049 0.01504
;        az  0.18664 0.14984 0.17228 0.17435 0.16076 0.14014
; 
; f(za): ffffffff +(ffffffff)*za +(ffffffff)*(za-14)^2 +(ffffffff)(za-14)^3
;f(1az): ffffffff*cos(1az) + (ffffffff)*sin(1az)
;f(2az): ffffffff*cos(2az) + (ffffffff)*sin(2az)
;f(3az): ffffffff*cos(3az) + (ffffffff)*sin(3az)
;SigCof:az f8.5 f8.5 f8.5 f8.5   
;       za f8.5 f8.5 f8.5 f8.5 f8.5 f8.5
;-
pro fitazzapr,fitI,over=over,_extra=e,ln=lngl,nocoef=nocoef,nosigma=nosigma,$
              noplot=noplot,plterms=plterms,plcomb=plcomb,xoff=xoff,$
              sclln=sclln,azreq=azreq,zareq=zareq,xp=xp
;
    common colph,decomposedph,colph

    if not keyword_set(lngl)  then lngl=3
    ln=lngl
    if n_elements(xoff) eq 0 then xoff=0.
    if n_elements(sclln) eq 0 then sclln=1.
    if n_elements(xp) eq 0 then xp=.05
    if keyword_set(plcomb) then plcomb=1 $
        else plcomb=0
    if n_elements(plterms) eq 0 then plterms  =0

    lnst=0
    polnm='A'
    if fitI.pol eq 'b' then begin
        lnst=1
        polnm='B'
    endif
    if fitI.pol eq 'I' then begin
        polnm='I'
    endif
    title=fitI.title + ' Plot az Terms'
;
;   put the fit info into some lines
;
    line=strarr(6)
    prlin=intarr(6)+1
    case fiti.fittype of
        1: begin
    line[0]=$
    string(format=$
'(" f(za): ",f8.5," +(",f8.5,")*za +(",f8.5,")*(za-14)^2 +(",f8.5,")(za-14)^3")',$
        fitI.coef[0],fitI.coef[1],fitI.coef[2],fitI.coef[3])
        end 
        2: begin
    line[0]=$
    string(format=$
'(" f(za): ",f8.5," +(",f8.5,")*(za-10)+(",f8.5,")*(za-10)^2 +(",f8.5,")(za-10)^3")',$
        fitI.coef[0],fitI.coef[1],fitI.coef[2],fitI.coef[3])
        end
        6: begin
    line[0]=$
    string(format=$
'(" f(za): ",f8.5," +(",f8.5,")*(za-10)+(",f8.5,")*(za-10)^2 +(",f8.5,")(za-10)^3")',$
        fitI.coef[0],fitI.coef[1],fitI.coef[2],fitI.coef[3])
        prlin[1:3]=0
        prlin[5]=0
        end
        3: begin
    line[0]=$
    string(format=$
'(" f(y ): ",f8.5," +(",f8.5,")*y+(",f8.5,")*(2y^2-1) +(",f8.5,")(4y^3-3y)..y=(za/10-1)")',$
        fitI.coef[0],fitI.coef[1],fitI.coef[2],fitI.coef[3])
        end
        4: begin
    line[0]=$
    string(format=$
'(" f(za): ",f8.5," +(",f8.5,")*za +(",f8.5,")*(za-14)^2 +(",f8.5,")(za-14)^3")',$
        fitI.coef[0],fitI.coef[1],fitI.coef[2],fitI.coef[3])
        prlin[1:3]=0 
        prlin[5]=0
        end 
        5: begin
    line[0]=$
    string(format=$
'(" f(za): ",f8.5," +(",f8.5,")*(za-10) +(",f8.5,")*(za-10)^2 +(",f8.5,")(za-10)^3")',$
        fitI.coef[0],fitI.coef[1],fitI.coef[2],fitI.coef[3])
        end
	    7:begin
			prlin[0]=0
			prlin[4]=0
		  end
    else: message,'fitazzapr, fittype is 1 or 2'
    endcase
;----------------------------------------------------------------------------
; az terms


	ii=(fiti.fittype eq 7)?1:4
    line[1]=$
    string(format='("f(1az): ",f8.4,"*cos(1az) + (",f8.4,")*sin(1az)")',$
        fitI.coef[ii],fitI.coef[ii+1])

    if fiti.fittype ne 5 then begin
    	line[2]=$
    	string(format='("f(2az): ",f8.4,"*cos(2az) + (",f8.4,")*sin(2az)")',$
       	 fitI.coef[ii+2],fitI.coef[ii+3])

    	line[3]=$
    	string(format='("f(3az): ",f8.4,"*cos(3az) + (",f8.4,")*sin(3az)")',$
        	fitI.coef[ii+4],fitI.coef[ii+5])
    endif else begin
    	line[2]=$
    	string(format='("f(3az): ",f8.4,"*cos(3az) + (",f8.4,")*sin(3az)")',$
       	 fitI.coef[6],fitI.coef[7])
    	line[3]=$
   	 string(format='("f(3az): ",f8.4,"sin(za-10)*cos(3az) + (",f8.4,")*sin(za-10)*sin(3az)")',$
   	     fitI.coef[8],fitI.coef[9])
    endelse

	if (fiti.fittype ne 7) then begin
    	line[4]= string(format='("SigCof: za ",f8.4,f8.4,f8.4,f8.4)',$
    	fitI.sigmaCoef[0],fitI.sigmaCoef[1],fitI.sigmaCoef[2],fitI.sigmaCoef[3]) 
	endif
    line[5]= string(format='("SigCof: az ",f8.4,f8.4,f8.4,f8.4,f8.4,f8.4)',$
    fitI.sigmaCoef[ii],fitI.sigmaCoef[ii+1],fitI.sigmaCoef[ii+2],fitI.sigmaCoef[ii+3],$
            fitI.sigmaCoef[ii+4],fitI.sigmaCoef[ii+5])


    for i=0,5 do begin
        if (prlin[i]) then print,line[i]
    endfor

    coefpl=fitI.coef
    if not keyword_set(noplot) then begin
      case 1 of 
;         za
        plterms eq 1 : begin
            title=fitI.title + ' Plot combined za Terms'
            plcomb=1
            if n_elements(zareq) gt 0 then begin
                x=zareq
            endif else begin
                x=findgen(95)/100.*20 + 1.
            endelse
            x=x + xoff
            y=fitazzaeval(x,x,fiti,/zaonly)
            xtitle='za'
        end
        plterms eq 0 : begin
            title=fitI.title + ' Plot az Terms'
            if n_elements(azreq) gt 0 then begin
               x  = azreq
            endif else begin
               x  =findgen(360)
            endelse
			if (fitI.fittype eq 4) or (fitI.fittype eq 6) then begin
				print,"Error fitazzapr.plterms=0. fittype",fitI.fittype," contains no az terms"
				return
			endif
            x=x + xoff
            xr =x*!dtor
            xtitle='az'
            if plcomb then begin
               title=fitI.title + ' Plot combined az Terms'
               y=fitazzaeval(x,x,fiti,/azonly)
            endif else begin
               title=fitI.title + ' Plot az Terms'
			   case 1 of
                 fiti.fittype eq 5: begin
                   y =coefpl[4]*cos(xr)     +coefpl[5]*sin(xr)
                   y3=coefpl[6]*cos(3.*xr)  +coefpl[7]*sin(3.*xr)
                   y2=fltarr(n_elements(xr))
				 end
			     fitI.fittype eq 7: begin
                   y =coefpl[1]*cos(xr)   + coefpl[2]*sin(xr)
                   y2=coefpl[3]*cos(2.*xr)+ coefpl[4]*sin(2.*xr)
                   y3=coefpl[5]*cos(3.*xr)+ coefpl[6]*sin(3.*xr)
                 end
			     else: begin
                    y =coefpl[4]*cos(xr)     +coefpl[5]*sin(xr)
                    y2=coefpl[6]*cos(2.*xr)+coefpl[7]*sin(2.*xr)
                    y3=coefpl[8]*cos(3.*xr)+coefpl[9]*sin(3.*xr)
				 end
			   end
            endelse
            end
        else : begin
            plcomb=1
            if (n_elements(azreq) gt 0 ) and (n_elements(zareq) gt 0) then begin
                az=azreq
                za=zareq
            endif else begin
                mkazzagrid,az,za,azstep=30,zastep=1,zastart=1
                a=size(az)
                az=reform(az,a[1]*a[2])
                za=reform(za,a[1]*a[2])
            endelse
            title=fitI.title + ' Plot combined fit'
            if plterms eq 2 then begin
                x=az+xoff
                xtitle='az'
            endif else begin
                x=za+xoff
                xtitle='za'
            endelse
            y=fitazzaeval(az,za,fiti)
            end
        endcase
;       print,xoff
      if keyword_set(over) then begin
        oplot ,x,y,color=colph[1],_extra=e,linestyle=lnst
      endif else begin
        plot,x,y,color=colph[1],/xstyle,/ystyle,xtitle=xtitle,$
                 ytitle=fitI.ytitle,$
                _extra=e,title=title,linestyle=lnst
      endelse
      if (not plcomb) and (plterms eq 0) then begin
        oplot,x,y2,color=colph[2], _extra=e,linestyle=lnst
        oplot,x,y3,color=colph[3], _extra=e,linestyle=lnst
      endif
    endif
    if not keyword_set(nocoef) then begin
    inc=0
    if ln gt 0 then begin
        if lnst eq 0 then begin
            note,ln,$
        string(format=$
        '("____ Pol ",a0,". ",a,"(az,za) ",f6.1," Mhz Sigma(y-yfit):",f7.4)',$
                polNm,fitI.type,fitI.freq,fitI.sigma),xp=xp
        endif else begin
            note,ln,$
        string(format=$
        '(".... Pol ",a0,". ",a,"(az,za) ",f6.1," Mhz Sigma(y-yfit):",f7.4)',$
                polNm,fitI.type,fitI.freq,fitI.sigma),xp=xp
        endelse
        ln=ln+1*sclln
        inclast=5
        if keyword_set(nosigma) then inclast=inclast-2
        for i=0,inclast do begin
            if  prlin[i] then begin
                note,ln+inc*sclln,line[i],xp=xp
                inc=inc+1
            endif
        endfor
    endif
    endif
    return
end
