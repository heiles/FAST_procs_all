.run tb_exp
.run tbgfitflex_exp

halfasseduse=0.1
nloopmax=600

xd= -200. + findgen(400)
xra=[-50,100]
xra=[-20,80]
continuum=3.4
continuum=0.
hgtwnm=50.
cenwnm=30.
widwnm=40.
fwnm_in= 0. ;+1

;gcurv, xd, 0., hgtwnm, cenwnm, widwnm, wnm

zrocnm= 0.
hgtcnm= [1.2e-4, 8.5]
cencnm= [50., 55.]
widcnm= [20., 2.]
tspincnm= [20., 10.]
ordercnm_in= [0, 1]
ordercnm_in= [1, 0]

continuum=10.
;continuum=10.
;hgtwnm=0.
help, hgtcnm
tb_exp, xd, zrocnm, hgtcnm, cencnm, widcnm, tspincnm, ordercnm_in, $
        continuum, hgtwnm, cenwnm, widwnm, fwnm_in, $
        tb_cont, tb_wnm_tot, tb_cnm_tot, tb_tot, exp_tausum

wset,0
;hor,0,100
;ver
;!p.multi=[0,1,2]

plot, xd, tb_tot, title=string(ordercnm_in[0]) + string(ordercnm_in[1]), $
      xra=xra
oplot, xd, tb_cont, color=!green
oplot, xd, tb_cnm_tot, color=!red
oplot, xd, tb_wnm_tot, color=!yellow
help, hgtcnm
;stop
;now let's try to ls fit these data...

look=-1
xfitrange= [0, 399]
zrocnm0= 0.
;hgtcnm0= [.15, 3.0]
;cencnm0= [45., 57.]
;widcnm0= [18., 4.]
hgtcnm0= hgtcnm
cencnm0= cencnm
widcnm0= widcnm
tspincnm0= [25., 3.]
tspincnm0= tspincnm
ordercnm= [0, 1]
ordercnm= [1, 0]

;hgtcnm0= hgtcnm
;cencnm0= cencnm
;widcnm0= widcnm
;tspincnm0= tspincnm


zrocnmyn= 0
hgtcnmyn= [1,1] ;*0
cencnmyn= [1,1] ;*0
widcnmyn= [1,1] ;*0
tspincnmyn= [1,1];*0
tspincnmyn= [0,1];*0

continuum0= continuum
hgtwnm0= hgtwnm
cenwnm0= 30.
widwnm0= 40.
cenwnm0=cenwnm
widwnm0=widwnm
fwnm= 0.

continuumyn=0 +1
hgtwnmyn=0 +1
cenwnmyn=0 +1
widwnmyn=0 +1
fwnmyn=0

continuum0= continuum
tbgfitflex_exp, look, xd, tb_tot, xfitrange, $
;tbgfitflex_exp_08may2012, look, xd, tb_tot, xfitrange, $
	zrocnm0, hgtcnm0, cencnm0, widcnm0, tspincnm0, ordercnm, $
	zrocnmyn, hgtcnmyn, cencnmyn, widcnmyn, tspincnmyn, $
	continuum0, hgtwnm0, cenwnm0, widwnm0, fwnm, $
	continuumyn, hgtwnmyn, cenwnmyn, widwnmyn, fwnmyn, $
	tfita, sigma, $
	zrocnm1, hgtcnm1, cencnm1, widcnm1, tspincnm1, $
	sigzrocnm1, sighgtcnm1, sigcencnm1, sigwidcnm1, sigtspincnm1, $	
	continuum1, hgtwnm1, cenwnm1, widwnm1, fwnm1, $
	sigcontinuum1, sighgtwnm1, sigcenwnm1, sigwidwnm1, sigfwnm1, $
        cov, problem, nloop, halfasseduse=halfasseduse, $
                nloopmax=nloopmax

print
print, $
'       nr          zrocnm          hgtcnm          cencnm          widcnm        tspincnm'
for nr=0,1 do begin &$
   print, nr, 'cnm', double(zrocnm), double(hgtcnm[nr]), double(cencnm[nr]), double(widcnm[nr]), double(tspincnm[nr]) &$
   print, nr, 'cnm', zrocnm1, hgtcnm1[nr], cencnm1[nr], widcnm1[nr], tspincnm1[nr] &$
   print, nr, 'cnm', sigzrocnm1, sighgtcnm1[nr], sigcencnm1[nr], sigwidcnm1[nr], sigtspincnm1[nr] &$
endfor

print
print, $
'       nr          continuum          hgtwnm          cenwnm          widwnm        tspinwnm'
for nr=0, 0 do begin &$
   print, nr, 'wnm', double(continuum), double(hgtwnm[nr]), double(cenwnm[nr]), double(widwnm[nr]) &$
   print, nr, 'wnm', continuum1, hgtwnm1[nr], cenwnm1[nr], widwnm1[nr], fwnm1[nr] &$
   print, nr, 'wnm', sigcontinuum1, sighgtwnm1[nr], sigcenwnm1[nr], sigwidwnm1[nr] &$ , sigfwn &$
endfor

print, 'problem, nloop, sigma: '  , problem, nloop, sigma
print, 'ordercnm_in, ordercnm; '  ,ordercnm_in, ordercnm
print, 'fwnm_in, fwnm ', fwnm_in, fwnm

wset,1
resid= tb_tot-tfita
plot, xd, tb_tot, psym=-2, xra=xra
oplot, xd, tfita, color=!red
oplot, xd, resid+ continuum/2, color=!green
print, 'minmax of resid spectrum = ', minmax(resid)
