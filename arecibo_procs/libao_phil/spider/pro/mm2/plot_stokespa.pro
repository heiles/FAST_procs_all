pro plot_stokespa, nwindow, indx, a, $
	qpa, xpy, xmy, xy, yx, $
        pacoeffs, ps=ps, title=title

common plotcolors

;+
;PURPOSE; plot the Stokes data and their fits versus position angle.

;CALLING SEQUENCE:
;PLOT_STOKESPA, nwindow, indx, a, $
;	qpa, xpy, xmy, xy, yx, $
;        pacoeffs, ps=ps, title=title

;INPUTS:

;	indx, the array of indices speciying the patterns being processed.
;	SOURCENAME...the source name read in 
;	QPA, the array of position angles of the fitted points
;	XPY, XMY, XY, YX, the four arrays of calibrated correlator
;outputs.

;KEYWORDS:
;	PS: if set, varies things a bit to make a nicer postscript plot.
;	TITLE: if set, uses the specified title for the plot. Otherwise
;it uses the default info, consisting of scan nr, freq, srcname.
;
;OUTPUTS: none, just the plot on the screen or the postscript device.

;-

sourcename= a[ indx[0]].srcname

pcolor = [red, green, blue]
bcolor= grey
if (keyword_set(ps)) then bcolor=black
plotsymbol= [ 7,4,6]

;OPEN WINDOW IF NECESSARY...
IF ( NWINDOW GE 0) THEN BEGIN
device, window=opnd
if ( opnd(nwindow) eq 0) then window, nwindow, xs=300, ys=225
wset,nwindow
ENDIF

ymaxtrial = fltarr(3)
for nrstk=1,3 do ymaxtrial[nrstk-1] = abs(pacoeffs[0, 0, nrstk]) + $
	sqrt( pacoeffs[ 1, 0, nrstk]^2 + pacoeffs[ 2, 0, nrstk]^2 )

ymaxx = max(ymaxtrial)
yrng = [-ymaxx, ymaxx]

nr=1
if keyword_set( title) then begin
title=title 
endif else $
title='SCAN=' + strcompress(string(a[ indx[0]].scan)) + $
        '  FREQ=' + strcompress( string(a[ indx[0]].cfr)) + $
        '  ' + sourcename

plot, qpa, xmy, $
        yra=yrng, /ysty, $
        xra=[-90,90], /xsty, $
        xtit='POSITION ANGLE, DEG', ytit='FRACTIONAL POL', $
        tit = title,  /nodata, background=bcolor

cpa = findgen(181)-90.
cpar = 2*!dtor*cpa
nr=0
oplot, modanglem( qpa), xmy, $
        linestyle=nr, psym=plotsymbol[ nr], color=pcolor[nr]
oplot, cpa, pacoeffs[0,0,nr+1]+ pacoeffs[1,0,nr+1]*cos(cpar) $
	+ pacoeffs[2,0,nr+1]*sin(cpar), color=pcolor[nr]

nr=1
oplot, modanglem( qpa), xy, $
        linestyle=nr, psym=plotsymbol[ nr], color=pcolor[nr]
oplot, cpa, pacoeffs[0,0,nr+1]+ pacoeffs[1,0,nr+1]*cos(cpar) $
	+ pacoeffs[2,0,nr+1]*sin(cpar), color=pcolor[nr]

nr=2
oplot, modanglem( qpa), yx, $
        linestyle=nr, psym=plotsymbol[ nr], color=pcolor[nr]
oplot, cpa, pacoeffs[0,0,nr+1]+ pacoeffs[1,0,nr+1]*cos(cpar) $
	+ pacoeffs[2,0,nr+1]*sin(cpar), color=pcolor[nr]


if (keyword_set(ps)) then begin
ypos = yrng[0] + .18*(yrng[1]- yrng[0])
;xxyy_norm= convert_coord( -80, 0, /data, /to_normal)
nr=0
oplot, [-80, -50], [ypos, ypos], color=pcolor[nr],psym=-plotsymbol[nr];, /data
xyouts, -50, ypos, ' X-Y', color=pcolor[nr]
nr=1
ypos = yrng[0] + .14*(yrng[1]- yrng[0])
oplot, [-80, -50], [ypos, ypos], color=pcolor[nr],psym=-plotsymbol[nr];, /data
xyouts, -50,ypos,' XY', color=pcolor[nr]
nr=2
ypos = yrng[0] + .1*(yrng[1]- yrng[0])
oplot, [-80, -50], [ypos, ypos], color=pcolor[nr],psym=-plotsymbol[nr];, /data
xyouts, -50,ypos, ' YX', color=pcolor[nr]

endif else begin
ypos = yrng[0] + .05*(yrng[1]- yrng[0])
xyouts, -80, ypos, 'X-Y', color=pcolor[0]
xyouts, '  XY', color=pcolor[1]
xyouts, '  XY', color=pcolor[2]
endelse

;STOP
return
end
