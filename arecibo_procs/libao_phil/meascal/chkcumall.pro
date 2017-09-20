;
; see what the best cum filter values are:
;
rangar=findgen(10)*.05   + .05
limar =findgen(10)*.4    + .5
ufrq=dabs[uniq(dabs.freq,sort(dabs.freq))].freq
nfrq=n_elements(ufrq)
calAbsFT=fltarr(2,16,10,10)
fracAbsFT=fltarr(2,16,10,10)
calSkyFT=fltarr(2,16,10,10)
fracSkyFT=fltarr(2,16,10,10)

for ll=5,8 do begin
	limit=limar[ll]
	print,'limit:',limit
	for rr=3,5 do begin
	   rangfract=rangar[rr]
	   print,'rangeFract:',rangfract
	   for i=0,nfrq-1 do begin
   	   	 ind=where(dabs.freq  eq ufrq[i],count)
	     range=count*nchn*rangfract
		 ver,0,.02
		 wait,.5
	     !p.multi=[0,1,4]
    	 for pol=0,1 do begin
        	x=reform(dabs[ind].spcal[*,pol],count*nchn)
        	cumfilter,x,range,limit,indxgood,indxbad,countbad
        	calAbsFT[pol,i,rr,ll]= median(x[indxgood])
        	fracAbsFT[pol,i,rr,ll]=1.- countbad/(1.*nchn*count)
    	 endfor
         ind=where(dsky.freq  eq ufrq[i],count)
	     range=count*nchn*rangfract
		 ver,0,.1
         for pol=0,1 do begin
           x=reform(dsky[ind].spcal[*,pol],count*nchn)
           cumfilter,x,range,limit,indxgood,indxbad,countbad
           calSkyFT[pol,i,rr,ll]= median(x[indxgood])
           fracSkyFT[pol,i,rr,ll]=1.- countbad/(1.*nchn*count)
         endfor
	   endfor
	endfor
endfor
calRatioFT=(Tsky + Tscattered-Tabs)*(calAbsFT*calSkyFT)/(calAbsFT-calSkyFT)
calAbsF[0,*]=calAbsFT[0,*]*(Trcvr[0]+Tabs)
calAbsF[1,*]=calAbsFT[1,*]*(Trcvr[1]+Tabs)
calSkyF[0,*]=calSkyFT[0,*]*(Trcvr[0]+Tsky+ Tscattered)
calSkyF[1,*]=calSkyFT[1,*]*(Trcvr[1]+Tsky+ Tscattered)
ver,1,3
lim=0
plot,[-1,16],[1,3],/nodata
for j=0,9 do begin &$
for i=0,9 do begin &$
	oplot,calratioft[0,*,i,j] &$
endfor &$
endfor
end
