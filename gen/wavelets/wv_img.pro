pro wv_img, res, stime, scale, stimefctr, scalefctr, $
	nowindow=nowindow, xtit=xtit, ytit=ytit, tit=tit, $
	xoff=xoff, yoff=yoff, $
	stime_exp=stime_exp, scale_exp=scale_exp, res_exp=res_exp, $
	contour=contour

;+
;purpose: tv display results of 1-d continuous wavelet analysis.
;
;inputs:
;	RES, the wavelet response
;	STIME, the x-axis for RES (from input function)
;	SCALE, the y-axis for RES (the scale, from wv_cwt)
;	STIMEfctr ,the factor by which to expand RES in x-direction
;	SCALEfctr, the factor by which to expand RES in y-direction
;	
;optional inputs/keywords:
;	nowindow: don't generate new window.
;	xtit: xtitle
;	ytit: ytitle
;	xoff: xoffset of corner in device units
;	yoff: yoffset of corner in device units
;	res_exp: resized image
;comment:
;	to look at 'profiles': profiles, res_exp, sx=xoff,sy=yoff
;-

sz= size(res)

xs= sz[1]*stimefctr
ys= sz[2]*scalefctr

res_exp= rebin( res, xs, ys)
stime_exp= rebin( stime, xs)
scale_exp= rebin( scale, ys)


w= 0.1
f= 1.+ 2.*w
if (keyword_set( nowindow) ne 1) then window,4, xs= f*xs, ys= f*ys

tvscl, res_exp, w/f, w/f, /norm, xsize=1./f, ysize=1./f

;print, 'contour:' ,n_elements( contour)

if n_elements( contour) eq 0 then $
	plot, stime_exp, scale_exp, pos=[w/f, w/f, 1.-w/f, 1.-w/f], $
	/xsty, xtit=xtit, /ysty, ytit=ytit, tit=tit, $
	/norm, /noerase, /nodata

if n_elements( contour) ne 0 then $
	contour, res_exp, stime_exp, scale_exp, $
	pos=[w/f, w/f, 1.-w/f, 1.-w/f], $
	/xsty, xtit=xtit, /ysty, ytit=ytit, tit=tit, $
	/norm, /noerase, levels=contour, thick=2

;stop

devcoords= convert_coord( w/f, w/f, /normal, /to_device)
xoff= devcoords[0]
yoff= devcoords[1]

return
end

