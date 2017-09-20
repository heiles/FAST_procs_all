;-----------------------------------------------------------------------------
;immosimg,{imday} hardcopy   - create mosaic of images
;-----------------------------------------------------------------------------
pro immosimg,d,dohardcopy,_extra=e,stretch=s,win=win,nohisteq=nohisteq,$
                linear=linear,bpc=bpc 
;
;   parameters
;
    if  n_params() lt 2 then  dohardcopy = 0
    if not keyword_set(nohisteq) then nohisteq=0
    if not keyword_set(linear) then linear=0
    if not keyword_set(bpc) then bpc=0
    curwin=0
    if  keyword_set(win) then curwin=win-1 
    immossetup,d.yymmdd,2,dohardcopy,mos,_extra=e
    plotsleft=(size(d.frql))[1]         ;number of frequencies
    pltperpage=mos.numrows*mos.numcols
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
;   plot the axis first
;
        curfrq=d.frql[i]
        imgfrq,d,curfrq,dfrq          ; select freq of interest
        if (bpc ne 0 ) then imbpc1,dfrq

        immosimg1,dfrq,curcol,currow,mos,dohardcopy,stretch=s,$
                    nohisteq=nohisteq,linear=linear
;
        if  (i mod pltperpage) eq 0 then begin
            xyouts,.5,mos.yOffMainTitle,mos.title,alignment=.5,/normal
        endif
        
    endfor
    if dohardcopy ne 0  then begin
        hardcopy
        if  dohardcopy gt 1 then spawn,'lpr idl.ps'
        wait,3
        set_plot,'x'
    endif
    immosreset
    return
end
;-----------------------------------------------------------------------------
;immosimg1,{dfrq} hardcopy   - plot 1 image of mosaic
;-----------------------------------------------------------------------------
pro immosimg1,dfrq,curcol,currow,mos,dohardcopy,stretch=s,nohisteq=nohisteq,$
                linear=linear
;
; plot 1 image of mosaic. you should call !p.multi before this routine
;
        forward_function immosimgscl
        if n_params() lt 3 then dohardcopy=0
        if not keyword_set(nohisteq) then nohisteq=0
        if not keyword_set(linear) then linear=0
        dt=(dfrq.r[1].h.secMid-dfrq.r[0].h.secMid)/3600.
        tm=findgen(dfrq.nrecs)*dt + (dfrq.r[0].h.secMid)/3600.
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
        plot,immkfrq(dfrq.r[0]),tm,xtitle=xtitle,ytitle=ytitle, $
                xstyle=1,ystyle=1,/nodata
;
;       tsys label
;
        curfrq=dfrq.r[0].h.cfrDataMhz
        tsys=imtsys(curfrq) 
        if (tsys gt 0.) then begin
            lab=string(format='("Tsys:",f6.0)',tsys)
            xoff=!x.crange[1]
            yoff=!y.crange[1]+(!y.crange[1]-!y.crange[0])*.018
            xyouts,xoff,yoff,lab,alignment=1.,charsize=mos.charSizeTsys
        end
;
;   now scale the array to the window size
;
        datAr=dfrq.r.d
        cmsize=256
        if  dohardcopy eq 0 then begin  ; if screen we must regrid the data
            px=!x.window * !d.x_vsize
            py=!y.window * !d.y_vsize
            sx=px[1]-px[0] + 1
            sy=py[1]-py[0] + 1
            datAr=congrid(temporary(datAr),sx,sy)
        endif
        byteAr=immosimgscl(datAr,stretch=s,nohisteq=nohisteq,linear=linear)

        if  dohardcopy eq 0 then  begin
            tv,byteAr,px[0],py[0]
        endif else begin
            tv,byteAr,     !x.window(0),  !y.window(0), $
                   XSIZE = !X.WINDOW(1) - !X.WINDOW(0), $
                   YSIZE = !Y.WINDOW(1) - !Y.WINDOW(0), /NORM
        endelse
        byteAr=0
        return
end
;-----------------------------------------------------------------------------
;immosimgscl, datAr  - scale the image
;-----------------------------------------------------------------------------
function immosimgscl,datAr,stretch=s,nohisteq=nohisteq,linear=linear
;
; scale the image.place in a separate function it's easy to redefine
; stretch[0 1]   
; assume 0->1 is full range of input data as a linear ramp
; then stretch will map s[0] s[1] to full scalee
; eg  s=[.2 .8] will map the full scale lut onto .2 .8
; let  s[map s[0]->s[1] into s[2]->s[3] below s[0] is 0, above s[1] is
;                 s[3] 
; if nohisteq set, then just scale to max/min
;
        cmsize=256
        if not keyword_set(linear) then linear=0
        if linear then begin
            datAr=10.^(datAr*.1)
        endif
        minv=min(datAr)
        maxv=max(datAr)
        delta=maxV-minV
        scale=cmsize/delta
        if (n_elements(s) eq 0) then begin
            if nohisteq ne 0 then begin
                    return,255B - (datAr-minv)*scale
            endif else begin
                return,255B - hist_equal((datAr-minv)*scale)
            endelse
        endif
;
;   they want us to stretch 
;
        delta2=(s[1] - s[0])
        scale2= 1./delta2
;
;       first scale floats to 0...255.
;
        if nohisteq then begin
            datAr=(datAr-minv)*scale
        endif else begin
            datAr=hist_equal((datAr-minv)*scale) 
        endelse
;       - s[0]*cmsize)*scale2)
        datAr= (datAr - s[0]*255)*scale2
;
;       now get the indices for s[0],s[1]
;        indexAr1=where(datAr lt s[0],count1)
;        indexAr2=where(datAr ge s[1],count2)
;        datAr= (datAr-s[0])*scale2 + s[3]
;        if count1 gt 0 then datAr[indexAr1]=0.
;        if count2 gt 0 then datAr[indexAr2]=255.
;
        indexAr1=where(datAr lt 0.,count1)
        indexAr2=where(datAr gt 255,count2)
        if count1 gt 0 then datAr[indexAr1]=0.
        if count2 gt 0 then datAr[indexAr2]=255.
        return,255B-byte(datAr)
end
