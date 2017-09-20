; 
; cormapcon - default countouring of map
; 
; SYNTAX: cormapcon,mi,mapa,numcont,dbstep,_extra=e
; 
pro cormapcon,mi,mapa,numcont,dbstep,_extra=e
    contourph,mapa,numcont,dbstep,maxval,levels,axes=mi.axes,_extra=e
    return
end

