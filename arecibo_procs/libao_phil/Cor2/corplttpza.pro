;+
;NAME:
;corplttpza - plot total power vs za for each scan
;SYNTAX: corplttpza,pwr,horza=horza,ver1=ver1,ver2=ver2,printscan=printscan,
;                   title=tile,sbc=sbc,scanpos=scanpos,avgpol=avgpol
;ARGS  :
;       pwr[]   :{corpwr} power data returned from corpwr
;KEYWORDS:
;   horza[2]: float za range to plot.def.. that of data
;   ver1[2]: vertical range top plot. default:range of data
;   ver2[2]: vertical range bottom plot. default:range of data
;   printscan: if set then print scannumber on bottom plot
;   title  : string   title to use for top plot.
;   sbc    : int      0 or 1 to plot 1st or 2nd sbc of board.
;                     For setups with 2 polarizations per board this
;                     lets you choose polA or polb. The default is 0=polA
;  scanpos: float     yposition for the start of the scan number list (if
;                     printscanis requested). Units are fration of the 
;                     window (measured from the bottom). The default value
;                     is .15
;  avgpol:            if set then average polarizations
;DESCRIPTION:
;   Display the total power versus zenith angle for all scans in a file.
;You must first input the total power information from the file using:
;   nrecs=corpwrfile(fileanme,p,maxrecs=20000)
;
;Corplottpza will then make two plots:
;1. the total power versus zenith angle.
;2. totalpower/median(totalpowerInscan) -1
;
;By default it will plot the total power from the first sbc of a board. The
;sbc keyword can be used to display the total power from the second
;sbc (if there were two sbc/board). Scans with only 1 record will be 
;ignored. Each scan will be plotted in a different color (cycling through
;10 colors). If the colors do not show up try ldcolph to load the color
;lookup table.
;
;This routine is handy to look at onoff position switching data since
;the on and off position will follow the same za track. The color order
;printed on the left helps you determine which was the on and which was
;the off (the on is taken before the off so its color will appear first
;in the list).
;
;The bottom plot shows the fractional change in power with za. Ideally this
;change should be the same for the on,off positions (if there is no
;continuum present). Rapid changes may be interference or the gain
;changing with temperature.
;
;   The keyword horza lets you adjust the horizontal scale.
;The vertical scale can be adjusted with ver1[] (top plot) and ver2[]
;bottom plot.
;   The keyword printscan will print the scannumbers (with the same color coding
;as the plots) at the bottom of the page.
;
;EXAMPLE:
;   nrecs=corpwrfile(fileanme,p,maxrecs=20000);
;   ldcolph                                .. make sure colortable is loaded.
;   corplttpza,p
;   corplttpaz,p,ver1=[.8,1.5],horza[0,20] ..modify vertical/horizontal scale
;   corplttpza,p,sbc=1,/printscan          ..plot other polarization 
;                                            print scan numbers at bottom.
;-
pro corplttpza,p,horza=horza,ver1=ver1,ver2=ver2 ,printscan=printscan,$
               sbc=sbc,scanpos=scanpos,title=title,avgpol=avgpol
;
    common colph,decomposedph,colph

    on_error,1
    getscanind,p.scan,scanind,scanlen
    nscans=(size(scanind))[1]
    !x.style=1
    !y.style=1
    scannum=lonarr(nscans)
;
;    find min,max values of data
;
    maxza=-1.
    minza=21.
    maxv1=-9999.
    minv1=-maxv1
    maxv2=maxv1
    minv2=-maxv2
    usescans=0
    avgpols=keyword_set(avgpol)
    if n_elements(sbc) eq 0 then sbc=0
    if sbc ne 0 then sbc=1
    for i=0,nscans-1 do begin 
        p1=getscanindx(p,i,scanind,scanlen)
        if ((size(p1))[1] gt 1) then begin 
             scannum[usescans]=p1[0].scan
             usescans=usescans+1
             for brd=0,p1[0].nbrds-1 do begin 
                minz=min( p1.za,max=maxz)
                minza= (minz < minza)
                maxza= (maxz > maxza)
                if (avgpols and (p1[0].pwr[1,brd] ne 0.)) then begin
                    yy=(p1.pwr[0,brd]+p1.pwr[1,brd])*.5
                    minv=min(yy,max=maxv)
                    minv1=(minv1 < minv)
                    maxv1=(maxv1 > maxv)
                    yp   =(yy)/median(yy) - 1.
                    minv =min(yp,max=maxv) 
                    minv2=(minv2 < minv)
                    maxv2=(maxv2 > maxv)
                endif else begin
                    minv=min(p1.pwr[sbc,brd],max=maxv)
                    minv1=(minv1 < minv)
                    maxv1=(maxv1 > maxv)
                    yp   =(p1.pwr[sbc,brd])/median(p1.pwr[sbc,brd]) - 1.
                    minv =min(yp,max=maxv) 
                    minv2=(minv2 < minv)
                    maxv2=(maxv2 > maxv)
                endelse
             endfor
        endif
    endfor

    if n_elements(horza) eq 2 then begin
        minza=horza[0]
        maxza=horza[1]
    endif else begin
        minza=min(p.za,max=maxza)
    endelse
    if n_elements(ver1) eq 2 then begin
        minv1=ver1[0]
        maxv1=ver1[1]
    endif 
    if n_elements(ver2) eq 2 then begin
        minv2=ver2[0]
        maxv2=ver2[1]
    endif 
    col=1
    firsttime=1
    if not keyword_set(title) then title='total power vs za'
    if avgpols then begin
        polL=' AvgPols'
    endif else begin
        polL=(sbc eq 0) ? ' PolA': ' PolB'
    endelse
    !p.multi=[0,1,2,0,0]
;
;   generate top plot
;
    hor,minza,maxza
    ver,minv1,maxv1
    for i=0,nscans-1 do begin 
        p1=getscanindx(p,i,scanind,scanlen) 
        if ((size(p1))[1] gt 1) then begin 
            for brd=0,p1[0].nbrds-1 do begin 
                x=p1.za 
                y=(avgpols)?(p1.pwr[0,brd] + p1.pwr[1,brd])*.5 : $
                            p1.pwr[sbc,brd] 
                if firsttime then begin 
                    plot,x,y,color=colph[col],xtitle='za',$
                    ytitle='total power [lin scale]',$
                    title=title+polL,/xstyle,/ystyle 
                    firsttime=0 
                    !p.multi=[2,1,2,0,0]
                endif else begin 
                    oplot,x,y,color=colph[col] 
                endelse 
            endfor 
            col=(col mod 10 ) +1 
        endif 
    endfor
    ln=2
    note,ln,'color order',xp=.01
    ln=ln+1
    for i=1,10 do begin 
        note,ln,string(format='(i2)',i),color=colph[i],xp=.01 
        ln=ln+1 
    endfor
;
;   now relative to median value
;
    !p.multi=[1,1,2,0,0]
    print,minv2,maxv2
    ver,minv2,maxv2
    col=1
    firsttime=1
    title2='fractional change in power vs za'
    for i=0,nscans-1 do begin 
        p1=getscanindx(p,i,scanind,scanlen) 
        if ((size(p1))[1] gt 1) then begin 
            for brd=0,p1[0].nbrds-1 do begin 
                x=p1.za 
                y=(avgpols)?(p1.pwr[0,brd] + p1.pwr[1,brd])*.5 :$
                            p1.pwr[sbc,brd] 
                yp=y/median(y) - 1. 
                if firsttime then begin 
                    plot,x,yp,color=colph[col],xtitle='za',$
                        ytitle='total power/MedianPwr - 1',$
                    title=title2
                    firsttime=0 
                endif else begin 
                    oplot,x,yp,color=colph[col] 
                endelse 
            endfor
            col=(col mod 10 ) +1 
        endif 
    endfor
    if keyword_set(printscan) then begin
        if n_elements(scanpos) eq 0 then scanpos=.15
        !p.multi=[1,1,2,0,0]
        col=1
        xoff=.1 
        xinc=.13
        yoff=scanpos
        yinc=-.02
        x=xoff
        y=yoff
        scanperline=7
        for i=0,usescans-1 do begin 
            if (i mod scanperline eq 0) and (i ne 0)  then begin
                y=y+yinc 
                x=xoff
            endif
            xyouts,x,y,/normal,color=colph[col],string(scannum[i])
            col=(col mod 10 ) +1 
            x=x+xinc
        endfor
    endif
    !p.multi=0
    return
end
