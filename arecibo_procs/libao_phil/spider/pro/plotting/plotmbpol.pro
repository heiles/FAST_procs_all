pro plotmbpol, path, indx, beamout_arr, a, ps=ps
;+
; PURPOSE: Generate plots of main beam squint and squash for all three
;polarized stokes parameters, both on screen and ps. For each stokes
;parameter you get squint ampl,pa and squash ampl, pa--four plots.
;-

IF ( N_ELEMENTS( INDX) LT 2) THEN BEGIN
        print, 'SKIP MBPOL FOR THIS SOURCE--FEWER THAN TWO PATTERNS'
        GOTO, FINISHED
ENDIF

device, window=opnd
if ( opnd(9) eq 0) then window, 9, xs=400, ys=850
 
b2dcfs= beamout_arr.b2dfit
pindx= where( b2dcfs[2,0,indx[*]] ne 0, count)
if (count eq 0) then goto, finished
pindx= indx[pindx]

pltfilename, indx, a, 'mbq', '.ps', title, plotfilenameq
pltfilename, indx, a, 'mbu', '.ps', title, plotfilenameu
pltfilename, indx, a, 'mbv', '.ps', title, plotfilenamev

;getrcvr, x, rcvr_name, hdr1info[ 29, pindx[0]]
;daycnv, hdr1info[ 2, pindx[0]]+2400000l, yr, mn, day
;datestring= date( yr, ymd2dn( yr, mn, day))

;title= rcvr_name + '  ' + trim(hdr1info[5,pindx[0]]) + ' MHz  ' + $
;        hdrsrcname[pindx[0]] + '  ' + datestring
title_augment= ['', ' STOKES Q', ' STOKES U', ' STOKES V']

;plotfilenameq= rcvr_name + '_' + trim(hdr1info[5,pindx[0]]) + '_' + $
;        hdrsrcname[pindx[0]] + '_' + 'mbq_' + datestring + '.ps'
;plotfilenameu= rcvr_name + '_' + trim(hdr1info[5,pindx[0]]) + '_' + $
;        hdrsrcname[pindx[0]] + '_' + 'mbu_' + datestring + '.ps'
;plotfilenamev= rcvr_name + '_' + trim(hdr1info[5,pindx[0]]) + '_' + $
;        hdrsrcname[pindx[0]] + '_' + 'mbv_' + datestring + '.ps'

plotfilename=[ plotfilenameq, plotfilenameu, plotfilenamev]
 
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


;PRINT, 'SOURCE, SOURCEFLUX = ', hdrsrcname[ pindx[ 0]], sourceflux
;print, 'FREQ, BOARD = ', hdr1info[5,pindx[0]], hdr1info[6,pindx[0]]

;print, '   AZ   ZA   KPERJY HPBW_G HPBWRATIO P_FSG ETA_MBG  ETARATIO   ETASUM'

;FOR NRC= 0, N_ELEMENTS(pindx)-1 DO BEGIN
;print, aza[ nrc], zaa[ nrc], kperjya[ nrc], hpbw_ga[ nrc], hpbwratioa[ nrc], $
;	p_fsga[ nrc], eta_mbga[ nrc], etaratioa[ nrc], etasuma[ nrc], $
;	format= '(f6.0, f5.1, f8.2, f7.2, f8.3, f8.3, f7.2, f9.2, f10.2)'
;ENDFOR

pindxrise= where( aza le 0., countrise)
pindxset= where( aza ge 0.)
if (countrise ne 0) then pindxset= [max( pindxrise), pindxset]

;ADDED 06 JUN 2001...
if (countrise eq 0) then pindxrise = pindxset

;THE FOLLOWING SUBTRACTED 25 OCT 2002...CANT FIND THE DEFINITION!
;if (countset eq 0) then pindxset = pindxrise

!p.multi=[ 0,1,4]
!p.charsize=1.5

YTITLESQUINT= ['Q SQUINT', 'U SQUINT', 'V SQUINT']
YTITLEPSQUINT= ['Q SQUINT PA', 'U SQUINT PA', 'V SQUINT PA']
YTITLESQUASH= ['Q SQUASH', 'U SQUASH', 'V SQUASH']
YTITLEPSQUASH= ['Q SQUASH PA', 'U SQUASH PA', 'V SQUASH PA']

FOR NSTK=1,3 DO BEGIN
FOR NPS=0,1 DO BEGIN
if (nps eq 1) then openplotps, file= path+ plotfilename[ nstk-1]
n20=23 + 10*( nstk-1)

n2x= n20
plot, zaa[ *], b2dcfs[n2x, 0, *], psym=-4, lines=2, $
	xtit='ZA', xra=[0,20], /xsty, $
	ytit= ytitlesquint[ nstk-1], $
	title= title + title_augment[ nstk]
oplot, zaa[pindxset], b2dcfs[n2x, 0, pindxset], psym=-6, lines=0
plots, [.15,.19, .23], [.825,.825,.825],psym=-4, lines=2, /norm
xyouts, .24,.825, 'RISE', /norm, charsize=1
plots, [.15,.19,.23], [.805,.805,.805],psym=-6, lines=0, /norm
xyouts, .24,.805, 'SET', /norm, charsize=1

n2x= n2x+ 1
plot, aza[ *], b2dcfs[n2x, 0, *], psym=4, lines=2, $
	xtit= 'AZ', xra=[-180,180], /xsty, $
	ytit= ytitlepsquint[ nstk-1], yra=[-200,200], /nodata
;oplot, aza[pindxset], b2dcfs[n2x, 0, pindxset], psym=6, lines=0
for nambig=0,2 do oplot, aza[pindxrise], $
        (360.*(nambig-1)+ b2dcfs[n2x, 0, pindxrise]), psym=4
for nambig=0,2 do oplot, aza[pindxset], $
        (360.*(nambig-1)+ b2dcfs[n2x, 0, pindxset]), psym=6
;oplot, [-200,200], [-200,200], lines=1
oplot, [-200,200], [200,-200], lines=1
yfs=.25
plots, [.15,.19, .23], [.825,.825,.825]-yfs,psym=4, lines=2, /norm
xyouts, .24,.825-yfs, 'RISE', /norm, charsize=1
plots, [.15,.19,.23], [.805,.805,.805]-yfs,psym=6, lines=0, /norm
xyouts, .24,.805-yfs, 'SET', /norm, charsize=1

n2x= n2x+ 1
plot, zaa[ *], b2dcfs[n2x, 0, *], psym=-4, lines=2, $
	xtit='ZA', xra=[0,20], /xsty, $
	ytit= ytitlesquash[ nstk-1]
oplot, zaa[pindxset], b2dcfs[n2x, 0, pindxset], psym=-6, lines=0
yfs=.5
plots, [.15,.19, .23], [.825,.825,.825]-yfs,psym=-4, lines=2, /norm
xyouts, .24,.825-yfs, 'RISE', /norm, charsize=1
plots, [.15,.19,.23], [.805,.805,.805]-yfs,psym=-6, lines=0, /norm
xyouts, .24,.805-yfs, 'SET', /norm, charsize=1

;stop

n2x= n2x+ 1
plot, aza[ *], b2dcfs[n2x, 0, *], psym=4, lines=2, $
	xtit= 'AZ', xra=[-180,180], /xsty, $
	ytit= ytitlepsquash[ nstk-1], yra=[-100,100], /nodata
;oplot, aza[pindxset], b2dcfs[n2x, 0, pindxset], psym=-6, lines=0
for nambig=0,2 do oplot, aza[pindxrise], $
        (180.*(nambig-1)+ b2dcfs[n2x, 0, pindxrise]), psym=4
for nambig=0,2 do oplot, aza[pindxset], $
        (180.*(nambig-1)+ b2dcfs[n2x, 0, pindxset]), psym=6
;oplot, [-200,200], [-200,200], lines=1
oplot, [-200,200], [200,-200], lines=1
yfs=.75
plots, [.15,.19, .23], [.825,.825,.825]-yfs,psym=4, lines=2, /norm
xyouts, .24,.825-yfs, 'RISE', /norm, charsize=1
plots, [.15,.19,.23], [.805,.805,.805]-yfs,psym=6, lines=0, /norm
xyouts, .24,.805-yfs, 'SET', /norm, charsize=1

if (nps eq 1) then closeps

;wait,5

endfor
endfor


FINISHED:

!p.multi=0
!p.charsize=0

end


