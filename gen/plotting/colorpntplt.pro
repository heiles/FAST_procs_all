pro colorpntplt, xd, yd, zd, xra=xra, yra=yra, zra=zra, $
  xtit=xtit, ytit=ytit, ztit=ztit, tit=tit, psym=psym, bg=bg, $
  symsize=symsize, hue0=hue0, loops=loops, original=original, $
  pltposition= pltposition, barposition= barposition, clip=clip, $
                 silent=silent, nodata=nodata

;+
; NAME: COLORPNTPLT
;
; PURPOSE: plot points in x, y with pseudocolor representing z.
;
; CALLING SEQUENCE:
;colorpntplt, xd, yd, zd, xra=xra, yra=yra, zra=zra, $
;  xtit=xtit, ytit=ytit, ztit=ztit, tit=tit, psym=psym, bg=bg, $
;  symsize=symsize
;
; INPUTS:
;       XD - the x data values
;       YD - the y data values
;       ZD - the z data values (z is represented by color)
;
; KEYWORD PARAMETERS:
;       XRA - the xrange 2-element vector
;       YRA - the yrange 2-element vector
;       ZRA - the zrange 2-element vector
;       XTITLE - x axis title
;       YTITLE - y axis title
;       ZTITLE - z colorbar title
;       TITLE - global title
;       PSYM - default=3
;       BG - if set, fills plot background to gray
;       SYMSIZE - array of symbol sizes; if not specified, all symbols
;                 are identical.
;       PLTPOSITION - position of plot
;       BARPOSITION - position of colorbar
;       CLIP - don't plot outside of window
;       SILENT: if set, doesn't print out in setcolors
;
; MODIFICATION HISTORY: original in
; /home/heiles/dzd4/heiles/arecibo/galfa_nvss/pntcolplt.pro; test with
; play3.idl
; 17dec2009: converted to colorpntplt.sav; determne ps outside of proc.
; to test this proc: /home/heiles/courses/handouts/plotting/colorpntplt.idl
;-

device, get_decomposed=gd
;TURN OFF DECOMPOSED COLOR TO ENABLE COLOR TABLES...
device, dec=0

if n_elements( clip) eq 0 then clip=1

if n_elements( barposition) eq 0 then barposition=[.79, .15, .85, .88]
if n_elements( pltposition) eq 0 then pltposition=[.15,0.15,.76,.88]

if n_elements( original) eq 0 then original=0
if n_elements( zra) eq 0 then zra=minmax(zd)

if (!d.name eq 'X') then erase

;stop
if keyword_set( bg) then bgfill, !gray
if keyword_set( bg) then bgfill, !gray
;if keyword_set( bg) then polyfill, [1,1,0,0,1], $
;          [1,0,0,1,1], /NORMAL, COLOR=bg

;device, dec=0
;stop

pseudo_ch, colr, hue0=hue0, loops=loops, original=original
loadct,0

colorbar, position=barposition, /vertical, $
        rgb=colr, crange= zra, $
        format='(f4.1)', $
;       irange=[0,0], divisions=1, $
        bottom=1, top=254, ytit=ztit;, /noerase 
sharpcorners, thick=axthk

plot, xd, yd, position=pltposition, /nodata, $ 
      xtit=xtit, /xstyle, xra=xra, $
      ytit=ytit, /ystyle, yra=yra, $
      tit=tit , /noerase, clip=clip

sharpcorners, thick=axthk

pseudo_ch, colr, hue0=hue0, loops=loops, original=original
;loadct,0
;setcolors,/sys
;stop
tvlct,a0,a1,a2,/get
;stop
;PLOT THE POINTS IN COLOR; allow for symsize array...
if keyword_set( nodata) eq 0 then begin
if n_elements( symsize) eq 1 then begin
   plots, xd, yd, psym=psym, color=bytscl( zd, min=zra[0], max=zra[1]), $
   symsize=symsize, noclip= clip eq 0
endif else begin
   pcolor=bytscl( zd, min=zra[0], max=zra[1])
         for np= 0l, n_elements( xd)-1l do $
            plots, xd[np], yd[np], psym=psym, $
            color= pcolor[ np], symsize=symsize[ np], noclip= clip eq 0
endelse
endif

loadct,0
device, dec=gd
setcolors,/dev, silent= keyword_set(silent)

return
end
