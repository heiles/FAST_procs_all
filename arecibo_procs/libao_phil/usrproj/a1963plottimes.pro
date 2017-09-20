;+
;NAME:
;a1963plottimes - a1963 plot the pattern times.
;SYNTAX: a1963plottimes,datI,h1=h1,v1=v1,h2=h2,v2=v2,v3=v3,thick=thick,$
;                hardcopy=hardcopy,psname=psname        
;ARGS:
;   datI[n]: {} Times computed be comptimes routine
;KEYWORDS:
;   h1[2]:  float [min,max] horizontal values for top plot on page
;   v1[2]:  float [min,max] vertical   values for top plot on page
;   h2[2]:  float [min,max] horizontal values for middle and bottom
;                  plot on page
;   v2[2]:  float [min,max] vertical   values for middle plot on page
;   v3[2]:  float [min,max] vertical   values for bottom plot on page
;   thick:  float line thickness for plots. Default value is 1. A larger
;                 number will make the line thicker. Some laser printers
;                 need this to be set to 2 so the line is visible.
;hardcopy:        If set then write to psfile rather than screen.
;                 default psfilename is 'idl.ps'
;psname  : string If hardcopy is set then the routine writes to a psfile.
;                 The default name is 'idl.ps'. You can change the name
;                 using psname=filename
;
;DESCRIPTION:
;   Plot the position time info for a a1963 patterns. This information
;is computed in the comptimes() routine and stored in the datI array
;of strucutres.
;   The routine makes 3 plots per page:
;
;TOP PLOT:
;    This is the azimuth, zenith angle for the start of each
;drift in the map.
;
;MIDDLE PLOT:
;   It contains 3 plots in white, red, and green:
;  white: the time available between each position. This is computed
;         from the azimuths and ra,decs.
;    red: the time needed to move between these az,za's
;  green: the total time need between patterns. it includes the 
;         requested integration times plus move times.
;BOTTOM PLOT:
;   The extra time available for between each pattern. It is
;available time - (integration + movetime).
;
;The values at location I are computed using the start of I - start(I-1)
;(eg. data at 2 has the times from start of pat 1 to start of pat 2).
;
;The move times use the slew rate. The actual time to move will take
;longer so these estimates are minimum time needed.
;
;EXAMPLES:
;   a1963comptimes,041130,'/share/obs4/usr/a1963/n2903_nov30.cat',datI
;   a1963plottimes,datI
;
;   To make hard copy you can put 1 plot per file or multiple plots per
;file:
;   1 plot per file
;   a1963plottimes,dati,/hardcopy,psname='a196330nov04.ps'
;
;   multiple plots per file
;   pscol,'a1963nov03',/full
;   a1963plottimes,dati28
;   a1963plottimes,dati29
;   a1963plottimes,dati30
;   hardcopy
;   x
;NOTE:
;   Do @usrprojinit to include the path to this routine.
;
;-
pro a1963plottimes,datI,h1=h1,v1=v1,h2=h2,v2=v2,v3=v3,thick=thick,$
    hardcopy=hardcopy,psname=psname 
;
; now plot what we found
;
    hard=keyword_set(hardcopy)
    if not keyword_set(psname) then psname='idl.ps'
    if hard then pscol,psname,/full
    cs=1.7
    if n_elements(thick) eq 0 then thick=1.
    !p.multi=[0,1,3]
    if n_elements(h1) eq 2 then begin
        hor,h1[0],h1[1]
    endif else begin
        hor,min(dati.az)-5,max(dati.az)+5
    endelse
    ver,0,20
    if n_elements(v1) eq 2 then ver,v1[0],v1[1]
    dateL=string(format='(" ",i6.6)',dati[0].yymmdd)
    plot,datI.az,datI.za,psym=-2,thick=thick,charsize=cs,$
        xtitle='az [deg]',ytitle='za ',$
        title='a1963 az za positions for ' + dateL


;
;   time between starts
;
    dt=(dati.jd - shift(dati.jd,1))*86400D
    dt[0]=0
;
;   move time
;
    daz=(dati.az - shift(dati.az,1))
    daz[0]=0
    dza=(dati.za - shift(dati.za,1))
    dza[0]=0
    movAz=abs(daz)/25. * 60.
    movZa=abs(dza)/2.5 * 60.
    movTm=(movAz > movZa)
    intTm=dati[0].srcTime
    totTm=movTm+intTm
    totTm[0]=0
;

    nsrc=n_elements(datI)
    x=findgen(nsrc)+1
    if n_elements(h2) eq 2 then begin
        hor,h2[0],h2[1]
    endif else begin
        hor,0,n_elements(dt)+1
    endelse
    if n_elements(v2) eq 2 then begin
        ver,v2[0],v2[1]
    endif else begin
        ver,-10,max(dt)+10
    endelse

    plot,x,dt,psym=10,thick=thick,charsize=cs,$
        xtitle='pattern number (1..n)',ytitle='time in seconds',$
        title='a1963, needed and available time for patterns on' $
            + dateL
    oplot,x,movTm,psym=10,color=2,thick=thick
    oplot,x,totTm,psym=10,color=3,thick=thick
;
    ln=12
    xp=.04
    scl=.7
    note,ln  ,'Time Available (pat[i-1] to pat[i])',color=1,xpos=xp
    note,ln+1*scl,'Time to move pat(i-1) to pat(i)',color=2,xpos=xp
    note,ln+2*scl,'Time Needed (move + integrate)',color=3,xpos=xp
;
;   
    if n_elements(v2) eq 2 then begin
        ver,v3[0],v3[1]
    endif else begin
        ver,min(dt-tottm)-5,max(dt-tottm)+5
    endelse
    plot,x,dt-totTm,thick=thick,charsize=cs,psym=10,$
        xtitle='pattern number (1..n)',ytitle='time in seconds',$
        title='a1963, Extra time available' 
    oplot,[-10,100],[0,0],linestyle=2
    if hard then begin
		hardcopy
    	x
	endif
    return
end
