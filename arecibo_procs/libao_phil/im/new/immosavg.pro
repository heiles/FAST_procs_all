;-----------------------------------------------------------------------------
;immosavg,{imday} hardcopy   - create mosaic of averages
;history:
;20aug00: switched to immosavg1 so immosavg1frq can also use it.
;-----------------------------------------------------------------------------
pro immosavg,d,dohardcopy,win=win,_extra=e
;
;   parameters
;
    if  n_params() lt 2 then  dohardcopy = 0
    curwin=0
    if  keyword_set(win) then curwin=win-1
    immossetup,d.yymmdd,1,dohardcopy,mos,_extra=e
    plotsleft=(size(d.frql))[1]         ;number of frequencies
    pltperpage=mos.numrows*mos.numcols
;
;   yrange:
;
    ylfMinMax=[-80.,0.]
    yhfMinMax=[-65.,0.]
;
;   loop through all the plots
;
    for i=0,plotsleft-1 do  begin
        curcol= ((i mod pltperpage) mod mos.numcols ) + 1   ;1..numrows 
        currow= ((i mod pltperpage) /   mos.numcols ) + 1   ;1..numcols
;
;       new page, update window number, start new page
;
        if  (i mod pltperpage) eq 0 then begin
            if (dohardcopy eq 0)  then begin
                curwin=curwin+1
                window,curwin,ysize=mos.winypix
            endif
            !p.multi=[0,mos.numcols,mos.numrows,0,0]
        endif
;
        curfrq=d.frql[i]
        imgfrq,d,curfrq,dfrq          ; select freq of interest
        immosavg1,dfrq,curfrq,curcol,currow,mos,dohardcopy,ylfMinMax,yhfMinMax

        if  (i mod pltperpage) eq 0 then begin
            xyouts,.5,mos.yOffMainTitle,mos.title,alignment=.5,/normal
        endif
        
    endfor
    if dohardcopy ne 0  then begin
        hardcopy
        if dohardcopy gt 1 then spawn,'lpr idl.ps'
        wait,3
        set_plot,'x'
    endif
    immosreset
    return
end

pro immosavg1,dfrq,curfrq,curcol,currow,mos,dohardcopy,ylfMinMax,yhfMinMax

        imlin,dfrq                    ; convert db to linear
        imavg=imavg(dfrq)             ; average
        imavg.d=(alog10(imavg.d))*10  ; back to db
;
;       left column yaxis labels, bottom row, xaxis labels
;
        ytitle=''
        xtitle=''
        if (curcol eq 1) then begin
            ytitle=mos.ytitle
        endif
        if (currow eq mos.numrows) then begin
            xtitle=mos.xtitle
        endif
;
;   yrange
;
        if      (curfrq lt  1400.) then ver,ylfMinMax[0],ylfMinMax[1] $
        else if (curfrq gt 1400.)  then ver,yhfMinMax[0],yhfMinMax[1] $
        else ver,min(imavg.d),max(imavg.d)
;
        plot,immkfrq(imavg),imavg.d,xtitle=xtitle,ytitle=ytitle,xstyle=1
;
;       tsys label
;
        tsys=imtsys(curfrq)
        if (tsys gt 0.) then begin
            lab=string(format='("Tsys:",f6.0)',tsys)
            xoff=!x.crange[1]
            yoff=!y.crange[1]+(!y.crange[1]-!y.crange[0])*.018
            xyouts,xoff,yoff,lab,alignment=1.,charsize=mos.charSizeTsys
        endif
    return
end
