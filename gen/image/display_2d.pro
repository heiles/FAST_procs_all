pro display_2d, xaxis, yaxis, brtimg, colimg, $
    brtmin, brtmax, gamma, colmin, colmax, $
    xtitle=xtitle, title=title, ytitle=ytitle, $
    cbar_posn=cbar_posn, cbar_xtitle=cbar_xtitle, cbar_ytitle=cbar_ytitle, $
                _REF_EXTRA=_extra

;+
; NAME:
;       DISPLAY
;
; PURPOSE:
;       Displays a 2d image and its colorbar on top. 
;
;**************************************************
;**************************************************
;**************************************************
;check out ~/display_2d_fix.pro, which is an enhanced version from
;willie ross in 2017 spring ay121 class
;**************************************************
;**************************************************
;**************************************************

; CALLING SEQUENCE:
;DISPLAY_2D, xaxis, yaxis, brtimg, colimg, $
;    brtmin, brtmax, gamma, colmin, colmax, $
;    xtitle=xtitle, title=title, ytitle=ytitle, $
;    cbar_posn=cbar_posn, cbar_xtitle=cbar_xtitle, _REF_EXTRA=_extra
;
; COMMENT: If you want to change how things fit on the window,
;               play around with windowsize and cbar_posn.
;
; INPUTS:
;       XAXIS - A vector representing the abscissa values to be plotted.  X
;           must contain the same number of elements as the horizontal
;           dimension of the images
;       YAXIS - A vector representing the ordinate values to be plotted. Y
;           must contain the same number of elements as the vertical
;           dimension of the two images.
;       BRTIMG - the image for the image brightness. Its units should be
;                physically meaningful, e.g. column density.,
;       COLIMG - the image for the image color. Its units should be
;                physically meaningful, e.g. velocity.
;       GAMMA, the power to which the BRTIMG data will be raised to
;                generate the displayed intensities
;       BRTMIN, the lower clipping level for the BRTIMG
;       BRTMAX, the upper clipping level for the BRTIMG
;       COLMIN, the lower clipping level for the COLIMG
;       COLMAX, the upper clipping level for the COLIMG

;KEYWORD PARAMETERS;
;       XTITLE, the title for the x axis
;       YTITLE, the title for the Y axis
;       CBAR_POSN, the 4-element vector that specifies where to put the
;       corners of the colorbar. No need to define it; the default is
;               OK. 
;       CBAR_XTITLE: Colorbar label for the quantity
;            represented by color).
;       CBAR_YTITLE: Colorbar label for the quantity 
;            represented by intensity
;
;HISTORY
; 6 sep 2011. carl fixed some errors, added the cbar_ytitle keyword, and
; made the image display last so that it could be annotated.
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

display, image_in, xaxis, yaxis, min=brtmin, max=brtmax, out=out, $
         xtit= xtitle, ytit= ytitle, title= title, /noscale, _EXTRA=_extra, $
         /nodisplay

;stop
if n_elements( cbar_posn) eq 0 then begin
   pos=out.position
   yspace= 1 - pos[3] 
  pos[ 1]= pos[ 3]+ yspace/4
   pos[3]= 1-yspace/4
endif

;stop

colorbar, position=pos, crange=[colmin, colmax], rgb=colr, color=plotcolor, $
  xtit=cbar_xtitle, $
  irange=[brtmin, brtmax], igamma=gamma, ytit=cbar_ytitle, $
          yticks=2, yminor=1,_EXTRA=_extra;, OUT=out

display, image_in, xaxis, yaxis, min=brtmin, max=brtmax, out=out, $
        xtit= xtitle, ytit= ytitle, title= title, /noscale, _EXTRA=_extra, $
  /noerase

return
end












