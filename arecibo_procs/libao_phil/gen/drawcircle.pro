;+
;NAME:
;drawcircle - draw a circle 
;SYNTAX: drawcircle,x,y,radius,npnts=npnts,color=color,thick=thick,$
;		 	       _extra=_e
; x,y	float	center of circle 
; radius: float radius of circle
;KEYWORDS:
;   npnts: int  number of points to use in drawing the circle. The default 
;               is 9 points. The circle will be drawn as an n-1 sided 
;               polyhedron.
;   color: int  number 0 to 10. Color to use when plotting symbol. The 
;               default is the same color as the lines beging drawn. See
;               shcolsym for a mapping of numbers to colors.
;   thick:float the line thicknes to use when drawing the lines. 1. is the
;               default.
;   over :      If set then oplot rather than plot
; _extra=_e     any other params to plot,oplot
;
;DESCRIPTION:
;   draw a circle about x,y with given radius
;
;- 
pro drawcircle,x,y,radius,npnts=npnts,color=color,thick=thick,$
			over=over,_extra=_e
    common colph,decomposedph,colph

    if n_elements(npnts) eq 0 then npnts=51
    icol=(n_elements(color) ne 0)?color:1
    a=findgen(npnts)/(npnts-1)*2.*!pi
	if keyword_set(over) then begin
		oplot,x+radius*cos(a),y+radius*sin(a),thick=thick,$
			color=colph[icol],_extra=_e
	endif else begin
		plot,x+radius*cos(a),y+radius*sin(a),thick=thick,$
			color=colph[icol],_extra=_e
	endelse
    return
end
