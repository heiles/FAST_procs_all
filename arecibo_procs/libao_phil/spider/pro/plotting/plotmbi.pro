pro plotmbi, path, indx, beamout_arr, a, ps=ps
;+
; PURPOSE: Plot selected Stokes I beam parameters (KperJy, etc).  Both
;on screen and ps. 
;
; CALLING SEQUENCE: First @mueller2_cal.idl to read the reduced data and
;select the source indx array.
;
;KEYWORD PS means do a ps file as well as a screen plot.

;-

IF ( N_ELEMENTS( INDX) LT 2) THEN BEGIN
        print, 'SKIP PLOTMBI FOR THIS SOURCE--FEWER THAN TWO PATTERNS'
        GOTO, FINISHED
ENDIF

device, window=opnd
if ( opnd(9) eq 0) then window, 9, xs=400, ys=850
 
b2dcfs= beamout_arr.b2dfit
pindx= where( b2dcfs[2,0,indx[*]] ne 0, count)

;stop
if (count eq 0) then goto, finished

pindx= indx[pindx]

pltfilename, indx, a, 'mbi', '.ps', title, plotfilename

;READING THINGS EXCLUSIVELY FROM THE HEADER INFO...
sourceflux= beamout_arr[ indx[0]].sourceflux
sourcefactor= 0.5* b2dcfs[ 12,0,pindx[*]]/sourceflux

lambda = 3.0e4 / a[ indx[0]].cfr
make_azza_newcal, 60, beamout_arr[0].b2dfit, pixelsize, azarray, zaarray
;make_azza, b2dcfs[ *,*, pindx[0]], pixelsize, azarray, zaarray

eta_mbga= sourcefactor* b2dcfs[ 14,0,pindx[*]]
eta_sidelobea= sourcefactor* b2dcfs[ 15,0,pindx[*]]
etaratioa= eta_sidelobea/eta_mbga
p_fsga= b2dcfs[ 13,0,pindx[*]]/b2dcfs[ 2,0,pindx[*]]
etasuma= eta_sidelobea+ eta_mbga
aza= b2dcfs[ 19,0, pindx[*]]
zaa= b2dcfs[19,1, pindx[*]]
kperjya = sourcefactor* b2dcfs[2,0,pindx[*]]/ b2dcfs[12,0,pindx[*]]
hpbw_g = 0.517* lambda/(kperjya^0.5)
hpbw_ga= b2dcfs[ 5,0, pindx[*]]
hpbwratioa= b2dcfs[ 5,0, pindx[*]]/hpbw_g

PRINT, 'SOURCE, SOURCEFLUX = ', beamout_arr[ indx[0]].sourcename , sourceflux
print, 'FREQ, BOARD = ', a[ indx[0]].cfr, a[ indx[0]].brd

print, '   AZ   ZA   KPERJY HPBW_G HPBWRATIO P_FSG ETA_MBG  ETARATIO   ETASUM'

FOR NRC= 0, N_ELEMENTS(pindx)-1 DO BEGIN
print, aza[ nrc], zaa[ nrc], kperjya[ nrc], hpbw_ga[ nrc], hpbwratioa[ nrc], $
	p_fsga[ nrc], eta_mbga[ nrc], etaratioa[ nrc], etasuma[ nrc], $
	format= '(f6.0, f5.1, f8.2, f7.2, f8.3, f8.3, f7.2, f9.2, f10.2)'
ENDFOR

pindxrise= where( aza le 0., countrise)
pindxset= where( aza ge 0., countset)
if (countrise ne 0) then pindxset= [max( pindxrise), pindxset]

;ADDED 06 JUN 2001...
if (countrise eq 0) then pindxrise = pindxset
if (countset eq 0) then pindxset = pindxrise
 
!p.multi=[ 0,1,5]
!p.charsize=1.5

;FOR NRPLOT=0,1 DO BEGIN
FOR NRPLOT=0,0 DO BEGIN

;stop
if ( (nrplot eq 1) and (keyword_set( ps))) then $
	openplotps, file= path + plotfilename

yrng= minmax( kperjya)
plot, zaa[ pindxrise], kperjya[ pindxrise], psym=-4, lines=2, $
	xtit='ZA', xra=[0,20], /xsty, $
	ytit='KperJY', yra=yrng, /ysty, $
	title=title 
oplot, zaa[ pindxset], kperjya[ pindxset], psym=-6, lines=0
ypos = yrng[0] + .16*(yrng[1]- yrng[0])
oplot, [1,2.5,4], [ypos, ypos, ypos], psym=-4, lines=2
xyouts, 4, ypos, ' RISE', charsize=1
ypos = yrng[0] + .06*(yrng[1]- yrng[0])
oplot, [1,2.5,4], [ypos, ypos, ypos], psym=-6, lines=0
xyouts, 4, ypos, ' SET', charsize=1

yrng= minmax( p_fsga)
plot, zaa[ pindxrise], p_fsga[pindxrise] , $
	psym=-4, lines=2, $
	xtit='ZA', xra=[0,20], /xsty, $
	ytit='HGT_FS/HGT_MB', yra=yrng, /ysty 
oplot, zaa[ pindxset], p_fsga[pindxset], $
	psym=-6, lines=0


sum =  b2dcfs[5,0,pindx[*]] + b2dcfs[6,0,pindx[*]]
diff =  b2dcfs[5,0,pindx[*]] - b2dcfs[6,0,pindx[*]]
yrng[1]= max( sum)
yrng[0]= min( diff)
plot, zaa[ pindxrise], sum[ pindxrise] , $
	psym=-4, lines=2, $
	xtit='ZA', xra=[0,20], /xsty, $
	ytit='BEAMWIDTHS', yra=yrng, /ysty 
oplot, zaa[ pindxset], sum[ pindxset], $
	psym=-6, lines=0
oplot, zaa[ pindxrise], diff[ pindxrise], $
	psym=-4, lines=2
oplot, zaa[ pindxset], diff[ pindxset], $
	psym=-6, lines=0

sum =  eta_mbga + eta_sidelobea
yrng[1]= max( sum)
yrng[0]= min( eta_mbga)
plot, zaa[ pindxrise], sum[ pindxrise] , $
	psym=-4, lines=2, $
	xtit='ZA', xra=[0,20], /xsty, $
	ytit='BEAM EFFICIENCIES', yra=yrng, /ysty 
oplot, zaa[ pindxset], sum[ pindxset], $
	psym=-6, lines=0
oplot, zaa[ pindxrise], eta_mbga[ pindxrise], $
	psym=-4, lines=2
oplot, zaa[ pindxset], eta_mbga[ pindxset], $
	psym=-6, lines=0
ypos = yrng[0] + .06*(yrng[1]- yrng[0])
xyouts, 1, ypos, 'BOT: MB', charsize=1
ypos = yrng[0] + .16*(yrng[1]- yrng[0])
xyouts, 1, ypos, 'TOP: MB+FS', charsize=1

yrng= minmax( b2dcfs[ 8, 0, pindx[*]])
plot, zaa[ pindxrise], b2dcfs[8,0,pindx[pindxrise]] , $
	psym=-4, lines=2, $
	xtit='ZA', xra=[0,20], /xsty, $
	ytit='COMA', yra=yrng, /ysty 
oplot, zaa[ pindxset], b2dcfs[8,0,pindx[pindxset]], $
	psym=-6, lines=0

if ( (nrplot eq 1) and (keyword_set( ps))) then closeps
ENDFOR

FINISHED:

!p.multi=0
!p.charsize=0

end


