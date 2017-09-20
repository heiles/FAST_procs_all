;***** CARLSTRETCH*******************************************
pro carlstretch, r, g, b, low, high, gamma

;+
;NAME
;carlstretch -- like IDL's 'stretch', but does color independently. obsolete?
;-

common colors, r_orig, g_orig, b_orig, r_curr, g_curr, b_curr
nc = !d.table_size      ;# of colors entries in device

;help, r, g, b, low, high, gamma
;return
slope = 1. / (float(high) - float(low))         ;Range of 0 to 1.
intercept = -slope * float(low)
p = findgen(nc) * slope + intercept > 0.0
p = long(nc * (p ^ gamma)) < 255

if (r ne 0) then r_curr = r_orig[p]
if (g ne 0) then g_curr = g_orig[p]
if (b ne 0) then b_curr = b_orig[p]

;tempwindow = !d.window
;wset, 0
;plot, r_curr, xstyle=1, xrange=[0,255], ystyle=1, yrange=[0,255], color=255
;oplot, g_curr, color=255l*256l
;oplot, b_curr, color=255l*256l*256l
;wset, tempwindow

tvlct, r_curr, g_curr, b_curr
return
end

