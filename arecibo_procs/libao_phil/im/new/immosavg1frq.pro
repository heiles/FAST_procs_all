;-----------------------------------------------------------------------------
;immosavg1frq, hardcopy   - create mosaic of avg 1 freq
;-----------------------------------------------------------------------------
pro immosavg1frq,year,mon,day1,dohardcopy,_extra=e,freq=freq,nplts=nplts,$
            bpc=bpc,win=win
;
;   create avgs of 1 freq . 10 per page start at day1..
; _extra 
;  linear=linear,nohisteq=nohisteq,stretch=s
;
;
;    yrange
;
    ylfMinMax=[-80.,0.]
    yhfMinMax=[-60.,0.]

    if (n_params() lt 4) then dohardcopy=0 
    if not keyword_set(freq) then freq=1400
    if not keyword_set(nplts) then nplts=1
    if not keyword_set(bpc) then bpc=0
    if not keyword_set(win) then win=1
    immossetup,0,1,dohardcopy,mos,_extra=e
    if nplts gt 1 then  mos.numcols=2 else mos.numcols=1
    mos.numrows= (nplts+1)/2
    pltperpage=mos.numrows*mos.numcols
    if pltperpage eq 2 then begin
        mos.numcols=1
        mos.numrows=2
    endif
    !p.multi=[0,mos.numcols,mos.numrows,0,0]
    if (dohardcopy eq 0)  then begin
         window,win,ysize=mos.winypix
    endif
    case mon of
            1: max=31
            2: max=28
            3: max=31
            4: max=30
            5: max=31
            6: max=30
            7: max=31
            8: max=31
            9: max=30
            10: max=31
            11: max=30
            12: max=31
    end
    offset=0
    for i=0,pltperpage-1 do begin
        curcol= ((i mod pltperpage) mod mos.numcols ) + 1   ;1..numrows
        currow= ((i mod pltperpage) /   mos.numcols ) + 1   ;1..numcols
        month=mon
        if  (i+day1) gt max then begin
            month=mon+1
            offset=-max
        endif
        yymmdd=(year mod 100)*10000L + month*100+i+day1+offset
        iminpday,yymmdd,d
        imgfrq,d,freq,dfrq
        if (bpc ne 0 ) then imbpc1,dfrq
        immosavg1,dfrq,freq,curcol,currow,mos,dohardcopy,ylfMinMax,yhfMinMax
        lab=string(format='("date:",i6)',yymmdd)
            xoff=!x.crange[0]
            yoff=!y.crange[1]+(!y.crange[1]-!y.crange[0])*.018
            xyouts,xoff,yoff,lab,alignment=0.,charsize=mos.charSizeTsys

        
        if  (i mod pltperpage) eq 0 then begin
            xyouts,.5,mos.yOffMainTitle,mos.title,alignment=.5,/normal
        endif
    endfor
    if dohardcopy ne 0  then begin
        hardcopy
        if dohardcopy gt 1 then  spawn,'lpr -Pop1 idl.ps'
        set_plot,'x'
    endif
    immosreset          
    return
end
