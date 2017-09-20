;
l=[0.D, 0.D, 45.D]
b=[0.D,90.D, 45.D]

n=n_elements(l)

raE=dblarr(n)
raG=dblarr(n)
decE=dblarr(n)
decG=dblarr(n)
for i=0,n-1 do begin &$
    euler,l[i],b[i],ra,dec,2 &$
    raE[i]=ra &$
    decE[i]=dec &$
    galconv,l[i],b[i],ra,dec &$
    raG[i]=ra &$
    decG[i]=dec &$
    lab1=string(format='("ra/dec:",f14.8,f14.8)',ra,dec) &$
    tmp1=sixty(ra/15.D) &$
    tmp2=sixty(dec) &$
    lab2=string(format=$
'(i3,":",i2,":",f7.4,"  ",i3,":",i2,":",f7.4)',tmp1,tmp2) &$
    lab0=string(format='("l/b:",f7.2," ",f7.2," ")',l[i],b[i]) &$
    print,lab0+lab1+lab2 &$
endfor
print,raE-raG
