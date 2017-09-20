pro plotsqpol, path, indx, beamout_arr, a, ps=ps
;+
; PURPOSE: Generate plots of the response of each Stokes parameter to
;first and second spatial derivatives of brightness temperature. Plot the
;sidelobe, mainbeam squint, mainbeam squash, and all-combined 
;contributions separately (but on the same plot frame). 
;
; CALLING SEQUENCE: first read data and select a source with mueller2,
;then do this.
;
; OUTPUTS: plots on the screen and also ps.
;-

IF ( N_ELEMENTS( INDX) LT 2) THEN BEGIN
        print, 'SKIP SQPOL FOR THIS SOURCE--FEWER THAN TWO PATTERNS'
        GOTO, FINISHED
ENDIF

device, window=opnd
if ( opnd(9) eq 0) then window, 9, xs=400, ys=850

b2dcfs= beamout_arr.b2dfit
strp_cfs= beamout_arr.stripfit

pindx= where( b2dcfs[2,0,indx[*]] ne 0, count)
if (count eq 0) then goto, finished
pindx= indx[pindx]
 
aza= b2dcfs[ 19,0, pindx[*]]
zaa= b2dcfs[ 19,1, pindx[*]]

mainamp= fltarr( 2, n_elements( pindx))
mainang= fltarr( 2, n_elements( pindx))
sideamp= fltarr( 4, 2, n_elements( pindx))
sideang= fltarr( 4, 2, n_elements( pindx))
squintamp= fltarr( 4, 2, n_elements( pindx))
squintang= fltarr( 4, 2, n_elements( pindx))
squashamp= fltarr( 4, 2, n_elements( pindx))
squashang= fltarr( 4, 2, n_elements( pindx))
totalamp= fltarr( 4, 2, n_elements( pindx))
totalang= fltarr( 4, 2, n_elements( pindx))

for nrc=0, n_elements( pindx)-1 do begin
stripfit=strp_cfs[*,*,*, pindx[nrc]]
b2dfit= b2dcfs[ *, *, pindx[ nrc]]
arcmin= b2dfit[ 10,1]

allresponse_eval, arcmin, stripfit, b2dfit, $
        mainampl, mainangl, sideampl, sideangl, $
        squintampl, squintangl, squashampl, squashangl, $
        totalampl, totalangl

mainamp[ *, nrc]=  mainampl
mainang[ *, nrc]=  mainangl
sideamp[ *,*,nrc]=  sideampl
sideang[ *,*,nrc]=  sideangl
squintamp[ *,*,nrc]=  squintampl
squintang[ *,*,nrc]=  squintangl
squashamp[ *,*,nrc]=  squashampl
squashang[ *,*,nrc]=  squashangl
totalamp[ *,*,nrc]=  totalampl
totalang[ *,*,nrc]=  totalangl

endfor

GOTO, SKIP

for nder=0, 1 do begin 
for nstk=1,3 do begin
print, '*** NSTK = ', nstk 
print, 'side ', sideampl[ nstk, nder], sideangl[ nstk, nder] 
print, 'squint ', squintampl[ nstk, nder], squintangl[ nstk, nder]
print, 'squash ', squashampl[ nstk, nder], squashangl[ nstk, nder]
endfor 
endfor

SKIP:

pltfilename, indx, a, 'sqq', '.ps', title, plotfilenameq
pltfilename, indx, a, 'squ', '.ps', title, plotfilenameu
pltfilename, indx, a, 'sqv', '.ps', title, plotfilenamev

;getrcvr, x, rcvr_name, hdr1info[ 29, pindx[0]]
;daycnv, hdr1info[ 2, pindx[0]]+2400000l, yr, mn, day
;datestring= date( yr, ymd2dn( yr, mn, day))
;title= rcvr_name + '  ' + trim(hdr1info[5,pindx[0]]) + ' MHz  ' + $
;        hdrsrcname[pindx[0]] + '  ' + datestring
;plotfilenameq= rcvr_name + '_' + trim(hdr1info[5,pindx[0]]) + '_' + $  
;        hdrsrcname[pindx[0]] + '_' + 'sqq_' + datestring + '.ps'
;plotfilenameu= rcvr_name + '_' + trim(hdr1info[5,pindx[0]]) + '_' + $  
;        hdrsrcname[pindx[0]] + '_' + 'squ_' + datestring + '.ps'
;plotfilenamev= rcvr_name + '_' + trim(hdr1info[5,pindx[0]]) + '_' + $  
;        hdrsrcname[pindx[0]] + '_' + 'sqv_' + datestring + '.ps'

plotfilename= [ '', plotfilenameq, plotfilenameu, plotfilenamev]
 
!p.multi=[ 0,1,4]
;!p.multi= 0 
!p.charsize=1.7
 
subtitle= ['dT/d!4h!X = 1K/arcmin','d!E2!NT/d!4h!X!E2!N = 1K/arcmin!E2!N']
title_augment= [ ['', ' STOKES Q', ' STOKES U', ' STOKES V'], $
	['','','','']]
title_nder= [ title, '-----------------------------------------']

FOR NSTK= 1,3 DO BEGIN
FOR NRPLOT= 0,1 DO BEGIN

if (nrplot eq 1) then openplotps, nbits=8, file=path+ plotfilename[ nstk]

FOR NDER= 0, 1 DO BEGIN

;GENERATE THE PLOT RANGE...
ymax1= max( sideamp[ nstk, nder, *])
ymax2= max( squintamp[ nstk, nder, *])
ymax3= max( squashamp[ nstk, nder, *])
ymax4= max( totalamp[ nstk, nder, *])
yrng= [0, max( [ymax1,ymax2,ymax3,ymax4])]

plot, aza, totalamp[ nstk, nder, *], psym=0, lines=0, $
	xra=[-180,180], /xsty, xtit='AZ', $
	yra= yrng, ytit='AMPLITUDE, KELVINS', $
	title=title_nder[ nder]+ title_augment[ nstk, nder], $
	subtitle= subtitle[ nder]
oplot, aza, sideamp[ nstk, nder, *], psym=-4, lines=3 ;, color=red
oplot, aza, squintamp[ nstk, nder, *], psym=-6, lines=4 ;, color=green
oplot, aza, squashamp[ nstk, nder, *], psym=-7, lines=2 ;, color=blue

ypos = yrng[0] + .36*(yrng[1]- yrng[0])
oplot, 10+ [-180, -160, -140], [ypos, ypos, ypos], psym=0, lines=0
xyouts, -140, ypos, '   TOTAL', charsize=1
ypos = yrng[0] + .26*(yrng[1]- yrng[0])  
oplot, 10+ [-180, -160, -140], [ypos, ypos, ypos], psym=-4, lines=3;,color=red
xyouts, -140, ypos, '   SIDELOBE', charsize=1;,color=red
ypos = yrng[0] + .16*(yrng[1]- yrng[0])  
oplot, 10+ [-180, -160, -140], [ypos, ypos, ypos], psym=-6, lines=4;,color=green
xyouts, -140, ypos, '   SQUINT', charsize=1;,color=green
ypos = yrng[0] + .06*(yrng[1]- yrng[0])  
oplot, 10+ [-180, -160, -140], [ypos, ypos, ypos], psym=-7, lines=2;,color=blue
xyouts, -140, ypos, '   SQUASH', charsize=1;,color=blue
 
sideavg= total(sideamp)/n_elements( pindx)
squintavg= total(squintamp)/n_elements( pindx)
squashavg= total(squashamp)/n_elements( pindx)

maxmax= max( [sideavg, squintavg, squashavg], indxmax)

plot, aza, totalang[ nstk, nder, *], psym=0, lines=0, $
	xra=[-180,180], /xsty, xtit='AZ', $
	yra= (2-nder)*[-100,100], ytit='PA, DEGREES', $
	subtitle= subtitle[ nder]
;if (indxmax eq 0) then $
	oplot, aza, modangle360( sideang[ nstk, nder, *], /c180), $
		psym=-4, lines=3;, color=red
;if (indxmax eq 1) then $
if (nder eq 0) then $
	oplot, aza, modangle360( squintang[ nstk, nder, *], /c180), $
		psym=-6, lines=4;, color=green
if (nder eq 1) then $
;if (indxmax eq 2) then $
	oplot, aza, modangle360( squashang[ nstk, nder, *], /c180), $
		psym=-7, lines=2;, color=blue

ENDFOR

if (nrplot eq 1) then closeps
ENDFOR
;wait, 4
ENDFOR


FINISHED:

end


