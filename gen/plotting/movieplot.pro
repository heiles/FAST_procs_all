pro movieplot, xp, yp, wp, delay=delay
;+
;make a movie of a bunch of plots.
;SYNTAX: 
;       movieplot, xp, yp, wp, delay=delay
;
;inputs:
;       XP= 1d array of x values. e.g. xp[129] has 129 values of x
;       YP= 2d array of y values. e.g. yp[129, 1000] has 129 values of y and
;               1000 movie framess
;       wp is the plotting window on which the movie will appear
;       delay=delay is the time delay between successive frames. default=0
;-

w_orig= !d.window
nframes= (size( yp))[2]
wset,wp
xs= !d.x_size
ys= !d.y_size
window, xsize=xs, ysize=ys, /pixmap, /free
wnr= !d.window

;stop
for nr=0,nframes-1 do begin
wset,wnr
plot, xp, yp[*,nr]
wset, wp
device, copy=[0, 0, xs, ys, 0, 0, wnr]
xyouts, 0.5, 0.07, strtrim(string(nr)), align=0.5, charsize=2, $
        /norm ;, col=!black
endfor

wdelete, wnr
!d.window= w_orig
end

