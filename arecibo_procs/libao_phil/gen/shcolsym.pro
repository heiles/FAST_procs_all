;+
;NAME:
;shcolsym - show the default colors and symbols
;SYNTAX: shcolsym
;ARGS:
;DESCRIPTION:
;   plot the default colors and symbols.
;-
pro shcolsym
    common colph,decomposedph,colph
    !x.style=!x.style or 1      
    !y.style=!y.style or 1      
    x=findgen(10)
    y=fltarr(10)
    ver,0,11
    hor
    plot,x,y,/nodata
    for i=1,10 do begin
        sym=i
        if i gt 7 then  sym=0
        oplot,x,y+i,color=colph[i],psym=-sym,linestyle=i
    endfor
    ver
    return
end
