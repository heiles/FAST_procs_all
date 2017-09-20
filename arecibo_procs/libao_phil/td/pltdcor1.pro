; 
;pltdcor1  - plot the td cor .. called by pltdcor
; 
pro pltdcor1,y,title,ytitle,linest=uselinest,note3=note3,oplot=oplot
;   
; y[360,41]
; plot 1 set of data 1..20 degrees in steps of .5 degrees
;
    common colph,decomposedph,colph

    dy =.03
    xpos=.14
    ypos=.90
    lnnote=3
    if !p.multi[2] gt 1 then begin
        numy=!p.multi[2]*1.
        case numy of
            1 : begin 
                dy=dy
                ypos=ypos
                end
            2 : begin
                ypos=ypos+1.5*dy
                dy=.015
                lnnote=1.5
                end
         else : begin 
                ypos=ypos+1.5*dy
                dy=.015
                lnnote=1.5
                end
        endcase
    endif
    jc=-1
    jl=-1
    if n_elements(uselinest) eq 0 then uselinest=0
    if n_elements(oplot) eq 0 then oplot=0
    linest=0
    for i=0,19 do begin 
        color=(i/2)+ 1 
        if uselinest ne 0 then begin
            linest=i/4
        endif else begin
            if i eq 19 then linest=1
        endelse
        ind=(i+1)*2
        if (i eq 0) and (oplot eq 0)  then begin 
            plot,y[*,ind],color=colph[color],xtitle='az',ytitle=ytitle, $
                    title=title,xstyle=1,ystyle=1,linestyle=linest 
        endif else begin 
            oplot,y[*,ind],color=colph[color],linestyle=linest
        endelse 
;
;   only za labels for top plot
;
        if !p.multi[0] eq 0 then begin
        if color ne jc then begin 
            lab=string(format='("za=",f4.0)',i+1) 
            xyouts,xpos,ypos,lab,/normal,color=colph[color] 
            jc=color 
            ypos=ypos-dy 
        endif
        if (linest ne jl) and (uselinest ne 0)  then begin 
;           lab=string(format='("za=",f4.0)',i+1) 
;           xyouts,xpos,ypos,lab,/normal,color=colph[color] 
            jl=linest
        endif
        endif
    endfor
    if  n_elements(note3) ne 0 then note,lnnote,note3
    return
end
