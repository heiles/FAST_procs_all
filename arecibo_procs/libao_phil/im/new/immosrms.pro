;-----------------------------------------------------------------------------
;immosrms,{imday} hardcopy   - create mosaic of rms's
;20aug00 - switched to use immosrms1
;-----------------------------------------------------------------------------
pro immosrms,d,dohardcopy,_extra=e,ver=ver,win=win 
;
;   parameters
;
    if  n_params() lt 2 then  dohardcopy = 0
    if  not keyword_set(ver) then ver=[0.,0.]
    immossetup,d.yymmdd,3,dohardcopy,mos,_extra=e
    curwin = 0
    if keyword_set(win) then curwin=win-1
; 
;   for plot windows 
;
;
    plotsleft=(size(d.frql))[1]         ;number of frequencies
    pltperpage=mos.numrows*mos.numcols
;
;   loop through all the plots
;
    for i=0,plotsleft-1 do  begin
        curcol= ((i mod pltperpage) mod mos.numcols ) + 1   ;1..numrows 
        currow= ((i mod pltperpage) / mos.numcols )   + 1   ;1..numcols
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
;   compute the plot
        curfrq=d.frql[i]
        imgfrq,d,curfrq,dfrq          ; select freq of interest
        immosrms1,dfrq,curfrq,curcol,currow,mos,dohardcopy,ver=ver

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
;*****************************************************************************
pro immosrms1,dfrq,curfrq,curcol,currow,mos,dohardcopy,ver=ver

        imlin,dfrq                    ; convert db to linear
        rmsDMean=dindgen(401);
        for  j=0, 400 do begin
            val=moment(dfrq.r.d[j],/double);
            rmsDMean[j]= sqrt(val[1])/val[0]
        endfor
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
        if (ver[0] ne 0.) or (ver[1] ne 0.) then begin
            ver,ver[0],ver[1]
         plot,immkfrq(dfrq.r[0]),rmsDMean,xtitle=xtitle,ytitle=ytitle,xstyle=1,$
            /ystyle
        endif else begin
          ver
          plot,immkfrq(dfrq.r[0]),rmsDMean,xtitle=xtitle,ytitle=ytitle,xstyle=1
        endelse
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
