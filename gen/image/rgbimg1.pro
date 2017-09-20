pro rgbimg, $
redtitle, redlabel1, redlabel2, redpwr, reddata, $
grntitle, grnlabel1, grnlabel2, grnpwr, grndata, $
blutitle, blulabel1, blulabel2, blupwr, bludata, $
fileout=fileout, close=close, ftexgamma=ftexgamma, $
plot_position= plot_position

;-
;NAME:
;rgbimg -- make rbg image with colorsquare-type colorbar
;
;THIS MAKES AN RGB IMAGE OF 3 DATASETS WITH COLORSQUARE-TYPE COLORBAR.
;THE THREE DATA SETS ARE: XM, BLUE; HALFA, RED; HI, GREEN.
;+

;CHECK TO SEE IF FILEOUT IS DEFINED...
if ( keyword_set( fileout) eq 0) then fileout= 'x'	

;SET ADDITIONAL GAMMA FOR PS FILE IF WE ARE NOT IN XWINDOWS, 
;	DEFAULT IS 1...
ftexgamma_local= 1.0
if (keyword_set( ftexgamma) eq 1 and fileout ne 'x') then $
	ftexgamma_local= ftexgamma

;SCALE THE DATA...
reddata_l = (reddata-float(redlabel1))/(float(redlabel2)-float(redlabel1))
grndata_l = (grndata-float(grnlabel1))/(float(grnlabel2)-float(grnlabel1)) 
bludata_l = (bludata-float(blulabel1))/(float(blulabel2)-float(blulabel1)) 
breddata = byte( 0. > 255.*( (reddata_l > 0.)^(redpwr*ftexgamma_local)) < 255.)
bgrndata = byte( 0. > 255.*( (grndata_l > 0.)^(grnpwr*ftexgamma_local)) < 255.)
bbludata = byte( 0. > 255.*( (bludata_l > 0.)^(blupwr*ftexgamma_local)) < 255.)

carlstretch,1,1,1,0,255,1.

;DEFINE COLORBAR PARAMETERS...
fcolormin=0. & fcolormax=1.
fintmin=0. & fintmax=1. 

;#####;SET UP THE DISPLAY WINDOW...
;xlimits = [90.-xleft/3., 90.-xrght/3.]
;ylimits=[ybot/3.-90., ytop/3.-90.]

;#####;CREATE THE Y VALUES THAT CORRESPOND TO TEN DEGEE INCREMENTS...
;beein = (latpole - 10.*findgen(19)) + 90.
;ellin = fltarr(19) + longpole
;stereogfwdxy, ellin, beein, xangout, yangout
;
;#####;CREATE THE OUTSIDE AXIS LABELS...
;yanglabel = strarr( 19) + '     '
;for i30 = 0, 18, 3 do yanglabel(i30)=strcompress( string(90-10*i30, format='(i3)'), $
;	/remove_all)
;yanglabel( 9) = '      '

;CREATE A LITTLE EXTRA SPACE AROUND THE IMAGE FOR PLOT GRAPHICS...
;WE ASSUME A 541x541 PLOT...
xplotsizepix = 541
yplotsizepix = 541
;xextraleft = 50
xextraleft = 30
xblank = 20
xwedge = 80
;xextraright = 150
xextraright = 110
yextrabottom = 50
yextratop = 50
xxsize = xextraleft + xplotsizepix + xblank + xwedge + xextraright
yysize = yplotsizepix+yextrabottom+yextratop

;TAKE CARE OF PLOTTING DEVICE DEFINITIONS...
IF (FILEOUT NE 'x') THEN BEGIN
	set_plot, 'ps', /copy, /interpolate
	device, file=fileout, /portrait, bits_per_pixel=8, /color, $
		ysize=10.0, xsize=8.207, xoff=0.25, yoff=0.85, /inch
ENDIF ELSE if (!d.window ne 13) then window, 13, ysize=xxsize, xsize=yysize

;DEFINE THE **NORMAL** COORDINATES OF THE TV WINDOW...
xtvleft = float(xextraleft)/float(xxsize)
xtvright = float(xplotsizepix+xextraleft)/float(xxsize)
ybotm = float(yextrabottom)/float(yysize)
ytopp= float(yplotsizepix+yextrabottom)/float(yysize)
xplotsize = xplotsizepix/float(xxsize)
yplotsize = yplotsizepix/float(yysize)

;DEFINE THE **NORMAL** COORDINAGES OF THE BAR WINDOW...
;xbarleft=float( xextraleft+xplotsizepix+xextraleft)/float(xxsize)
;xbarright=float( xextraleft+xplotsizepix+xextraright-xextraleft)/float(xxsize)
xbarleft=float( xextraleft+xplotsizepix+xblank)/float(xxsize)
xbarright=float( xextraleft+xplotsizepix+xblank+xwedge)/float(xxsize)
xbarsize = float(xwedge)/float(xxsize)

;DEFINE THE COLORBAR...
nrwedges=8
redimg = fltarr( yplotsizepix, xwedge)
grnimg = redimg
bluimg = redimg
xwedger = xwedge-15
xbarrightr=float( xextraleft+xplotsizepix+xblank+xwedger)/float(xxsize)
xsz = float(yplotsizepix)/float(nrwedges)
for igx=3*xsz, yplotsizepix-1 do $
	grnimg[igx,0:xwedger-1]= 255.*findgen(xwedger)/(xwedger-1) 

FOR NX=3,NRWEDGES-1 DO BEGIN
nx1 = fix(nx*xsz)
nx2 = fix((nx+1)*xsz-1)
nxsz = nx2-nx1+1
for igy=0,xwedger-1 do $
	redimg[nx1:nx2, igy] = 255.*findgen(nxsz)/(nxsz-1) 
for igy=0,xwedge-1  do $
	bluimg[nx1:nx2, igy] = 255.*(nx-3)/(nrwedges-4) + fltarr(nxsz) 
ENDFOR

nx1=0 & nx2=fix(3.*xsz-1)
redimg[nx1:nx2, xwedger:xwedge-1] = 255. + fltarr(3.*xsz, xwedge-xwedger)
grnimg[nx1:nx2, xwedger:xwedge-1] = 255. + fltarr(3.*xsz, xwedge-xwedger)
bluimg[nx1:nx2, xwedger:xwedge-1] = 255. + fltarr(3.*xsz, xwedge-xwedger)

for igx=0*xsz, 1*xsz-1 do $
	redimg[igx,0:xwedger-1]= 255.*findgen(xwedger)/(xwedger-1) 
for igx=1*xsz, 2*xsz-1 do $
	grnimg[igx,0:xwedger-1]= 255.*findgen(xwedger)/(xwedger-1) 
for igx=2*xsz, 3*xsz-1 do $
	bluimg[igx,0:xwedger-1]= 255.*findgen(xwedger)/(xwedger-1) 

;DISPLAY THE COLORBAR...
tv, [[[redimg]], [[grnimg]], [[bluimg]]], true=3, $
	ybotm, xbarleft, ysize=xbarsize, xsize=yplotsize, /normal

;DISPLAY THE IMAGE...
tv, [[[breddata]], [[bgrndata]], [[bbludata]]], true=3, $ 
	ybotm, xtvleft, ysize=xplotsize, xsize=yplotsize, /normal

;DEFINE COLORS FOR ANNOTATING COLORBAR...
;red = purered & green=puregreen & blue=pureblue & white=purewhite
red = !red & green=!green & blue=!blue & white=!white
IF (FILEOUT NE 'x') THEN BEGIN
	black=0 & red=1 & green=2 & blue=3 & white=4 & purple=5
	redtemp = [0b, 255b,   0b,   0b, 255b,  255b]
	grntemp = [0b,   0b, 255b,   0b, 255b,   0b]
	blutemp = [0b,   0b,   0b, 255b, 255b, 255b]
	tvlct, redtemp, grntemp, blutemp
ENDIF

;ANNOTATE THE COLORBAR...
plot, [fcolormin, fcolormax], [0., 0.], /noerase, $
	position=[ybotm, xbarleft, ytopp, xbarrightr], /normal, $
 	yrange=[0,1.], xrange=[fcolormin, fcolormax], xstyle=5, ystyle=5
oplot, [0,1],[1,1], /noclip
axis, yaxis=0, yrange=[fintmin, fintmax], ystyle=1, yticks=1, /norm 
for nx=3, nrwedges-1 do xyouts, nx/8.+1./16., 1.07, $
	strtrim(string(nx-3)+'/4',1), align=.5, color=white
nx=0 & xyouts, nx/8.+1./16., 1.1, redtitle, align=.5, color=red
xmns=.005
ymns=-0.15
xyouts, nx/8., ymns, redlabel1, align=0., color=red
xyouts, (nx+1)/8.-xmns, ymns, redlabel2, align=1., color=red
nx=1 & xyouts, nx/8.+1./16., 1.1, grntitle, align=.5, color=green
xyouts, nx/8., ymns, grnlabel1, align=0., color=green
xyouts, (nx+1)/8.-xmns, ymns, grnlabel2, align=1., color=green
nx=2 & xyouts, nx/8.+1./16., 1.1, blutitle, align=.5, color=blue
xyouts, nx/8., ymns, blulabel1, align=0., color=blue
xyouts, (nx+1)/8.-xmns, ymns, blulabel2, align=1., color=blue

for nx=0, nrwedges-1 do oplot, [nx/8.,nx/8.],[0.,1.]
xvals = (0.+ findgen(256)/255.)/nrwedges
yvals = (findgen(256)/255.)^(redpwr*ftexgamma_local)
oplot, xvals, yvals, color=white
xvals = (1. + findgen(256)/255.)/nrwedges
yvals = (findgen(256)/255.)^(grnpwr*ftexgamma_local)
oplot, xvals, yvals, color=white
xvals = (2. + findgen(256)/255.)/nrwedges
yvals = (findgen(256)/255.)^(blupwr*ftexgamma_local)
oplot, xvals, yvals, color=white
;stop

;#####;PUT ON AXIS ANGLE TIC MARKS AND THEIR LABELS...
;plot, [90., -90.], [-90., 90.], /noerase, /nodata, $
;	position=[ybotm, xtvleft, ytopp, xtvright], /normal, $
; 	xrange=xlimits, yrange=ylimits, xstyle=5, ystyle=5
;axis, xaxis=0, xticks=19, xtickv=yangout, xtickname=yanglabel
;axis, yaxis=0, yticks=19, ytickv=yangout, ytickname=yanglabel
;axis, yaxis=1, yticks=19, ytickv=yangout, ytickname=yanglabel
;yangblank = yanglabel
;indx = where( yangblank ne ' ')
;yangblank( indx) = ' '
;axis, xaxis=1, xticks=19, xtickv=yangout, xtickname=yangblank
;
;#####;PUT ON THE COORDINATE GRID...
;c256l = 256l
;if (fileout ne 'x') then c256l = 0
;clr=0l
;pureblack = clr + c256l*( clr + c256l*clr) 
;clr=255l
;purewhite = clr + c256l*( clr + c256l*clr) 
;clr=long( not(32b))
;puregrey = clr + c256l*( clr + c256l*clr) 
;;coordplot, 2, purewhite
;coordplot, 1, purewhite
;xyouts,  29.2064, 14.5582, 'b=0', alignment=0.5, orient=5, color=purewhite
;xyouts,   21.2212, -38.6765, 'b=-60', alignment=0.5, orient=30, color=purewhite
;xyouts, 28.0086, -11.6599, 'b=-30', alignment=0.5, orient=15, color=purewhite
;xyouts, 26.2785, 20.1479, 'l=240', alignment=0.5, orient=2, color=purewhite
;xyouts,  0.991994, 20.9464, 'l=210', alignment=0.5, orient=0, color=purewhite
;xyouts, -24.2945, 20.5471, 'l=180', alignment=0.5, orient=-5, color=purewhite

;#####@julia_slits.idl

;IF REQUESTED, AND IF IN PS MODE, CLOSE PS DEVICE AND RESTORE XWINDOWS...
if keyword_set( close) and fileout ne 'x' then psclose

plot_position= [ybotm, xtvleft, ytopp, xtvright]

return
end
