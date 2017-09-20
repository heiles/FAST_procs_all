;+
;NAME:
;symcircle - create a circle symbol for plots
;SYNTAX: symcircle,npnts=npnts,color=color,thick=thick,fill=fill
;KEYWORDS:
;   npnts: int  number of points to use in drawing the circle. The default 
;               is 9 points. The circle will be drawn as an n-1 sided 
;               polyhedron.
;   color: int  number 0 to 10. Color to use when plotting symbol. The 
;               default is the same color as the lines beging drawn. See
;               shcolsym for a mapping of numbers to colors.
;   thick:float the line thicknes to use when drawing the lines. 1. is the
;               default.
;   fill :      If set then fill the circles
;
;DESCRIPTION:
;   Create a cirlce symbol to use for plotting. After calling this routine,
;plot,....psym=-8 will draw a circle about every point.
;
;EXAMPLE:
;   symcircle,npnts=17    .. use 17 points to define circle
;   plot,findgen(30),psym=-8
;- 
pro symcircle,npnts=npnts,color=color,fill=fill,thick=thick
    common colph,decomposedph,colph

    if n_elements(npnts) eq 0 then npnts=9
    useCol= n_elements(color) ne 0
    a=findgen(npnts)/(npnts-1)*2.*!pi
    if useCol then begin
        usersym,cos(a),sin(a),fill=fill,thick=thick,color=colph[color]
    endif else begin
        usersym,cos(a),sin(a),fill=fill,thick=thick
    endelse
    return
end
