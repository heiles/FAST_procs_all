pro display_2d_fix, xaxis, yaxis, brtimg, colimg, $
    brtmin, brtmax, gamma, colmin, colmax, $
    xtitle=xtitle, title=title, ytitle=ytitle, $
    cbar_posn=cbar_posn, cbar_xtitle=cbar_xtitle, cbar_ytitle=cbar_ytitle, $
                _REF_EXTRA=_extra,extra_cbar=extra_cbar,extra_display=extra_display

;+
; NAME:
;       DISPLAY_2D_FIX
;
; PURPOSE:
;       Displays a 2d image and its colorbar on top. Slight
;       modification of colorbar location and keyword inheritance.
;       
; CHECK 'DISPLAY_2D.PRO' FOR FULL DOCUMENTATION 
;
; KEYWORDS:
;       _REF_EXTRA: if set, passes keywords to both display and colorbar
;       extra_cbar: strutcture of extra keywords for colorbar
;       extra_display: struture of extra keywords for display
;
; MODIFICATIONS:
;       Keyword _REF_EXTRA is either passed to both display and colorbar
;       or extra_cbar and extra_display separately take keywords as
;       strutures. If wanted, all keywords can be removed and
;       implemented through the extras. Colorbar position is implemented.
;
; HISTORY
;       6 sep 2011. carl fixed some errors, added the cbar_ytitle keyword, and
;       made the image display last so that it could be annotated.
;       1 May 2017 Timothy Ross Implemented cbar_posn correctly and
;       allowed display and colorbar to have extra keywords set
;       independently or together.
;-

;this is a test section, bypassed unless we uncomment the goto...
goto, bypassfake

;FAKE IMAGES...
brtimg= fltarr( 840, 390)
colimg= fltarr( 840, 390)
for nr=0,839 do brtimg[ nr,*]=findgen(390)
for nr=0,389 do colimg[ *,nr]=findgen(840)
gamma=1.
brtmin= 0.
brtmax= 300.
colmin= 0
colmax= 800
cbar_xtitle= 'fake'

bypassfake:

countx= n_elements( xaxis)
county= n_elements( yaxis)


;STRETCH AND CONTRAST THE INTENSITY IMAGE...
brtimgxx= ( ((brtimg > brtmin) < brtmax)- brtmin)/(brtmax-brtmin)
brtimgx= brtimgxx^ gamma

;CREATE THE INTENSITY-MODULATED COLOR IMAGE WITH THE FOLLOWING SIX STEPS:
; 0. LOAD THE PSEUDO COLOR TABLE...
pseudo_ch, colr ;COLR is 256 X 3: 256 intensities in the 3 colors (r,g,b)
; 1. BYTSCL THE COLOR IMAGE...
colimgb= bytscl( colimg, min=colmin, max=colmax)
; 2. DEFINE THE (R,G,B) COMPONENTSOF THE VELOCITY (COLOR) IMAGE. NOTE HOW WE USE INDICES!
redimg= colr[ colimgb, 0]
grnimg= colr[ colimgb, 1]
bluimg= colr[ colimgb, 2]
; 3. USING INDICES AS ABOVE CREATES VECTORS of length 541 X 470 = 254270,
; 4. WHICH MUST BE CONVERTED TO IMAGES...
redimg= reform( redimg, countx, county)
grnimg= reform( grnimg, countx, county)
bluimg= reform( bluimg, countx, county)
; 5. MODULATE THE VELOCITY (COLOR) IMAGE BY THE INTENSITY IMAGE...
r_img= byte( round( brtimgx* redimg) )
g_img= byte( round( brtimgx* grnimg) )
b_img= byte( round( brtimgx* bluimg) )

image_in= [[[r_img]], [[g_img]], [[b_img]]]
loadct,0

; if _REF_EXTRA is set, set both extra keywords
if n_elements(_extra) ne 0 then begin
   extra_cbar=_extra
   extra_display=_extra
endif

display, image_in, xaxis, yaxis, min=brtmin, max=brtmax, out=out, $
         xtit= xtitle, ytit= ytitle, title= title, /noscale, _EXTRA=extra_display, $
         /nodisplay

;stop
if n_elements( cbar_posn) eq 0 then begin
   cbar_pos=out.position
   yspace= 1 - cbar_pos[3] 
  cbar_pos[ 1]= cbar_pos[ 3]+ yspace/4
   cbar_pos[3]= 1-yspace/4
endif


;stop


colorbar, position=cbar_pos, crange=[colmin, colmax], rgb=colr, color=plotcolor,$
  xtit=cbar_xtitle, $
  irange=[brtmin, brtmax], igamma=gamma, ytit=cbar_ytitle, $
          yticks=2, yminor=1, _EXTRA=extra_cbar;, OUT=out

display, image_in, xaxis, yaxis, min=brtmin, max=brtmax, out=out, $
        xtit= xtitle, ytit= ytitle, title= title, /noscale,/noerase, _EXTRA=extra_display 

return
end












