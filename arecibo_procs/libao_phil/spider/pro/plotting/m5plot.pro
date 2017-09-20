pro m5plot, path, indx, a, muellerparams_chnls, ps=ps

;+
; PURPOSE: Generate the plots of mueller matrix parameters versus frequency.
;Invoke this after .run mueller5.idlprc.
;
; CALLING SEQUENCE: see mueller2_5.idl.pro
;
; OUTPUTS: plots on the screen and ps.
;
;KEYWORD: ps means also make a ps file.

;-

!p.multi=[ 0, 1, 5]
!p.charsize=1.5

device, window=opnd
if ( opnd(9) eq 0) then window, 9, xs=400, ys=850
wset,9

pltfilename, indx, a, 'm4frq', '.ps', title, plotfilename

;freq= corfrq( hb_arr[ 0])

nchnls= a[indx[0]].nchnls 
bw= a[ indx[ 0]].fchnl_max- a[ indx[0]].fchnl_0
freq= a[ indx[0]].fchnl_0 + bw* (findgen( nchnls)/float( nchnls))

c180= 1

FOR NR=0,1 DO BEGIN

IF ((NR EQ 1) AND KEYWORD_SET( PS)) THEN BEGIN
	openplotps, filenm= path+plotfilename
	print, 'writing M5 plot to ', path+plotfilename
ENDIF

xrng= minmax(freq)
;PLOT DELTAG...
yrng= max( abs( minmax( muellerparams_chnls.deltag)))
plot, freq, muellerparams_chnls.deltag, $
	xra= xrng, /xsty, xtit='FREQ', $
	yra=yrng*[-1., 1.], ytit='DELTAG', $
        tit= title
oplot, [1200,1600], [0,0], lines=3


;PLOT psi...
plot, freq, (modangle360( !radeg*muellerparams_chnls.psi, /c180))[ *,0], psym=-4, $
	xra= xrng, /xsty, xtit='FREQ', $
	yra=200.*[-1., 1.], /ysty, ytit='PSI'
oplot, [1200,1600], [0,0], lines=3

;PLOT epsilon...
yrng= max( muellerparams_chnls.epsilon)
plot, freq,  muellerparams_chnls.epsilon[ *,0], $
	xra= xrng, /xsty, xtit='FREQ', $
	yra= yrng*[0, 1.], ysty=0, ytit='EPSILON'
oplot, [1200,1600], [0,0], lines=3

;PLOT phi...
plot, freq, (modangle360( !radeg*muellerparams_chnls.phi, /c180))[ *,0], psym=-4, $
	xra= xrng, /xsty, xtit='FREQ', $
	yra=200.*[-1., 1.], /ysty, ytit='PHI'
oplot, [1200,1600], [0,0], lines=3

;PLOT ALPHA...
plot, freq, (modanglem(  !radeg*muellerparams_chnls.alpha))[ *,0], psym=-4, $
	xra= xrng, /xsty, xtit='FREQ', $
	yra=100.*[-1., 1.], /ysty, ytit='ALPHA'
oplot, [1200,1600], [0,0], lines=3

;stop

if ((nr eq 1) and keyword_set( ps)) then closeps

endfor

!p.multi=0
!p.charsize=1


end

