;
; make sure the common positions in nvss and aopnt catalog agree
;
fnvss='/share/obs4/usr/x101/cat/nvssao.cat'
fao  ='~phil/catalog/Ao/src.list'
print,cataloginp(fnvss,1,catnv)
print,cataloginp(fao  ,1,catao)
nsrc=n_elements(catnv)
src =strarr(nsrc)
diff=fltarr(2,nsrc)
n=0
aoname=catao.name
for i=0,n_elements(catnv)-1 do begin &$
    ind=where(catnv[i].name eq aoname,count) &$
	if count gt 0 then begin &$
		src[n]=catao[ind[0]].name &$
		diff[0,n]=(catnv[i].raH -catao[ind[0]].raH)*3600.D*15.D* $
 					 sin(catnv[i].decD/360.*2.*!pi) &$
		diff[1,n]=(catnv[i].decD-catao[ind[0]].decD)*3600.D &$
		n=n+1 &$
	endif &$
endfor
diff=diff[*,0:n-1]
src =src[0:n-1]

badmin=1.5
a=sqrt(diff[0,*]^2 + diff[1,*]^2)
badi=where(a gt badmin,count)
print,count
out=-1
;
; output the differences
;
for i=0,count-1 do begin
	indn=where(src[badi[i]] eq catnv.name)
	inda=where(src[badi[i]] eq catao.name)
	sgn='+'
	if catnv[indn].decsgn lt 0 then sgn='-'
	lab=string(format='(a9," ",i3,i3,f6.2," ",a,i3,i3,f6.2," nvss")',$
				catnv[indn].name,catnv[indn].ra,sgn,catnv[indn].dec)
	printf,out,lab
	sgn='+'
	if catao[inda].decsgn lt 0 then sgn='-'
	lab=string(format='(9x," ",i3,i3,f6.2," ",a,i3,i3,f6.2," ao  ",1x,f8.2)',$
			catao[inda].ra,sgn,catao[inda].dec,a[badi[i]])
	printf,out,lab
endfor
end
