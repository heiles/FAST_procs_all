;
;compare the normalized gains
;
restore,'jan05norm.sav',/verb
tN_jan05=t25N
gN_jan05=g25N
bwN_jan05=bw25N
ii1_jan05=ii1
ii2_jan05=ii2
njan05=n_elements(t25N[0,*])
;
restore,'22jul06norm.sav'
tN_22jul06=t25N
gN_22jul06=g25N
bwN_22jul06=bw25N
ii1_22jul06=ii1
ii2_22jul06=ii2
n22jul06=n_elements(t25N[0,*])
;
restore,'15jul06norm.sav'
tN_15jul06=t25N
gN_15jul06=g25N
bwN_15jul06=bw25N
ii1_15jul06=ii1
ii2_15jul06=ii2
n15jul06=n_elements(t25N[0,*])
;
gN1_jan05=fltarr(128)
gN1_22jul06=fltarr(128)
gN1_15jul06=fltarr(128)
bwN1_jan05=fltarr(128)
bwN1_22jul06=fltarr(128)
bwN1_15jul06=fltarr(128)
for i=0,127 do begin &$
	gn1_jan05[i]=median(gn_jan05[i,*]) &$
	gn1_15jul06[i]=median(gn_15jul06[i,*]) &$
	gn1_22jul06[i]=median(gn_22jul06[i,*]) &$
	bwn1_jan05[i]=median(bwn_jan05[i,*]) &$
	bwn1_15jul06[i]=median(bwn_15jul06[i,*]) &$
	bwn1_22jul06[i]=median(bwn_22jul06[i,*]) &$
endfor
;
if hard then pscol,'430_freqdep_cmpJan05_Jul06.ps',/full
ver,.85,1.1
!p.multi=[0,1,4]
stripsxy,frq25,gn_jan05[*,ii1_jan05],0,0,charsize=cs,$
	xtitle='freq [Mhz]',ytitle='relative gain',$
	title='Relative gain vs freq jan05,jul06'
stripsxy,frq25,gn_jan05[*,ii2_jan05],0,0,/over,color=1
stripsxy,frq25,gn_15jul06[*,ii1_15jul06],0,0,/over,color=4
stripsxy,frq25,gn_15jul06[*,ii2_15jul06],0,0,/over,color=4
stripsxy,frq25,gn_22jul06[*,ii1_22jul06],0,0,/over,color=2
stripsxy,frq25,gn_22jul06[*,ii2_22jul06],0,0,/over,color=2
ln=4.5
scl=.7
note,ln      ,'jan05 data',xp=xp,color=1
note,ln+1*scl,'15jul06 data',xp=xp,color=4
note,ln+2*scl,'22jul06 data new turnstile',xp=xp,color=2
;
th=2
plot,frq25,gn1_jan05,color=1,thick=th,charsize=cs,$
	xtitle='freq [Mhz]',ytitle='relative gain',$
	title='gain vs freq: average all patterns'
oplot,frq25,gn1_22jul06,color=2,thick=th
oplot,frq25,gn1_15jul06,color=4,thick=th
;
ver,.96,1.04
;
stripsxy,frq25,bwn_jan05[*,ii1_jan05],0,0,charsize=cs,$
   xtitle='freq [Mhz]',ytitle='spectral Densisty ',$
	title='Relative beamWidth vs freq jan05,jul06'

stripsxy,frq25,bwn_jan05[*,ii2_jan05],0,0,/over,color=1
stripsxy,frq25,bwn_15jul06[*,ii1_15jul06],0,0,/over,color=4
stripsxy,frq25,bwn_15jul06[*,ii2_15jul06],0,0,/over,color=4
stripsxy,frq25,bwn_22jul06[*,ii1_22jul06],0,0,/over,color=2
stripsxy,frq25,bwn_22jul06[*,ii2_22jul06],0,0,/over,color=2
oplot,frq25, 1/(frq25/430.),color=3
ln=20
note,ln,'1/freq',xp=xp,color=3
;
th=2
plot,frq25,bwn1_jan05,color=1,charsize=cs,thick=th,$
	xtitle='freq [Mhz]',ytitle='relative beamwidt',$
	title='Beamwidth vs freq: average all patterns'
oplot,frq25,bwn1_22jul06,color=2,thick=th
oplot,frq25,bwn1_15jul06,color=4,thick=th
oplot,frq25, 1/(frq25/430.),color=3

if hard then hardcopy
x
end
