;+
;NAME:
;windpltdate - plot wind data versus date
;SYNTAX: windplot,wd,h1=h1,h2=h2,datef=datef,ast=ast
;ARGS:
;	wd[n]	: {windstr} wind data to plot
;KEYWORDS:
;    h1: double yymmdd.fract date for left edge of plot. default is the start of
;               the data.
;    h2: double yymmdd.fract date for right edge of plot. default is the end of
;               the data.
;	AST:	    if set the subtract 4./24. so the date is ast rather the gmt.
;datef : string date format to use when plotting. The default is 
;               '%D%M%Z' (see label_date() routine).
;
;DESCRIPTION:
;	Plot the window velocity vs date for the wind data structure. This can
;be for multiple days.
;-
pro	windpltdate,wd,h1=h1,h2=h2,datef=datef,ast=ast,_extra=e
;	
	off=keyword_set(ast)?   4./24.:0.
	if not keyword_set(datef) then datef='%D%M%Z'
	a=label_date(date_format=datef)
	jd1=min(wd.jd ,max=jd2)
	if keyword_set(h1) then begin
		h1fract=h1 mod 1D
		jd1=yymmddtojulday(h1) + h1fract
	endif
	if keyword_set(h2) then  begin
		h2fract=h2 mod 1D
		jd2=yymmddtojulday(h2) + h2fract
	endif
	hsave=!x.range
	hor,jd1,jd2
	plot,wd.jd - off,wd.vel,xtickf='label_date',_extra=e
	hor,hsave[0],hsave[1]
	return
end
